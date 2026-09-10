import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

/// نتيجة محاولة إنشاء الحساب
class SignUpResult {
  final bool success;
  final bool needsEmailConfirmation;
  final String? email;
  final String? errorMessage;

  const SignUpResult({
    required this.success,
    this.needsEmailConfirmation = false,
    this.email,
    this.errorMessage,
  });
}

/// متحكم إدارة حالة المصادقة وحسابات المستخدمين
class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._internal();
  AuthController._internal() {
    _initListener();
  }

  StreamSubscription<AuthState>? _authSubscription;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isEmailNotConfirmed = false;
  String? _unconfirmedEmail;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isEmailNotConfirmed => _isEmailNotConfirmed;
  String? get unconfirmedEmail => _unconfirmedEmail;

  String? get userEmail => _currentUser?.email;
  String? get displayName =>
      _currentUser?.userMetadata?['display_name'] as String? ??
      _currentUser?.email?.split('@').first;

  void _initListener() {
    try {
      _currentUser = SupabaseService.client.auth.currentUser;
      _authSubscription =
          SupabaseService.client.auth.onAuthStateChange.listen((data) {
        _currentUser = data.session?.user;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      });
    } catch (_) {
      // وضع الأوفلاين في حال تعذر الاتصال
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _isEmailNotConfirmed = false;
    _unconfirmedEmail = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isEmailNotConfirmed = isUnconfirmedError(e.message, e.statusCode);
      if (_isEmailNotConfirmed) {
        _unconfirmedEmail = email.trim();
      }
      _errorMessage = translateAuthError(e.message, e.statusCode);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال، يرجى المحاولة لاحقاً';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إنشاء حساب جديد
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _isEmailNotConfirmed = false;
    _unconfirmedEmail = null;
    notifyListeners();

    try {
      final String? redirectTo = kIsWeb ? Uri.base.origin : null;

      final response = await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: redirectTo,
        data: displayName != null ? {'display_name': displayName.trim()} : null,
      );
      _currentUser = response.user;
      _isLoading = false;

      // إذا كان session == null و user != null، فالمستخدم يتطلب تأكيد البريد
      final needsEmailConfirmation =
          response.session == null && response.user != null;
      if (needsEmailConfirmation) {
        _isEmailNotConfirmed = true;
        _unconfirmedEmail = email.trim();
      }

      notifyListeners();
      return SignUpResult(
        success: true,
        needsEmailConfirmation: needsEmailConfirmation,
        email: email.trim(),
      );
    } on AuthException catch (e) {
      _isEmailNotConfirmed = isUnconfirmedError(e.message, e.statusCode);
      if (_isEmailNotConfirmed) {
        _unconfirmedEmail = email.trim();
      }
      _errorMessage = translateAuthError(e.message, e.statusCode);
      _isLoading = false;
      notifyListeners();
      return SignUpResult(
        success: false,
        errorMessage: _errorMessage,
      );
    } catch (e) {
      _errorMessage = 'حدث خطأ في إنشاء الحساب، يرجى المحاولة لاحقاً';
      _isLoading = false;
      notifyListeners();
      return SignUpResult(
        success: false,
        errorMessage: _errorMessage,
      );
    }
  }

  /// إعادة إرسال رابط تأكيد البريد الإلكتروني
  Future<bool> resendConfirmationEmail([String? email]) async {
    final targetEmail = (email ?? _unconfirmedEmail)?.trim();
    if (targetEmail == null || targetEmail.isEmpty) {
      _errorMessage = 'يرجى إدخال البريد الإلكتروني لإعادة إرسال الرابط';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final String? redirectTo = kIsWeb ? Uri.base.origin : null;

      await SupabaseService.client.auth.resend(
        type: OtpType.signup,
        email: targetEmail,
        emailRedirectTo: redirectTo,
      );
      _isLoading = false;
      _successMessage = 'تمت إعادة إرسال رابط التفعيل إلى $targetEmail بنجاح!';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = translateAuthError(e.message, e.statusCode);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'تعذر إعادة إرسال رابط التفعيل، يرجى المحاولة لاحقاً';
      notifyListeners();
      return false;
    }
  }

  /// استعادة كلمة المرور
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final String? redirectTo = kIsWeb ? Uri.base.origin : null;

      await SupabaseService.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectTo,
      );
      _isLoading = false;
      _successMessage = 'تم إرسال رابط استعادة كلمة المرور إلى بريدك.';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = translateAuthError(e.message, e.statusCode);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'تعذر إرسال رابط الاستعادة';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث الاسم المعروض (يعرض اسماً هادفاً في الواجهات).
  Future<bool> updateDisplayName(String newName) async {
    final name = newName.trim();
    if (name.isEmpty || _currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.updateUser(
        UserAttributes(data: {'display_name': name}),
      );
      _currentUser = response.user;
      _isLoading = false;
      _successMessage = 'تم تحديث الاسم المعروض بنجاح';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = translateAuthError(e.message, e.statusCode);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'تعذر تحديث الاسم، يرجى المحاولة لاحقاً';
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    _currentUser = null;
    _errorMessage = null;
    _successMessage = null;
    _isEmailNotConfirmed = false;
    _unconfirmedEmail = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  static bool isUnconfirmedError(String message, [String? code]) {
    final lower = message.toLowerCase();
    final lowerCode = code?.toLowerCase();
    return lowerCode == 'email_not_confirmed' ||
        lower.contains('email not confirmed') ||
        lower.contains('email is not confirmed');
  }

  static String translateAuthError(String message, [String? code]) {
    final lower = message.toLowerCase();
    final lowerCode = code?.toLowerCase();

    if (lowerCode == 'email_not_confirmed' ||
        lower.contains('email not confirmed') ||
        lower.contains('email is not confirmed')) {
      return 'لم يتم تأكيد بريدك الإلكتروني بعد. يرجى فتح الرسالة المرسلة إلى بريدك والنقر على رابط التفعيل لتسجيل الدخول.';
    } else if (lower.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (lower.contains('user already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    } else if (lower.contains('password should be at least')) {
      return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
    } else if (lower.contains('invalid email')) {
      return 'صيغة البريد الإلكتروني غير صالحة';
    } else if (lower.contains('rate limit') ||
        lower.contains('for security purposes')) {
      return 'يرجى الانتظار دقيقة قبل طلب إرسال رابط جديد';
    }
    return message;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
