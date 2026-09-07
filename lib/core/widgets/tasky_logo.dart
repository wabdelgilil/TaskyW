import 'package:flutter/material.dart';

enum TaskyLogoType {
  emblem,
  horizontal,
  vertical,
}

/// ويدجت الشعار الرسمي لتطبيق TaskyW
/// يوفر عرضاً عالي الدقة للشعار بمختلف أشكاله (الرمز فقط، الشعار الأفقي، أو الرأسي الكامل)
/// مع دعم متجاوب للوضعين النهاري والليلي.
class TaskyLogo extends StatelessWidget {
  final TaskyLogoType type;
  final double size;
  final bool? isDark;
  final VoidCallback? onTap;

  const TaskyLogo.emblem({
    super.key,
    this.size = 36,
    this.isDark,
    this.onTap,
  }) : type = TaskyLogoType.emblem;

  const TaskyLogo.horizontal({
    super.key,
    this.size = 36,
    this.isDark,
    this.onTap,
  }) : type = TaskyLogoType.horizontal;

  const TaskyLogo.vertical({
    super.key,
    this.size = 120,
    this.isDark,
    this.onTap,
  }) : type = TaskyLogoType.vertical;

  @override
  Widget build(BuildContext context) {
    final effectiveIsDark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    Widget content;
    switch (type) {
      case TaskyLogoType.emblem:
        final assetPrefix = effectiveIsDark ? 'taskyw_emblem_dark_' : 'taskyw_emblem_';
        final assetPath = size <= 48
            ? 'assets/logos/${assetPrefix}64.png'
            : size <= 128
                ? 'assets/logos/${assetPrefix}256.png'
                : 'assets/logos/${assetPrefix}512.png';
        content = Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );
        break;

      case TaskyLogoType.horizontal:
        final assetPath = effectiveIsDark
            ? 'assets/logos/taskyw_horizontal_dark_512.png'
            : 'assets/logos/taskyw_horizontal_512.png';
        content = Image.asset(
          assetPath,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );
        break;

      case TaskyLogoType.vertical:
        final assetPath = effectiveIsDark
            ? 'assets/logos/taskyw_logo_dark_512.png'
            : 'assets/logos/taskyw_logo_512.png';
        content = Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );
        break;
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }
}
