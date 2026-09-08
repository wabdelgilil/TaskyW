import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import 'supabase_service.dart';

/// نتيجة عملية المزامنة.
class SyncResult {
  final bool authenticated;
  final int pushedInserts;
  final int pushedUpdates;
  final int pushedDeletes;
  final int fetchedApplied;
  final int errors;
  final String? message;

  const SyncResult({
    this.authenticated = true,
    this.pushedInserts = 0,
    this.pushedUpdates = 0,
    this.pushedDeletes = 0,
    this.fetchedApplied = 0,
    this.errors = 0,
    this.message,
  });

  bool get success => authenticated && errors == 0;

  SyncResult copyWith({
    bool? authenticated,
    int? pushedInserts,
    int? pushedUpdates,
    int? pushedDeletes,
    int? fetchedApplied,
    int? errors,
    String? message,
  }) {
    return SyncResult(
      authenticated: authenticated ?? this.authenticated,
      pushedInserts: pushedInserts ?? this.pushedInserts,
      pushedUpdates: pushedUpdates ?? this.pushedUpdates,
      pushedDeletes: pushedDeletes ?? this.pushedDeletes,
      fetchedApplied: fetchedApplied ?? this.fetchedApplied,
      errors: errors ?? this.errors,
      message: message ?? this.message,
    );
  }
}

/// جدول بيانات <-> سحابة مع خيارات دعم التخزين المؤقت لاحقاً.
class _SyncTable {
  final String table;
  final List<String> columns;

  const _SyncTable(this.table, this.columns);
}

/// خدمة المزامنة السحابية (Offline-First Sync).
///
/// تقرا الصفوف غير المزامنة (`sync_status` يبدأ بـ `pending_`) من SQLite
/// وترسلها إلى Supabase ثم تنزّل الصفوف الجديدة من السحابة إلى SQLite.
class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  static const List<_SyncTable> _tables = [
    _SyncTable(DatabaseTables.areaTable, [
      'id', 'name', 'icon_emoji', 'color_hex', 'order_index',
      'sync_status', 'created_at', 'updated_at', 'deleted_at',
    ]),
    _SyncTable(DatabaseTables.projectTable, [
      'id', 'area_id', 'name', 'description', 'icon_emoji', 'color_hex',
      'status', 'target_date', 'order_index',
      'sync_status', 'created_at', 'updated_at', 'deleted_at',
    ]),
    _SyncTable(DatabaseTables.taskTable, [
      'id', 'area_id', 'project_id', 'title', 'description', 'status',
      'priority', 'color_hex', 'due_date', 'reminder_time', 'share_token',
      'is_recurring', 'recurrence_pattern', 'recurrence_interval',
      'recurrence_end_date', 'assigned_to',
      'order_index',
      'sync_status', 'created_at', 'updated_at', 'deleted_at',
    ]),
    _SyncTable(DatabaseTables.subtaskTable, [
      'id', 'task_id', 'title', 'is_completed', 'order_index',
      'sync_status', 'created_at', 'updated_at', 'deleted_at',
    ]),
    _SyncTable(DatabaseTables.tagTable, [
      'id', 'name', 'color_hex', 'order_index',
      'sync_status', 'created_at', 'updated_at', 'deleted_at',
    ]),
    _SyncTable(DatabaseTables.taskTagTable, [
      'id', 'task_id', 'tag_id',
      'sync_status', 'created_at', 'updated_at', 'deleted_at',
    ]),
  ];

  /// هل توجد صفوف لم تُزامَن بعد؟
  Future<bool> hasPendingChanges() async => (await countPendingChanges()) > 0;

  /// عدد الصفوف غير المزامنة (pending_insert / pending_update / pending_delete).
  Future<int> countPendingChanges() async {
    final db = await AppDatabase.instance.database;
    var count = 0;
    for (final t in _tables) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as c FROM ${t.table} WHERE sync_status IN (?, ?, ?)',
        ['pending_insert', 'pending_update', 'pending_delete'],
      );
      count += (result.first['c'] as int?) ?? 0;
    }
    return count;
  }

  /// تشغيل دورة مزامنة كاملة: رفع التعديلات ثم تنزيل التحديثات.
  Future<SyncResult> syncNow() async {
    final userId = _tryGetUserId();
    if (userId == null) {
      return const SyncResult(
        authenticated: false,
        message: 'المستخدم غير مسجل الدخول',
      );
    }

    final client = _tryGetClient();
    if (client == null) {
      return const SyncResult(
        authenticated: false,
        message: 'Supabase غير مهيأ',
      );
    }

    final db = await AppDatabase.instance.database;
    var inserts = 0;
    var updates = 0;
    var deletes = 0;
    var fetched = 0;
    var errors = 0;

    // ─── المرحلة ١: رفع التعديلات المحلية ─────────────────────────────
    for (final t in _tables) {
      final pendingRows = await db.query(
        t.table,
        where: 'sync_status IN (?, ?, ?)',
        whereArgs: ['pending_insert', 'pending_update', 'pending_delete'],
      );

      for (final row in pendingRows) {
        final syncStatus = row['sync_status'] as String;
        final id = row['id'] as String;

        try {
          if (syncStatus == 'pending_delete') {
            await client.from(t.table).delete().eq('id', id);
            deletes++;
          } else {
            final payload = toCloudPayload(row, userId);
            if (syncStatus == 'pending_insert') {
              await client.from(t.table).upsert(payload, onConflict: 'id');
              inserts++;
            } else {
              // pending_update: استخدم upsert أيضاً ليكون آمناً
              // إذا الصف غير موجود في السحابة (لم يُرفع قط) → إنشاء
              await client.from(t.table).upsert(payload, onConflict: 'id');
              updates++;
            }
          }

          // تحديث الحالة إلى 'synced' بعد الرفع الناجح
          await db.update(
            t.table,
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [id],
          );
        } catch (e) {
          errors++;
          debugPrint('[SyncService] Error pushing ${t.table}/$id: $e');
        }
      }
    }

    // ─── المرحلة ٢: تنزيل التحديثات من السحابة ──────────────────────────
    for (final t in _tables) {
      try {
        final cloudRows = await client
            .from(t.table)
            .select()
            .isFilter('deleted_at', null);

        // بناء فهرس الصفوف المحلية
        final localRows = await db.query(t.table);
        final localById = <String, Map<String, dynamic>>{
          for (final row in localRows) row['id'] as String: row,
        };

        final toInsert = <Map<String, dynamic>>[];
        final toUpdate = <Map<String, dynamic>>[];

        for (final cloudRow in cloudRows) {
          final id = cloudRow['id'] as String;
          final local = localById[id];

          if (shouldOverlayCloud(localRow: local, cloudRow: cloudRow)) {
            final localPayload = toLocalRow(cloudRow, t.columns);
            if (local == null) {
              toInsert.add(localPayload);
            } else {
              toUpdate.add(localPayload);
            }
            fetched++;
          }
        }

        // تنفيذ الدفعات
        final batch = db.batch();
        for (final row in toInsert) {
          batch.insert(t.table, row);
        }
        for (final row in toUpdate) {
          batch.update(
            t.table,
            row,
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
        await batch.commit(noResult: true);
      } catch (e) {
        errors++;
        debugPrint('[SyncService] Error fetching ${t.table}: $e');
      }
    }

    debugPrint(
      '[SyncService] Sync complete: '
      'pushed ${inserts + updates + deletes} | '
      'fetched $fetched | errors $errors',
    );

    return SyncResult(
      authenticated: true,
      pushedInserts: inserts,
      pushedUpdates: updates,
      pushedDeletes: deletes,
      fetchedApplied: fetched,
      errors: errors,
      message: errors > 0 ? 'اكتملت المزامنة مع $errors أخطاء' : null,
    );
  }

  // ─── مساعدات داخلية ──────────────────────────────────────────────────

  SupabaseClient? _tryGetClient() {
    try {
      return SupabaseService.client;
    } catch (_) {
      return null;
    }
  }

  String? _tryGetUserId() {
    try {
      return SupabaseService.currentUserId;
    } catch (_) {
      return null;
    }
  }

  /// تحويل صف من SQLite إلى حمولة سحابية (إزالة `sync_status` وتضمين `user_id`).
  @visibleForTesting
  static Map<String, dynamic> toCloudPayload(
    Map<String, dynamic> row, [
    String? userId,
  ]) {
    final payload = Map<String, dynamic>.from(row);
    payload.remove('sync_status');
    if (userId != null && !payload.containsKey('user_id')) {
      payload['user_id'] = userId;
    }
    return payload;
  }

  /// تحويل صف من السحابة إلى صف محلي (فلترة الأعمدة غير الموجودة في SQLite وإضافة `sync_status`='synced').
  @visibleForTesting
  static Map<String, dynamic> toLocalRow(
    Map<String, dynamic> cloudRow, [
    List<String>? validColumns,
  ]) {
    final row = <String, dynamic>{};
    if (validColumns != null) {
      for (final col in validColumns) {
        if (cloudRow.containsKey(col)) {
          var val = cloudRow[col];
          if (col == 'is_completed' && val is bool) {
            val = val ? 1 : 0;
          }
          row[col] = val;
        }
      }
    } else {
      row.addAll(cloudRow);
      row.remove('user_id');
      if (row.containsKey('is_completed') && row['is_completed'] is bool) {
        row['is_completed'] = (row['is_completed'] as bool) ? 1 : 0;
      }
    }
    row['sync_status'] = 'synced';
    return row;
  }

  /// هل يجب أن يُكتب الصف السحابي فوق المحلي؟
  @visibleForTesting
  static bool shouldOverlayCloud({
    required Map<String, dynamic>? localRow,
    required Map<String, dynamic> cloudRow,
  }) {
    if (localRow == null) return true;
    final localSync = localRow['sync_status'] as String? ?? 'synced';
    if (localSync.startsWith('pending_')) return false;
    if (localRow['deleted_at'] != null) return false;
    final localUpdated = _parseDateTime(localRow['updated_at']);
    final cloudUpdated = _parseDateTime(cloudRow['updated_at']);
    if (localUpdated != null &&
        cloudUpdated != null &&
        localUpdated.isAfter(cloudUpdated)) {
      return false;
    }
    return true;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
