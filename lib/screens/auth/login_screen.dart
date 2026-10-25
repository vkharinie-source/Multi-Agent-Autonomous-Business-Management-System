import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../employee/employee_dashboard.dart' as employee_dashboard;
import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';

import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool rememberMe = true;
  bool hidePassword = true;
  bool _isLoading = false;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  static const double _mobileBreakpoint = 950;

  late final AnimationController _bgController;
  late final AnimationController _entryController;
  late final AnimationController _robotController;

  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _robotOffset;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _robotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    _robotOffset = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _robotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _bgController.dispose();
    _entryController.dispose();
    _robotController.dispose();

    super.dispose();
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
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
        await AuthService.instance.logout();

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

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const employee_dashboard.EmployeeDashboard();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 450),
        ),
        (route) => false,
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

      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();

      _showMessage(
        message: message.isEmpty
            ? 'Unable to connect to the backend server.'
            : message,
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
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE74C3C)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background.
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

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < _mobileBreakpoint;

                if (isMobile) {
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
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withValues(alpha: 0.08),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [mobileBanner(), rightPanel(isMobile)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final double cardWidth = constraints.maxWidth.clamp(
                  0.0,
                  1200.0,
                );

                final double cardHeight = constraints.maxHeight.clamp(
                  0.0,
                  780.0,
                );

                return Center(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Container(
                          width: cardWidth > 1000 ? 1200 : cardWidth,
                          height: cardHeight > 700 ? 780 : null,
                          constraints: const BoxConstraints(minHeight: 700),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0B1330,
                                ).withValues(alpha: 0.12),
                                blurRadius: 60,
                                offset: const Offset(0, 24),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [leftPanel(), rightPanel(isMobile)],
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

  // Mobile top banner.
  Widget mobileBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF281E30), Color(0xFF4C3C56), Color(0xFF6B5875)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9988A1), Color(0xFF7A6883)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9988A1).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AUTONOMOUS',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFE0E7FF), Color(0xFFC084FC)],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'BUSINESS AI',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Smart Decisions. Stronger Business.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Desktop left-side branding panel.
  Widget leftPanel() {
    return Expanded(
      flex: 47,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1724), Color(0xFF281E30), Color(0xFF3D3046)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            bottomLeft: Radius.circular(32),
          ),
        ),
        child: Stack(
          children: [
            // Background dot-grid design.
            Positioned.fill(child: CustomPaint(painter: DotGridPainter())),

            // Mauve glow.
            Positioned(
              top: -60,
              left: -60,
              child: glowBlob(
                260,
                const Color(0xFF9988A1).withValues(alpha: 0.18),
              ),
            ),

            // Deep mauve glow.
            Positioned(
              bottom: -80,
              right: -80,
              child: glowBlob(
                300,
                const Color(0xFF7A6883).withValues(alpha: 0.22),
              ),
            ),

            // Soft plum glow.
            Positioned(
              top: 200,
              right: -50,
              child: glowBlob(
                200,
                const Color(0xFF5E4E68).withValues(alpha: 0.15),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(44, 48, 44, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Application logo and title.
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9988A1), Color(0xFF7A6883)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF9988A1,
                              ).withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUTONOMOUS',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 10,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFDED8E4),
                                  Color(0xFF9988A1),
                                ],
                              ).createShader(bounds);
                            },
                            child: Text(
                              'BUSINESS AI',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Smart Decisions. Stronger Business.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(),

                  // Robot and business cards.
                  Center(
                    child: SizedBox(
                      width: 360,
                      height: 340,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow behind the robot.
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(
                                    0xFF9988A1,
                                  ).withValues(alpha: 0.35),
                                  const Color(0xFF9988A1).withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),

                          // Animated AI robot image.
                          AnimatedBuilder(
                            animation: _robotOffset,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _robotOffset.value),
                                child: Image.asset(
                                  'assets/images/ai_robot_glossy.png',
                                  height: 230,
                                  width: 230,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4C3C56),
                                            Color(0xFF9988A1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF9988A1,
                                            ).withValues(alpha: 0.35),
                                            blurRadius: 35,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.smart_toy_rounded,
                                        color: Colors.white,
                                        size: 85,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          // Total sales card.
                          Positioned(
                            top: 25,
                            left: 0,
                            child: SizedBox(
                              width: 195,
                              child: frostedGlassCard(
                                title: 'Total Sales',
                                value: '\$24,780',
                                sparklineData: const [
                                  22,
                                  28,
                                  24,
                                  32,
                                  29,
                                  36,
                                  33,
                                  40,
                                ],
                                lineColor: const Color(0xFF10B981),
                                trendPercent: '+12.5%',
                                isUp: true,
                              ),
                            ),
                          ),

                          // Profit card.
                          Positioned(
                            bottom: 25,
                            right: 0,
                            child: SizedBox(
                              width: 185,
                              child: frostedGlassCard(
                                title: 'Profit',
                                value: '\$8,460',
                                sparklineData: const [
                                  15,
                                  13,
                                  19,
                                  15,
                                  23,
                                  21,
                                  28,
                                ],
                                lineColor: const Color(0xFF3B82F6),
                                trendPercent: '+8.2%',
                                isUp: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  quoteFooterNew(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Glass business-statistics card.
  Widget frostedGlassCard({
    required String title,
    required String value,
    required List<double> sparklineData,
    required Color lineColor,
    required String trendPercent,
    required bool isUp,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isUp
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: lineColor,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trendPercent,
                          style: GoogleFonts.inter(
                            color: lineColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 36,
                child: CustomPaint(
                  painter: SparklinePainter(sparklineData, lineColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom information card.
  Widget quoteFooterNew() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9988A1), Color(0xFF7A6883)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9988A1).withValues(alpha: 0.30),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empowered by AI intelligence',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.90),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Automate decisions, predict growth.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Background glowing circle.
  Widget glowBlob(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }

  // Right-side login form panel.
  Widget rightPanel(bool isMobile) {
    final Widget formCard = Container(
      width: isMobile ? double.infinity : 520,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Welcome badge.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9988A1).withValues(alpha: 0.12),
                    const Color(0xFF7A6883).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF9988A1).withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7A6883),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main login heading.
            Text(
              'Login to your account',
              style: GoogleFonts.inter(
                color: const Color(0xFF9988A1),
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Access your AI-powered business dashboard and manage your operations smarter.',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Email field.
            customInputField(
              controller: _emailController,
              icon: Icons.email_outlined,
              title: 'Email Address',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),

            const SizedBox(height: 20),

            // Password field.
            customInputField(
              controller: _passwordController,
              icon: Icons.lock_outline,
              title: 'Password',
              hint: 'Enter your password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onFieldSubmitted: (_) {
                login();
              },
            ),

            const SizedBox(height: 16),

            // Remember me and forgot password.
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: rememberMe,
                    activeColor: const Color(0xFF9988A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  'Remember me',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ForgotPasswordScreen();
                              },
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7A6883),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Login button.
            gradientCtaButton(),

            const SizedBox(height: 28),

            // Social-login divider.
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'or continue with',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              ],
            ),

            const SizedBox(height: 22),

            // Social login buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                socialButton(
                  logo: const GoogleLogo(),
                  onTap: () {
                    _showMessage(
                      message: 'Google login will be connected later.',
                      isError: true,
                    );
                  },
                ),
                socialButton(
                  logo: const MicrosoftLogo(),
                  onTap: () {
                    _showMessage(
                      message: 'Microsoft login will be connected later.',
                      isError: true,
                    );
                  },
                ),
                socialButton(
                  logo: const Icon(
                    Icons.apple,
                    size: 22,
                    color: Color(0xFF0F172A),
                  ),
                  onTap: () {
                    _showMessage(
                      message: 'Apple login will be connected later.',
                      isError: true,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Open registration page.
            Center(
              child: GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const RegisterScreen();
                            },
                          ),
                        );
                      },
                child: Text.rich(
                  TextSpan(
                    text: 'New to Business AI? ',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Create account',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9988A1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      return formCard;
    }

    return Expanded(
      flex: 53,
      child: Center(child: SingleChildScrollView(child: formCard)),
    );
  }

  // Email validation.
  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    final RegExp emailPattern = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation.
  String? _validatePassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.length < 6) {
      return 'Password must have at least 6 characters';
    }

    return null;
  }

  // Reusable email and password field.
  Widget customInputField({
    required TextEditingController controller,
    required IconData icon,
    required String title,
    required String hint,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: isPassword && hidePassword,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          enabled: !_isLoading,
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE74C3C),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Login button with loading animation.
  Widget gradientCtaButton() {
    return _AnimatedPressable(
      onTap: _isLoading
          ? () {}
          : () {
              login();
            },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _isLoading ? 0.72 : 1,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9988A1), Color(0xFF7A6883)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9988A1).withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login to Dashboard',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Google, Microsoft and Apple buttons.
  static Widget socialButton({
    required Widget logo,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: _AnimatedPressable(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF281E30).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: logo),
          ),
        ),
      ),
    );
  }
}

// Press animation for buttons.
class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressable({required this.child, required this.onTap});

  @override
  State<_AnimatedPressable> createState() {
    return _AnimatedPressableState();
  }
}

class _AnimatedPressableState extends State<_AnimatedPressable> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.97;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1;
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1;
        });
      },
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

// Professional Google logo with precise vector geometry.
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24.0;
    canvas.save();
    canvas.scale(s, s);

    // 1. Blue (Right bar and arc)
    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path bluePath = Path()
      ..moveTo(23.74, 12.27)
      ..cubicTo(23.74, 11.48, 23.67, 10.73, 23.55, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.51)
      ..lineTo(18.59, 14.51)
      ..cubicTo(18.31, 16.03, 17.45, 17.31, 16.16, 18.17)
      ..lineTo(16.16, 21.26)
      ..lineTo(20.08, 21.26)
      ..cubicTo(22.38, 19.14, 23.74, 16.0, 23.74, 12.27)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 2. Green (Bottom)
    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path greenPath = Path()
      ..moveTo(12.0, 24.0)
      ..cubicTo(15.24, 24.0, 17.96, 22.92, 19.98, 21.06)
      ..lineTo(16.06, 17.97)
      ..cubicTo(14.98, 18.7, 13.6, 19.13, 12.0, 19.13)
      ..cubicTo(8.87, 19.13, 6.22, 17.02, 5.27, 14.19)
      ..lineTo(1.23, 14.19)
      ..lineTo(1.23, 17.32)
      ..cubicTo(3.25, 21.34, 7.33, 24.0, 12.0, 24.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // 3. Yellow (Bottom-Left)
    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path yellowPath = Path()
      ..moveTo(5.27, 14.19)
      ..cubicTo(5.03, 13.47, 4.9, 12.7, 4.9, 11.9)
      ..cubicTo(4.9, 11.1, 5.03, 10.33, 5.27, 9.61)
      ..lineTo(5.27, 6.48)
      ..lineTo(1.23, 6.48)
      ..cubicTo(0.44, 8.04, 0.0, 9.8, 0.0, 11.9)
      ..cubicTo(0.0, 14.0, 0.44, 15.76, 1.23, 17.32)
      ..lineTo(5.27, 14.19)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Red (Top)
    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final Path redPath = Path()
      ..moveTo(12.0, 4.67)
      ..cubicTo(13.76, 4.67, 15.34, 5.28, 16.59, 6.47)
      ..lineTo(20.08, 2.98)
      ..cubicTo(17.96, 1.0, 15.24, 0.0, 12.0, 0.0)
      ..cubicTo(7.33, 0.0, 3.25, 2.66, 1.23, 6.68)
      ..lineTo(5.27, 9.81)
      ..cubicTo(6.22, 6.98, 8.87, 4.67, 12.0, 4.67)
      ..close();
    canvas.drawPath(redPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Professional Microsoft logo with rounded corners.
class MicrosoftLogo extends StatelessWidget {
  final double size;
  const MicrosoftLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final double boxSize = (size - 2.5) / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF25022),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 2.5),
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF7FBA00),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A4EF),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 2.5),
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB900),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Dot-grid design for the desktop left panel.
class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const double spacing = 22;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// Small animated statistics graph.
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path linePath = Path();

    final double stepX = size.width / (data.length - 1);

    final double minimumValue = data.reduce((first, second) {
      return first < second ? first : second;
    });

    final double maximumValue = data.reduce((first, second) {
      return first > second ? first : second;
    });

    final double valueRange = maximumValue - minimumValue == 0
        ? 1
        : maximumValue - minimumValue;

    for (int index = 0; index < data.length; index++) {
      final double x = index * stepX;

      final double normalizedValue = (data[index] - minimumValue) / valueRange;

      final double y = size.height - 2 - (normalizedValue * (size.height - 4));

      if (index == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    // Area below the graph line.
    final Path shadowPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint shadowPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(shadowPath, shadowPaint);

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

// Animated background behind the login card.
class AmbientBackgroundPainter extends CustomPainter {
  final double t;

  AmbientBackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect backgroundRect = Offset.zero & size;

    // Main light background gradient.
    final Paint backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFEEF2F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(backgroundRect);

    canvas.drawRect(backgroundRect, backgroundPaint);

    // Helper function for glow circles.
    void drawGlowBlob({
      required Offset center,
      required double radius,
      required Color color,
    }) {
      final Paint glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, glowPaint);
    }

    final double angle = t * 2 * math.pi;

    // Top-left blue glow.
    drawGlowBlob(
      center: Offset(
        size.width * 0.15 + math.sin(angle) * 35,
        size.height * 0.20 + math.cos(angle) * 25,
      ),
      radius: size.width * 0.28,
      color: const Color(0xFF93C5FD),
    );

    // Top-right purple glow.
    drawGlowBlob(
      center: Offset(
        size.width * 0.85 + math.cos(angle * 0.8) * 30,
        size.height * 0.15 + math.sin(angle * 0.8) * 28,
      ),
      radius: size.width * 0.25,
      color: const Color(0xFFC084FC),
    );

    // Bottom-right teal glow.
    drawGlowBlob(
      center: Offset(
        size.width * 0.75 + math.sin(angle * 0.6) * 40,
        size.height * 0.85 + math.cos(angle * 0.6) * 25,
      ),
      radius: size.width * 0.32,
      color: const Color(0xFF2DD4BF),
    );

    // Bottom-left pink glow.
    drawGlowBlob(
      center: Offset(
        size.width * 0.20 + math.cos(angle * 0.5) * 35,
        size.height * 0.90 + math.sin(angle * 0.5) * 20,
      ),
      radius: size.width * 0.24,
      color: const Color(0xFFFBCFE8),
    );
  }

  @override
  bool shouldRepaint(covariant AmbientBackgroundPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
