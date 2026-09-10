import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'TaskyW'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get commonSettings;

  /// No description provided for @commonSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get commonSearch;

  /// No description provided for @commonToday.
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get commonToday;

  /// عدد المهام المتبقية في مجموعة ما.
  ///
  /// In ar, this message translates to:
  /// **'متبقي {count} مهام'**
  String taskCountRemaining(int count);

  /// ترحيب ترحيبي بالمستخدم باسمه.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {name}'**
  String welcomeUser(String name);

  /// No description provided for @sectionNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات والتنبيهات'**
  String get sectionNotifications;

  /// No description provided for @sectionLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة والمنطقة'**
  String get sectionLanguage;

  /// No description provided for @sectionFinance.
  ///
  /// In ar, this message translates to:
  /// **'المالية والعملات'**
  String get sectionFinance;

  /// No description provided for @sectionAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر والثيم'**
  String get sectionAppearance;

  /// No description provided for @sectionData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التطبيق'**
  String get sectionData;

  /// No description provided for @settingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات التطبيق'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل أو إيقاف كل التنبيهات المحلية (تذكيرات المهام)'**
  String get settingsNotificationsDesc;

  /// No description provided for @settingsReminderTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير الافتراضي'**
  String get settingsReminderTime;

  /// تذكير افتراضي قبل الموعد بالدقائق.
  ///
  /// In ar, this message translates to:
  /// **'قبل الموعد بـ {minutes} دقيقة'**
  String settingsReminderMinutes(int minutes);

  /// No description provided for @settingsRequestPermission.
  ///
  /// In ar, this message translates to:
  /// **'طلب صلاحية التنبيهات'**
  String get settingsRequestPermission;

  /// No description provided for @settingsRequestPermissionDesc.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد صلاحية التنبيهات على الأندرويد/IOS'**
  String get settingsRequestPermissionDesc;

  /// No description provided for @settingsPermissionGranted.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل صلاحية التنبيهات بنجاح'**
  String get settingsPermissionGranted;

  /// No description provided for @settingsPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلب الصلاحية'**
  String get settingsPermissionDenied;

  /// No description provided for @settingsEnable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get settingsEnable;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In ar, this message translates to:
  /// **'اختيار لغة الواجهات (الافتراضي: لغة الجهاز)'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (لغة الجهاز)'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSystemShort.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settingsLanguageSystemShort;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية (RTL)'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English (LTR)'**
  String get languageEnglish;

  /// No description provided for @syncSyncing.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة...'**
  String get syncSyncing;

  /// عدد التغييرات المحلية غير المزامنة.
  ///
  /// In ar, this message translates to:
  /// **'{count} معلق'**
  String syncPending(int count);

  /// No description provided for @syncSynced.
  ///
  /// In ar, this message translates to:
  /// **'متزامن'**
  String get syncSynced;

  /// No description provided for @signInToCloud.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول للسحابة'**
  String get signInToCloud;

  /// No description provided for @toggleThemeShort.
  ///
  /// In ar, this message translates to:
  /// **'تبديل'**
  String get toggleThemeShort;

  /// No description provided for @directionTitle.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه الواجهة والسايد بار'**
  String get directionTitle;

  /// No description provided for @directionDesc.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء القائمة الجانبية على اليسار دائماً بغض النظر عن اللغة'**
  String get directionDesc;

  /// No description provided for @directionLtr.
  ///
  /// In ar, this message translates to:
  /// **'يسار دائماً'**
  String get directionLtr;

  /// No description provided for @directionAuto.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (يتبع اللغة)'**
  String get directionAuto;

  /// No description provided for @settingsCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة الافتراضية'**
  String get settingsCurrency;

  /// وصف العملة الافتراضية الحالية.
  ///
  /// In ar, this message translates to:
  /// **'العملة المستخدمة في السجلات المالية الجديدة: {currency}'**
  String settingsCurrencyDesc(String currency);

  /// No description provided for @settingsViewMode.
  ///
  /// In ar, this message translates to:
  /// **'طريقة العرض'**
  String get settingsViewMode;

  /// No description provided for @viewModeList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة'**
  String get viewModeList;

  /// No description provided for @viewModeKanban.
  ///
  /// In ar, this message translates to:
  /// **'كانبان'**
  String get viewModeKanban;

  /// No description provided for @themeModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وضع المظهر'**
  String get themeModeLabel;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'نهاري'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get themeDark;

  /// No description provided for @themeOled.
  ///
  /// In ar, this message translates to:
  /// **'OLED'**
  String get themeOled;

  /// No description provided for @themeLightFull.
  ///
  /// In ar, this message translates to:
  /// **'الوضع النهاري (Light)'**
  String get themeLightFull;

  /// No description provided for @themeDarkFull.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي (Dark)'**
  String get themeDarkFull;

  /// No description provided for @themeOledFull.
  ///
  /// In ar, this message translates to:
  /// **'السواد العميق (OLED)'**
  String get themeOledFull;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// رقم إصدار التطبيق الحالي.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionLabel(String version);

  /// No description provided for @accountStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الحساب'**
  String get accountStatus;

  /// حالة تسجيل الدخول مع البريد.
  ///
  /// In ar, this message translates to:
  /// **'مسجل الدخول: {email}'**
  String signedInAs(String email);

  /// No description provided for @signedOut.
  ///
  /// In ar, this message translates to:
  /// **'غير مسجل الدخول'**
  String get signedOut;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileTitle;

  /// No description provided for @profileDisplayName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم المعروض'**
  String get profileDisplayName;

  /// No description provided for @profileEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get profileEmail;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get navHome;

  /// No description provided for @navProjects.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع'**
  String get navProjects;

  /// No description provided for @navNotes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get navNotes;

  /// No description provided for @navFinance.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get navFinance;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @newTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة جديدة'**
  String get newTask;

  /// No description provided for @preview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة'**
  String get preview;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get signOut;

  /// No description provided for @taskyUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم Tasky'**
  String get taskyUser;

  /// No description provided for @closeSearch.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق البحث'**
  String get closeSearch;

  /// No description provided for @sidebarMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة الجانبية'**
  String get sidebarMenu;

  /// No description provided for @viewList.
  ///
  /// In ar, this message translates to:
  /// **'عرض القوائم'**
  String get viewList;

  /// No description provided for @viewKanban.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكانبان'**
  String get viewKanban;

  /// No description provided for @viewTable.
  ///
  /// In ar, this message translates to:
  /// **'عرض الجدول'**
  String get viewTable;

  /// No description provided for @exportCsvTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تصدير المهام إلى CSV / Excel'**
  String get exportCsvTooltip;

  /// No description provided for @exportCsvCurrentTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تصدير المهام الحالية إلى CSV / Excel'**
  String get exportCsvCurrentTooltip;

  /// No description provided for @globalSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث شامل'**
  String get globalSearch;

  /// No description provided for @globalSearchInApp.
  ///
  /// In ar, this message translates to:
  /// **'بحث شامل في كل التطبيق'**
  String get globalSearchInApp;

  /// No description provided for @cancelGlobalSearch.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء البحث الشامل'**
  String get cancelGlobalSearch;

  /// No description provided for @cancelGlobalShort.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الشامل'**
  String get cancelGlobalShort;

  /// No description provided for @filterToday.
  ///
  /// In ar, this message translates to:
  /// **'☀️ مهام اليوم'**
  String get filterToday;

  /// No description provided for @filterUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'📅 المهام القادمة'**
  String get filterUpcoming;

  /// No description provided for @filterWaiting.
  ///
  /// In ar, this message translates to:
  /// **'⏳ المهام المعلّقة (Waiting)'**
  String get filterWaiting;

  /// No description provided for @filterUrgent.
  ///
  /// In ar, this message translates to:
  /// **'🔥 المهام العاجلة (Urgent)'**
  String get filterUrgent;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'📋 جميع المهام'**
  String get filterAll;

  /// No description provided for @contextTitleNotes.
  ///
  /// In ar, this message translates to:
  /// **'📚 الملاحظات ومستودع المعرفة (Knowledge Vault)'**
  String get contextTitleNotes;

  /// No description provided for @contextTitleFinance.
  ///
  /// In ar, this message translates to:
  /// **'💰 السجل المالي والتسويات'**
  String get contextTitleFinance;

  /// No description provided for @contextTitleArchive.
  ///
  /// In ar, this message translates to:
  /// **'🗄️ الأرشيف العام (Global Archive)'**
  String get contextTitleArchive;

  /// No description provided for @contextTitleTrash.
  ///
  /// In ar, this message translates to:
  /// **'🗑️ سلة المهملات (Trash Bin)'**
  String get contextTitleTrash;

  /// No description provided for @contextTitleSharedProject.
  ///
  /// In ar, this message translates to:
  /// **'💼 مشروع مشترك'**
  String get contextTitleSharedProject;

  /// No description provided for @contextTitleSharedArea.
  ///
  /// In ar, this message translates to:
  /// **'📁 مجال مشترك'**
  String get contextTitleSharedArea;

  /// عنوان شريط الرأس عند تصفية مهمة حسب وسم.
  ///
  /// In ar, this message translates to:
  /// **'🏷️ وسم: {name}'**
  String contextTitleTag(String name);

  /// No description provided for @searchHintTasks.
  ///
  /// In ar, this message translates to:
  /// **'بحث في المهام...'**
  String get searchHintTasks;

  /// No description provided for @searchHintGlobal.
  ///
  /// In ar, this message translates to:
  /// **'بحث شامل في كل المجالات والمشاريع...'**
  String get searchHintGlobal;

  /// تلميح البحث داخل مشروع محدد.
  ///
  /// In ar, this message translates to:
  /// **'بحث في مشروع ({title})...'**
  String searchHintProject(String title);

  /// تلميح البحث داخل مجال محدد.
  ///
  /// In ar, this message translates to:
  /// **'بحث في مجال ({title})...'**
  String searchHintArea(String title);

  /// No description provided for @exportEmptyToast.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام لتصديرها في العرض الحالي'**
  String get exportEmptyToast;

  /// رسالة نجاح تصدير المهام إلى الحافظة.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير {count} مهمة ونسخ CSV إلى الحافظة بنجاح!'**
  String exportSuccessToast(int count);

  /// No description provided for @quickAddHint.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة سريعة...'**
  String get quickAddHint;

  /// No description provided for @smartFiltersHeader.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر السريعة'**
  String get smartFiltersHeader;

  /// No description provided for @smartFilterToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get smartFilterToday;

  /// No description provided for @smartFilterUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get smartFilterUpcoming;

  /// No description provided for @smartFilterWaiting.
  ///
  /// In ar, this message translates to:
  /// **'معلّقة (Waiting)'**
  String get smartFilterWaiting;

  /// No description provided for @smartFilterUrgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجل (Urgent)'**
  String get smartFilterUrgent;

  /// No description provided for @smartFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'جميع المهام'**
  String get smartFilterAll;

  /// No description provided for @areasProjectsSection.
  ///
  /// In ar, this message translates to:
  /// **'المجالات والمشاريع'**
  String get areasProjectsSection;

  /// No description provided for @addNewAreaTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مجال جديد'**
  String get addNewAreaTooltip;

  /// No description provided for @newProjectEllipsis.
  ///
  /// In ar, this message translates to:
  /// **'مشروع جديد...'**
  String get newProjectEllipsis;

  /// No description provided for @tagsSection.
  ///
  /// In ar, this message translates to:
  /// **'الوسوم والتصنيفات'**
  String get tagsSection;

  /// No description provided for @createTagTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء وسم جديد'**
  String get createTagTooltip;

  /// No description provided for @noTagsAdded.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وسوم مضافة'**
  String get noTagsAdded;

  /// No description provided for @sharedWithMeHeader.
  ///
  /// In ar, this message translates to:
  /// **'مشارك معي (Shared)'**
  String get sharedWithMeHeader;

  /// No description provided for @refreshSharedTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الكيانات المشتركة'**
  String get refreshSharedTooltip;

  /// No description provided for @sharedEntityDefault.
  ///
  /// In ar, this message translates to:
  /// **'عنصر مشترك'**
  String get sharedEntityDefault;

  /// No description provided for @permissionAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول'**
  String get permissionAdmin;

  /// No description provided for @permissionEditor.
  ///
  /// In ar, this message translates to:
  /// **'محرر'**
  String get permissionEditor;

  /// No description provided for @permissionViewer.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدة'**
  String get permissionViewer;

  /// No description provided for @sidebarNotesSection.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات والمعرفة (Vault)'**
  String get sidebarNotesSection;

  /// No description provided for @sidebarNotesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات ومستودع المعرفة'**
  String get sidebarNotesTitle;

  /// No description provided for @sidebarFinanceSection.
  ///
  /// In ar, this message translates to:
  /// **'الماليات والتسويات'**
  String get sidebarFinanceSection;

  /// No description provided for @sidebarFinanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'السجل المالي والتسويات'**
  String get sidebarFinanceTitle;

  /// No description provided for @sidebarArchiveSection.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف والمهملات'**
  String get sidebarArchiveSection;

  /// No description provided for @sidebarArchiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف العام'**
  String get sidebarArchiveTitle;

  /// No description provided for @sidebarTrashTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلة المهملات'**
  String get sidebarTrashTitle;

  /// No description provided for @attachmentSyncing.
  ///
  /// In ar, this message translates to:
  /// **'⏳ قيد المزامنة'**
  String get attachmentSyncing;

  /// No description provided for @reminderNote.
  ///
  /// In ar, this message translates to:
  /// **'⚠️ (تذكير)'**
  String get reminderNote;

  /// No description provided for @chipPendingInvoice.
  ///
  /// In ar, this message translates to:
  /// **'⚠️ بانتظار الفاتورة'**
  String get chipPendingInvoice;

  /// No description provided for @invoicePendingTap.
  ///
  /// In ar, this message translates to:
  /// **'⚠️ بانتظار الفاتورة (اضغط للاستلام)'**
  String get invoicePendingTap;

  /// No description provided for @attachmentSynced.
  ///
  /// In ar, this message translates to:
  /// **'✓ مزامن'**
  String get attachmentSynced;

  /// No description provided for @paidPersonalFromWork.
  ///
  /// In ar, this message translates to:
  /// **'🏠 دفعت شخصي من حساب الشغل (عليّ للشغل)'**
  String get paidPersonalFromWork;

  /// No description provided for @chipPaidToWork.
  ///
  /// In ar, this message translates to:
  /// **'🏠 مدفوع للشغل'**
  String get chipPaidToWork;

  /// No description provided for @paidFromPocket.
  ///
  /// In ar, this message translates to:
  /// **'💼 دفعت للشغل من جيبي (لي عند الشغل)'**
  String get paidFromPocket;

  /// No description provided for @chipDueFromWork.
  ///
  /// In ar, this message translates to:
  /// **'💼 مستحق من الشغل'**
  String get chipDueFromWork;

  /// No description provided for @chipTransfers.
  ///
  /// In ar, this message translates to:
  /// **'🔄 تحويلات'**
  String get chipTransfers;

  /// No description provided for @sharedPublicTitle.
  ///
  /// In ar, this message translates to:
  /// **'TaskyW — مشاركة عامة'**
  String get sharedPublicTitle;

  /// No description provided for @enterNewName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الجديد'**
  String get enterNewName;

  /// No description provided for @descriptionNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تفاصيل وملاحظات أو أرقام قطع الغيار...'**
  String get descriptionNotesHint;

  /// No description provided for @archiveAction.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة'**
  String get archiveAction;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعياً'**
  String get recurrenceWeekly;

  /// No description provided for @pasteEmojiHint.
  ///
  /// In ar, this message translates to:
  /// **'ألصق إيموجي (مثال: 🤖) أو كوده (U+1F680)'**
  String get pasteEmojiHint;

  /// No description provided for @enterHexCode.
  ///
  /// In ar, this message translates to:
  /// **'أو أدخل كود HEX مخصص:'**
  String get enterHexCode;

  /// No description provided for @orCreateTag.
  ///
  /// In ar, this message translates to:
  /// **'أو إنشاء وسم جديد:'**
  String get orCreateTag;

  /// No description provided for @trashTasksEmptyDesc.
  ///
  /// In ar, this message translates to:
  /// **'أي مهمة يتم حذفها ستُحفظ هنا ويمكن استعادتها بأي وقت.'**
  String get trashTasksEmptyDesc;

  /// No description provided for @quickEmojis.
  ///
  /// In ar, this message translates to:
  /// **'أيقونات مقترحة سريعة:'**
  String get quickEmojis;

  /// No description provided for @customEmojiInput.
  ///
  /// In ar, this message translates to:
  /// **'إدخال مخصص (لصق إيموجي أو كود U+...):'**
  String get customEmojiInput;

  /// No description provided for @projectNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات هذا المشروع'**
  String get projectNotifications;

  /// No description provided for @createTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المهمة'**
  String get createTask;

  /// No description provided for @addStepHint.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خطوة فرعية جديدة...'**
  String get addStepHint;

  /// No description provided for @addNewAreaTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مجال مسؤولية جديد'**
  String get addNewAreaTitle;

  /// No description provided for @addAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مرفق'**
  String get addAttachment;

  /// No description provided for @addNewProjectTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مشروع جديد'**
  String get addNewProjectTitle;

  /// No description provided for @addNewTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة جديدة'**
  String get addNewTaskTitle;

  /// No description provided for @addGeneralTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة عامة'**
  String get addGeneralTask;

  /// No description provided for @addTaskInProject.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة في المشروع'**
  String get addTaskInProject;

  /// No description provided for @kanbanAddInColumn.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهمة في هذا العمود'**
  String get kanbanAddInColumn;

  /// No description provided for @addTag.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وسم'**
  String get addTag;

  /// No description provided for @addTagForTask.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وسم للمهمة'**
  String get addTagForTask;

  /// No description provided for @retryAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retryAction;

  /// No description provided for @emptyTrash.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ السلة'**
  String get emptyTrash;

  /// No description provided for @emptyTrashConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ السلة نهائياً'**
  String get emptyTrashConfirmAction;

  /// No description provided for @emptyTrashConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ سلة المهملات بالكامل؟'**
  String get emptyTrashConfirmTitle;

  /// No description provided for @unarchive.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الأرشفة'**
  String get unarchive;

  /// No description provided for @unpinNote.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التثبيت'**
  String get unpinNote;

  /// No description provided for @toAccount.
  ///
  /// In ar, this message translates to:
  /// **'إلى حساب'**
  String get toAccount;

  /// No description provided for @markDone.
  ///
  /// In ar, this message translates to:
  /// **'إنجاز'**
  String get markDone;

  /// No description provided for @createAction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get createAction;

  /// No description provided for @createArea.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء المجال'**
  String get createArea;

  /// No description provided for @createProject.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء المشروع'**
  String get createProject;

  /// No description provided for @createAndAttachTag.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء وإضافة الوسم'**
  String get createAndAttachTag;

  /// No description provided for @createNewTag.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء وسم جديد'**
  String get createNewTag;

  /// No description provided for @startAddingTasks.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة مهمة جديدة لمتابعة إنجازك اليومي'**
  String get startAddingTasks;

  /// No description provided for @chooseIconTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر أيقونة معبرة'**
  String get chooseIconTitle;

  /// No description provided for @chooseTagColor.
  ///
  /// In ar, this message translates to:
  /// **'اختر لون الوسم:'**
  String get chooseTagColor;

  /// No description provided for @chooseCustomColor.
  ///
  /// In ar, this message translates to:
  /// **'اختر لوناً مخصصاً'**
  String get chooseCustomColor;

  /// No description provided for @choose.
  ///
  /// In ar, this message translates to:
  /// **'اختيار'**
  String get choose;

  /// No description provided for @restoreAction.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get restoreAction;

  /// No description provided for @restoreProject.
  ///
  /// In ar, this message translates to:
  /// **'استعادة المشروع'**
  String get restoreProject;

  /// No description provided for @restoreNote.
  ///
  /// In ar, this message translates to:
  /// **'استعادة الملاحظة'**
  String get restoreNote;

  /// No description provided for @restoreTask.
  ///
  /// In ar, this message translates to:
  /// **'استعادة المهمة'**
  String get restoreTask;

  /// No description provided for @archiveRestoreToActive.
  ///
  /// In ar, this message translates to:
  /// **'استعادة للأعمال النشطة'**
  String get archiveRestoreToActive;

  /// No description provided for @kanbanDropHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب المهام إلى هنا أو أضف مهمة جديدة'**
  String get kanbanDropHint;

  /// No description provided for @areaName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجال'**
  String get areaName;

  /// No description provided for @projectName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المشروع'**
  String get projectName;

  /// No description provided for @tagName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الوسم'**
  String get tagName;

  /// No description provided for @newTagNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الوسم (مثلاً: عاجل، قطع_غيار...)'**
  String get newTagNameHint;

  /// No description provided for @notesEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط + لإضافة أول ملاحظة...'**
  String get notesEmptyHint;

  /// No description provided for @noteContentHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب أفكارك ومراجعك هنا...'**
  String get noteContentHint;

  /// No description provided for @archiveGlobalTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف العام (Global Archive)'**
  String get archiveGlobalTitle;

  /// No description provided for @suggestedColors.
  ///
  /// In ar, this message translates to:
  /// **'الألوان المقترحة:'**
  String get suggestedColors;

  /// No description provided for @priorityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية'**
  String get priorityLabel;

  /// No description provided for @priorityColon.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية:'**
  String get priorityColon;

  /// No description provided for @trashSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث في سلة المهملات...'**
  String get trashSearchHint;

  /// No description provided for @archiveSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث في عناصر الأرشيف...'**
  String get archiveSearchHint;

  /// No description provided for @bankOption.
  ///
  /// In ar, this message translates to:
  /// **'البنك'**
  String get bankOption;

  /// No description provided for @toAccountHint.
  ///
  /// In ar, this message translates to:
  /// **'البنك، المحفظة...'**
  String get toAccountHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In ar, this message translates to:
  /// **'البيان *'**
  String get descriptionLabel;

  /// No description provided for @recurrenceColon.
  ///
  /// In ar, this message translates to:
  /// **'التكرار:'**
  String get recurrenceColon;

  /// No description provided for @reminderColon.
  ///
  /// In ar, this message translates to:
  /// **'التنبيه:'**
  String get reminderColon;

  /// No description provided for @emojiCategoryStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالات والتنبيه'**
  String get emojiCategoryStatus;

  /// No description provided for @statusLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get statusLabel;

  /// No description provided for @statusColon.
  ///
  /// In ar, this message translates to:
  /// **'الحالة:'**
  String get statusColon;

  /// No description provided for @deadlineColon.
  ///
  /// In ar, this message translates to:
  /// **'الديدلاين:'**
  String get deadlineColon;

  /// No description provided for @invalidShareLink.
  ///
  /// In ar, this message translates to:
  /// **'الرابط غير صالح أو انتهت صلاحية المشاركة.'**
  String get invalidShareLink;

  /// No description provided for @linkUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الرابط غير متوفر'**
  String get linkUnavailable;

  /// No description provided for @emojiCategoryPersonal.
  ///
  /// In ar, this message translates to:
  /// **'الشخصية والمنزل'**
  String get emojiCategoryPersonal;

  /// No description provided for @emojiCategoryWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل والمشاريع'**
  String get emojiCategoryWork;

  /// No description provided for @trashSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'العناصر المحذوفة مؤقتاً، يمكنك استعادتها أو حذفها نهائياً لتفريغ المساحة'**
  String get trashSubtitle;

  /// No description provided for @noteTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get noteTitle;

  /// No description provided for @allFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allFilter;

  /// No description provided for @colorLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get colorLabel;

  /// No description provided for @colorColon.
  ///
  /// In ar, this message translates to:
  /// **'اللون: '**
  String get colorColon;

  /// No description provided for @amountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ (SAR) *'**
  String get amountLabel;

  /// No description provided for @pinnedNotes.
  ///
  /// In ar, this message translates to:
  /// **'المثبتة'**
  String get pinnedNotes;

  /// No description provided for @areaLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجال'**
  String get areaLabel;

  /// No description provided for @areaProjectColumn.
  ///
  /// In ar, this message translates to:
  /// **'المجال / المشروع'**
  String get areaProjectColumn;

  /// No description provided for @areaColon.
  ///
  /// In ar, this message translates to:
  /// **'المجال:'**
  String get areaColon;

  /// No description provided for @noteContent.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى'**
  String get noteContent;

  /// No description provided for @notesScreenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'المستودع المعرفي والمساحة الهادئة للأفكار، المراجع، الروابط وجهات الاتصال دون مواعيد أو قيود مهام.'**
  String get notesScreenSubtitle;

  /// No description provided for @areaProjects.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع التابعة للمجال'**
  String get areaProjects;

  /// No description provided for @trashProjectsEmptyDesc.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع المحذوفة تظهر هنا لحين استعادتها أو مسحها نهائياً.'**
  String get trashProjectsEmptyDesc;

  /// No description provided for @archiveProjectsEmptyDesc.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع المنتهية أو المؤرشفة ستظهر هنا للحفظ المرجعي.'**
  String get archiveProjectsEmptyDesc;

  /// No description provided for @projectLabel.
  ///
  /// In ar, this message translates to:
  /// **'المشروع'**
  String get projectLabel;

  /// No description provided for @projectColon.
  ///
  /// In ar, this message translates to:
  /// **'المشروع:'**
  String get projectColon;

  /// No description provided for @trashNotesEmptyDesc.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات المحذوفة ناعماً تظهر هنا.'**
  String get trashNotesEmptyDesc;

  /// No description provided for @notesScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات ومستودع المعرفة (Knowledge Vault)'**
  String get notesScreenTitle;

  /// No description provided for @attachmentNotSynced.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير مرفوع بعد؛ سيتوفر التنزيل بعد المزامنة'**
  String get attachmentNotSynced;

  /// No description provided for @subtasksColumn.
  ///
  /// In ar, this message translates to:
  /// **'المهام الفرعية'**
  String get subtasksColumn;

  /// No description provided for @subtasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهام الفرعية (Checklist)'**
  String get subtasksTitle;

  /// No description provided for @completedTasksSection.
  ///
  /// In ar, this message translates to:
  /// **'المهام المكتملة (Completed Tasks)'**
  String get completedTasksSection;

  /// No description provided for @archiveGlobalSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'المهام والمشاريع والملاحظات المنتهية المحفوظة للرجوع إليها دون تشويش مساحات العمل اليومية'**
  String get archiveGlobalSubtitle;

  /// No description provided for @patternColon.
  ///
  /// In ar, this message translates to:
  /// **'النمط:'**
  String get patternColon;

  /// No description provided for @emojiCategoryTools.
  ///
  /// In ar, this message translates to:
  /// **'الهندسة والأدوات'**
  String get emojiCategoryTools;

  /// No description provided for @tagsColumn.
  ///
  /// In ar, this message translates to:
  /// **'الوسوم'**
  String get tagsColumn;

  /// No description provided for @availableTags.
  ///
  /// In ar, this message translates to:
  /// **'الوسوم المتاحة:'**
  String get availableTags;

  /// No description provided for @tagsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوسوم والتصنيفات (Tags)'**
  String get tagsTitle;

  /// No description provided for @descriptionNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوصف والملاحظات:'**
  String get descriptionNotesLabel;

  /// No description provided for @financeSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في العمليات، الحسابات، الملاحظات...'**
  String get financeSearchHint;

  /// No description provided for @notesSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث لحظي في العناوين والمحتوى...'**
  String get notesSearchHint;

  /// No description provided for @noEndDate.
  ///
  /// In ar, this message translates to:
  /// **'بدون تاريخ انتهاء (مستمر)'**
  String get noEndDate;

  /// No description provided for @untitled.
  ///
  /// In ar, this message translates to:
  /// **'بدون عنوان'**
  String get untitled;

  /// No description provided for @noProject.
  ///
  /// In ar, this message translates to:
  /// **'بدون مشروع'**
  String get noProject;

  /// No description provided for @noProjectGeneral.
  ///
  /// In ar, this message translates to:
  /// **'بدون مشروع (مهمة عامة)'**
  String get noProjectGeneral;

  /// No description provided for @exportedCsvData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات CSV المُصدّرة'**
  String get exportedCsvData;

  /// No description provided for @confirmChoice.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاختيار'**
  String get confirmChoice;

  /// No description provided for @dueDateColumn.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get dueDateColumn;

  /// No description provided for @dueDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسليم'**
  String get dueDateLabel;

  /// No description provided for @pinNote.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت'**
  String get pinNote;

  /// No description provided for @groupByProject.
  ///
  /// In ar, this message translates to:
  /// **'تجميع بحسب المشروع'**
  String get groupByProject;

  /// No description provided for @archiveRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الأرشيف'**
  String get archiveRefresh;

  /// No description provided for @refreshTrash.
  ///
  /// In ar, this message translates to:
  /// **'تحديث السلة'**
  String get refreshTrash;

  /// No description provided for @transferOption.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get transferOption;

  /// No description provided for @customizeTaskColor.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص لون للمهمة'**
  String get customizeTaskColor;

  /// No description provided for @undoAction.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undoAction;

  /// No description provided for @registerTransaction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل العملية'**
  String get registerTransaction;

  /// No description provided for @newTransactionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل عملية مالية جديدة'**
  String get newTransactionTitle;

  /// No description provided for @settlementLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسوية حساب الشغل والشخصي:'**
  String get settlementLabel;

  /// No description provided for @exportStatement.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كشف الحساب إلى Excel / CSV'**
  String get exportStatement;

  /// No description provided for @pendingInvoiceReminder.
  ///
  /// In ar, this message translates to:
  /// **'تظل معلقة حتى تستلم الفاتورة لتتذكر المطالبة بها'**
  String get pendingInvoiceReminder;

  /// No description provided for @editLabel.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editLabel;

  /// No description provided for @editName.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم'**
  String get editName;

  /// No description provided for @editTransactionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العملية المالية'**
  String get editTransactionTitle;

  /// No description provided for @editArea.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المجال'**
  String get editArea;

  /// No description provided for @editProject.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المشروع'**
  String get editProject;

  /// No description provided for @editNote.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملاحظة'**
  String get editNote;

  /// No description provided for @editAreaData.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات المجال'**
  String get editAreaData;

  /// No description provided for @editProjectData.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات المشروع'**
  String get editProjectData;

  /// No description provided for @syncFailedTapRetry.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالسحابة. اضغط للمحاولة مجدداً.'**
  String get syncFailedTapRetry;

  /// No description provided for @invalidEmojiCode.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التعرف على كود الإيموجي'**
  String get invalidEmojiCode;

  /// No description provided for @attachSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ المرفق'**
  String get attachSaveError;

  /// No description provided for @openFileError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الملف'**
  String get openFileError;

  /// No description provided for @setDateHint.
  ///
  /// In ar, this message translates to:
  /// **'تعيين موعد...'**
  String get setDateHint;

  /// No description provided for @taskDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المهمة'**
  String get taskDetails;

  /// No description provided for @enableProjectNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل إشعارات هذا Projekt'**
  String get enableProjectNotifications;

  /// No description provided for @projectNotificationsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التذكيرات المحلية لمهام هذا المشروع'**
  String get projectNotificationsDesc;

  /// No description provided for @trashEmptiedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم إفراغ سلة المهملات بنجاح'**
  String get trashEmptiedToast;

  /// No description provided for @allDoneSection.
  ///
  /// In ar, this message translates to:
  /// **'تم إنجاز كل المهام في هذا القسم 🎉'**
  String get allDoneSection;

  /// No description provided for @invoiceReceivedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الفاتورة وتحديث الحالة لمكتملة ✅'**
  String get invoiceReceivedToast;

  /// No description provided for @nameUpdatedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الاسم بنجاح'**
  String get nameUpdatedToast;

  /// No description provided for @projectNotifEnabledToast.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل إشعارات المشروع'**
  String get projectNotifEnabledToast;

  /// No description provided for @projectDeletedPermanentToast.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المشروع نهائياً'**
  String get projectDeletedPermanentToast;

  /// No description provided for @taskDeletedPermanentToast.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المهمة نهائياً'**
  String get taskDeletedPermanentToast;

  /// No description provided for @projectNotifMutedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم كتم إشعارات المشروع'**
  String get projectNotifMutedToast;

  /// No description provided for @settledToast.
  ///
  /// In ar, this message translates to:
  /// **'تمت التسوية ✔️'**
  String get settledToast;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري التنفيذ'**
  String get statusInProgress;

  /// No description provided for @syncInProgressNow.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة مع السحابة الآن...'**
  String get syncInProgressNow;

  /// No description provided for @syncingNow.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة...'**
  String get syncingNow;

  /// No description provided for @loadingSharedItem.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل العنصر المشترك...'**
  String get loadingSharedItem;

  /// No description provided for @syncUploading.
  ///
  /// In ar, this message translates to:
  /// **'جاري رفع التعديلات السحابية...'**
  String get syncUploading;

  /// No description provided for @syncChecking.
  ///
  /// In ar, this message translates to:
  /// **'جاري فحص وتحديث البيانات مع السحابة...'**
  String get syncChecking;

  /// No description provided for @tryOtherKeywords.
  ///
  /// In ar, this message translates to:
  /// **'جرّب البحث بكلمات أخرى.'**
  String get tryOtherKeywords;

  /// No description provided for @syncAllSynced.
  ///
  /// In ar, this message translates to:
  /// **'جميع بياناتك متزامنة مع السحابة'**
  String get syncAllSynced;

  /// No description provided for @cloudStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة السحابة'**
  String get cloudStatus;

  /// No description provided for @projectStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة المشروع'**
  String get projectStatus;

  /// No description provided for @shareLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل البيانات. يرجى المحاولة مرة أخرى.'**
  String get shareLoadError;

  /// No description provided for @deleteStep.
  ///
  /// In ar, this message translates to:
  /// **'حذف الخطوة'**
  String get deleteStep;

  /// No description provided for @deleteTransaction.
  ///
  /// In ar, this message translates to:
  /// **'حذف العملية المالية'**
  String get deleteTransaction;

  /// No description provided for @deleteArea.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجال'**
  String get deleteArea;

  /// No description provided for @deleteAreaFully.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجال بالكامل'**
  String get deleteAreaFully;

  /// No description provided for @deleteAttachment.
  ///
  /// In ar, this message translates to:
  /// **'حذف المرفق'**
  String get deleteAttachment;

  /// No description provided for @deleteProject.
  ///
  /// In ar, this message translates to:
  /// **'حذف المشروع'**
  String get deleteProject;

  /// No description provided for @deleteProjectPermanentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف المشروع نهائياً؟'**
  String get deleteProjectPermanentConfirm;

  /// No description provided for @deleteNote.
  ///
  /// In ar, this message translates to:
  /// **'حذف الملاحظة'**
  String get deleteNote;

  /// No description provided for @deleteTask.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة'**
  String get deleteTask;

  /// No description provided for @deleteSubtask.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة الفرعية'**
  String get deleteSubtask;

  /// No description provided for @deleteTaskPermanentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة نهائياً؟'**
  String get deleteTaskPermanentConfirm;

  /// No description provided for @deletePermanent.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائي'**
  String get deletePermanent;

  /// No description provided for @saveEdit.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديل'**
  String get saveEdit;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @incomeRefundOption.
  ///
  /// In ar, this message translates to:
  /// **'دخل/استرداد'**
  String get incomeRefundOption;

  /// No description provided for @notesHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإيصال، اسم المورد، تفاصيل...'**
  String get notesHint;

  /// No description provided for @trashProjectsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'سلة المشاريع فارغة'**
  String get trashProjectsEmpty;

  /// No description provided for @trashNotesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'سلة الملاحظات فارغة'**
  String get trashNotesEmpty;

  /// No description provided for @trashTasksEmpty.
  ///
  /// In ar, this message translates to:
  /// **'سلة المهام فارغة'**
  String get trashTasksEmpty;

  /// No description provided for @trashTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلة المهملات (Trash Bin)'**
  String get trashTitle;

  /// No description provided for @emptyTrashConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف جميع المهام والمشاريع الموجودة في سلة المهملات نهائياً وبلا رجعة. هل تريد الاستمرار؟'**
  String get emptyTrashConfirmBody;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In ar, this message translates to:
  /// **'شهرياً'**
  String get recurrenceMonthly;

  /// No description provided for @setReminderHint.
  ///
  /// In ar, this message translates to:
  /// **'ضبط تذكير...'**
  String get setReminderHint;

  /// No description provided for @priorityCritical.
  ///
  /// In ar, this message translates to:
  /// **'عاجل جداً'**
  String get priorityCritical;

  /// No description provided for @priorityHigh.
  ///
  /// In ar, this message translates to:
  /// **'عالية'**
  String get priorityHigh;

  /// No description provided for @netYouOwe.
  ///
  /// In ar, this message translates to:
  /// **'عليك للشغل (صافي)'**
  String get netYouOwe;

  /// No description provided for @newTransaction.
  ///
  /// In ar, this message translates to:
  /// **'عملية جديدة'**
  String get newTransaction;

  /// No description provided for @normalTransaction.
  ///
  /// In ar, this message translates to:
  /// **'عملية عادية (لا تتطلب تسوية)'**
  String get normalTransaction;

  /// No description provided for @archiveTasksEmptyDesc.
  ///
  /// In ar, this message translates to:
  /// **'عند أرشفة أي مهمة ستظهر هنا للرجوع إليها مستقبلاً.'**
  String get archiveTasksEmptyDesc;

  /// No description provided for @noteTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الملاحظة...'**
  String get noteTitleHint;

  /// No description provided for @columnTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة'**
  String get columnTitle;

  /// No description provided for @taskTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة *'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleEditHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة...'**
  String get taskTitleEditHint;

  /// No description provided for @notSpecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSpecified;

  /// No description provided for @notSignedIn.
  ///
  /// In ar, this message translates to:
  /// **'غير مسجل الدخول'**
  String get notSignedIn;

  /// No description provided for @openAttachment.
  ///
  /// In ar, this message translates to:
  /// **'فتح / تنزيل المرفق'**
  String get openAttachment;

  /// No description provided for @pendingInvoices.
  ///
  /// In ar, this message translates to:
  /// **'فواتير معلقة'**
  String get pendingInvoices;

  /// No description provided for @statusWaiting.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get statusWaiting;

  /// No description provided for @cashOption.
  ///
  /// In ar, this message translates to:
  /// **'كاش'**
  String get cashOption;

  /// No description provided for @paymentMethodHint.
  ///
  /// In ar, this message translates to:
  /// **'كاش، CIB، فودافون كاش...'**
  String get paymentMethodHint;

  /// No description provided for @muteProjectNotifications.
  ///
  /// In ar, this message translates to:
  /// **'كتم إشعارات هذا المشروع'**
  String get muteProjectNotifications;

  /// No description provided for @exportedStatementCsv.
  ///
  /// In ar, this message translates to:
  /// **'كشف الحساب المُصدّر (CSV)'**
  String get exportedStatementCsv;

  /// No description provided for @financeEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أي عمليات مالية مسجلة بعد'**
  String get financeEmpty;

  /// No description provided for @attachmentsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرفقات بعد — يمكنك إرفاق مستندات وصور وملفات.'**
  String get attachmentsEmpty;

  /// No description provided for @archiveEmptyProjects.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشاريع مؤرشفة'**
  String get archiveEmptyProjects;

  /// No description provided for @areaNoProjects.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشاريع مضافة تحت هذا المجال بعد'**
  String get areaNoProjects;

  /// No description provided for @notesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات بعد'**
  String get notesEmpty;

  /// No description provided for @archiveEmptyNotes.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات مؤرشفة'**
  String get archiveEmptyNotes;

  /// No description provided for @areaNoGeneralTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام عامة خارج المشاريع لهذا المجال'**
  String get areaNoGeneralTasks;

  /// No description provided for @noTasksInSection.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام في هذا القسم حالياً'**
  String get noTasksInSection;

  /// No description provided for @tableEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام لعرضها في الجدول'**
  String get tableEmpty;

  /// No description provided for @archiveEmptyTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام مؤرشفة'**
  String get archiveEmptyTasks;

  /// No description provided for @noTasksRegistered.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام مسجلة حالياً'**
  String get noTasksRegistered;

  /// No description provided for @projectNoTasks.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام مضافة لهذا المشروع حتى الآن'**
  String get projectNoTasks;

  /// No description provided for @noMatchingResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get noMatchingResults;

  /// No description provided for @financeNoFilterMatch.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة للفلتر المحدد'**
  String get financeNoFilterMatch;

  /// No description provided for @noTagsForTask.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وسوم مرتبطة بهذه المهمة. اضغط \"إضافة وسم\" للتصنيف.'**
  String get noTagsForTask;

  /// No description provided for @paste.
  ///
  /// In ar, this message translates to:
  /// **'لصق'**
  String get paste;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In ar, this message translates to:
  /// **'لصق من الحافظة'**
  String get pasteFromClipboard;

  /// No description provided for @netOwedToYou.
  ///
  /// In ar, this message translates to:
  /// **'لك عند الشغل (صافي)'**
  String get netOwedToYou;

  /// No description provided for @readOnlyBadge.
  ///
  /// In ar, this message translates to:
  /// **'للقراءة فقط'**
  String get readOnlyBadge;

  /// No description provided for @notReceivedInvoice.
  ///
  /// In ar, this message translates to:
  /// **'لم أستلم الفاتورة بعد'**
  String get notReceivedInvoice;

  /// No description provided for @noFileSelected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم اختيار أي ملف'**
  String get noFileSelected;

  /// No description provided for @noteColor.
  ///
  /// In ar, this message translates to:
  /// **'لون الملاحظة'**
  String get noteColor;

  /// No description provided for @customTaskColor.
  ///
  /// In ar, this message translates to:
  /// **'لون مخصص للمهمة'**
  String get customTaskColor;

  /// No description provided for @taskTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي ترغب في إنجازه؟'**
  String get taskTitleHint;

  /// No description provided for @fullySynced.
  ///
  /// In ar, this message translates to:
  /// **'متزامن بالكامل'**
  String get fullySynced;

  /// No description provided for @recurrenceRecurring.
  ///
  /// In ar, this message translates to:
  /// **'متكررة'**
  String get recurrenceRecurring;

  /// No description provided for @priorityMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة'**
  String get priorityMedium;

  /// No description provided for @descriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: شراء قطع غيار، غداء عمل، تحويل عهدة...'**
  String get descriptionHint;

  /// No description provided for @tagNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: عاجل، قطع_غيار...'**
  String get tagNameHint;

  /// No description provided for @entityArea.
  ///
  /// In ar, this message translates to:
  /// **'مجال (Area)'**
  String get entityArea;

  /// No description provided for @statusReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get statusReview;

  /// No description provided for @syncNowButton.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة...'**
  String get syncNowButton;

  /// No description provided for @owedByYou.
  ///
  /// In ar, this message translates to:
  /// **'مستحق عليك للشغل ⏳'**
  String get owedByYou;

  /// No description provided for @shareAreaWithTeam.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة المجال مع الفريق'**
  String get shareAreaWithTeam;

  /// No description provided for @shareProjectWithTeam.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة المشروع مع الفريق'**
  String get shareProjectWithTeam;

  /// No description provided for @shareTaskWithTeam.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة المهمة مع الفريق برابط أو حساب'**
  String get shareTaskWithTeam;

  /// No description provided for @entityProject.
  ///
  /// In ar, this message translates to:
  /// **'مشروع (Project)'**
  String get entityProject;

  /// No description provided for @newProject.
  ///
  /// In ar, this message translates to:
  /// **'مشروع جديد'**
  String get newProject;

  /// No description provided for @expenseOption.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get expenseOption;

  /// No description provided for @reimbursementRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب استرداده من الشغل ⏳'**
  String get reimbursementRequired;

  /// No description provided for @generalTransaction.
  ///
  /// In ar, this message translates to:
  /// **'معاملة عامة'**
  String get generalTransaction;

  /// No description provided for @areaCompletionRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل إنجاز المجال العام:'**
  String get areaCompletionRate;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get disabled;

  /// No description provided for @projectStatusOnHold.
  ///
  /// In ar, this message translates to:
  /// **'معلّق مؤقتاً (On Hold)'**
  String get projectStatusOnHold;

  /// No description provided for @statusOnHold.
  ///
  /// In ar, this message translates to:
  /// **'معلّقة'**
  String get statusOnHold;

  /// No description provided for @enabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get enabled;

  /// No description provided for @projectStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل (Completed)'**
  String get projectStatusCompleted;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get statusCompleted;

  /// No description provided for @notesListTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notesListTitle;

  /// No description provided for @taskNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات أو وصف (اختياري)'**
  String get taskNotesLabel;

  /// No description provided for @additionalNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية (اختياري)'**
  String get additionalNotes;

  /// No description provided for @archiveNotesEmptyDesc.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات المعرفة والتوثيق المؤرشفة تظهر هنا.'**
  String get archiveNotesEmptyDesc;

  /// No description provided for @newNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة جديدة'**
  String get newNote;

  /// No description provided for @chooseIconSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'من القائمة أو بلصق الإيموجي أو كود Unicode'**
  String get chooseIconSubtitle;

  /// No description provided for @fromAccount.
  ///
  /// In ar, this message translates to:
  /// **'من حساب'**
  String get fromAccount;

  /// No description provided for @priorityLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفضة'**
  String get priorityLow;

  /// No description provided for @areaGeneralTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهام عامة تابعة للمجال'**
  String get areaGeneralTasks;

  /// No description provided for @entityTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة (Task)'**
  String get entityTask;

  /// No description provided for @projectCompletionRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة إنجاز المشروع:'**
  String get projectCompletionRate;

  /// No description provided for @projectStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط (Active)'**
  String get projectStatusActive;

  /// No description provided for @yesDelete.
  ///
  /// In ar, this message translates to:
  /// **'نعم، حذف'**
  String get yesDelete;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'وسيلة الدفع / الحساب'**
  String get paymentMethodLabel;

  /// No description provided for @projectDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف المشروع (اختياري)'**
  String get projectDescription;

  /// No description provided for @syncOffline.
  ///
  /// In ar, this message translates to:
  /// **'وضع أوفلاين. يعمل التطبيق محلياً بالكامل.'**
  String get syncOffline;

  /// No description provided for @requireAreaFirst.
  ///
  /// In ar, this message translates to:
  /// **'يجب إنشاء مجال أولاً قبل إضافة المهام.'**
  String get requireAreaFirst;

  /// No description provided for @invalidTransactionMsg.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة البيان وتحديد مبلغ صحيح'**
  String get invalidTransactionMsg;

  /// No description provided for @endsAtColon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي في:'**
  String get endsAtColon;

  /// No description provided for @recurrenceDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومياً'**
  String get recurrenceDaily;

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'توجد {count} تعديلات محلية بانتظار الرفع. اضغط للمزامنة.'**
  String syncPendingTooltip(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المهمة \"{title}\"'**
  String taskDeletedToast(String title);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف الملف \"{fileName}\"؟'**
  String deleteFileConfirm(String fileName);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'الملف محفوظ محلياً: {url}'**
  String fileSavedLocal(String url);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'المرفقات ({count})'**
  String attachmentsCount(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في حذف المهمة \"{title}\"؟'**
  String deleteTaskConfirm(String title);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف الخطوة \"{title}\"؟'**
  String deleteStepConfirm(String title);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'المهام ({count})'**
  String tabsTasks(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع ({count})'**
  String tabsProjects(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات ({count})'**
  String tabsNotes(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة المهمة \"{title}\" بنجاح'**
  String restoredTaskToast(String title);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة المشروع \"{name}\" بنجاح'**
  String restoredProjectToast(String name);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة الملاحظة \"{title}\" بنجاح'**
  String restoredNoteToast(String title);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'لن تتمكن من استعادة المهمة \"{title}\" بعد الحذف النهائي.'**
  String cannotRestoreTaskMsg(String title);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'لن تتمكن من استعادة المشروع \"{name}\" بعد الحذف النهائي.'**
  String cannotRestoreProjectMsg(String name);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف \"{title}\"؟'**
  String deleteNoteConfirm(String title);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'مجال مسؤولية يضم {projects} مشاريع و {tasks} مهام'**
  String areaStats(int projects, int tasks);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'{done}/{total} مهام'**
  String taskCounter(int done, int total);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'{count} عاجلة'**
  String urgentCount(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% ({done}/{total} مكتملة)'**
  String projectProgress(int percent, int done, int total);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'{count} تعديل معلق'**
  String pendingChangesCount(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'الموعد: {date}'**
  String dueDateBadge(String date);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير {count} عملية ونسخ CSV إلى الحافظة!'**
  String financeExportToast(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'من {from} ⬅️ إلى {to}'**
  String transferFromTo(String from, String to);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'عبر: {account}'**
  String viaAccount(String account);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف عملية \"{title}\"؟'**
  String deleteTransactionConfirm(String title);

  /// No description provided for @yesNow.
  ///
  /// In ar, this message translates to:
  /// **'نعم، احذف'**
  String get yesNow;

  /// تأكيد حذف عنصر مع اسمه في Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في حذف مجال \"{name}\" وجميع المشاريع والمهام التابعة له؟ لا يمكن التراجع عن هذا الإجراء.'**
  String deleteAreaConfirm(String name);

  /// تأكيد حذف عنصر مع اسمه في Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في حذف مشروع \"{name}\" وجميع المهام التابعة له؟ لا يمكن التراجع عن هذا الإجراء.'**
  String deleteProjectConfirm(String name);

  /// No description provided for @syncPartialFail.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت المزامنة مع بعض الأخطاء'**
  String get syncPartialFail;

  /// No description provided for @syncAutoFail.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إتمام المزامنة التلقائية'**
  String get syncAutoFail;

  /// No description provided for @syncLoginRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب تسجيل الدخول لمزامنة البيانات'**
  String get syncLoginRequired;

  /// No description provided for @tagDefault.
  ///
  /// In ar, this message translates to:
  /// **'وسم'**
  String get tagDefault;

  /// No description provided for @currencySearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم الدولة، العملة، أو الرمز (SAR, EGP...)'**
  String get currencySearchHint;

  /// No description provided for @selectCurrencyTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار العملة الافتراضية'**
  String get selectCurrencyTitle;

  /// No description provided for @noCurrencyResult.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عملة تطابق بحثك'**
  String get noCurrencyResult;

  /// No description provided for @authResendActivation.
  ///
  /// In ar, this message translates to:
  /// **' إعادة إرسال رابط التفعيل الآن'**
  String get authResendActivation;

  /// No description provided for @shareRestrictedNotice.
  ///
  /// In ar, this message translates to:
  /// **'🔒 صلاحيتك الحالية (مشاهدة أو تحرير) لا تسمح بدعوة أعضاء أو تعديل صلاحياتهم. هذه الإجراءات متاحة فقط للمالك (Owner) أو المسؤول (Admin).'**
  String get shareRestrictedNotice;

  /// No description provided for @authResetEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك المسجل لإرسال رابط التعيين'**
  String get authResetEmailHint;

  /// No description provided for @authConfirmEmailResent.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رابط التفعيل مسبقاً. تفقّد صندوق الوارد وكذلك مجلد الرسائل غير المرغوب فيها (Spam / Junk).'**
  String get authConfirmEmailResent;

  /// No description provided for @shareTeamMembers.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء الفريق (بحساب)'**
  String get shareTeamMembers;

  /// No description provided for @authConfirmEmailAction.
  ///
  /// In ar, this message translates to:
  /// **'أكدت بريدي، تسجيل الدخول الآن'**
  String get authConfirmEmailAction;

  /// No description provided for @shareSecurityNote.
  ///
  /// In ar, this message translates to:
  /// **'أمان مضمون: الزائر عبر هذا الرابط لن يرى سوى هذا العنصر فقط، ولن يتمكن من تعديل أو حذف أي شيء إطلاقاً.'**
  String get shareSecurityNote;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك للنسخ الاحتياطي السحابي والمشاركة'**
  String get authSignUpSubtitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط الاستعادة'**
  String get authSendResetLink;

  /// No description provided for @authCreateAccountAction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get authCreateAccountAction;

  /// No description provided for @authCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get authCreateAccount;

  /// No description provided for @authGetStartedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ إدارة مشاريعك باحتراف'**
  String get authGetStartedSubtitle;

  /// No description provided for @authResetPassword.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get authResetPassword;

  /// No description provided for @authFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get authFullName;

  /// No description provided for @authEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authEmailLabel;

  /// No description provided for @shareInviteUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الدعوة غير متاحة لصلاحيتك'**
  String get shareInviteUnavailable;

  /// No description provided for @shareLinkDisabled.
  ///
  /// In ar, this message translates to:
  /// **'الرابط العام معطّل حالياً'**
  String get shareLinkDisabled;

  /// No description provided for @shareEntityElement.
  ///
  /// In ar, this message translates to:
  /// **'العنصر'**
  String get shareEntityElement;

  /// No description provided for @authContinueOffline.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة دون حساب (محلياً)'**
  String get authContinueOffline;

  /// No description provided for @shareEntityArea.
  ///
  /// In ar, this message translates to:
  /// **'المجال'**
  String get shareEntityArea;

  /// No description provided for @sharePublicLinkTitle.
  ///
  /// In ar, this message translates to:
  /// **'المشاركة عبر رابط عام'**
  String get sharePublicLinkTitle;

  /// No description provided for @shareEntityProject.
  ///
  /// In ar, this message translates to:
  /// **'المشروع'**
  String get shareEntityProject;

  /// No description provided for @shareEntityTask.
  ///
  /// In ar, this message translates to:
  /// **'المهمة'**
  String get shareEntityTask;

  /// No description provided for @authEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'بريد إلكتروني غير صحيح'**
  String get authEmailInvalid;

  /// No description provided for @authConfirmEmailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد البريد الإلكتروني'**
  String get authConfirmEmailTitle;

  /// No description provided for @authConfirmAccount.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحساب'**
  String get authConfirmAccount;

  /// No description provided for @authConfirmRequired.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحساب مطلوب لتسجيل الدخول'**
  String get authConfirmRequired;

  /// No description provided for @shareRevokeConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد السحب'**
  String get shareRevokeConfirmTitle;

  /// No description provided for @shareFullAccessBadge.
  ///
  /// In ar, this message translates to:
  /// **'تحكم كامل 🗑️'**
  String get shareFullAccessBadge;

  /// No description provided for @authSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authSignIn;

  /// No description provided for @authChangeEmail.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البريد الإلكتروني أو المحاولة بحساب آخر'**
  String get authChangeEmail;

  /// No description provided for @shareInviteError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال الدعوة'**
  String get shareInviteError;

  /// No description provided for @shareLinkCreationError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء الرابط العام، تأكد من تسجيل الدخول والمزامنة.'**
  String get shareLinkCreationError;

  /// No description provided for @sharePermissionUpdateError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث الصلاحية، يرجى المحاولة لاحقاً'**
  String get sharePermissionUpdateError;

  /// No description provided for @shareRevokeError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر سحب الصلاحية'**
  String get shareRevokeError;

  /// No description provided for @sharePublicLinkToggleDesc.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل أو إيقاف الرابط العام متاح فقط للمالك (Owner) أو المسؤول (Admin).'**
  String get sharePublicLinkToggleDesc;

  /// No description provided for @authResetEmailSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط استعادة كلمة المرور إلى بريدك.'**
  String get authResetEmailSent;

  /// No description provided for @authAccountCreatedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب بنجاح!'**
  String get authAccountCreatedSuccessfully;

  /// No description provided for @authAccountCreatedBody.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء حسابك بنجاح! أرسلنا رسالة تأكيد تحتوي على رابط التفعيل إلى:'**
  String get authAccountCreatedBody;

  /// No description provided for @shareRevokeSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم سحب الصلاحية بنجاح'**
  String get shareRevokeSuccess;

  /// No description provided for @shareCopyLinkSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ رابط المشاركة العام إلى الحافظة'**
  String get shareCopyLinkSuccess;

  /// No description provided for @authResendSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة إرسال رابط التفعيل بنجاح! تفقد بريدك.'**
  String get authResendSuccess;

  /// No description provided for @shareLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get shareLoading;

  /// No description provided for @shareInviteButton.
  ///
  /// In ar, this message translates to:
  /// **'دعوة'**
  String get shareInviteButton;

  /// No description provided for @shareInviteNewMember.
  ///
  /// In ar, this message translates to:
  /// **'دعوة شخص جديد وتحديد صلاحيته'**
  String get shareInviteNewMember;

  /// No description provided for @sharePublicLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط عام (بدون حساب)'**
  String get sharePublicLink;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل دخولك لمزامنة مهامك ومشاركتها مع فريقك'**
  String get authSignInSubtitle;

  /// No description provided for @shareRevokeAccess.
  ///
  /// In ar, this message translates to:
  /// **'سحب الصلاحية'**
  String get shareRevokeAccess;

  /// No description provided for @sharePermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيتك على هذا العنصر لا تسمح بإدارة المشاركة. هذه الإجراءات متاحة فقط للمالك (Owner) أو المسؤول (Admin).'**
  String get sharePermissionDenied;

  /// No description provided for @shareLinkToggleHint.
  ///
  /// In ar, this message translates to:
  /// **'قم بتفعيل المفتاح بالأعلى لتوليد رابط مشاركة سريع يمكن إرساله للعملاء أو الزملاء.'**
  String get shareLinkToggleHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordMin.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور 6 خانات كحد أدنى'**
  String get authPasswordMin;

  /// No description provided for @authHasAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authHasAccount;

  /// No description provided for @shareNotSharedYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم مشاركة هذا العنصر مع أي شخص بعد.'**
  String get shareNotSharedYet;

  /// No description provided for @authResendLink.
  ///
  /// In ar, this message translates to:
  /// **'لم تصلك الرسالة؟ إعادة الإرسال'**
  String get authResendLink;

  /// No description provided for @authNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب بعد؟'**
  String get authNoAccount;

  /// No description provided for @shareEditor.
  ///
  /// In ar, this message translates to:
  /// **'محرر'**
  String get shareEditor;

  /// No description provided for @shareEditorBadge.
  ///
  /// In ar, this message translates to:
  /// **'محرر / تعديل ✏️'**
  String get shareEditorBadge;

  /// No description provided for @authWelcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك إلى Tasky'**
  String get authWelcomeBack;

  /// No description provided for @shareAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول'**
  String get shareAdmin;

  /// No description provided for @shareUserWithoutEmail.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم بدون بريد'**
  String get shareUserWithoutEmail;

  /// No description provided for @shareViewer.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدة فقط'**
  String get shareViewer;

  /// No description provided for @shareViewOnlyBadge.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدة فقط 👁️'**
  String get shareViewOnlyBadge;

  /// No description provided for @sharePending.
  ///
  /// In ar, this message translates to:
  /// **'معلّق (في انتظار التسجيل)'**
  String get sharePending;

  /// No description provided for @shareCopyLink.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرابط'**
  String get shareCopyLink;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @shareActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get shareActive;

  /// No description provided for @authOfflineMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع الأوفلاين'**
  String get authOfflineMode;

  /// No description provided for @sharePublicLinkDesc.
  ///
  /// In ar, this message translates to:
  /// **'يتيح لأي شخص لديه الرابط الاطلاع على المحتوى (قراءة فقط بدون حساب)'**
  String get sharePublicLinkDesc;

  /// No description provided for @shareInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صالح'**
  String get shareInvalidEmail;

  /// No description provided for @authConfirmEmailBody.
  ///
  /// In ar, this message translates to:
  /// **'يرجى فتح الرسالة والنقر على رابط التفعيل. إذا لم تجد الرسالة في صندوق الوارد، تفقّد مجلد الرسائل غير المرغوب فيها (Spam / Junk).'**
  String get authConfirmEmailBody;

  /// No description provided for @authNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة الاسم'**
  String get authNameRequired;

  /// No description provided for @authEmailRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة البريد الإلكتروني'**
  String get authEmailRequired;

  /// No description provided for @authPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة كلمة المرور'**
  String get authPasswordRequired;

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'الأشخاص الذين لديهم صلاحية وصول ({count})'**
  String sharePeopleWithAccess(int count);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الصلاحية إلى {permission} بنجاح'**
  String sharePermissionUpdatedSuccess(String permission);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة إرسال رابط التفعيل إلى {email} بنجاح! تفقد بريدك الآن.'**
  String authResendActivationSuccess(String email);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'تمت دعوة {email} بنجاح'**
  String shareInviteSentSuccess(String email);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة {name}'**
  String shareDialogTitle(String name);

  /// نص واجهة مع متغيرات لتطبيق Tasky.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إلغاء مشاركة هذا العنصر مع {email}؟'**
  String shareRevokeConfirmBody(String email);

  /// No description provided for @authConnectionError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في الاتصال، يرجى المحاولة لاحقاً'**
  String get authConnectionError;

  /// No description provided for @authSignUpError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في إنشاء الحساب، يرجى المحاولة لاحقاً'**
  String get authSignUpError;

  /// No description provided for @authEnterEmailForResend.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال البريد الإلكتروني لإعادة إرسال الرابط'**
  String get authEnterEmailForResend;

  /// No description provided for @authResendActivationError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إعادة إرسال رابط التفعيل، يرجى المحاولة لاحقاً'**
  String get authResendActivationError;

  /// No description provided for @authResetPasswordError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال رابط الاستعادة'**
  String get authResetPasswordError;

  /// No description provided for @authDisplayNameUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الاسم المعروض بنجاح'**
  String get authDisplayNameUpdated;

  /// No description provided for @authUpdateNameError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث الاسم، يرجى المحاولة لاحقاً'**
  String get authUpdateNameError;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تأكيد بريدك الإلكتروني بعد. يرجى فتح الرسالة المرسلة إلى بريدك والنقر على رابط التفعيل لتسجيل الدخول.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة'**
  String get authInvalidCredentials;

  /// No description provided for @authUserAlreadyRegistered.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد الإلكتروني مسجل بالفعل'**
  String get authUserAlreadyRegistered;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب ألا تقل عن 6 أحرف'**
  String get authPasswordTooShort;

  /// No description provided for @authInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'صيغة البريد الإلكتروني غير صالحة'**
  String get authInvalidEmail;

  /// No description provided for @authRateLimit.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار دقيقة قبل طلب إرسال رابط جديد'**
  String get authRateLimit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
