import 'package:flutter/material.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  final String email;
  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() {
    return _ResetPasswordScreenState();
  }
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance
          .resetPassword(
            email: widget.email,
            resetToken: widget.resetToken,
            newPassword: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      _showMessage(
        message:
            response['message']?.toString() ?? 'Password reset successfully.',
        isError: false,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return const LoginScreen();
          },
        ),
        (Route<dynamic> route) {
          return false;
        },
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

      String message = error.toString().trim();

      message = message
          .replaceFirst('Exception: ', '')
          .replaceFirst('ApiException: ', '')
          .trim();

      _showMessage(
        message: message.isEmpty ? 'Unable to reset password.' : message,
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

  String? _validatePassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter a new password';
    }

    if (password.length < 8) {
      return 'Password must have at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final String confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your new password';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _showMessage({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFE74C3C)
            : const Color(0xFF21A366),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EEFF), Color(0xFFEDE8FF), Color(0xFFF8F6FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock_reset_rounded,
                          size: 80,
                          color: Color(0xFF6C5CE7),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Create new password',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF201A3D),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: _hidePassword,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            labelText: 'New password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          enabled: !_isLoading,
                          obscureText: _hideConfirmPassword,
                          validator: _validateConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm new password',
                            prefixIcon: const Icon(
                              Icons.verified_user_outlined,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideConfirmPassword = !_hideConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
