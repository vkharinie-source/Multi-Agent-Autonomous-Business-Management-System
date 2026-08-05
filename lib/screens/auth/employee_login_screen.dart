import 'package:flutter/material.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../employee/employee_dashboard.dart';
import '../forgot_password/forgot_password_screen.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(message),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance.login(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      final dynamic rawUser = response['user'];

      if (rawUser is! Map) {
        throw const ApiException(message: 'User details were not returned.');
      }

      final Map<String, dynamic> user = Map<String, dynamic>.from(rawUser);

      final String role = user['role']?.toString().trim().toLowerCase() ?? '';

      if (role != 'employee') {
        await AuthService.instance.logout();

        throw const ApiException(
          message:
              'This page is only for Employee accounts. Use Manager / Admin Sign In.',
          statusCode: 403,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(message: 'Employee login successful.', isError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmployeeDashboard()),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(message: error.message, isError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        message: error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: const Color(0xFF7C6AE6)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F4FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE2DAF8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE2DAF8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF7C6AE6), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2E285C),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Employee Sign In',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E285C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with your employee account to continue.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF7E7898),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C6AE6).withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C6AE6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Autonomous Business AI',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E285C),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Smart. Secure. Automated.',
                                  style: TextStyle(
                                    color: Color(0xFF8C87A3),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Company email',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF403A68),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          hintText: 'Enter your company email',
                          icon: Icons.alternate_email_rounded,
                        ),
                        validator: (value) {
                          final String email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Please enter your email';
                          }

                          if (!RegExp(
                            r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(email)) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF403A68),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          hintText: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF7C6AE6),
                            ),
                          ),
                        ),
                        validator: (value) {
                          final String password = value ?? '';

                          if (password.trim().isEmpty) {
                            return 'Please enter your password';
                          }

                          if (password.length < 6) {
                            return 'Password must be at least 6 characters';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: const Color(0xFF7C6AE6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              color: Color(0xFF6A6583),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF7C6AE6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A5AF9), Color(0xFF9A45F6)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF7C6AE6,
                                ).withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.6,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
