import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.isSuccess) {
        // Sử dụng go thay vì push để reset stack
        context.go('/dashboard');
        
        // Backup: Nếu go vẫn lỗi thì dùng Navigator truyền thống
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => const DashboardScreen()),
        // );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo + tiêu đề
                Image.asset(
                  'assets/logo_umc.jpg',
                  height: 56,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.business,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'UMC ATTENDANCE SYSTEM',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hệ Thống Quản Trị Chấm Công GPS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                    if (!v.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Mật khẩu
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Nút đăng nhập
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    icon: authState.isLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.login_rounded),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text(
                      authState.isLoading ? 'Đang đăng nhập...' : 'ĐĂNG NHẬP HỆ THỐNG',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}