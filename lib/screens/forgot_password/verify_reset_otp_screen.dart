import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';
import 'reset_password_screen.dart';

class VerifyResetOtpScreen extends StatefulWidget {
  const VerifyResetOtpScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyResetOtpScreen> createState() {
    return _VerifyResetOtpScreenState();
  }
}

class _VerifyResetOtpScreenState extends State<VerifyResetOtpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final String email = widget.email.trim().toLowerCase();

    final String otp = _otpController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance
          .verifyResetOtp(email: email, otp: otp);

      final String resetToken =
          response['reset_token']?.toString().trim() ?? '';

      if (resetToken.isEmpty) {
        throw const ApiException(
          message: 'OTP verified, but reset token was not returned.',
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        message:
            response['message']?.toString() ?? 'OTP verified successfully.',
        isError: false,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return ResetPasswordScreen(email: email, resetToken: resetToken);
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

      _showMessage(message: _cleanError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance
          .forgotPassword(email: widget.email.trim().toLowerCase());

      if (!mounted) {
        return;
      }

      _otpController.clear();

      _showMessage(
        message:
            response['message']?.toString() ??
            'A new password reset OTP has been sent.',
        isError: false,
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

      _showMessage(message: _cleanError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  String _cleanError(Object error) {
    String message = error.toString().trim();

    message = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  String? _validateOtp(String? value) {
    final String otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'Please enter the OTP';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      return 'Enter a valid 6-digit OTP';
    }

    return null;
  }

  void _showMessage({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? const Color(0xFFE74C3C)
            : const Color(0xFF21A366),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Reset OTP'), centerTitle: true),
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
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6C5CE7,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            size: 58,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Check your email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF201A3D),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We sent a password reset OTP to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6F6981),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                        const SizedBox(height: 34),
                        TextFormField(
                          controller: _otpController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 10,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter 6-digit OTP',
                            counterText: '',
                            prefixIcon: const Icon(
                              Icons.password_rounded,
                              color: Color(0xFF6C5CE7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C5CE7),
                                width: 1.8,
                              ),
                            ),
                          ),
                          validator: _validateOtp,
                          onFieldSubmitted: (String value) {
                            _verifyOtp();
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
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
                                : const Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Didn't receive the OTP?"),
                            TextButton(
                              onPressed: _isResending ? null : _resendOtp,
                              child: _isResending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Resend OTP'),
                            ),
                          ],
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
