import 'package:flutter/material.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../home/landing_page.dart';
import 'forgot_password_screen.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() {
    return _ManagerLoginScreenState();
  }
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
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

        throw const ApiException(
          message: 'Login succeeded, but account details were not returned.',
        );
      }

      final Map<String, dynamic> user = Map<String, dynamic>.from(rawUser);

      final String role = user['role']?.toString().trim().toLowerCase() ?? '';

      if (role != 'manager' && role != 'admin') {
        await AuthService.instance.logout();

        throw const ApiException(
          message:
              'This account does not have Manager or Admin access. Use Employee Sign In.',
          statusCode: 403,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        message: role == 'admin'
            ? 'Admin login successful.'
            : 'Manager login successful.',
        isError: false,
      );

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder<void>(
          pageBuilder:
              (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return const LandingPage();
              },
          transitionsBuilder:
              (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
          transitionDuration: const Duration(milliseconds: 450),
        ),
        (Route<dynamic> route) => false,
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

  String _cleanError(Object error) {
    final String message = error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();

    if (message.isEmpty) {
      return 'Unable to connect to the backend server.';
    }

    return message;
  }

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F6FF),
                    Color(0xFFEAE5FF),
                    Color(0xFFF7F4FF),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool mobile = constraints.maxWidth < 850;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(mobile ? 18 : 30),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: mobile
                          ? _buildLoginCard(context, true)
                          : Row(
                              children: [
                                Expanded(child: _buildInformationPanel()),
                                const SizedBox(width: 28),
                                Expanded(
                                  child: _buildLoginCard(context, false),
                                ),
                              ],
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

  Widget _buildInformationPanel() {
    return Container(
      height: 650,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07134F), Color(0xFF1749E5), Color(0xFF8B3DFF)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1749E5).withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Color(0xFF1749E5),
                  size: 29,
                ),
              ),
              SizedBox(width: 14),
              Text(
                'BUSINESS AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Spacer(),
          Icon(Icons.security_rounded, color: Colors.white, size: 82),
          SizedBox(height: 25),
          Text(
            'Manager & Admin Portal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Securely manage employees, attendance, devices and business operations.',
            style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.5),
          ),
          SizedBox(height: 28),
          _SecurityFeature(text: 'Backend verified role access'),
          _SecurityFeature(text: 'Secure attendance management'),
          _SecurityFeature(text: 'Admin and Manager controls'),
          Spacer(),
          Text(
            'Authorized accounts only',
            style: TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool mobile) {
    return Container(
      padding: EdgeInsets.all(mobile ? 24 : 34),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.14),
            blurRadius: 38,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF0EBFF),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: 24),
            const Text(
              'Manager Sign In',
              style: TextStyle(
                color: Color(0xFF201A3D),
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Use your authorized Manager or Admin account.',
              style: TextStyle(
                color: Color(0xFF6F6981),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Company email',
              style: TextStyle(
                color: Color(0xFF3F3859),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              decoration: _inputDecoration(
                hintText: 'Enter manager or admin email',
                icon: Icons.alternate_email_rounded,
              ),
            ),
            const SizedBox(height: 19),
            const Text(
              'Password',
              style: TextStyle(
                color: Color(0xFF3F3859),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onFieldSubmitted: (_) {
                _login();
              },
              decoration: _inputDecoration(
                hintText: 'Enter your password',
                icon: Icons.lock_outline_rounded,
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
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: _isLoading
                      ? null
                      : (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                ),
                const Expanded(
                  child: Text(
                    'Remember me',
                    style: TextStyle(color: Color(0xFF6F6981)),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return const ForgotPasswordScreen();
                              },
                            ),
                          );
                        },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            const SizedBox(height: 21),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _login,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8B3DFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.admin_panel_settings_rounded),
                label: Text(
                  _isLoading ? 'Signing In...' : 'Login to Management Portal',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 19),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5DF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFC17A00),
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Manager and Admin accounts cannot be created publicly. Contact your Admin for access.',
                      style: TextStyle(
                        color: Color(0xFF805400),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: const Color(0xFF7B61FF)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F6FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2DDEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2DDEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8B3DFF), width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

class _SecurityFeature extends StatelessWidget {
  const _SecurityFeature({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Colors.greenAccent),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
