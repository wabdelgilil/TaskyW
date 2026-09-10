// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'TaskyW';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonSettings => 'الإعدادات';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonToday => 'مهام اليوم';

  @override
  String taskCountRemaining(int count) {
    return 'متبقي $count مهام';
  }

  @override
  String welcomeUser(String name) {
    return 'مرحباً $name';
  }

  @override
  String get sectionNotifications => 'الإشعارات والتنبيهات';

  @override
  String get sectionLanguage => 'اللغة والمنطقة';

  @override
  String get sectionFinance => 'المالية والعملات';

  @override
  String get sectionAppearance => 'المظهر والثيم';

  @override
  String get sectionData => 'بيانات التطبيق';

  @override
  String get settingsNotifications => 'إشعارات التطبيق';

  @override
  String get settingsNotificationsDesc =>
      'تشغيل أو إيقاف كل التنبيهات المحلية (تذكيرات المهام)';

  @override
  String get settingsReminderTime => 'وقت التذكير الافتراضي';

  @override
  String settingsReminderMinutes(int minutes) {
    return 'قبل الموعد بـ $minutes دقيقة';
  }

  @override
  String get settingsRequestPermission => 'طلب صلاحية التنبيهات';

  @override
  String get settingsRequestPermissionDesc =>
      'تأكيد صلاحية التنبيهات على الأندرويد/IOS';

  @override
  String get settingsPermissionGranted => 'تم تفعيل صلاحية التنبيهات بنجاح';

  @override
  String get settingsPermissionDenied => 'تم رفض طلب الصلاحية';

  @override
  String get settingsEnable => 'تفعيل';

  @override
  String get settingsLanguage => 'لغة التطبيق';

  @override
  String get settingsLanguageDesc =>
      'اختيار لغة الواجهات (الافتراضي: لغة الجهاز)';

  @override
  String get settingsLanguageSystem => 'تلقائي (لغة الجهاز)';

  @override
  String get settingsLanguageSystemShort => 'تلقائي';

  @override
  String get languageArabic => 'العربية (RTL)';

  @override
  String get languageEnglish => 'English (LTR)';

  @override
  String get syncSyncing => 'جاري المزامنة...';

  @override
  String syncPending(int count) {
    return '$count معلق';
  }

  @override
  String get syncSynced => 'متزامن';

  @override
  String get signInToCloud => 'تسجيل الدخول للسحابة';

  @override
  String get toggleThemeShort => 'تبديل';

  @override
  String get directionTitle => 'اتجاه الواجهة والسايد بار';

  @override
  String get directionDesc =>
      'إبقاء القائمة الجانبية على اليسار دائماً بغض النظر عن اللغة';

  @override
  String get directionLtr => 'يسار دائماً';

  @override
  String get directionAuto => 'تلقائي (يتبع اللغة)';

  @override
  String get settingsCurrency => 'العملة الافتراضية';

  @override
  String settingsCurrencyDesc(String currency) {
    return 'العملة المستخدمة في السجلات المالية الجديدة: $currency';
  }

  @override
  String get settingsViewMode => 'طريقة العرض';

  @override
  String get viewModeList => 'قائمة';

  @override
  String get viewModeKanban => 'كانبان';

  @override
  String get themeModeLabel => 'وضع المظهر';

  @override
  String get themeLight => 'نهاري';

  @override
  String get themeDark => 'ليلي';

  @override
  String get themeOled => 'OLED';

  @override
  String get themeLightFull => 'الوضع النهاري (Light)';

  @override
  String get themeDarkFull => 'الوضع الليلي (Dark)';

  @override
  String get themeOledFull => 'السواد العميق (OLED)';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String signedInAs(String email) {
    return 'مسجل الدخول: $email';
  }

  @override
  String get signedOut => 'غير مسجل الدخول';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileDisplayName => 'الاسم المعروض';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get navHome => 'اليوم';

  @override
  String get navProjects => 'المشاريع';

  @override
  String get navNotes => 'الملاحظات';

  @override
  String get navFinance => 'المالية';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get preview => 'معاينة';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get taskyUser => 'مستخدم Tasky';

  @override
  String get closeSearch => 'إغلاق البحث';

  @override
  String get sidebarMenu => 'القائمة الجانبية';

  @override
  String get viewList => 'عرض القوائم';

  @override
  String get viewKanban => 'عرض الكانبان';

  @override
  String get viewTable => 'عرض الجدول';

  @override
  String get exportCsvTooltip => 'تصدير المهام إلى CSV / Excel';

  @override
  String get exportCsvCurrentTooltip => 'تصدير المهام الحالية إلى CSV / Excel';

  @override
  String get globalSearch => 'بحث شامل';

  @override
  String get globalSearchInApp => 'بحث شامل في كل التطبيق';

  @override
  String get cancelGlobalSearch => 'إلغاء البحث الشامل';

  @override
  String get cancelGlobalShort => 'إلغاء الشامل';

  @override
  String get filterToday => '☀️ مهام اليوم';

  @override
  String get filterUpcoming => '📅 المهام القادمة';

  @override
  String get filterWaiting => '⏳ المهام المعلّقة (Waiting)';

  @override
  String get filterUrgent => '🔥 المهام العاجلة (Urgent)';

  @override
  String get filterAll => '📋 جميع المهام';

  @override
  String get contextTitleNotes =>
      '📚 الملاحظات ومستودع المعرفة (Knowledge Vault)';

  @override
  String get contextTitleFinance => '💰 السجل المالي والتسويات';

  @override
  String get contextTitleArchive => '🗄️ الأرشيف العام (Global Archive)';

  @override
  String get contextTitleTrash => '🗑️ سلة المهملات (Trash Bin)';

  @override
  String get contextTitleSharedProject => '💼 مشروع مشترك';

  @override
  String get contextTitleSharedArea => '📁 مجال مشترك';

  @override
  String contextTitleTag(String name) {
    return '🏷️ وسم: $name';
  }

  @override
  String get searchHintTasks => 'بحث في المهام...';

  @override
  String get searchHintGlobal => 'بحث شامل في كل المجالات والمشاريع...';

  @override
  String searchHintProject(String title) {
    return 'بحث في مشروع ($title)...';
  }

  @override
  String searchHintArea(String title) {
    return 'بحث في مجال ($title)...';
  }

  @override
  String get exportEmptyToast => 'لا توجد مهام لتصديرها في العرض الحالي';

  @override
  String exportSuccessToast(int count) {
    return 'تم تصدير $count مهمة ونسخ CSV إلى الحافظة بنجاح!';
  }

  @override
  String get quickAddHint => 'إضافة مهمة سريعة...';

  @override
  String get smartFiltersHeader => 'الفلاتر السريعة';

  @override
  String get smartFilterToday => 'اليوم';

  @override
  String get smartFilterUpcoming => 'القادمة';

  @override
  String get smartFilterWaiting => 'معلّقة (Waiting)';

  @override
  String get smartFilterUrgent => 'عاجل (Urgent)';

  @override
  String get smartFilterAll => 'جميع المهام';

  @override
  String get areasProjectsSection => 'المجالات والمشاريع';

  @override
  String get addNewAreaTooltip => 'إضافة مجال جديد';

  @override
  String get newProjectEllipsis => 'مشروع جديد...';

  @override
  String get tagsSection => 'الوسوم والتصنيفات';

  @override
  String get createTagTooltip => 'إنشاء وسم جديد';

  @override
  String get noTagsAdded => 'لا توجد وسوم مضافة';

  @override
  String get sharedWithMeHeader => 'مشارك معي (Shared)';

  @override
  String get refreshSharedTooltip => 'تحديث الكيانات المشتركة';

  @override
  String get sharedEntityDefault => 'عنصر مشترك';

  @override
  String get permissionAdmin => 'مسؤول';

  @override
  String get permissionEditor => 'محرر';

  @override
  String get permissionViewer => 'مشاهدة';

  @override
  String get sidebarNotesSection => 'الملاحظات والمعرفة (Vault)';

  @override
  String get sidebarNotesTitle => 'الملاحظات ومستودع المعرفة';

  @override
  String get sidebarFinanceSection => 'الماليات والتسويات';

  @override
  String get sidebarFinanceTitle => 'السجل المالي والتسويات';

  @override
  String get sidebarArchiveSection => 'الأرشيف والمهملات';

  @override
  String get sidebarArchiveTitle => 'الأرشيف العام';

  @override
  String get sidebarTrashTitle => 'سلة المهملات';

  @override
  String get attachmentSyncing => '⏳ قيد المزامنة';

  @override
  String get reminderNote => '⚠️ (تذكير)';

  @override
  String get chipPendingInvoice => '⚠️ بانتظار الفاتورة';

  @override
  String get invoicePendingTap => '⚠️ بانتظار الفاتورة (اضغط للاستلام)';

  @override
  String get attachmentSynced => '✓ مزامن';

  @override
  String get paidPersonalFromWork => '🏠 دفعت شخصي من حساب الشغل (عليّ للشغل)';

  @override
  String get chipPaidToWork => '🏠 مدفوع للشغل';

  @override
  String get paidFromPocket => '💼 دفعت للشغل من جيبي (لي عند الشغل)';

  @override
  String get chipDueFromWork => '💼 مستحق من الشغل';

  @override
  String get chipTransfers => '🔄 تحويلات';

  @override
  String get sharedPublicTitle => 'TaskyW — مشاركة عامة';

  @override
  String get enterNewName => 'أدخل اسمك الجديد';

  @override
  String get descriptionNotesHint =>
      'أدخل تفاصيل وملاحظات أو أرقام قطع الغيار...';

  @override
  String get archiveAction => 'أرشفة';

  @override
  String get recurrenceWeekly => 'أسبوعياً';

  @override
  String get pasteEmojiHint => 'ألصق إيموجي (مثال: 🤖) أو كوده (U+1F680)';

  @override
  String get enterHexCode => 'أو أدخل كود HEX مخصص:';

  @override
  String get orCreateTag => 'أو إنشاء وسم جديد:';

  @override
  String get trashTasksEmptyDesc =>
      'أي مهمة يتم حذفها ستُحفظ هنا ويمكن استعادتها بأي وقت.';

  @override
  String get quickEmojis => 'أيقونات مقترحة سريعة:';

  @override
  String get customEmojiInput => 'إدخال مخصص (لصق إيموجي أو كود U+...):';

  @override
  String get projectNotifications => 'إشعارات هذا المشروع';

  @override
  String get createTask => 'إضافة المهمة';

  @override
  String get addStepHint => 'إضافة خطوة فرعية جديدة...';

  @override
  String get addNewAreaTitle => 'إضافة مجال مسؤولية جديد';

  @override
  String get addAttachment => 'إضافة مرفق';

  @override
  String get addNewProjectTitle => 'إضافة مشروع جديد';

  @override
  String get addNewTaskTitle => 'إضافة مهمة جديدة';

  @override
  String get addGeneralTask => 'إضافة مهمة عامة';

  @override
  String get addTaskInProject => 'إضافة مهمة في المشروع';

  @override
  String get kanbanAddInColumn => 'إضافة مهمة في هذا العمود';

  @override
  String get addTag => 'إضافة وسم';

  @override
  String get addTagForTask => 'إضافة وسم للمهمة';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get emptyTrash => 'إفراغ السلة';

  @override
  String get emptyTrashConfirmAction => 'إفراغ السلة نهائياً';

  @override
  String get emptyTrashConfirmTitle => 'إفراغ سلة المهملات بالكامل؟';

  @override
  String get unarchive => 'إلغاء الأرشفة';

  @override
  String get unpinNote => 'إلغاء التثبيت';

  @override
  String get toAccount => 'إلى حساب';

  @override
  String get markDone => 'إنجاز';

  @override
  String get createAction => 'إنشاء';

  @override
  String get createArea => 'إنشاء المجال';

  @override
  String get createProject => 'إنشاء المشروع';

  @override
  String get createAndAttachTag => 'إنشاء وإضافة الوسم';

  @override
  String get createNewTag => 'إنشاء وسم جديد';

  @override
  String get startAddingTasks => 'ابدأ بإضافة مهمة جديدة لمتابعة إنجازك اليومي';

  @override
  String get chooseIconTitle => 'اختر أيقونة معبرة';

  @override
  String get chooseTagColor => 'اختر لون الوسم:';

  @override
  String get chooseCustomColor => 'اختر لوناً مخصصاً';

  @override
  String get choose => 'اختيار';

  @override
  String get restoreAction => 'استعادة';

  @override
  String get restoreProject => 'استعادة المشروع';

  @override
  String get restoreNote => 'استعادة الملاحظة';

  @override
  String get restoreTask => 'استعادة المهمة';

  @override
  String get archiveRestoreToActive => 'استعادة للأعمال النشطة';

  @override
  String get kanbanDropHint => 'اسحب المهام إلى هنا أو أضف مهمة جديدة';

  @override
  String get areaName => 'اسم المجال';

  @override
  String get projectName => 'اسم المشروع';

  @override
  String get tagName => 'اسم الوسم';

  @override
  String get newTagNameHint => 'اسم الوسم (مثلاً: عاجل، قطع_غيار...)';

  @override
  String get notesEmptyHint => 'اضغط + لإضافة أول ملاحظة...';

  @override
  String get noteContentHint => 'اكتب أفكارك ومراجعك هنا...';

  @override
  String get archiveGlobalTitle => 'الأرشيف العام (Global Archive)';

  @override
  String get suggestedColors => 'الألوان المقترحة:';

  @override
  String get priorityLabel => 'الأولوية';

  @override
  String get priorityColon => 'الأولوية:';

  @override
  String get trashSearchHint => 'البحث في سلة المهملات...';

  @override
  String get archiveSearchHint => 'البحث في عناصر الأرشيف...';

  @override
  String get bankOption => 'البنك';

  @override
  String get toAccountHint => 'البنك، المحفظة...';

  @override
  String get descriptionLabel => 'البيان *';

  @override
  String get recurrenceColon => 'التكرار:';

  @override
  String get reminderColon => 'التنبيه:';

  @override
  String get emojiCategoryStatus => 'الحالات والتنبيه';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get statusColon => 'الحالة:';

  @override
  String get deadlineColon => 'الديدلاين:';

  @override
  String get invalidShareLink => 'الرابط غير صالح أو انتهت صلاحية المشاركة.';

  @override
  String get linkUnavailable => 'الرابط غير متوفر';

  @override
  String get emojiCategoryPersonal => 'الشخصية والمنزل';

  @override
  String get emojiCategoryWork => 'العمل والمشاريع';

  @override
  String get trashSubtitle =>
      'العناصر المحذوفة مؤقتاً، يمكنك استعادتها أو حذفها نهائياً لتفريغ المساحة';

  @override
  String get noteTitle => 'العنوان';

  @override
  String get allFilter => 'الكل';

  @override
  String get colorLabel => 'اللون';

  @override
  String get colorColon => 'اللون: ';

  @override
  String get amountLabel => 'المبلغ (SAR) *';

  @override
  String get pinnedNotes => 'المثبتة';

  @override
  String get areaLabel => 'المجال';

  @override
  String get areaProjectColumn => 'المجال / المشروع';

  @override
  String get areaColon => 'المجال:';

  @override
  String get noteContent => 'المحتوى';

  @override
  String get notesScreenSubtitle =>
      'المستودع المعرفي والمساحة الهادئة للأفكار، المراجع، الروابط وجهات الاتصال دون مواعيد أو قيود مهام.';

  @override
  String get areaProjects => 'المشاريع التابعة للمجال';

  @override
  String get trashProjectsEmptyDesc =>
      'المشاريع المحذوفة تظهر هنا لحين استعادتها أو مسحها نهائياً.';

  @override
  String get archiveProjectsEmptyDesc =>
      'المشاريع المنتهية أو المؤرشفة ستظهر هنا للحفظ المرجعي.';

  @override
  String get projectLabel => 'المشروع';

  @override
  String get projectColon => 'المشروع:';

  @override
  String get trashNotesEmptyDesc => 'الملاحظات المحذوفة ناعماً تظهر هنا.';

  @override
  String get notesScreenTitle => 'الملاحظات ومستودع المعرفة (Knowledge Vault)';

  @override
  String get attachmentNotSynced =>
      'الملف غير مرفوع بعد؛ سيتوفر التنزيل بعد المزامنة';

  @override
  String get subtasksColumn => 'المهام الفرعية';

  @override
  String get subtasksTitle => 'المهام الفرعية (Checklist)';

  @override
  String get completedTasksSection => 'المهام المكتملة (Completed Tasks)';

  @override
  String get archiveGlobalSubtitle =>
      'المهام والمشاريع والملاحظات المنتهية المحفوظة للرجوع إليها دون تشويش مساحات العمل اليومية';

  @override
  String get patternColon => 'النمط:';

  @override
  String get emojiCategoryTools => 'الهندسة والأدوات';

  @override
  String get tagsColumn => 'الوسوم';

  @override
  String get availableTags => 'الوسوم المتاحة:';

  @override
  String get tagsTitle => 'الوسوم والتصنيفات (Tags)';

  @override
  String get descriptionNotesLabel => 'الوصف والملاحظات:';

  @override
  String get financeSearchHint => 'بحث في العمليات، الحسابات، الملاحظات...';

  @override
  String get notesSearchHint => 'بحث لحظي في العناوين والمحتوى...';

  @override
  String get noEndDate => 'بدون تاريخ انتهاء (مستمر)';

  @override
  String get untitled => 'بدون عنوان';

  @override
  String get noProject => 'بدون مشروع';

  @override
  String get noProjectGeneral => 'بدون مشروع (مهمة عامة)';

  @override
  String get exportedCsvData => 'بيانات CSV المُصدّرة';

  @override
  String get confirmChoice => 'تأكيد الاختيار';

  @override
  String get dueDateColumn => 'تاريخ الاستحقاق';

  @override
  String get dueDateLabel => 'تاريخ التسليم';

  @override
  String get pinNote => 'تثبيت';

  @override
  String get groupByProject => 'تجميع بحسب المشروع';

  @override
  String get archiveRefresh => 'تحديث الأرشيف';

  @override
  String get refreshTrash => 'تحديث السلة';

  @override
  String get transferOption => 'تحويل';

  @override
  String get customizeTaskColor => 'تخصيص لون للمهمة';

  @override
  String get undoAction => 'تراجع';

  @override
  String get registerTransaction => 'تسجيل العملية';

  @override
  String get newTransactionTitle => 'تسجيل عملية مالية جديدة';

  @override
  String get settlementLabel => 'تسوية حساب الشغل والشخصي:';

  @override
  String get exportStatement => 'تصدير كشف الحساب إلى Excel / CSV';

  @override
  String get pendingInvoiceReminder =>
      'تظل معلقة حتى تستلم الفاتورة لتتذكر المطالبة بها';

  @override
  String get editLabel => 'تعديل';

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get editTransactionTitle => 'تعديل العملية المالية';

  @override
  String get editArea => 'تعديل المجال';

  @override
  String get editProject => 'تعديل المشروع';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get editAreaData => 'تعديل بيانات المجال';

  @override
  String get editProjectData => 'تعديل بيانات المشروع';

  @override
  String get syncFailedTapRetry =>
      'تعذر الاتصال بالسحابة. اضغط للمحاولة مجدداً.';

  @override
  String get invalidEmojiCode => 'تعذر التعرف على كود الإيموجي';

  @override
  String get attachSaveError => 'تعذر حفظ المرفق';

  @override
  String get openFileError => 'تعذر فتح الملف';

  @override
  String get setDateHint => 'تعيين موعد...';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get enableProjectNotifications => 'تفعيل إشعارات هذا Projekt';

  @override
  String get projectNotificationsDesc =>
      'تفعيل التذكيرات المحلية لمهام هذا المشروع';

  @override
  String get trashEmptiedToast => 'تم إفراغ سلة المهملات بنجاح';

  @override
  String get allDoneSection => 'تم إنجاز كل المهام في هذا القسم 🎉';

  @override
  String get invoiceReceivedToast =>
      'تم استلام الفاتورة وتحديث الحالة لمكتملة ✅';

  @override
  String get nameUpdatedToast => 'تم تحديث الاسم بنجاح';

  @override
  String get projectNotifEnabledToast => 'تم تفعيل إشعارات المشروع';

  @override
  String get projectDeletedPermanentToast => 'تم حذف المشروع نهائياً';

  @override
  String get taskDeletedPermanentToast => 'تم حذف المهمة نهائياً';

  @override
  String get projectNotifMutedToast => 'تم كتم إشعارات المشروع';

  @override
  String get settledToast => 'تمت التسوية ✔️';

  @override
  String get statusInProgress => 'جاري التنفيذ';

  @override
  String get syncInProgressNow => 'جاري المزامنة مع السحابة الآن...';

  @override
  String get syncingNow => 'جاري المزامنة...';

  @override
  String get loadingSharedItem => 'جاري تحميل العنصر المشترك...';

  @override
  String get syncUploading => 'جاري رفع التعديلات السحابية...';

  @override
  String get syncChecking => 'جاري فحص وتحديث البيانات مع السحابة...';

  @override
  String get tryOtherKeywords => 'جرّب البحث بكلمات أخرى.';

  @override
  String get syncAllSynced => 'جميع بياناتك متزامنة مع السحابة';

  @override
  String get cloudStatus => 'حالة السحابة';

  @override
  String get projectStatus => 'حالة المشروع';

  @override
  String get shareLoadError =>
      'حدث خطأ أثناء تحميل البيانات. يرجى المحاولة مرة أخرى.';

  @override
  String get deleteStep => 'حذف الخطوة';

  @override
  String get deleteTransaction => 'حذف العملية المالية';

  @override
  String get deleteArea => 'حذف المجال';

  @override
  String get deleteAreaFully => 'حذف المجال بالكامل';

  @override
  String get deleteAttachment => 'حذف المرفق';

  @override
  String get deleteProject => 'حذف المشروع';

  @override
  String get deleteProjectPermanentConfirm => 'حذف المشروع نهائياً؟';

  @override
  String get deleteNote => 'حذف الملاحظة';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get deleteSubtask => 'حذف المهمة الفرعية';

  @override
  String get deleteTaskPermanentConfirm => 'حذف المهمة نهائياً؟';

  @override
  String get deletePermanent => 'حذف نهائي';

  @override
  String get saveEdit => 'حفظ التعديل';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get incomeRefundOption => 'دخل/استرداد';

  @override
  String get notesHint => 'رقم الإيصال، اسم المورد، تفاصيل...';

  @override
  String get trashProjectsEmpty => 'سلة المشاريع فارغة';

  @override
  String get trashNotesEmpty => 'سلة الملاحظات فارغة';

  @override
  String get trashTasksEmpty => 'سلة المهام فارغة';

  @override
  String get trashTitle => 'سلة المهملات (Trash Bin)';

  @override
  String get emptyTrashConfirmBody =>
      'سيتم حذف جميع المهام والمشاريع الموجودة في سلة المهملات نهائياً وبلا رجعة. هل تريد الاستمرار؟';

  @override
  String get recurrenceMonthly => 'شهرياً';

  @override
  String get setReminderHint => 'ضبط تذكير...';

  @override
  String get priorityCritical => 'عاجل جداً';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get netYouOwe => 'عليك للشغل (صافي)';

  @override
  String get newTransaction => 'عملية جديدة';

  @override
  String get normalTransaction => 'عملية عادية (لا تتطلب تسوية)';

  @override
  String get archiveTasksEmptyDesc =>
      'عند أرشفة أي مهمة ستظهر هنا للرجوع إليها مستقبلاً.';

  @override
  String get noteTitleHint => 'عنوان الملاحظة...';

  @override
  String get columnTitle => 'عنوان المهمة';

  @override
  String get taskTitleLabel => 'عنوان المهمة *';

  @override
  String get taskTitleEditHint => 'عنوان المهمة...';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get notSignedIn => 'غير مسجل الدخول';

  @override
  String get openAttachment => 'فتح / تنزيل المرفق';

  @override
  String get pendingInvoices => 'فواتير معلقة';

  @override
  String get statusWaiting => 'قيد الانتظار';

  @override
  String get cashOption => 'كاش';

  @override
  String get paymentMethodHint => 'كاش، CIB، فودافون كاش...';

  @override
  String get muteProjectNotifications => 'كتم إشعارات هذا المشروع';

  @override
  String get exportedStatementCsv => 'كشف الحساب المُصدّر (CSV)';

  @override
  String get financeEmpty => 'لا توجد أي عمليات مالية مسجلة بعد';

  @override
  String get attachmentsEmpty =>
      'لا توجد مرفقات بعد — يمكنك إرفاق مستندات وصور وملفات.';

  @override
  String get archiveEmptyProjects => 'لا توجد مشاريع مؤرشفة';

  @override
  String get areaNoProjects => 'لا توجد مشاريع مضافة تحت هذا المجال بعد';

  @override
  String get notesEmpty => 'لا توجد ملاحظات بعد';

  @override
  String get archiveEmptyNotes => 'لا توجد ملاحظات مؤرشفة';

  @override
  String get areaNoGeneralTasks =>
      'لا توجد مهام عامة خارج المشاريع لهذا المجال';

  @override
  String get noTasksInSection => 'لا توجد مهام في هذا القسم حالياً';

  @override
  String get tableEmpty => 'لا توجد مهام لعرضها في الجدول';

  @override
  String get archiveEmptyTasks => 'لا توجد مهام مؤرشفة';

  @override
  String get noTasksRegistered => 'لا توجد مهام مسجلة حالياً';

  @override
  String get projectNoTasks => 'لا توجد مهام مضافة لهذا المشروع حتى الآن';

  @override
  String get noMatchingResults => 'لا توجد نتائج مطابقة';

  @override
  String get financeNoFilterMatch => 'لا توجد نتائج مطابقة للفلتر المحدد';

  @override
  String get noTagsForTask =>
      'لا توجد وسوم مرتبطة بهذه المهمة. اضغط \"إضافة وسم\" للتصنيف.';

  @override
  String get paste => 'لصق';

  @override
  String get pasteFromClipboard => 'لصق من الحافظة';

  @override
  String get netOwedToYou => 'لك عند الشغل (صافي)';

  @override
  String get readOnlyBadge => 'للقراءة فقط';

  @override
  String get notReceivedInvoice => 'لم أستلم الفاتورة بعد';

  @override
  String get noFileSelected => 'لم يتم اختيار أي ملف';

  @override
  String get noteColor => 'لون الملاحظة';

  @override
  String get customTaskColor => 'لون مخصص للمهمة';

  @override
  String get taskTitleHint => 'ما الذي ترغب في إنجازه؟';

  @override
  String get fullySynced => 'متزامن بالكامل';

  @override
  String get recurrenceRecurring => 'متكررة';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get descriptionHint => 'مثلاً: شراء قطع غيار، غداء عمل، تحويل عهدة...';

  @override
  String get tagNameHint => 'مثلاً: عاجل، قطع_غيار...';

  @override
  String get entityArea => 'مجال (Area)';

  @override
  String get statusReview => 'مراجعة';

  @override
  String get syncNowButton => 'مزامنة...';

  @override
  String get owedByYou => 'مستحق عليك للشغل ⏳';

  @override
  String get shareAreaWithTeam => 'مشاركة المجال مع الفريق';

  @override
  String get shareProjectWithTeam => 'مشاركة المشروع مع الفريق';

  @override
  String get shareTaskWithTeam => 'مشاركة المهمة مع الفريق برابط أو حساب';

  @override
  String get entityProject => 'مشروع (Project)';

  @override
  String get newProject => 'مشروع جديد';

  @override
  String get expenseOption => 'مصروف';

  @override
  String get reimbursementRequired => 'مطلوب استرداده من الشغل ⏳';

  @override
  String get generalTransaction => 'معاملة عامة';

  @override
  String get areaCompletionRate => 'معدل إنجاز المجال العام:';

  @override
  String get disabled => 'معطّل';

  @override
  String get projectStatusOnHold => 'معلّق مؤقتاً (On Hold)';

  @override
  String get statusOnHold => 'معلّقة';

  @override
  String get enabled => 'مفعّل';

  @override
  String get projectStatusCompleted => 'مكتمل (Completed)';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get notesListTitle => 'ملاحظات';

  @override
  String get taskNotesLabel => 'ملاحظات أو وصف (اختياري)';

  @override
  String get additionalNotes => 'ملاحظات إضافية (اختياري)';

  @override
  String get archiveNotesEmptyDesc =>
      'ملاحظات المعرفة والتوثيق المؤرشفة تظهر هنا.';

  @override
  String get newNote => 'ملاحظة جديدة';

  @override
  String get chooseIconSubtitle => 'من القائمة أو بلصق الإيموجي أو كود Unicode';

  @override
  String get fromAccount => 'من حساب';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get areaGeneralTasks => 'مهام عامة تابعة للمجال';

  @override
  String get entityTask => 'مهمة (Task)';

  @override
  String get projectCompletionRate => 'نسبة إنجاز المشروع:';

  @override
  String get projectStatusActive => 'نشط (Active)';

  @override
  String get yesDelete => 'نعم، حذف';

  @override
  String get paymentMethodLabel => 'وسيلة الدفع / الحساب';

  @override
  String get projectDescription => 'وصف المشروع (اختياري)';

  @override
  String get syncOffline => 'وضع أوفلاين. يعمل التطبيق محلياً بالكامل.';

  @override
  String get requireAreaFirst => 'يجب إنشاء مجال أولاً قبل إضافة المهام.';

  @override
  String get invalidTransactionMsg => 'يرجى كتابة البيان وتحديد مبلغ صحيح';

  @override
  String get endsAtColon => 'ينتهي في:';

  @override
  String get recurrenceDaily => 'يومياً';

  @override
  String syncPendingTooltip(int count) {
    return 'توجد $count تعديلات محلية بانتظار الرفع. اضغط للمزامنة.';
  }

  @override
  String taskDeletedToast(String title) {
    return 'تم حذف المهمة \"$title\"';
  }

  @override
  String deleteFileConfirm(String fileName) {
    return 'هل أنت متأكد من حذف الملف \"$fileName\"؟';
  }

  @override
  String fileSavedLocal(String url) {
    return 'الملف محفوظ محلياً: $url';
  }

  @override
  String attachmentsCount(int count) {
    return 'المرفقات ($count)';
  }

  @override
  String deleteTaskConfirm(String title) {
    return 'هل أنت متأكد من رغبتك في حذف المهمة \"$title\"؟';
  }

  @override
  String deleteStepConfirm(String title) {
    return 'هل أنت متأكد من حذف الخطوة \"$title\"؟';
  }

  @override
  String tabsTasks(int count) {
    return 'المهام ($count)';
  }

  @override
  String tabsProjects(int count) {
    return 'المشاريع ($count)';
  }

  @override
  String tabsNotes(int count) {
    return 'الملاحظات ($count)';
  }

  @override
  String restoredTaskToast(String title) {
    return 'تمت استعادة المهمة \"$title\" بنجاح';
  }

  @override
  String restoredProjectToast(String name) {
    return 'تمت استعادة المشروع \"$name\" بنجاح';
  }

  @override
  String restoredNoteToast(String title) {
    return 'تمت استعادة الملاحظة \"$title\" بنجاح';
  }

  @override
  String cannotRestoreTaskMsg(String title) {
    return 'لن تتمكن من استعادة المهمة \"$title\" بعد الحذف النهائي.';
  }

  @override
  String cannotRestoreProjectMsg(String name) {
    return 'لن تتمكن من استعادة المشروع \"$name\" بعد الحذف النهائي.';
  }

  @override
  String deleteNoteConfirm(String title) {
    return 'هل أنت متأكد من حذف \"$title\"؟';
  }

  @override
  String areaStats(int projects, int tasks) {
    return 'مجال مسؤولية يضم $projects مشاريع و $tasks مهام';
  }

  @override
  String taskCounter(int done, int total) {
    return '$done/$total مهام';
  }

  @override
  String urgentCount(int count) {
    return '$count عاجلة';
  }

  @override
  String projectProgress(int percent, int done, int total) {
    return '$percent% ($done/$total مكتملة)';
  }

  @override
  String pendingChangesCount(int count) {
    return '$count تعديل معلق';
  }

  @override
  String dueDateBadge(String date) {
    return 'الموعد: $date';
  }

  @override
  String financeExportToast(int count) {
    return 'تم تصدير $count عملية ونسخ CSV إلى الحافظة!';
  }

  @override
  String transferFromTo(String from, String to) {
    return 'من $from ⬅️ إلى $to';
  }

  @override
  String viaAccount(String account) {
    return 'عبر: $account';
  }

  @override
  String deleteTransactionConfirm(String title) {
    return 'هل أنت متأكد من حذف عملية \"$title\"؟';
  }

  @override
  String get yesNow => 'نعم، احذف';

  @override
  String deleteAreaConfirm(String name) {
    return 'هل أنت متأكد من رغبتك في حذف مجال \"$name\" وجميع المشاريع والمهام التابعة له؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String deleteProjectConfirm(String name) {
    return 'هل أنت متأكد من رغبتك في حذف مشروع \"$name\" وجميع المهام التابعة له؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get syncPartialFail => 'اكتملت المزامنة مع بعض الأخطاء';

  @override
  String get syncAutoFail => 'تعذر إتمام المزامنة التلقائية';

  @override
  String get syncLoginRequired => 'يجب تسجيل الدخول لمزامنة البيانات';

  @override
  String get tagDefault => 'وسم';

  @override
  String get currencySearchHint =>
      'ابحث باسم الدولة، العملة، أو الرمز (SAR, EGP...)';

  @override
  String get selectCurrencyTitle => 'اختيار العملة الافتراضية';

  @override
  String get noCurrencyResult => 'لا توجد عملة تطابق بحثك';

  @override
  String get authResendActivation => ' إعادة إرسال رابط التفعيل الآن';

  @override
  String get shareRestrictedNotice =>
      '🔒 صلاحيتك الحالية (مشاهدة أو تحرير) لا تسمح بدعوة أعضاء أو تعديل صلاحياتهم. هذه الإجراءات متاحة فقط للمالك (Owner) أو المسؤول (Admin).';

  @override
  String get authResetEmailHint => 'أدخل بريدك المسجل لإرسال رابط التعيين';

  @override
  String get authConfirmEmailResent =>
      'أرسلنا رابط التفعيل مسبقاً. تفقّد صندوق الوارد وكذلك مجلد الرسائل غير المرغوب فيها (Spam / Junk).';

  @override
  String get shareTeamMembers => 'أعضاء الفريق (بحساب)';

  @override
  String get authConfirmEmailAction => 'أكدت بريدي، تسجيل الدخول الآن';

  @override
  String get shareSecurityNote =>
      'أمان مضمون: الزائر عبر هذا الرابط لن يرى سوى هذا العنصر فقط، ولن يتمكن من تعديل أو حذف أي شيء إطلاقاً.';

  @override
  String get authSignUpSubtitle =>
      'أنشئ حسابك للنسخ الاحتياطي السحابي والمشاركة';

  @override
  String get authSendResetLink => 'إرسال رابط الاستعادة';

  @override
  String get authCreateAccountAction => 'إنشاء الحساب';

  @override
  String get authCreateAccount => 'إنشاء حساب جديد';

  @override
  String get authGetStartedSubtitle => 'ابدأ إدارة مشاريعك باحتراف';

  @override
  String get authResetPassword => 'استعادة كلمة المرور';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get shareInviteUnavailable => 'الدعوة غير متاحة لصلاحيتك';

  @override
  String get shareLinkDisabled => 'الرابط العام معطّل حالياً';

  @override
  String get shareEntityElement => 'العنصر';

  @override
  String get authContinueOffline => 'المتابعة دون حساب (محلياً)';

  @override
  String get shareEntityArea => 'المجال';

  @override
  String get sharePublicLinkTitle => 'المشاركة عبر رابط عام';

  @override
  String get shareEntityProject => 'المشروع';

  @override
  String get shareEntityTask => 'المهمة';

  @override
  String get authEmailInvalid => 'بريد إلكتروني غير صحيح';

  @override
  String get authConfirmEmailTitle => 'تأكيد البريد الإلكتروني';

  @override
  String get authConfirmAccount => 'تأكيد الحساب';

  @override
  String get authConfirmRequired => 'تأكيد الحساب مطلوب لتسجيل الدخول';

  @override
  String get shareRevokeConfirmTitle => 'تأكيد السحب';

  @override
  String get shareFullAccessBadge => 'تحكم كامل 🗑️';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authChangeEmail => 'تعديل البريد الإلكتروني أو المحاولة بحساب آخر';

  @override
  String get shareInviteError => 'تعذر إرسال الدعوة';

  @override
  String get shareLinkCreationError =>
      'تعذر إنشاء الرابط العام، تأكد من تسجيل الدخول والمزامنة.';

  @override
  String get sharePermissionUpdateError =>
      'تعذر تحديث الصلاحية، يرجى المحاولة لاحقاً';

  @override
  String get shareRevokeError => 'تعذر سحب الصلاحية';

  @override
  String get sharePublicLinkToggleDesc =>
      'تفعيل أو إيقاف الرابط العام متاح فقط للمالك (Owner) أو المسؤول (Admin).';

  @override
  String get authResetEmailSent =>
      'تم إرسال رابط استعادة كلمة المرور إلى بريدك.';

  @override
  String get authAccountCreatedSuccessfully => 'تم إنشاء الحساب بنجاح!';

  @override
  String get authAccountCreatedBody =>
      'تم إنشاء حسابك بنجاح! أرسلنا رسالة تأكيد تحتوي على رابط التفعيل إلى:';

  @override
  String get shareRevokeSuccess => 'تم سحب الصلاحية بنجاح';

  @override
  String get shareCopyLinkSuccess => 'تم نسخ رابط المشاركة العام إلى الحافظة';

  @override
  String get authResendSuccess =>
      'تمت إعادة إرسال رابط التفعيل بنجاح! تفقد بريدك.';

  @override
  String get shareLoading => 'جاري التحميل...';

  @override
  String get shareInviteButton => 'دعوة';

  @override
  String get shareInviteNewMember => 'دعوة شخص جديد وتحديد صلاحيته';

  @override
  String get sharePublicLink => 'رابط عام (بدون حساب)';

  @override
  String get authSignInSubtitle => 'سجل دخولك لمزامنة مهامك ومشاركتها مع فريقك';

  @override
  String get shareRevokeAccess => 'سحب الصلاحية';

  @override
  String get sharePermissionDenied =>
      'صلاحيتك على هذا العنصر لا تسمح بإدارة المشاركة. هذه الإجراءات متاحة فقط للمالك (Owner) أو المسؤول (Admin).';

  @override
  String get shareLinkToggleHint =>
      'قم بتفعيل المفتاح بالأعلى لتوليد رابط مشاركة سريع يمكن إرساله للعملاء أو الزملاء.';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordMin => 'كلمة المرور 6 خانات كحد أدنى';

  @override
  String get authHasAccount => 'لديك حساب بالفعل؟';

  @override
  String get shareNotSharedYet => 'لم تتم مشاركة هذا العنصر مع أي شخص بعد.';

  @override
  String get authResendLink => 'لم تصلك الرسالة؟ إعادة الإرسال';

  @override
  String get authNoAccount => 'ليس لديك حساب بعد؟';

  @override
  String get shareEditor => 'محرر';

  @override
  String get shareEditorBadge => 'محرر / تعديل ✏️';

  @override
  String get authWelcomeBack => 'مرحباً بعودتك إلى Tasky';

  @override
  String get shareAdmin => 'مسؤول';

  @override
  String get shareUserWithoutEmail => 'مستخدم بدون بريد';

  @override
  String get shareViewer => 'مشاهدة فقط';

  @override
  String get shareViewOnlyBadge => 'مشاهدة فقط 👁️';

  @override
  String get sharePending => 'معلّق (في انتظار التسجيل)';

  @override
  String get shareCopyLink => 'نسخ الرابط';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get shareActive => 'نشط';

  @override
  String get authOfflineMode => 'وضع الأوفلاين';

  @override
  String get sharePublicLinkDesc =>
      'يتيح لأي شخص لديه الرابط الاطلاع على المحتوى (قراءة فقط بدون حساب)';

  @override
  String get shareInvalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get authConfirmEmailBody =>
      'يرجى فتح الرسالة والنقر على رابط التفعيل. إذا لم تجد الرسالة في صندوق الوارد، تفقّد مجلد الرسائل غير المرغوب فيها (Spam / Junk).';

  @override
  String get authNameRequired => 'يرجى كتابة الاسم';

  @override
  String get authEmailRequired => 'يرجى كتابة البريد الإلكتروني';

  @override
  String get authPasswordRequired => 'يرجى كتابة كلمة المرور';

  @override
  String sharePeopleWithAccess(int count) {
    return 'الأشخاص الذين لديهم صلاحية وصول ($count)';
  }

  @override
  String sharePermissionUpdatedSuccess(String permission) {
    return 'تم تحديث الصلاحية إلى $permission بنجاح';
  }

  @override
  String authResendActivationSuccess(String email) {
    return 'تمت إعادة إرسال رابط التفعيل إلى $email بنجاح! تفقد بريدك الآن.';
  }

  @override
  String shareInviteSentSuccess(String email) {
    return 'تمت دعوة $email بنجاح';
  }

  @override
  String shareDialogTitle(String name) {
    return 'مشاركة $name';
  }

  @override
  String shareRevokeConfirmBody(String email) {
    return 'هل أنت متأكد من إلغاء مشاركة هذا العنصر مع $email؟';
  }

  @override
  String get authConnectionError => 'حدث خطأ في الاتصال، يرجى المحاولة لاحقاً';

  @override
  String get authSignUpError => 'حدث خطأ في إنشاء الحساب، يرجى المحاولة لاحقاً';

  @override
  String get authEnterEmailForResend =>
      'يرجى إدخال البريد الإلكتروني لإعادة إرسال الرابط';

  @override
  String get authResendActivationError =>
      'تعذر إعادة إرسال رابط التفعيل، يرجى المحاولة لاحقاً';

  @override
  String get authResetPasswordError => 'تعذر إرسال رابط الاستعادة';

  @override
  String get authDisplayNameUpdated => 'تم تحديث الاسم المعروض بنجاح';

  @override
  String get authUpdateNameError => 'تعذر تحديث الاسم، يرجى المحاولة لاحقاً';

  @override
  String get authEmailNotConfirmed =>
      'لم يتم تأكيد بريدك الإلكتروني بعد. يرجى فتح الرسالة المرسلة إلى بريدك والنقر على رابط التفعيل لتسجيل الدخول.';

  @override
  String get authInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get authUserAlreadyRegistered => 'هذا البريد الإلكتروني مسجل بالفعل';

  @override
  String get authPasswordTooShort => 'كلمة المرور يجب ألا تقل عن 6 أحرف';

  @override
  String get authInvalidEmail => 'صيغة البريد الإلكتروني غير صالحة';

  @override
  String get authRateLimit => 'يرجى الانتظار دقيقة قبل طلب إرسال رابط جديد';
}
