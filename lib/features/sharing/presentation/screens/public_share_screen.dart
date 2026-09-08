import 'package:flutter/material.dart';
import '../../../../core/services/share_read_service.dart';

/// شاشة عرض الكيان المشارك عاماً (بدون تسجيل دخول)
class PublicShareScreen extends StatefulWidget {
  final String shareToken;

  const PublicShareScreen({
    super.key,
    required this.shareToken,
  });

  @override
  State<PublicShareScreen> createState() => _PublicShareScreenState();
}

class _PublicShareScreenState extends State<PublicShareScreen> {
  final ShareReadService _shareService = ShareReadService();
  bool _isLoading = true;
  SharedEntityResult? _sharedResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSharedContent();
  }

  Future<void> _loadSharedContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _shareService.fetchPublicEntityByToken(widget.shareToken);
      if (!mounted) return;
      if (result == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'الرابط غير صالح أو انتهت صلاحية المشاركة.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _sharedResult = result;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'TaskyW — مشاركة عامة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _buildBody(theme),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل العنصر المشترك...'),
          ],
        ),
      );
    }

    if (_errorMessage != null || _sharedResult == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_off_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'الرابط غير متوفر',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadSharedContent,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final entity = _sharedResult!.entity;
    final isTask = _sharedResult!.isTask;
    final isProject = _sharedResult!.isProject;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شارة النوع
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isTask
                      ? Colors.blue.withValues(alpha: 0.15)
                      : isProject
                          ? Colors.purple.withValues(alpha: 0.15)
                          : Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTask
                          ? Icons.task_alt
                          : isProject
                              ? Icons.folder_open
                              : Icons.layers,
                      size: 14,
                      color: isTask
                          ? Colors.blue
                          : isProject
                              ? Colors.purple
                              : Colors.teal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTask
                          ? 'مهمة (Task)'
                          : isProject
                              ? 'مشروع (Project)'
                              : 'مجال (Area)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isTask
                            ? Colors.blue
                            : isProject
                                ? Colors.purple
                                : Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined, size: 14),
                    SizedBox(width: 4),
                    Text('للقراءة فقط', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // بطاقة الكيان الرئيسية
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (entity['title'] ?? entity['name'] ?? 'بدون عنوان').toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (entity['description'] != null &&
                      (entity['description'] as String).trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      entity['description'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (entity['status'] != null)
                        _buildBadge(
                          icon: Icons.info_outline,
                          label: 'الحالة: ${entity['status']}',
                          color: _getStatusColor(entity['status'].toString()),
                        ),
                      if (entity['priority'] != null)
                        _buildBadge(
                          icon: Icons.flag_outlined,
                          label: 'الأولوية: ${entity['priority']}',
                          color: _getPriorityColor(entity['priority'].toString()),
                        ),
                      if (entity['due_date'] != null || entity['target_date'] != null)
                        _buildBadge(
                          icon: Icons.calendar_today_outlined,
                          label: 'الموعد: ${(entity['due_date'] ?? entity['target_date']).toString().split('T').first}',
                          color: Colors.blueGrey,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // العناصر الفرعية
          if (_sharedResult!.children.isNotEmpty) ...[
            Text(
              isTask
                  ? 'المهام الفرعية (${_sharedResult!.children.length})'
                  : isProject
                      ? 'مهام المشروع (${_sharedResult!.children.length})'
                      : 'مشاريع المجال (${_sharedResult!.children.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._sharedResult!.children.map((child) => _buildChildItem(child, theme, isTask)),
          ],
        ],
      ),
    );
  }

  Widget _buildChildItem(Map<String, dynamic> child, ThemeData theme, bool isSubtask) {
    final title = (child['title'] ?? child['name'] ?? '').toString();
    final isCompleted = child['is_completed'] == true || child['status'] == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: isCompleted ? Colors.green : theme.colorScheme.outline,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: child['priority'] != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(child['priority'].toString()).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  child['priority'].toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: _getPriorityColor(child['priority'].toString()),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
      default:
        return Colors.grey;
    }
  }
}
