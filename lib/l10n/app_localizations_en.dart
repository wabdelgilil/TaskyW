// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TaskyW';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonToday => 'Today\'s Tasks';

  @override
  String taskCountRemaining(int count) {
    return '$count tasks remaining';
  }

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get sectionNotifications => 'Notifications & Alerts';

  @override
  String get sectionLanguage => 'Language & Region';

  @override
  String get sectionFinance => 'Finance & Currencies';

  @override
  String get sectionAppearance => 'Appearance & Theme';

  @override
  String get sectionData => 'App Data';

  @override
  String get settingsNotifications => 'App Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Turn all local notifications (task reminders) on or off';

  @override
  String get settingsReminderTime => 'Default reminder time';

  @override
  String settingsReminderMinutes(int minutes) {
    return '$minutes minutes before due';
  }

  @override
  String get settingsRequestPermission => 'Request notification permission';

  @override
  String get settingsRequestPermissionDesc =>
      'Confirm notification permission on Android/iOS';

  @override
  String get settingsPermissionGranted =>
      'Notification permission enabled successfully';

  @override
  String get settingsPermissionDenied => 'Notification permission was denied';

  @override
  String get settingsEnable => 'Enable';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsLanguageDesc =>
      'Choose the interface language (default: device language)';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageSystemShort => 'System';

  @override
  String get languageArabic => 'العربية (RTL)';

  @override
  String get languageEnglish => 'English (LTR)';

  @override
  String get syncSyncing => 'Syncing...';

  @override
  String syncPending(int count) {
    return '$count pending';
  }

  @override
  String get syncSynced => 'Synced';

  @override
  String get signInToCloud => 'Sign in to cloud';

  @override
  String get toggleThemeShort => 'Switch';

  @override
  String get directionTitle => 'Layout & sidebar direction';

  @override
  String get directionDesc =>
      'Keep the sidebar on the left regardless of language';

  @override
  String get directionLtr => 'Always left';

  @override
  String get directionAuto => 'Auto (follow language)';

  @override
  String get settingsCurrency => 'Default currency';

  @override
  String settingsCurrencyDesc(String currency) {
    return 'Currency used for new financial records: $currency';
  }

  @override
  String get settingsViewMode => 'View mode';

  @override
  String get viewModeList => 'List';

  @override
  String get viewModeKanban => 'Kanban';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED';

  @override
  String get themeLightFull => 'Light mode';

  @override
  String get themeDarkFull => 'Dark mode';

  @override
  String get themeOledFull => 'Deep black (OLED)';

  @override
  String get appVersion => 'App version';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get accountStatus => 'Account status';

  @override
  String signedInAs(String email) {
    return 'Signed in: $email';
  }

  @override
  String get signedOut => 'Not signed in';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileEmail => 'Email address';

  @override
  String get navHome => 'Today';

  @override
  String get navProjects => 'Projects';

  @override
  String get navNotes => 'Notes';

  @override
  String get navFinance => 'Finance';

  @override
  String get navSettings => 'Settings';

  @override
  String get newTask => 'New Task';

  @override
  String get preview => 'Preview';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get taskyUser => 'Tasky User';

  @override
  String get closeSearch => 'Close search';

  @override
  String get sidebarMenu => 'Sidebar';

  @override
  String get viewList => 'List View';

  @override
  String get viewKanban => 'Kanban View';

  @override
  String get viewTable => 'Table View';

  @override
  String get exportCsvTooltip => 'Export tasks to CSV / Excel';

  @override
  String get exportCsvCurrentTooltip => 'Export current tasks to CSV / Excel';

  @override
  String get globalSearch => 'Search all';

  @override
  String get globalSearchInApp => 'Search across the whole app';

  @override
  String get cancelGlobalSearch => 'Cancel global search';

  @override
  String get cancelGlobalShort => 'Cancel global';

  @override
  String get filterToday => '☀️ Today\'s Tasks';

  @override
  String get filterUpcoming => '📅 Upcoming Tasks';

  @override
  String get filterWaiting => '⏳ Waiting Tasks';

  @override
  String get filterUrgent => '🔥 Urgent Tasks';

  @override
  String get filterAll => '📋 All Tasks';

  @override
  String get contextTitleNotes => '📚 Notes & Knowledge Vault';

  @override
  String get contextTitleFinance => '💰 Financial Logs & Settlements';

  @override
  String get contextTitleArchive => '🗄️ Global Archive';

  @override
  String get contextTitleTrash => '🗑️ Trash Bin';

  @override
  String get contextTitleSharedProject => '💼 Shared project';

  @override
  String get contextTitleSharedArea => '📁 Shared area';

  @override
  String contextTitleTag(String name) {
    return '🏷️ Tag: $name';
  }

  @override
  String get searchHintTasks => 'Search tasks...';

  @override
  String get searchHintGlobal => 'Search across all areas and projects...';

  @override
  String searchHintProject(String title) {
    return 'Search in project ($title)...';
  }

  @override
  String searchHintArea(String title) {
    return 'Search in area ($title)...';
  }

  @override
  String get exportEmptyToast => 'No tasks to export in the current view';

  @override
  String exportSuccessToast(int count) {
    return 'Exported $count tasks and copied CSV to clipboard!';
  }

  @override
  String get quickAddHint => 'Quick add a task...';

  @override
  String get smartFiltersHeader => 'Smart Filters';

  @override
  String get smartFilterToday => 'Today';

  @override
  String get smartFilterUpcoming => 'Upcoming';

  @override
  String get smartFilterWaiting => 'Waiting';

  @override
  String get smartFilterUrgent => 'Urgent';

  @override
  String get smartFilterAll => 'All Tasks';

  @override
  String get areasProjectsSection => 'Areas & Projects';

  @override
  String get addNewAreaTooltip => 'Add new area';

  @override
  String get newProjectEllipsis => 'New project...';

  @override
  String get tagsSection => 'Tags & Labels';

  @override
  String get createTagTooltip => 'Create new tag';

  @override
  String get noTagsAdded => 'No tags added yet';

  @override
  String get sharedWithMeHeader => 'Shared with me';

  @override
  String get refreshSharedTooltip => 'Refresh shared entities';

  @override
  String get sharedEntityDefault => 'Shared item';

  @override
  String get permissionAdmin => 'Admin';

  @override
  String get permissionEditor => 'Editor';

  @override
  String get permissionViewer => 'Viewer';

  @override
  String get sidebarNotesSection => 'Notes & Knowledge Vault';

  @override
  String get sidebarNotesTitle => 'Notes & Knowledge Vault';

  @override
  String get sidebarFinanceSection => 'Finance & Settlements';

  @override
  String get sidebarFinanceTitle => 'Financial Logs & Settlements';

  @override
  String get sidebarArchiveSection => 'Archive & Trash';

  @override
  String get sidebarArchiveTitle => 'Global Archive';

  @override
  String get sidebarTrashTitle => 'Trash Bin';

  @override
  String get attachmentSyncing => '⏳ Syncing';

  @override
  String get reminderNote => '⚠️ (reminder)';

  @override
  String get chipPendingInvoice => '⚠️ Awaiting invoice';

  @override
  String get invoicePendingTap => '⚠️ Awaiting invoice (tap to receive)';

  @override
  String get attachmentSynced => '✓ Synced';

  @override
  String get paidPersonalFromWork =>
      '🏠 Paid personal from work account (I owe work)';

  @override
  String get chipPaidToWork => '🏠 Paid to work';

  @override
  String get paidFromPocket => '💼 Paid work from my pocket (work owes me)';

  @override
  String get chipDueFromWork => '💼 Due from work';

  @override
  String get chipTransfers => '🔄 Transfers';

  @override
  String get sharedPublicTitle => 'TaskyW — Public share';

  @override
  String get enterNewName => 'Enter your new name';

  @override
  String get descriptionNotesHint =>
      'Enter details, notes, or spare part numbers...';

  @override
  String get archiveAction => 'Archive';

  @override
  String get recurrenceWeekly => 'Weekly';

  @override
  String get pasteEmojiHint => 'Paste an emoji (e.g. 🤖) or its code (U+1F680)';

  @override
  String get enterHexCode => 'Or enter a custom HEX code:';

  @override
  String get orCreateTag => 'Or create a new tag:';

  @override
  String get trashTasksEmptyDesc =>
      'Any deleted task is kept here and can be restored anytime.';

  @override
  String get quickEmojis => 'Quick suggested icons:';

  @override
  String get customEmojiInput => 'Custom input (paste emoji or a U+... code):';

  @override
  String get projectNotifications => 'Notifications for this project';

  @override
  String get createTask => 'Add task';

  @override
  String get addStepHint => 'Add a new subtask step...';

  @override
  String get addNewAreaTitle => 'Add a new responsibility area';

  @override
  String get addAttachment => 'Add attachment';

  @override
  String get addNewProjectTitle => 'Add new project';

  @override
  String get addNewTaskTitle => 'Add new task';

  @override
  String get addGeneralTask => 'Add general task';

  @override
  String get addTaskInProject => 'Add task in project';

  @override
  String get kanbanAddInColumn => 'Add task in this column';

  @override
  String get addTag => 'Add tag';

  @override
  String get addTagForTask => 'Add a tag to the task';

  @override
  String get retryAction => 'Retry';

  @override
  String get emptyTrash => 'Empty trash';

  @override
  String get emptyTrashConfirmAction => 'Empty trash permanently';

  @override
  String get emptyTrashConfirmTitle => 'Empty the trash entirely?';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get unpinNote => 'Unpin';

  @override
  String get toAccount => 'To account';

  @override
  String get markDone => 'Mark done';

  @override
  String get createAction => 'Create';

  @override
  String get createArea => 'Create area';

  @override
  String get createProject => 'Create project';

  @override
  String get createAndAttachTag => 'Create & attach the tag';

  @override
  String get createNewTag => 'Create new tag';

  @override
  String get startAddingTasks =>
      'Start by adding a new task to track your daily progress';

  @override
  String get chooseIconTitle => 'Choose an expressive icon';

  @override
  String get chooseTagColor => 'Choose the tag color:';

  @override
  String get chooseCustomColor => 'Choose a custom color';

  @override
  String get choose => 'Select';

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreProject => 'Restore project';

  @override
  String get restoreNote => 'Restore note';

  @override
  String get restoreTask => 'Restore task';

  @override
  String get archiveRestoreToActive => 'Restore to active work';

  @override
  String get kanbanDropHint => 'Drag tasks here or add a new task';

  @override
  String get areaName => 'Area name';

  @override
  String get projectName => 'Project name';

  @override
  String get tagName => 'Tag name';

  @override
  String get newTagNameHint => 'Tag name (e.g. urgent, spare_parts...)';

  @override
  String get notesEmptyHint => 'Tap + to add your first note...';

  @override
  String get noteContentHint => 'Write your thoughts and references here...';

  @override
  String get archiveGlobalTitle => 'Global Archive';

  @override
  String get suggestedColors => 'Suggested colors:';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityColon => 'Priority:';

  @override
  String get trashSearchHint => 'Search in the trash...';

  @override
  String get archiveSearchHint => 'Search archive items...';

  @override
  String get bankOption => 'Bank';

  @override
  String get toAccountHint => 'Bank, wallet...';

  @override
  String get descriptionLabel => 'Description *';

  @override
  String get recurrenceColon => 'Recurrence:';

  @override
  String get reminderColon => 'Reminder:';

  @override
  String get emojiCategoryStatus => 'Status & Alerts';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusColon => 'Status:';

  @override
  String get deadlineColon => 'Deadline:';

  @override
  String get invalidShareLink =>
      'The link is invalid or the share has expired.';

  @override
  String get linkUnavailable => 'Link unavailable';

  @override
  String get emojiCategoryPersonal => 'Personal & Home';

  @override
  String get emojiCategoryWork => 'Work & Projects';

  @override
  String get trashSubtitle =>
      'Items deleted temporarily; restore them or delete permanently to free up space';

  @override
  String get noteTitle => 'Title';

  @override
  String get allFilter => 'All';

  @override
  String get colorLabel => 'Color';

  @override
  String get colorColon => 'Color:';

  @override
  String get amountLabel => 'Amount (SAR) *';

  @override
  String get pinnedNotes => 'Pinned';

  @override
  String get areaLabel => 'Area';

  @override
  String get areaProjectColumn => 'Area / project';

  @override
  String get areaColon => 'Area:';

  @override
  String get noteContent => 'Content';

  @override
  String get notesScreenSubtitle =>
      'The knowledge vault and calm space for ideas, references, links, and contacts without task deadlines or constraints.';

  @override
  String get areaProjects => 'Area projects';

  @override
  String get trashProjectsEmptyDesc =>
      'Deleted projects appear here until restored or permanently deleted.';

  @override
  String get archiveProjectsEmptyDesc =>
      'Completed or archived projects appear here for reference.';

  @override
  String get projectLabel => 'Project';

  @override
  String get projectColon => 'Project:';

  @override
  String get trashNotesEmptyDesc => 'Soft-deleted notes appear here.';

  @override
  String get notesScreenTitle => 'Notes & Knowledge Vault';

  @override
  String get attachmentNotSynced =>
      'File not uploaded yet; download will be available after sync';

  @override
  String get subtasksColumn => 'Subtasks';

  @override
  String get subtasksTitle => 'Subtasks (Checklist)';

  @override
  String get completedTasksSection => 'Completed Tasks';

  @override
  String get archiveGlobalSubtitle =>
      'Completed tasks, projects, and notes kept for reference without cluttering daily workspaces';

  @override
  String get patternColon => 'Pattern:';

  @override
  String get emojiCategoryTools => 'Tools & Engineering';

  @override
  String get tagsColumn => 'Tags';

  @override
  String get availableTags => 'Available tags:';

  @override
  String get tagsTitle => 'Tags & categories';

  @override
  String get descriptionNotesLabel => 'Description & notes:';

  @override
  String get financeSearchHint => 'Search transactions, accounts, notes...';

  @override
  String get notesSearchHint => 'Instant search in titles and content...';

  @override
  String get noEndDate => 'No end date (ongoing)';

  @override
  String get untitled => 'Untitled';

  @override
  String get noProject => 'No project';

  @override
  String get noProjectGeneral => 'No project (general task)';

  @override
  String get exportedCsvData => 'Exported CSV data';

  @override
  String get confirmChoice => 'Confirm selection';

  @override
  String get dueDateColumn => 'Due date';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get pinNote => 'Pin';

  @override
  String get groupByProject => 'Group by project';

  @override
  String get archiveRefresh => 'Refresh archive';

  @override
  String get refreshTrash => 'Refresh trash';

  @override
  String get transferOption => 'Transfer';

  @override
  String get customizeTaskColor => 'Customize task color';

  @override
  String get undoAction => 'Undo';

  @override
  String get registerTransaction => 'Register transaction';

  @override
  String get newTransactionTitle => 'Register a new financial transaction';

  @override
  String get settlementLabel => 'Settle work vs personal account:';

  @override
  String get exportStatement => 'Export statement to Excel / CSV';

  @override
  String get pendingInvoiceReminder =>
      'Stays pending until you receive the invoice so you remember to claim it';

  @override
  String get editLabel => 'Edit';

  @override
  String get editName => 'Edit name';

  @override
  String get editTransactionTitle => 'Edit financial transaction';

  @override
  String get editArea => 'Edit area';

  @override
  String get editProject => 'Edit project';

  @override
  String get editNote => 'Edit note';

  @override
  String get editAreaData => 'Edit area details';

  @override
  String get editProjectData => 'Edit project details';

  @override
  String get syncFailedTapRetry =>
      'Couldn\'t connect to the cloud. Tap to retry.';

  @override
  String get invalidEmojiCode => 'Couldn\'t recognize the emoji code';

  @override
  String get attachSaveError => 'Couldn\'t save the attachment';

  @override
  String get openFileError => 'Couldn\'t open the file';

  @override
  String get setDateHint => 'Set date...';

  @override
  String get taskDetails => 'Task details';

  @override
  String get enableProjectNotifications =>
      'Enable notifications for this project';

  @override
  String get projectNotificationsDesc =>
      'Enable local reminders for this project\'s tasks';

  @override
  String get trashEmptiedToast => 'Trash emptied successfully';

  @override
  String get allDoneSection => 'All tasks in this section done 🎉';

  @override
  String get invoiceReceivedToast =>
      'Invoice received; status updated to complete ✅';

  @override
  String get nameUpdatedToast => 'Name updated successfully';

  @override
  String get projectNotifEnabledToast => 'Project notifications enabled';

  @override
  String get projectDeletedPermanentToast => 'Project deleted permanently';

  @override
  String get taskDeletedPermanentToast => 'Task deleted permanently';

  @override
  String get projectNotifMutedToast => 'Project notifications muted';

  @override
  String get settledToast => 'Settlement completed ✔️';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get syncInProgressNow => 'Syncing with the cloud now...';

  @override
  String get syncingNow => 'Syncing...';

  @override
  String get loadingSharedItem => 'Loading the shared item...';

  @override
  String get syncUploading => 'Uploading cloud changes...';

  @override
  String get syncChecking => 'Checking and updating data with the cloud...';

  @override
  String get tryOtherKeywords => 'Try searching with other words.';

  @override
  String get syncAllSynced => 'All your data is synced with the cloud';

  @override
  String get cloudStatus => 'Cloud status';

  @override
  String get projectStatus => 'Project status';

  @override
  String get shareLoadError =>
      'An error occurred while loading the data. Please try again.';

  @override
  String get deleteStep => 'Delete step';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String get deleteArea => 'Delete area';

  @override
  String get deleteAreaFully => 'Delete area completely';

  @override
  String get deleteAttachment => 'Delete attachment';

  @override
  String get deleteProject => 'Delete project';

  @override
  String get deleteProjectPermanentConfirm => 'Delete the project permanently?';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get deleteSubtask => 'Delete subtask';

  @override
  String get deleteTaskPermanentConfirm => 'Delete the task permanently?';

  @override
  String get deletePermanent => 'Delete permanently';

  @override
  String get saveEdit => 'Save edit';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get incomeRefundOption => 'Income / refund';

  @override
  String get notesHint => 'Receipt number, supplier name, details...';

  @override
  String get trashProjectsEmpty => 'Project trash is empty';

  @override
  String get trashNotesEmpty => 'Note trash is empty';

  @override
  String get trashTasksEmpty => 'Task trash is empty';

  @override
  String get trashTitle => 'Trash Bin';

  @override
  String get emptyTrashConfirmBody =>
      'All tasks and projects in the trash will be permanently and irreversibly deleted. Continue?';

  @override
  String get recurrenceMonthly => 'Monthly';

  @override
  String get setReminderHint => 'Set reminder...';

  @override
  String get priorityCritical => 'Very urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get netYouOwe => 'You owe (net)';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get normalTransaction => 'Normal transaction (no settlement needed)';

  @override
  String get archiveTasksEmptyDesc =>
      'Any archived task will appear here for future reference.';

  @override
  String get noteTitleHint => 'Note title...';

  @override
  String get columnTitle => 'Title';

  @override
  String get taskTitleLabel => 'Task title *';

  @override
  String get taskTitleEditHint => 'Task title...';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get openAttachment => 'Open / download the attachment';

  @override
  String get pendingInvoices => 'Pending invoices';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get cashOption => 'Cash';

  @override
  String get paymentMethodHint => 'Cash, CIB, Vodafone Cash...';

  @override
  String get muteProjectNotifications => 'Mute this project\'s notifications';

  @override
  String get exportedStatementCsv => 'Exported statement (CSV)';

  @override
  String get financeEmpty => 'No financial transactions recorded yet';

  @override
  String get attachmentsEmpty =>
      'No attachments yet — you can attach documents, images, and files.';

  @override
  String get archiveEmptyProjects => 'No archived projects';

  @override
  String get areaNoProjects => 'No projects added under this area yet';

  @override
  String get notesEmpty => 'No notes yet';

  @override
  String get archiveEmptyNotes => 'No archived notes';

  @override
  String get areaNoGeneralTasks =>
      'No general tasks outside projects in this area';

  @override
  String get noTasksInSection => 'No tasks in this section right now';

  @override
  String get tableEmpty => 'No tasks to show in the table';

  @override
  String get archiveEmptyTasks => 'No archived tasks';

  @override
  String get noTasksRegistered => 'No tasks recorded currently';

  @override
  String get projectNoTasks => 'No tasks added to this project yet';

  @override
  String get noMatchingResults => 'No matching results';

  @override
  String get financeNoFilterMatch => 'No results match the selected filter';

  @override
  String get noTagsForTask =>
      'No tags linked to this task. Tap \"Add tag\" to categorize it.';

  @override
  String get paste => 'Paste';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get netOwedToYou => 'Owed to you (net)';

  @override
  String get readOnlyBadge => 'Read-only';

  @override
  String get notReceivedInvoice => 'I haven\'t received the invoice yet';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get noteColor => 'Note color';

  @override
  String get customTaskColor => 'Custom task color';

  @override
  String get taskTitleHint => 'What do you want to accomplish?';

  @override
  String get fullySynced => 'Fully synced';

  @override
  String get recurrenceRecurring => 'Recurring';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get descriptionHint =>
      'E.g. buying spare parts, business lunch, cash advance...';

  @override
  String get tagNameHint => 'E.g. urgent, spare_parts...';

  @override
  String get entityArea => 'Area';

  @override
  String get statusReview => 'Review';

  @override
  String get syncNowButton => 'Sync...';

  @override
  String get owedByYou => '⏳ Owed by you to work';

  @override
  String get shareAreaWithTeam => 'Share area with the team';

  @override
  String get shareProjectWithTeam => 'Share project with the team';

  @override
  String get shareTaskWithTeam =>
      'Share the task with the team via link or account';

  @override
  String get entityProject => 'Project';

  @override
  String get newProject => 'New project';

  @override
  String get expenseOption => 'Expense';

  @override
  String get reimbursementRequired => '⏳ Reimbursement required from work';

  @override
  String get generalTransaction => 'General transaction';

  @override
  String get areaCompletionRate => 'Overall area completion rate:';

  @override
  String get disabled => 'Disabled';

  @override
  String get projectStatusOnHold => 'On Hold';

  @override
  String get statusOnHold => 'On hold';

  @override
  String get enabled => 'Enabled';

  @override
  String get projectStatusCompleted => 'Completed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get notesListTitle => 'Notes';

  @override
  String get taskNotesLabel => 'Notes or description (optional)';

  @override
  String get additionalNotes => 'Additional notes (optional)';

  @override
  String get archiveNotesEmptyDesc =>
      'Archived knowledge and documentation notes appear here.';

  @override
  String get newNote => 'New note';

  @override
  String get chooseIconSubtitle =>
      'From the list or by pasting an emoji or Unicode code';

  @override
  String get fromAccount => 'From account';

  @override
  String get priorityLow => 'Low';

  @override
  String get areaGeneralTasks => 'General tasks in this area';

  @override
  String get entityTask => 'Task';

  @override
  String get projectCompletionRate => 'Project completion rate:';

  @override
  String get projectStatusActive => 'Active';

  @override
  String get yesDelete => 'Yes, delete';

  @override
  String get paymentMethodLabel => 'Payment method / account';

  @override
  String get projectDescription => 'Project description (optional)';

  @override
  String get syncOffline => 'Offline mode. The app works fully locally.';

  @override
  String get requireAreaFirst => 'You must create an area before adding tasks.';

  @override
  String get invalidTransactionMsg =>
      'Please enter a description and a valid amount';

  @override
  String get endsAtColon => 'Ends at:';

  @override
  String get recurrenceDaily => 'Daily';

  @override
  String syncPendingTooltip(int count) {
    return '$count local changes are waiting to upload. Tap to sync.';
  }

  @override
  String taskDeletedToast(String title) {
    return 'Task \"$title\" deleted';
  }

  @override
  String deleteFileConfirm(String fileName) {
    return 'Are you sure you want to delete the file \"$fileName\"?';
  }

  @override
  String fileSavedLocal(String url) {
    return 'File saved locally: $url';
  }

  @override
  String attachmentsCount(int count) {
    return 'Attachments ($count)';
  }

  @override
  String deleteTaskConfirm(String title) {
    return 'Are you sure you want to delete the task \"$title\"?';
  }

  @override
  String deleteStepConfirm(String title) {
    return 'Are you sure you want to delete the step \"$title\"?';
  }

  @override
  String tabsTasks(int count) {
    return 'Tasks ($count)';
  }

  @override
  String tabsProjects(int count) {
    return 'Projects ($count)';
  }

  @override
  String tabsNotes(int count) {
    return 'Notes ($count)';
  }

  @override
  String restoredTaskToast(String title) {
    return 'Task \"$title\" restored successfully';
  }

  @override
  String restoredProjectToast(String name) {
    return 'Project \"$name\" restored successfully';
  }

  @override
  String restoredNoteToast(String title) {
    return 'Note \"$title\" restored successfully';
  }

  @override
  String cannotRestoreTaskMsg(String title) {
    return 'You won\'t be able to restore the task \"$title\" after permanent deletion.';
  }

  @override
  String cannotRestoreProjectMsg(String name) {
    return 'You won\'t be able to restore the project \"$name\" after permanent deletion.';
  }

  @override
  String deleteNoteConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String areaStats(int projects, int tasks) {
    return 'A responsibility area with $projects projects and $tasks tasks';
  }

  @override
  String taskCounter(int done, int total) {
    return '$done/$total tasks';
  }

  @override
  String urgentCount(int count) {
    return '$count urgent';
  }

  @override
  String projectProgress(int percent, int done, int total) {
    return '$percent% ($done/$total completed)';
  }

  @override
  String pendingChangesCount(int count) {
    return '$count pending change(s)';
  }

  @override
  String dueDateBadge(String date) {
    return 'Due: $date';
  }

  @override
  String financeExportToast(int count) {
    return '$count operations exported and CSV copied to clipboard!';
  }

  @override
  String transferFromTo(String from, String to) {
    return 'From $from ⬅️ to $to';
  }

  @override
  String viaAccount(String account) {
    return 'Via: $account';
  }

  @override
  String deleteTransactionConfirm(String title) {
    return 'Are you sure you want to delete the transaction \"$title\"?';
  }

  @override
  String get yesNow => 'Yes, delete';

  @override
  String deleteAreaConfirm(String name) {
    return 'Are you sure you want to delete the area \"$name\" and all its projects and tasks? This cannot be undone.';
  }

  @override
  String deleteProjectConfirm(String name) {
    return 'Are you sure you want to delete the project \"$name\" and all its tasks? This cannot be undone.';
  }

  @override
  String get syncPartialFail => 'Sync completed with some errors';

  @override
  String get syncAutoFail => 'Automatic sync could not be completed';

  @override
  String get syncLoginRequired => 'Sign in is required to sync data';

  @override
  String get tagDefault => 'Tag';

  @override
  String get currencySearchHint =>
      'Search by country name, currency, or code (SAR, EGP...)';

  @override
  String get selectCurrencyTitle => 'Select Default Currency';

  @override
  String get noCurrencyResult => 'No matching currencies found';

  @override
  String get authResendActivation => 'Resend activation link now';

  @override
  String get shareRestrictedNotice =>
      '🔒 Your current role (view or edit) doesn\'t allow inviting members or changing permissions. These actions are available only to the owner or admin.';

  @override
  String get authResetEmailHint =>
      'Enter your registered email to receive a reset link';

  @override
  String get authConfirmEmailResent =>
      'We already sent the activation link. Check your inbox and spam / junk folder.';

  @override
  String get shareTeamMembers => 'Team members (account)';

  @override
  String get authConfirmEmailAction => 'I confirmed my email, sign in now';

  @override
  String get shareSecurityNote =>
      'Secure: visitors via this link will only see this item and won\'t be able to edit or delete anything.';

  @override
  String get authSignUpSubtitle =>
      'Create your account for cloud backup and sharing';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authCreateAccountAction => 'Create account';

  @override
  String get authCreateAccount => 'Create a new account';

  @override
  String get authGetStartedSubtitle =>
      'Start managing your projects professionally';

  @override
  String get authResetPassword => 'Reset password';

  @override
  String get authFullName => 'Full name';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get shareInviteUnavailable =>
      'Invitation is not available for your role';

  @override
  String get shareLinkDisabled => 'The public link is currently disabled';

  @override
  String get shareEntityElement => 'Item';

  @override
  String get authContinueOffline => 'Continue without an account (offline)';

  @override
  String get shareEntityArea => 'Area';

  @override
  String get sharePublicLinkTitle => 'Share via public link';

  @override
  String get shareEntityProject => 'Project';

  @override
  String get shareEntityTask => 'Task';

  @override
  String get authEmailInvalid => 'Invalid email address';

  @override
  String get authConfirmEmailTitle => 'Confirm your email';

  @override
  String get authConfirmAccount => 'Confirm account';

  @override
  String get authConfirmRequired =>
      'Account confirmation is required to sign in';

  @override
  String get shareRevokeConfirmTitle => 'Confirm revoke';

  @override
  String get shareFullAccessBadge => 'Full access 🗑️';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authChangeEmail => 'Change email or try another account';

  @override
  String get shareInviteError => 'Failed to send the invitation';

  @override
  String get shareLinkCreationError =>
      'Failed to create the public link. Make sure you\'re signed in and synced.';

  @override
  String get sharePermissionUpdateError =>
      'Failed to update permission. Please try again later.';

  @override
  String get shareRevokeError => 'Failed to revoke access';

  @override
  String get sharePublicLinkToggleDesc =>
      'Enabling or disabling the public link is available only to the owner or admin.';

  @override
  String get authResetEmailSent =>
      'A password reset link has been sent to your email.';

  @override
  String get authAccountCreatedSuccessfully =>
      'Your account has been created successfully!';

  @override
  String get authAccountCreatedBody =>
      'Your account has been created! We sent a confirmation email to:';

  @override
  String get shareRevokeSuccess => 'Access revoked successfully';

  @override
  String get shareCopyLinkSuccess => 'Public share link copied to clipboard';

  @override
  String get authResendSuccess =>
      'The activation link has been resent! Check your email.';

  @override
  String get shareLoading => 'Loading...';

  @override
  String get shareInviteButton => 'Invite';

  @override
  String get shareInviteNewMember =>
      'Invite a new person and set their permission';

  @override
  String get sharePublicLink => 'Public link (no account required)';

  @override
  String get authSignInSubtitle =>
      'Sign in to sync and share your tasks with your team';

  @override
  String get shareRevokeAccess => 'Revoke access';

  @override
  String get sharePermissionDenied =>
      'You don\'t have permission to manage sharing for this item. These actions are available only to the owner or admin.';

  @override
  String get shareLinkToggleHint =>
      'Toggle the switch above to generate a quick share link that can be sent to clients or colleagues.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordMin => 'Password must be at least 6 characters';

  @override
  String get authHasAccount => 'Already have an account?';

  @override
  String get shareNotSharedYet =>
      'This item hasn\'t been shared with anyone yet.';

  @override
  String get authResendLink => 'Didn\'t receive the email? Resend';

  @override
  String get authNoAccount => 'Don\'t have an account yet?';

  @override
  String get shareEditor => 'Editor';

  @override
  String get shareEditorBadge => 'Editor / edit ✏️';

  @override
  String get authWelcomeBack => 'Welcome back to Tasky';

  @override
  String get shareAdmin => 'Admin';

  @override
  String get shareUserWithoutEmail => 'User without email';

  @override
  String get shareViewer => 'View only';

  @override
  String get shareViewOnlyBadge => 'View only 👁️';

  @override
  String get sharePending => 'Pending (awaiting registration)';

  @override
  String get shareCopyLink => 'Copy link';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get shareActive => 'Active';

  @override
  String get authOfflineMode => 'Offline mode';

  @override
  String get sharePublicLinkDesc =>
      'Allows anyone with the link to view the content (read-only, no account needed)';

  @override
  String get shareInvalidEmail => 'Please enter a valid email address';

  @override
  String get authConfirmEmailBody =>
      'Please open the email and click the activation link. If you can\'t find it in your inbox, check the spam / junk folder.';

  @override
  String get authNameRequired => 'Please enter your name';

  @override
  String get authEmailRequired => 'Please enter your email';

  @override
  String get authPasswordRequired => 'Please enter a password';

  @override
  String sharePeopleWithAccess(int count) {
    return 'People with access ($count)';
  }

  @override
  String sharePermissionUpdatedSuccess(String permission) {
    return 'Permission updated to $permission successfully';
  }

  @override
  String authResendActivationSuccess(String email) {
    return 'The activation link has been resent to $email! Check your email now.';
  }

  @override
  String shareInviteSentSuccess(String email) {
    return '$email has been invited successfully';
  }

  @override
  String shareDialogTitle(String name) {
    return 'Share $name';
  }

  @override
  String shareRevokeConfirmBody(String email) {
    return 'Are you sure you want to revoke sharing with $email?';
  }

  @override
  String get authConnectionError => 'Connection error, please try again later';

  @override
  String get authSignUpError =>
      'Failed to create account, please try again later';

  @override
  String get authEnterEmailForResend =>
      'Please enter your email to resend the link';

  @override
  String get authResendActivationError =>
      'Failed to resend activation link, please try again later';

  @override
  String get authResetPasswordError => 'Failed to send reset link';

  @override
  String get authDisplayNameUpdated => 'Display name updated successfully';

  @override
  String get authUpdateNameError =>
      'Failed to update name, please try again later';

  @override
  String get authEmailNotConfirmed =>
      'Your email hasn\'t been confirmed yet. Please open the email and click the activation link to sign in.';

  @override
  String get authInvalidCredentials => 'Invalid email or password';

  @override
  String get authUserAlreadyRegistered => 'This email is already registered';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get authInvalidEmail => 'Invalid email format';

  @override
  String get authRateLimit =>
      'Please wait a minute before requesting a new link';
}
