import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

enum AuthMode { signIn, signUp, forgotPassword }

/// شاشة تسجيل الدخول وإنشاء الحساب واستعادة كلمة المرور
class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthSuccess;

  const AuthScreen({super.key, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  bool _obscurePassword = true;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _mode = mode;
      _successMessage = null;
    });
    AuthController.instance.clearError();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    final auth = AuthController.instance;

    if (_mode == AuthMode.signIn) {
      final success = await auth.signInWithEmail(email: email, password: password);
      if (success && mounted) {
        if (widget.onAuthSuccess != null) {
          widget.onAuthSuccess!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } else if (_mode == AuthMode.signUp) {
      final success = await auth.signUpWithEmail(
        email: email,
        password: password,
        displayName: name.isNotEmpty ? name : null,
      );
      if (success && mounted) {
        setState(() {
          _successMessage = 'تم إنشاء الحساب بنجاح! تفقد بريدك لتأكيد الحساب إذا تطلب الأمر.';
        });
        if (auth.isAuthenticated) {
          if (widget.onAuthSuccess != null) {
            widget.onAuthSuccess!();
          } else {
            Navigator.of(context).pop();
          }
        }
      }
    } else if (_mode == AuthMode.forgotPassword) {
      final success = await auth.resetPassword(email);
      if (success && mounted) {
        setState(() {
          _successMessage = 'تم إرسال رابط استعادة كلمة المرور إلى بريدك.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mode == AuthMode.signIn
              ? 'تسجيل الدخول'
              : _mode == AuthMode.signUp
                  ? 'إنشاء حساب جديد'
                  : 'استعادة كلمة المرور',
        ),
        centerTitle: true,
        actions: [
          // زر المتابعة دون تسجيل كضيف
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.offline_bolt_outlined, size: 16),
            label: const Text('وضع الأوفلاين'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListenableBuilder(
              listenable: AuthController.instance,
              builder: (context, _) {
                final auth = AuthController.instance;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // أيقونة وهوية التطبيق
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock_outline_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Center(
                            child: Text(
                              _mode == AuthMode.signIn
                                  ? 'مرحباً بعودتك إلى Tasky'
                                  : _mode == AuthMode.signUp
                                      ? 'ابدأ إدارة مشاريعك باحتراف'
                                      : 'استعادة كلمة المرور',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              _mode == AuthMode.signIn
                                  ? 'سجل دخولك لمزامنة مهامك ومشاركتها مع فريقك'
                                  : _mode == AuthMode.signUp
                                      ? 'أنشئ حسابك للنسخ الاحتياطي السحابي والمشاركة'
                                      : 'أدخل بريدك المسجل لإرسال رابط التعيين',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // رسالة نجاح
                          if (_successMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _successMessage!,
                                      style: const TextStyle(color: Colors.green, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // رسالة خطأ
                          if (auth.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auth.errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // حقل الاسم في وضع إنشاء الحساب
                          if (_mode == AuthMode.signUp) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'الاسم الكامل',
                                prefixIcon: Icon(Icons.person_outline, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'يرجى كتابة الاسم';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          // حقل البريد الإلكتروني
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              hintText: 'name@example.com',
                              prefixIcon: Icon(Icons.email_outlined, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'يرجى كتابة البريد الإلكتروني';
                              if (!Validators.isValidEmail(v.trim())) return 'بريد إلكتروني غير صحيح';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // حقل كلمة المرور (في الدخول والإنشاء)
                          if (_mode != AuthMode.forgotPassword) ...[
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'يرجى كتابة كلمة المرور';
                                if (v.length < 6) return 'كلمة المرور 6 خانات كحد أدنى';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // رابط نسيت كلمة المرور
                            if (_mode == AuthMode.signIn)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () => _switchMode(AuthMode.forgotPassword),
                                  child: const Text('نسيت كلمة المرور؟', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                          ],

                          const SizedBox(height: 16),

                          // زر الإرسال الرئيسي
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      _mode == AuthMode.signIn
                                          ? 'تسجيل الدخول'
                                          : _mode == AuthMode.signUp
                                              ? 'إنشاء الحساب'
                                              : 'إرسال رابط الاستعادة',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // روابط التبديل
                          if (_mode == AuthMode.signIn) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('ليس لديك حساب بعد؟', style: TextStyle(fontSize: 13)),
                                TextButton(
                                  onPressed: () => _switchMode(AuthMode.signUp),
                                  child: const Text('إنشاء حساب جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('لديك حساب بالفعل؟', style: TextStyle(fontSize: 13)),
                                TextButton(
                                  onPressed: () => _switchMode(AuthMode.signIn),
                                  child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],

                          const Divider(height: 24),

                          // خيار المتابعة دون تسجيل (Offline-First)
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.flash_on_outlined, size: 18),
                            label: const Text('المتابعة دون حساب (محلياً)'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
