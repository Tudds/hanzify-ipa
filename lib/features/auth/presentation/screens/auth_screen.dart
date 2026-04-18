import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/theme_state.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/app_theme_helper.dart';
import '../../../../core/widgets/hanzify_button.dart';
import '../../../../core/widgets/hanzify_snack.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          data: {'name': _nameCtrl.text.trim()},
        );
        if (mounted) {
          HanzifySnack.success(context, 'Kiểm tra email để xác nhận tài khoản!');
        }
      }
    } on AuthException catch (e) {
      if (mounted) HanzifySnack.error(context, e.message);
    } catch (_) {
      if (mounted) HanzifySnack.error(context, 'Lỗi không xác định');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      HanzifySnack.info(context, 'Nhập email trước');
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) HanzifySnack.success(context, 'Đã gửi link đặt lại mật khẩu!');
    } on AuthException catch (e) {
      if (mounted) HanzifySnack.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Text(
                    '汉字',
                    textAlign: TextAlign.center,
                    style: AppTypography.headline(
                      fontSize: 56,
                      color: c.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hanzify',
                    textAlign: TextAlign.center,
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelLg,
                      color: c.placeholder,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tab toggle login / signup
                  Container(
                    decoration: BoxDecoration(
                      color: c.surfaceLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _tab('Đăng nhập', _isLogin, c, () => setState(() => _isLogin = true)),
                        _tab('Đăng ký', !_isLogin, c, () => setState(() => _isLogin = false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name field (signup only)
                  if (!_isLogin) ...[
                    _field(
                      controller: _nameCtrl,
                      label: 'Tên hiển thị',
                      icon: Icons.person_outline,
                      c: c,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nhập tên của bạn' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  _field(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    c: c,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _field(
                    controller: _passwordCtrl,
                    label: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    c: c,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: c.placeholder,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                  ),
                  const SizedBox(height: 28),

                  // Submit
                  AbsorbPointer(
                    absorbing: _loading,
                    child: Opacity(
                      opacity: _loading ? 0.6 : 1.0,
                      child: _loading
                          ? Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              decoration: BoxDecoration(
                                gradient: c.primaryGradient,
                                borderRadius: BorderRadius.circular(AppRadii.xl),
                              ),
                              child: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : HanzifyButton(
                              label: _isLogin ? 'Đăng nhập' : 'Tạo tài khoản',
                              onTap: _submit,
                            ),
                    ),
                  ),

                  // Forgot password
                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading ? null : _forgotPassword,
                      child: Text(
                        'Quên mật khẩu?',
                        style: AppTypography.body(
                          fontSize: AppFontSizes.bodySm,
                          color: c.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, AppThemeColors c, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label(
              fontSize: AppFontSizes.labelMd,
              color: active ? c.text : c.placeholder,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppThemeColors c,
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    final borderColor = c.placeholder.withValues(alpha: 0.25);
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      style: AppTypography.body(fontSize: AppFontSizes.bodyMd, color: c.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.body(fontSize: AppFontSizes.bodySm, color: c.placeholder),
        prefixIcon: Icon(icon, color: c.placeholder, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: c.surfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
