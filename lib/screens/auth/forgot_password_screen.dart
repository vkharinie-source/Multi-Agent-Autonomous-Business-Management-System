import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Imports the AmbientBackgroundPainter and GoogleLogo

enum ForgotPasswordStep { email, otp }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  final TextEditingController _emailController = TextEditingController();
  bool _showGoogleWarning = false;

  // OTP State fields
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Timer State
  Timer? _timer;
  int _secondsRemaining = 45;
  bool _timerActive = false;

  // Background and transition animation controllers
  late final AnimationController _bgController;
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  static const double _mobileBreakpoint = 950;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    // Listen to email input to toggle Google Sign-In warning dynamically
    _emailController.addListener(() {
      final email = _emailController.text.toLowerCase();
      setState(() {
        _showGoogleWarning = email.contains('google');
      });
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _emailController.dispose();
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 45;
      _timerActive = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _timerActive = false;
        });
        _timer?.cancel();
      }
    });
  }

  void _sendOtp() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid email address.",
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = ForgotPasswordStep.otp;
    });
    _startTimer();
    // Focus first OTP field
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _otpFocusNodes[0].requestFocus();
      }
    });
  }

  void _verifyOtp() {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter the complete 6-digit OTP code.",
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show simulated success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 20,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xffD1FAE5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff10B981).withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xff059669),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "OTP Verified",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your email has been verified. You can now proceed to set a new password.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xff64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to login screen
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff10B981), Color(0xff059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Return to Login",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Ambient background from LoginScreen
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                return CustomPaint(
                  painter: AmbientBackgroundPainter(_bgController.value),
                );
              },
            ),
          ),
          // Centered Card Layout
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < _mobileBreakpoint;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 520),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xff0B1330,
                                ).withOpacity(0.08),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xffE2E8F0),
                              width: 1.0,
                            ),
                          ),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 24 : 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Back navigation and simulation pills
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (_currentStep ==
                                              ForgotPasswordStep.otp) {
                                            setState(() {
                                              _currentStep =
                                                  ForgotPasswordStep.email;
                                            });
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF8FAFC),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xffE2E8F0),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back_rounded,
                                            color: Color(0xff64748B),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      if (_currentStep ==
                                          ForgotPasswordStep.email)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _showGoogleWarning =
                                                  !_showGoogleWarning;
                                              if (_showGoogleWarning) {
                                                _emailController.text =
                                                    "user@google.com";
                                              } else {
                                                _emailController.clear();
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(
                                                  0xff2563EB,
                                                ).withOpacity(0.15),
                                              ),
                                            ),
                                            child: Text(
                                              "Simulate Google Account",
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: const Color(0xff2563EB),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  // Icon Badge & Headline based on active step
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child:
                                        _currentStep == ForgotPasswordStep.email
                                        ? _buildEmailStepHeader()
                                        : _buildOtpStepHeader(),
                                  ),
                                  const SizedBox(height: 32),

                                  // Form Body based on active step
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child:
                                        _currentStep == ForgotPasswordStep.email
                                        ? _buildEmailForm()
                                        : _buildOtpForm(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1 Components: Email Send OTP ---

  Widget _buildEmailStepHeader() {
    return Column(
      key: const ValueKey('email_header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lock Icon in a soft blue circular badge
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: const Color(0xffEFF6FF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xff3B82F6).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Color(0xff2563EB),
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Forgot Password?",
          style: GoogleFonts.inter(
            color: const Color(0xff0B1330),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Enter your registered email and we'll send you a 6-digit OTP to reset your password.",
          style: GoogleFonts.inter(
            color: const Color(0xff64748B),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      key: const ValueKey('email_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
          style: GoogleFonts.inter(
            color: const Color(0xff334155),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffE2E8F0), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff0F172A).withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(
              color: const Color(0xff0F172A),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: "Enter your email",
              hintStyle: GoogleFonts.inter(
                color: const Color(0xff94A3B8),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: const Color(0xff3B82F6).withOpacity(0.7),
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Send OTP Button (gradient blue to purple with glow)
        _AnimatedPressable(
          onTap: _sendOtp,
          child: Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff2563EB), Color(0xff9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Send OTP",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),

        // Conditional Google Alert Card
        if (_showGoogleWarning) ...[
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffE2E8F0), width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: GoogleLogo(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "This account was created using Google Sign-In. Please continue with Google to access your account instead of resetting a password.",
                        style: GoogleFonts.inter(
                          color: const Color(0xff475569),
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AnimatedPressable(
                  onTap: () {
                    // Google Sign-In Simulation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Simulating Google Sign-In...",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: const Color(0xff2563EB),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xffE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff0F172A).withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const GoogleLogo(),
                        const SizedBox(width: 10),
                        Text(
                          "Continue with Google",
                          style: GoogleFonts.inter(
                            color: const Color(0xff0F172A),
                            fontSize: 14,
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
        ],
      ],
    );
  }

  // --- Step 2 Components: OTP Code verification ---

  Widget _buildOtpStepHeader() {
    return Column(
      key: const ValueKey('otp_header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mail badge
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: const Color(0xffF5F3FF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xff7C3AED).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_unread_rounded,
            color: Color(0xff7C3AED),
            size: 26,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Verify OTP",
          style: GoogleFonts.inter(
            color: const Color(0xff0B1330),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: "We sent a 6-digit OTP to your registered email ",
            style: GoogleFonts.inter(
              color: const Color(0xff64748B),
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: _emailController.text,
                style: GoogleFonts.inter(
                  color: const Color(0xff0F172A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ". Please enter it below."),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      key: const ValueKey('otp_form'),
      children: [
        // 6 OTP Input Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              height: 56,
              child: _buildOtpTextField(index),
            );
          }),
        ),
        const SizedBox(height: 28),

        // Countdown timer & Resend button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_timerActive) ...[
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: const Color(0xff64748B).withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                "Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
                style: GoogleFonts.inter(
                  color: const Color(0xff64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else
              TextButton(
                onPressed: _startTimer,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Resend OTP",
                  style: GoogleFonts.inter(
                    color: const Color(0xff2563EB),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 32),

        // Verify OTP Button
        _AnimatedPressable(
          onTap: _verifyOtp,
          child: Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff2563EB), Color(0xff9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              "Verify OTP",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpTextField(int index) {
    return _OtpInputField(
      controller: _otpControllers[index],
      focusNode: _otpFocusNodes[index],
      onChanged: (value) {
        if (value.isNotEmpty) {
          // Move focus to the next field
          if (index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else {
            // Dismiss keyboard on the last digit
            _otpFocusNodes[index].unfocus();
          }
        } else {
          // On backspace / empty value, move focus to the previous field
          if (index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        }
      },
    );
  }
}

// Single OTP Digit Input Field with focus-state glow
class _OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<_OtpInputField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? const Color(0xff2563EB) : const Color(0xffE2E8F0),
          width: _isFocused ? 2.0 : 1.5,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: const Color(0xff2563EB).withOpacity(0.16),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: const Color(0xff0F172A).withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLines: 1,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xff0F172A),
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

// Reusable animated pressable scaling effect from login_screen.dart
class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedPressable({required this.child, required this.onTap});

  @override
  State<_AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<_AnimatedPressable> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
