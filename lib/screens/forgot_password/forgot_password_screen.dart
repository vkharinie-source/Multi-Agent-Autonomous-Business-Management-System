import 'package:flutter/material.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';
import 'verify_reset_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() {
    return _ForgotPasswordScreenState();
  }
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final String email = _emailController.text.trim().toLowerCase();

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance
          .forgotPassword(email: email);

      if (!mounted) {
        return;
      }

      _showMessage(
        message:
            response['message']?.toString() ??
            'Password reset OTP sent successfully.',
        isError: false,
      );

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return VerifyResetOtpScreen(email: email);
          },
        ),
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

      String message = error.toString().replaceFirst('Exception: ', '').trim();

      if (message.isEmpty) {
        message = 'Unable to send the password reset OTP.';
      }

      _showMessage(message: message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your registered email';
    }

    final RegExp emailPattern = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  void _showMessage({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE74C3C)
            : const Color(0xFF21A366),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      labelText: 'Registered email address',
      hintText: 'Enter your registered email',
      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C5CE7)),
      filled: true,
      fillColor: const Color(0xFFF8F6FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E0EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE74C3C)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF9B6CFF)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Forgot your password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF201A3D),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Enter your registered email address. We will send a password reset OTP.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6F6981),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          validator: _validateEmail,
                          decoration: _inputDecoration(),
                          onFieldSubmitted: (String value) {
                            _sendOtp();
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send_rounded),
                                      SizedBox(width: 10),
                                      Text(
                                        'Send OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
