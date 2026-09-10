/// نموذج بيانات العملة لدعم البحث السريع باسم العملة أو الدولة أو الكود.
/// مقتصر على العملات الأكثر تداولاً ورواجاً لتجنب أي ثقل على الكود.
class AppCurrency {
  /// كود العملة القياسي (ISO 4217)، مثل: SAR, EGP, USD
  final String code;

  /// اسم العملة باللغة العربية، مثل: ريال سعودي، جنيه مصري
  final String nameAr;

  /// اسم العملة باللغة الإنجليزية، مثل: Saudi Riyal, Egyptian Pound
  final String nameEn;

  /// اسم الدولة أو المنطقة بالعربية، مثل: مصر، السعودية
  final String countryAr;

  /// اسم الدولة أو المنطقة بالإنجليزية، مثل: Egypt, Saudi Arabia
  final String countryEn;

  /// رمز العملة المختصر، مثل: ر.س، ج.م، $
  final String symbol;

  /// علم الدولة التعبيري
  final String flagEmoji;

  const AppCurrency({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.countryAr,
    required this.countryEn,
    required this.symbol,
    required this.flagEmoji,
  });

  /// فحص مطابقة البحث (بالكود، اسم العملة، واسم البلد عربي وإنجليزي)
  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    return code.toLowerCase().contains(q) ||
        nameAr.toLowerCase().contains(q) ||
        nameEn.toLowerCase().contains(q) ||
        countryAr.toLowerCase().contains(q) ||
        countryEn.toLowerCase().contains(q) ||
        symbol.toLowerCase().contains(q);
  }

  /// القائمة الرشيقة لأهم العملات الشائعة والمتداولة
  static const List<AppCurrency> popularCurrencies = [
    // الدول العربية الأكثر تداولاً
    AppCurrency(
      code: 'SAR',
      nameAr: 'ريال سعودي',
      nameEn: 'Saudi Riyal',
      countryAr: 'المملكة العربية السعودية',
      countryEn: 'Saudi Arabia',
      symbol: 'ر.س',
      flagEmoji: '🇸🇦',
    ),
    AppCurrency(
      code: 'EGP',
      nameAr: 'جنيه مصري',
      nameEn: 'Egyptian Pound',
      countryAr: 'مصر',
      countryEn: 'Egypt',
      symbol: 'ج.م',
      flagEmoji: '🇪🇬',
    ),
    AppCurrency(
      code: 'AED',
      nameAr: 'درهم إماراتي',
      nameEn: 'UAE Dirham',
      countryAr: 'الإمارات العربية المتحدة',
      countryEn: 'United Arab Emirates',
      symbol: 'د.إ',
      flagEmoji: '🇦🇪',
    ),
    AppCurrency(
      code: 'KWD',
      nameAr: 'دينار كويتي',
      nameEn: 'Kuwaiti Dinar',
      countryAr: 'الكويت',
      countryEn: 'Kuwait',
      symbol: 'د.ك',
      flagEmoji: '🇰🇼',
    ),
    AppCurrency(
      code: 'QAR',
      nameAr: 'ريال قطري',
      nameEn: 'Qatari Riyal',
      countryAr: 'قطر',
      countryEn: 'Qatar',
      symbol: 'ر.ق',
      flagEmoji: '🇶🇦',
    ),
    AppCurrency(
      code: 'BHD',
      nameAr: 'دينار بحريني',
      nameEn: 'Bahraini Dinar',
      countryAr: 'البحرين',
      countryEn: 'Bahrain',
      symbol: 'د.ب',
      flagEmoji: '🇧🇭',
    ),
    AppCurrency(
      code: 'OMR',
      nameAr: 'ريال عماني',
      nameEn: 'Omani Rial',
      countryAr: 'سلطنة عمان',
      countryEn: 'Oman',
      symbol: 'ر.ع',
      flagEmoji: '🇴🇲',
    ),
    AppCurrency(
      code: 'JOD',
      nameAr: 'دينار أردني',
      nameEn: 'Jordanian Dinar',
      countryAr: 'الأردن',
      countryEn: 'Jordan',
      symbol: 'د.أ',
      flagEmoji: '🇯🇴',
    ),

    // العملات العالمية الرئيسية
    AppCurrency(
      code: 'USD',
      nameAr: 'دولار أمريكي',
      nameEn: 'US Dollar',
      countryAr: 'الولايات المتحدة الأمريكية',
      countryEn: 'United States',
      symbol: '\$',
      flagEmoji: '🇺🇸',
    ),
    AppCurrency(
      code: 'EUR',
      nameAr: 'يورو',
      nameEn: 'Euro',
      countryAr: 'الاتحاد الأوروبي',
      countryEn: 'European Union',
      symbol: '€',
      flagEmoji: '🇪🇺',
    ),
    AppCurrency(
      code: 'GBP',
      nameAr: 'جنيه إسترليني',
      nameEn: 'British Pound',
      countryAr: 'المملكة المتحدة',
      countryEn: 'United Kingdom',
      symbol: '£',
      flagEmoji: '🇬🇧',
    ),
    AppCurrency(
      code: 'TRY',
      nameAr: 'ليرة تركية',
      nameEn: 'Turkish Lira',
      countryAr: 'تركيا',
      countryEn: 'Turkey',
      symbol: '₺',
      flagEmoji: '🇹🇷',
    ),
  ];

  /// البحث عن العملة بكودها
  static AppCurrency findByCode(String code) {
    return popularCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => AppCurrency(
        code: code,
        nameAr: code,
        nameEn: code,
        countryAr: '',
        countryEn: '',
        symbol: code,
        flagEmoji: '🌐',
      ),
    );
  }
}
