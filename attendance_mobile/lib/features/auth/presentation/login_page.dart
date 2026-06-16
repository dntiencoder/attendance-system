import 'package:flutter/material.dart';

import '../data/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _employeeCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authRepository.login(
        employeeCode: _employeeCodeController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final employeeCodeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Quên mật khẩu'),
          content: TextField(
            controller: employeeCodeController,
            textCapitalization:
            TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Mã nhân viên',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator =
                Navigator.of(dialogContext);

                final messenger =
                ScaffoldMessenger.of(context);

                try {
                  await _authRepository
                      .sendResetPasswordEmail(
                    employeeCodeController.text,
                  );

                  navigator.pop();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Đã gửi email đặt lại mật khẩu',
                      ),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _employeeCodeController,
              textCapitalization:
              TextCapitalization.characters,
              textInputAction:
              TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Mã nhân viên',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              textInputAction:
              TextInputAction.done,
              onSubmitted: (_) => _login(),
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                _showForgotPasswordDialog,
                child:
                const Text('Quên mật khẩu?'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Đăng nhập',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}