import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/settings/data/models/app_currency.dart';

/// نافذة منبثقة تفاعلية لاختيار العملة مع محرك بحث فوري باسم الدولة أو العملة أو الكود.
class CurrencyPickerSheet extends StatefulWidget {
  final String selectedCurrencyCode;
  final ValueChanged<String> onCurrencySelected;

  const CurrencyPickerSheet({
    super.key,
    required this.selectedCurrencyCode,
    required this.onCurrencySelected,
  });

  /// عرض النافذة السفلية أو الحوار التفاعلي
  static Future<void> show(
    BuildContext context, {
    required String selectedCurrencyCode,
    required ValueChanged<String> onCurrencySelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyPickerSheet(
        selectedCurrencyCode: selectedCurrencyCode,
        onCurrencySelected: onCurrencySelected,
      ),
    );
  }

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<AppCurrency> _filtered = AppCurrency.popularCurrencies;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _filtered = AppCurrency.popularCurrencies
          .where((c) => c.matches(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.selectCurrencyTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                    tooltip: context.l10n.commonClose,
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: context.l10n.currencySearchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
              ),
            ),
          ),

          const Divider(height: 1),

          // List of Currencies
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: AppColors.textMuted(context)),
                          const SizedBox(height: 12),
                          Text(
                              context.l10n.noCurrencyResult,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, index) => const Divider(height: 1, indent: 64),
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      final isSelected = item.code.toUpperCase() ==
                          widget.selectedCurrencyCode.toUpperCase();
                      final countryName = isAr ? item.countryAr : item.countryEn;
                      final currencyName = isAr ? item.nameAr : item.nameEn;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
                              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                          child: Text(
                            item.flagEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              item.code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${item.symbol})',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted(context),
                              ),
                            ),
                            const Spacer(),
                            if (countryName.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  countryName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          currencyName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : AppColors.textSecondary(context),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 22)
                            : null,
                        onTap: () {
                          widget.onCurrencySelected(item.code);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
