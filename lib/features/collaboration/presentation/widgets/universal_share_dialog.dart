import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/sharing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/url_helper.dart';
import '../../data/models/entity_share_model.dart';
import '../controllers/collaboration_controller.dart';


/// نافذة موحدة لإدارة المشاركة والتعاون لجميع الكيانات (مجال / مشروع / مهمة).
///
/// تحتوي على تبويبين:
/// 1. رابط عام (قراءة فقط بدون حساب).
/// 2. أعضاء الفريق (مشاركة بحساب مع تحديد الصلاحيات: مشاهدة، تعديل، تحكم كامل).
class UniversalShareDialog extends StatefulWidget {
  final String entityType; // 'area' | 'project' | 'task'
  final String entityId;
  final String entityTitle;
  final String? existingShareToken;
  final ValueChanged<String?>? onShareTokenChanged;

  /// معرّفات الأجداد الهرمية (مثل: مشروع ← مجال) لفحوصات الإدارة الدقيقة.
  final List<String> parentEntityIds;

  /// متحكم حقن قابل للاختبار؛ عند غيابه يُنشأ داخلياً بكوّنة الإنتاج.
  final CollaborationController? controller;

  const UniversalShareDialog({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.entityTitle,
    this.existingShareToken,
    this.onShareTokenChanged,
    this.parentEntityIds = const [],
    this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required String entityType,
    required String entityId,
    required String entityTitle,
    String? existingShareToken,
    ValueChanged<String?>? onShareTokenChanged,
    List<String> parentEntityIds = const [],
    CollaborationController? controller,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => UniversalShareDialog(
        entityType: entityType,
        entityId: entityId,
        entityTitle: entityTitle,
        existingShareToken: existingShareToken,
        onShareTokenChanged: onShareTokenChanged,
        parentEntityIds: parentEntityIds,
        controller: controller,
      ),
    );
  }

  @override
  State<UniversalShareDialog> createState() => _UniversalShareDialogState();
}

class _UniversalShareDialogState extends State<UniversalShareDialog> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CollaborationController _collabController;
  final TextEditingController _emailController = TextEditingController();

  String? _shareToken;
  String _selectedPermission = 'viewer';
  bool _isInviting = false;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ownsController = widget.controller == null;
    _collabController = widget.controller ?? CollaborationController();
    _shareToken = widget.existingShareToken;

    // لا نحمّل المشاركات إذا وصل контроллер اختبار جاهز مسبقاً
    if (_ownsController) {
      _collabController.loadEntityShares(
        entityType: widget.entityType,
        entityId: widget.entityId,
        parentEntityIds: widget.parentEntityIds,
      );

      // إصلاح ذاتي: إن وُجد رمز سابق غير محفوظ في السحابة، ننشئ صف الرابط
      // العام في entity_shares حتى يبقى الرابط صالحاً بعد فتح النافذة.
      if (_shareToken != null && _shareToken!.isNotEmpty) {
        _syncPublicLink();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    if (_ownsController) _collabController.dispose();
    super.dispose();
  }

  String _getEntityTypeName() {
    switch (widget.entityType) {
      case 'area':
        return 'المجال';
      case 'project':
        return 'المشروع';
      case 'task':
        return 'المهمة';
      default:
        return 'العنصر';
    }
  }

  /// هل يمتلك المستخدم الحالي صلاحية إدارة المشاركات (مالك أو مسؤول)؟
  bool _canManageShares() =>
      _collabController.canManage(
        widget.entityId,
        ancestorEntityIds: widget.parentEntityIds,
      );

  void _showBlockedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('صلاحيتك على هذا العنصر لا تسمح بإدارة المشاركة. هذه الإجراءات متاحة فقط للمالك (Owner) أو المسؤول (Admin).'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _togglePublicLink(bool enable) async {
    if (!_canManageShares()) {
      _showBlockedSnackBar();
      return;
    }
    final sharingService = SharingService.instance;
    if (enable) {
      final newToken = await sharingService.generatePublicLink(
        entityType: _shareEntityType(),
        entityId: widget.entityId,
      );
      if (!mounted) return;
      if (newToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر إنشاء الرابط العام، تأكد من تسجيل الدخول والمزامنة.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setState(() => _shareToken = newToken);
      widget.onShareTokenChanged?.call(newToken);
    } else {
      await sharingService.revokePublicLink(
        entityType: _shareEntityType(),
        entityId: widget.entityId,
      );
      if (!mounted) return;
      setState(() => _shareToken = null);
      widget.onShareTokenChanged?.call(null);
    }
  }

  /// يحوّل نوع الكيان النصي إلى نوع المشاركة المستخدم في [SharingService].
  ShareEntityType _shareEntityType() {
    switch (widget.entityType) {
      case 'area':
        return ShareEntityType.area;
      case 'project':
        return ShareEntityType.project;
      default:
        return ShareEntityType.task;
    }
  }

  /// يضمن وجود صف الرابط العام في السحابة (entity_shares) لرمز قديم غير محفوظ.
  Future<void> _syncPublicLink() async {
    final token = await SharingService.instance.generatePublicLink(
      entityType: _shareEntityType(),
      entityId: widget.entityId,
    );
    if (!mounted) return;
    if (token != null && token != _shareToken) {
      setState(() => _shareToken = token);
      widget.onShareTokenChanged?.call(token);
    }
  }

  Future<void> _inviteMember() async {
    if (!_canManageShares()) {
      _showBlockedSnackBar();
      return;
    }
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بريد إلكتروني صالح')),
      );
      return;
    }

    setState(() => _isInviting = true);
    final success = await _collabController.invite(
      entityType: widget.entityType,
      entityId: widget.entityId,
      email: email,
      permissionLevel: _selectedPermission,
    );
    setState(() => _isInviting = false);

    if (mounted) {
      if (success) {
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت دعوة $email بنجاح'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_collabController.errorMessage ?? 'تعذر إرسال الدعوة'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entityTypeName = _getEntityTypeName();
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.share_rounded, color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مشاركة $entityTypeName',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.entityTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // TabBar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border(context)),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                labelColor: primaryColor,
                unselectedLabelColor: AppColors.textSecondary(context),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.group_outlined, size: 18),
                    text: 'أعضاء الفريق (بحساب)',
                  ),
                  Tab(
                    icon: Icon(Icons.link_rounded, size: 18),
                    text: 'رابط عام (بدون حساب)',
                  ),
                ],
              ),
            ),
            // TabView Content
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTeamTab(context, primaryColor),
                  _buildPublicLinkTab(context, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Tab 1: أعضاء الفريق بحساب ---
  Widget _buildTeamTab(BuildContext context, Color primaryColor) {
    return AnimatedBuilder(
      animation: _collabController,
      builder: (context, _) {
        final shares = _collabController.shares;
        final isLoading = _collabController.isLoading;
        final canManage = _canManageShares();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // لوحة القفل للمحررين والمشاهدين
              if (!canManage) _buildLockBanner(context),

              // Invitation Input Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'دعوة شخص جديد وتحديد صلاحيته',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _emailController,
                            enabled: canManage,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: canManage ? 'user@example.com' : 'الدعوة غير متاحة لصلاحيتك',
                              prefixIcon: const Icon(Icons.mail_outline, size: 18),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border(context)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPermission,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'viewer',
                                    child: Text('مشاهدة فقط 👁️', style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'editor',
                                    child: Text('محرر / تعديل ✏️', style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'admin',
                                    child: Text('تحكم كامل 🗑️', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                                onChanged: canManage
                                    ? (val) {
                                        if (val != null) setState(() => _selectedPermission = val);
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: canManage && !_isInviting ? _inviteMember : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isInviting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('دعوة', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Members List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الأشخاص الذين لديهم صلاحية وصول (${shares.length})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Members List
              Expanded(
                child: shares.isEmpty
                    ? Center(
                        child: Text(
                          isLoading ? 'جاري التحميل...' : 'لم تتم مشاركة هذا العنصر مع أي شخص بعد.',
                          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        itemCount: shares.length,
                        separatorBuilder: (_, _) => Divider(color: AppColors.border(context), height: 1),
                        itemBuilder: (context, index) {

                          final share = shares[index];
                          return _buildShareMemberTile(share, canManage: canManage);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// لوحة توضيحية تظهر للمحررين والمشاهدين (الإدارة حصرية للمالك والمسؤول).
  Widget _buildLockBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withOpacity(0.35)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🔒 صلاحيتك الحالية (مشاهدة أو تحرير) لا تسمح بدعوة أعضاء أو تعديل صلاحياتهم. هذه الإجراءات متاحة فقط للمالك (Owner) أو المسؤول (Admin).',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareMemberTile(EntityShareModel share, {bool canManage = true}) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: primaryColor.withOpacity(0.15),
            child: Text(
              (share.collaboratorEmail ?? 'U').substring(0, 1).toUpperCase(),
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  share.collaboratorEmail ?? 'مستخدم بدون بريد',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  share.status == 'active' ? 'نشط' : 'معلّق (في انتظار التسجيل)',
                  style: TextStyle(
                    fontSize: 11,
                    color: share.status == 'active' ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          // منتقي/عرض الصلاحية: معرّف للمدير فقط، وقراءة فقط للبقية
          if (canManage)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: share.permissionLevel,
                  items: const [
                    DropdownMenuItem(value: 'viewer', child: Text('مشاهدة فقط', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'editor', child: Text('محرر', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'admin', child: Text('مسؤول', style: TextStyle(fontSize: 11))),
                  ],
                  onChanged: (newPerm) async {
                    if (newPerm != null && newPerm != share.permissionLevel) {
                      final success = await _collabController.updatePermission(
                        shareId: share.id,
                        newPermissionLevel: newPerm,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'تم تحديث الصلاحية إلى (${newPerm == 'admin' ? 'مسؤول' : newPerm == 'editor' ? 'محرر' : 'مشاهدة فقط'}) بنجاح'
                                : 'تعذر تحديث الصلاحية، يرجى المحاولة لاحقاً',
                          ),
                          backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: share.permissionLevel == 'admin'
                    ? Colors.purple.withOpacity(0.12)
                    : (share.permissionLevel == 'editor'
                        ? Colors.blue.withOpacity(0.12)
                        : Colors.grey.withOpacity(0.12)),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: share.permissionLevel == 'admin'
                      ? Colors.purple
                      : (share.permissionLevel == 'editor' ? Colors.blue : Colors.grey),
                  width: 0.8,
                ),
              ),
              child: Text(
                share.permissionLevel == 'admin'
                    ? 'مسؤول'
                    : (share.permissionLevel == 'editor' ? 'محرر' : 'مشاهدة فقط'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: share.permissionLevel == 'admin'
                      ? Colors.purple
                      : (share.permissionLevel == 'editor' ? Colors.blue : Colors.grey),
                ),
              ),
            ),
          const SizedBox(width: 6),
          // زر سحب الصلاحية: للمدير فقط
          if (canManage)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              tooltip: 'سحب الصلاحية',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('سحب الصلاحية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    content: Text('هل أنت متأكد من إلغاء مشاركة هذا العنصر مع ${share.collaboratorEmail}؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('تأكيد السحب'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final ok = await _collabController.revoke(shareId: share.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'تم سحب الصلاحية بنجاح' : 'تعذر سحب الصلاحية'),
                      backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  // --- Tab 2: رابط عام بدون حساب ---
  Widget _buildPublicLinkTab(BuildContext context, Color primaryColor) {
    final hasLink = _shareToken != null && _shareToken!.isNotEmpty;
    final shareUrl = hasLink ? UrlHelper.buildShareUrl(_shareToken!) : '';
    final canManage = _canManageShares();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المشاركة عبر رابط عام',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'يتيح لأي شخص لديه الرابط الاطلاع على المحتوى (قراءة فقط بدون حساب)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Switch(
                value: hasLink,
                activeColor: primaryColor,
                onChanged: canManage ? _togglePublicLink : null,
              ),
            ],
          ),
          if (!canManage) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تفعيل أو إيقاف الرابط العام متاح فقط للمالك (Owner) أو المسؤول (Admin).',
                      style: TextStyle(fontSize: 11.5, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (hasLink) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 20, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      shareUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('نسخ الرابط', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ رابط المشاركة العام إلى الحافظة'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'أمان مضمون: الزائر عبر هذا الرابط لن يرى سوى هذا العنصر فقط، ولن يتمكن من تعديل أو حذف أي شيء إطلاقاً.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_off_rounded, size: 48, color: AppColors.textSecondary(context).withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'الرابط العام معطّل حالياً',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'قم بتفعيل المفتاح بالأعلى لتوليد رابط مشاركة سريع يمكن إرساله للعملاء أو الزملاء.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
