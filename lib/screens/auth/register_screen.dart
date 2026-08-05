import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/auth_service.dart';
import '../otp/otp_screen.dart';
import 'role_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _employeeIdController = TextEditingController();

  final TextEditingController _departmentController = TextEditingController();

  final TextEditingController _designationController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
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

    if (!_acceptTerms) {
      _showMessage(
        message: 'Please accept the Terms of Service and Privacy Policy.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim().toLowerCase();

    try {
      final Map<String, dynamic> response = await AuthService.instance.register(
        name: _nameController.text.trim(),
        email: email,
        employeeId: _employeeIdController.text.trim(),
        department: _departmentController.text.trim(),
        designation: _designationController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        message:
            response['message']?.toString() ??
            'Registration successful. OTP sent to your email.',
        isError: false,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return OtpScreen(email: email);
          },
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(message: _getErrorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(Object error) {
    String message = error.toString().trim();

    message = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();

    if (message.isEmpty) {
      return 'Registration failed. Please try again.';
    }

    return message;
  }

  void _openLoginScreen() {
    if (_isLoading) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const RoleSelectionScreen();
        },
      ),
    );
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

  String? _validateName(String? value) {
    final String name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name';
    }

    if (name.length < 2) {
      return 'Name must have at least 2 characters';
    }

    if (name.length > 100) {
      return 'Name cannot exceed 100 characters';
    }

    return null;
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

  String? _validateEmployeeId(String? value) {
    final String employeeId = value?.trim() ?? '';

    if (employeeId.isEmpty) {
      return 'Please enter your employee ID';
    }

    if (employeeId.length < 2) {
      return 'Please enter a valid employee ID';
    }

    if (employeeId.length > 50) {
      return 'Employee ID cannot exceed 50 characters';
    }

    final RegExp employeeIdPattern = RegExp(r'^[A-Za-z0-9_-]+$');

    if (!employeeIdPattern.hasMatch(employeeId)) {
      return 'Employee ID contains invalid characters';
    }

    return null;
  }

  String? _validateDepartment(String? value) {
    final String department = value?.trim() ?? '';

    if (department.isEmpty) {
      return 'Please enter your department';
    }

    if (department.length < 2) {
      return 'Please enter a valid department';
    }

    if (department.length > 100) {
      return 'Department cannot exceed 100 characters';
    }

    return null;
  }

  String? _validateDesignation(String? value) {
    final String designation = value?.trim() ?? '';

    if (designation.isEmpty) {
      return 'Please enter your designation';
    }

    if (designation.length < 2) {
      return 'Please enter a valid designation';
    }

    if (designation.length > 100) {
      return 'Designation cannot exceed 100 characters';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Please enter your phone number';
    }

    final RegExp phonePattern = RegExp(r'^\+?[0-9]{10,15}$');

    if (!phonePattern.hasMatch(phone)) {
      return 'Enter a valid 10 to 15 digit phone number';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter a password';
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

    if (password.length > 100) {
      return 'Password cannot exceed 100 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final String confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -70,
                child: _buildGlowCircle(
                  size: 250,
                  color: const Color(0xFF7B61FF),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _buildGlowCircle(
                  size: 280,
                  color: const Color(0xFFB66DFF),
                ),
              ),
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).maybePop();
                                },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.75,
                            ),
                            foregroundColor: const Color(0xFF4C3F91),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Create your profile',
                          style: TextStyle(
                            color: Color(0xFF201A3D),
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enter the same information available in your employee record.',
                          style: TextStyle(
                            color: Color(0xFF6F6981),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF5D4BB7,
                                ).withValues(alpha: 0.12),
                                blurRadius: 35,
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
                                _buildLogo(),
                                const SizedBox(height: 28),
                                _buildTextField(
                                  label: 'Full name',
                                  controller: _nameController,
                                  hintText: 'Enter your full name',
                                  icon: Icons.person_outline_rounded,
                                  validator: _validateName,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                _buildTextField(
                                  label: 'Company email',
                                  controller: _emailController,
                                  hintText: 'Enter your company email',
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  autocorrect: false,
                                ),
                                _buildTextField(
                                  label: 'Employee ID',
                                  controller: _employeeIdController,
                                  hintText: 'Example: EMP001',
                                  icon: Icons.badge_outlined,
                                  validator: _validateEmployeeId,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                ),
                                _buildTextField(
                                  label: 'Department',
                                  controller: _departmentController,
                                  hintText: 'Example: IT',
                                  icon: Icons.business_outlined,
                                  validator: _validateDepartment,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                _buildTextField(
                                  label: 'Designation',
                                  controller: _designationController,
                                  hintText: 'Example: Software Developer',
                                  icon: Icons.work_outline_rounded,
                                  validator: _validateDesignation,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                _buildTextField(
                                  label: 'Phone number',
                                  controller: _phoneController,
                                  hintText: 'Enter your phone number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9+]'),
                                    ),
                                    LengthLimitingTextInputFormatter(16),
                                  ],
                                ),
                                _buildPasswordField(),
                                _buildConfirmPasswordField(),
                                _buildTermsCheckbox(),
                                const SizedBox(height: 22),
                                _buildCreateButton(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF6F6981),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _openLoginScreen,
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool autocorrect = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: !_isLoading,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            textInputAction: TextInputAction.next,
            autocorrect: autocorrect,
            inputFormatters: inputFormatters,
            decoration: _inputDecoration(hintText: hintText, icon: icon),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            enabled: !_isLoading,
            obscureText: _hidePassword,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'Create a strong password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: _isLoading
                    ? null
                    : () {
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
            validator: _validatePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Confirm password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_isLoading,
            obscureText: _hideConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (String value) {
              _register();
            },
            decoration: _inputDecoration(
              hintText: 'Re-enter your password',
              icon: Icons.verified_user_outlined,
              suffixIcon: IconButton(
                onPressed: _isLoading
                    ? null
                    : () {
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
            ),
            validator: _validateConfirmPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(-4, -3),
          child: Checkbox(
            value: _acceptTerms,
            activeColor: const Color(0xFF6C5CE7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: _isLoading
                ? null
                : (bool? value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  color: Color(0xFF6F6981),
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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
                    Text(
                      'Create Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF9B6CFF)],
            ),
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
                  color: Color(0xFF241D42),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Smart. Secure. Automated.',
                style: TextStyle(color: Color(0xFF888197), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF332A56),
        fontSize: 14,
        fontWeight: FontWeight.w700,
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
      hintStyle: const TextStyle(color: Color(0xFFA6A0B3), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF7566B4)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F6FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E0EE)),
      ),
      disabledBorder: OutlineInputBorder(
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

  Widget _buildGlowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}
