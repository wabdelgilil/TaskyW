/// دوال مساعدة للتعامل مع التواريخ والأوقات بشكل ودّي باللغة العربية.
class DateTimeUtils {
  DateTimeUtils._();

  static const List<String> _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  // الترتيب يبدأ من يوم الأحد ليتوافق مع الأسبوع العربي.
  static const List<String> _weekdayNames = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
  ];

  /// التحقق مما إذا كان التاريخ يوافق اليوم الحالي (بالتوقيت المحلي).
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final local = date.toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  /// التحقق مما إذا كان التاريخ بعد يوم اليوم (أي في المستقبل).
  static bool isUpcoming(DateTime? date) {
    if (date == null) return false;
    final today = _dateOnly(DateTime.now());
    return _dateOnly(date.toLocal()).isAfter(today);
  }

  /// التحقق مما إذا كانت مهلة التاريخ قد انقضت (أي قبل اليوم).
  /// ملاحظة: يُطبق "ولم تكتمل المهمة" من جانب المتصل عبر دمج الحالة مع هذه الدالة.
  static bool isOverdue(DateTime? date) {
    if (date == null) return false;
    final today = _dateOnly(DateTime.now());
    return _dateOnly(date.toLocal()).isBefore(today);
  }

  /// تنسيق التاريخ بصيغة مريحة بالعربية مثل: "اليوم 10:00 ص"، "غداً"، "الأحد 12 مارس".
  static String formatFriendlyDate(DateTime? date) {
    if (date == null) return 'بدون تاريخ';
    final local = date.toLocal();
    final now = DateTime.now();
    final today = _dateOnly(now);
    final day = _dateOnly(local);

    final hasTime = local.hour != 0 || local.minute != 0;

    if (day.isBefore(today)) {
      if (day.isAfter(today.subtract(const Duration(days: 1)))) {
        return 'أمس';
      }
    } else if (day.isAtSameMomentAs(today)) {
      return hasTime ? 'اليوم ${_formatTime(local)}' : 'اليوم';
    } else if (day.isAfter(today) && day.isBefore(today.add(const Duration(days: 2)))) {
      return 'غداً';
    }

    final weekday = _weekdayNames[local.weekday % 7];
    final withYear = local.year != now.year;
    final datePart = '$weekday ${local.day} ${_monthNames[local.month - 1]}';
    return withYear ? '$datePart ${local.year}' : datePart;
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static String _formatTime(DateTime dateTime) {
    var hour = dateTime.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'ص' : 'م';
    return '$hour:$minute $period';
  }
}