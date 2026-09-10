import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

enum AuthMode { signIn, signUp, forgotPassword, emailConfirmationPending }

/// شاشة تسجيل الدخول وإنشاء الحساب واستعادة كلمة المرور وتأكيد البريد
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
  String? _pendingConfirmationEmail;

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
    AuthController.instance.clearSuccess();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    final auth = AuthController.instance;

    if (_mode == AuthMode.signIn) {
      final success = await auth.signInWithEmail(email: email, password: password, l10n: context.l10n);
      if (success && mounted) {
        if (widget.onAuthSuccess != null) {
          widget.onAuthSuccess!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } else if (_mode == AuthMode.signUp) {
      final result = await auth.signUpWithEmail(
        email: email,
        password: password,
        displayName: name.isNotEmpty ? name : null,
        l10n: context.l10n,
      );
      if (result.success && mounted) {
        if (result.needsEmailConfirmation) {
          setState(() {
            _pendingConfirmationEmail = email;
            _mode = AuthMode.emailConfirmationPending;
            _successMessage = null;
          });
        } else {
          setState(() {
            _successMessage = context.l10n.authAccountCreatedSuccessfully;
          });
          if (auth.isAuthenticated) {
            if (widget.onAuthSuccess != null) {
              widget.onAuthSuccess!();
            } else {
              Navigator.of(context).pop();
            }
          }
        }
      }
    } else if (_mode == AuthMode.forgotPassword) {
      final success = await auth.resetPassword(email, context.l10n);
      if (success && mounted) {
        setState(() {
          _successMessage = context.l10n.authResetEmailSent;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mode == AuthMode.signIn
              ? l10n.authSignIn
              : _mode == AuthMode.signUp
                  ? l10n.authCreateAccount
                  : _mode == AuthMode.emailConfirmationPending
                      ? l10n.authConfirmAccount
                      : l10n.authResetPassword,
        ),
        centerTitle: true,
        actions: [
          // زر المتابعة دون تسجيل كضيف
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.offline_bolt_outlined, size: 16),
            label: Text(l10n.authOfflineMode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListenableBuilder(
              listenable: AuthController.instance,
              builder: (context, _) {
                final auth = AuthController.instance;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: _mode == AuthMode.emailConfirmationPending
                        ? _buildEmailConfirmationView(context, isDark, auth)
                        : _buildAuthForm(context, isDark, auth),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailConfirmationView(
    BuildContext context,
    bool isDark,
    AuthController auth,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final displayEmail = _pendingConfirmationEmail ?? _emailController.text.trim();
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // أيقونة البريد
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              Icons.mark_email_unread_outlined,
              color: primaryColor,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 18),

        Center(
          child: Text(
            l10n.authConfirmEmailTitle,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        Center(
          child: Text(
            l10n.authAccountCreatedBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // بطاقة عرض البريد
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface(context) : Colors.blue.shade50.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    displayEmail,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // تنبيه مجلد الرسائل غير المرغوب فيها (Spam / Junk)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withOpacity(0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.authConfirmEmailBody,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: isDark ? AppColors.darkTextSecondary : Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // رسالة نجاح إعادة الإرسال
        if (auth.successMessage != null || _successMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auth.successMessage ?? _successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // رسالة خطأ إن وجدت
        if (auth.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // زر تسجيل الدخول
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () {
              _switchMode(AuthMode.signIn);
              _emailController.text = displayEmail;
            },
            icon: const Icon(Icons.login_rounded, size: 18),
            label: Text(
              l10n.authConfirmEmailAction,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // زر إعادة إرسال رابط التفعيل
        OutlinedButton.icon(
          onPressed: auth.isLoading
              ? null
              : () async {
                  final ok = await auth.resendConfirmationEmail(displayEmail, context.l10n);
                  if (ok && mounted) {
                    setState(() {
                      _successMessage = l10n.authResendSuccess;
                    });
                  }
                },
          icon: auth.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded, size: 18),
          label: Text(l10n.authResendLink),
        ),
        const SizedBox(height: 8),

        // زر تعديل البريد
        TextButton(
          onPressed: () => _switchMode(AuthMode.signUp),
          child: Text(l10n.authChangeEmail, style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildAuthForm(
    BuildContext context,
    bool isDark,
    AuthController auth,
  ) {
    final l10n = context.l10n;
    return Form(
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
                  ? l10n.authWelcomeBack
                  : _mode == AuthMode.signUp
                      ? l10n.authGetStartedSubtitle
                      : l10n.authResetPassword,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _mode == AuthMode.signIn
                  ? l10n.authSignInSubtitle
                  : _mode == AuthMode.signUp
                      ? l10n.authSignUpSubtitle
                      : l10n.authResetEmailHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // رسالة نجاح
          if (_successMessage != null || auth.successMessage != null) ...[
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
                      auth.successMessage ?? _successMessage!,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // تنبيه وإجراء خاص عند محاولة تسجيل الدخول ببريد غير مؤكد
          if (_mode == AuthMode.signIn && auth.isEmailNotConfirmed) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mark_email_unread_outlined, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.authConfirmRequired,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.authConfirmEmailResent,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) return;
                            final ok = await auth.resendConfirmationEmail(email, context.l10n);
                            if (ok && mounted) {
                              setState(() {
                                _successMessage = context.l10n.authResendActivationSuccess(email);
                              });
                            }
                          },
                    icon: auth.isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 15),
                    label: Text(
                      l10n.authResendActivation,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // حقل الاسم في وضع إنشاء الحساب
          if (_mode == AuthMode.signUp) ...[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.authFullName,
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.authNameRequired;
                return null;
              },
            ),
            const SizedBox(height: 14),
          ],

          // حقل البريد الإلكتروني
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.authEmailLabel,
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.authEmailRequired;
              if (!Validators.isValidEmail(v.trim())) return l10n.authEmailInvalid;
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
                labelText: l10n.authPasswordLabel,
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
                if (v == null || v.isEmpty) return l10n.authPasswordRequired;
                if (v.length < 6) return l10n.authPasswordMin;
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
                  child: Text(l10n.authForgotPassword, style: TextStyle(fontSize: 12)),
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
                          ? l10n.authSignIn
                          : _mode == AuthMode.signUp
                              ? l10n.authCreateAccountAction
                              : l10n.authSendResetLink,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // روابط التبديل
          if (_mode == AuthMode.signIn) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.authNoAccount, style: TextStyle(fontSize: 13)),
                TextButton(
                  onPressed: () => _switchMode(AuthMode.signUp),
                  child: Text(l10n.authCreateAccount, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.authHasAccount, style: TextStyle(fontSize: 13)),
                TextButton(
                  onPressed: () => _switchMode(AuthMode.signIn),
                  child: Text(l10n.authSignIn, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],

          const Divider(height: 24),

          // خيار المتابعة دون تسجيل (Offline-First)
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.flash_on_outlined, size: 18),
            label: Text(l10n.authContinueOffline),
          ),
        ],
      ),
    );
  }
}
