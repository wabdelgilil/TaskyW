import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

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

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get userEmail => _currentUser?.email;
  String? get displayName => _currentUser?.userMetadata?['display_name'] as String? ?? _currentUser?.email?.split('@').first;

  void _initListener() {
    try {
      _currentUser = SupabaseService.client.auth.currentUser;
      _authSubscription = SupabaseService.client.auth.onAuthStateChange.listen((data) {
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
      _errorMessage = _translateAuthError(e.message);
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
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: displayName != null ? {'display_name': displayName.trim()} : null,
      );
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _translateAuthError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إنشاء الحساب، يرجى المحاولة لاحقاً';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// استعادة كلمة المرور
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseService.client.auth.resetPasswordForEmail(email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _translateAuthError(e.message);
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

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _translateAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (message.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    } else if (message.contains('Password should be at least')) {
      return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
    } else if (message.contains('invalid email')) {
      return 'صيغة البريد الإلكتروني غير صالحة';
    }
    return message;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
