import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../l10n/app_localizations.dart';

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
    AppLocalizations? l10n,
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
      _errorMessage = translateAuthError(e.message, e.statusCode, l10n);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = l10n?.authConnectionError ?? 'Connection error, please try again later';
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
    AppLocalizations? l10n,
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
      _errorMessage = translateAuthError(e.message, e.statusCode, l10n);
      _isLoading = false;
      notifyListeners();
      return SignUpResult(
        success: false,
        errorMessage: _errorMessage,
      );
    } catch (e) {
      _errorMessage = l10n?.authSignUpError ?? 'Failed to create account, please try again later';
      _isLoading = false;
      notifyListeners();
      return SignUpResult(
        success: false,
        errorMessage: _errorMessage,
      );
    }
  }

  /// إعادة إرسال رابط تأكيد البريد الإلكتروني
  Future<bool> resendConfirmationEmail([String? email, AppLocalizations? l10n]) async {
    final targetEmail = (email ?? _unconfirmedEmail)?.trim();
    if (targetEmail == null || targetEmail.isEmpty) {
      _errorMessage = l10n?.authEnterEmailForResend ?? 'Please enter your email to resend the link';
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
      _successMessage = l10n?.authResendActivationSuccess(targetEmail) ?? 'The activation link has been resent to $targetEmail! Check your email now.';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = translateAuthError(e.message, e.statusCode, l10n);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = l10n?.authResendActivationError ?? 'Failed to resend activation link, please try again later';
      notifyListeners();
      return false;
    }
  }

  /// استعادة كلمة المرور
  Future<bool> resetPassword(String email, [AppLocalizations? l10n]) async {
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
      _successMessage = l10n?.authResetEmailSent ?? 'A password reset link has been sent to your email.';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = translateAuthError(e.message, e.statusCode, l10n);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = l10n?.authResetPasswordError ?? 'Failed to send reset link';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث الاسم المعروض (يعرض اسماً هادفاً في الواجهات).
  Future<bool> updateDisplayName(String newName, [AppLocalizations? l10n]) async {
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
      _successMessage = l10n?.authDisplayNameUpdated ?? 'Display name updated successfully';
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = translateAuthError(e.message, e.statusCode, l10n);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = l10n?.authUpdateNameError ?? 'Failed to update name, please try again later';
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

  static String translateAuthError(String message, [String? code, AppLocalizations? l10n]) {
    final lower = message.toLowerCase();
    final lowerCode = code?.toLowerCase();

    if (lowerCode == 'email_not_confirmed' ||
        lower.contains('email not confirmed') ||
        lower.contains('email is not confirmed')) {
      return l10n?.authEmailNotConfirmed ?? 'Your email hasn\'t been confirmed yet. Please open the email and click the activation link to sign in.';
    } else if (lower.contains('invalid login credentials')) {
      return l10n?.authInvalidCredentials ?? 'Invalid email or password';
    } else if (lower.contains('user already registered')) {
      return l10n?.authUserAlreadyRegistered ?? 'This email is already registered';
    } else if (lower.contains('password should be at least')) {
      return l10n?.authPasswordTooShort ?? 'Password must be at least 6 characters';
    } else if (lower.contains('invalid email')) {
      return l10n?.authInvalidEmail ?? 'Invalid email format';
    } else if (lower.contains('rate limit') ||
        lower.contains('for security purposes')) {
      return l10n?.authRateLimit ?? 'Please wait a minute before requesting a new link';
    }
    return message;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
