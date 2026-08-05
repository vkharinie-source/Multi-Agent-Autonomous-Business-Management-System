import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/auth_service.dart';
import '../employee/employee_dashboard.dart';
import '../otp/otp_screen.dart';

class EmployeeAuthScreen extends StatefulWidget {
  const EmployeeAuthScreen({super.key});

  @override
  State<EmployeeAuthScreen> createState() {
    return _EmployeeAuthScreenState();
  }
}

class _EmployeeAuthScreenState extends State<EmployeeAuthScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registrationFormKey = GlobalKey<FormState>();

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _companyEmailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showNewEmployeeForm = false;
  bool _hideLoginPassword = true;
  bool _hideRegistrationPassword = true;
  bool _hideConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();

    _employeeIdController.dispose();
    _fullNameController.dispose();
    _companyEmailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _signInEmployee() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    final bool isValid = _loginFormKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> response = await AuthService.instance.login(
        email: _loginEmailController.text.trim().toLowerCase(),
        password: _loginPasswordController.text,
      );

      final dynamic rawUser = response['user'];

      if (rawUser is! Map) {
        throw Exception('Employee information was not returned by the server.');
      }

      final Map<String, dynamic> user = Map<String, dynamic>.from(rawUser);

      final String role = user['role']?.toString().trim().toLowerCase() ?? '';

      if (role != 'employee') {
        await AuthService.instance.logout();

        throw Exception('This sign-in page is only for employee accounts.');
      }

      if (!mounted) {
        return;
      }

      _showMessage(message: 'Employee sign in successful.', isError: false);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return const EmployeeDashboard();
          },
        ),
        (Route<dynamic> route) => false,
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

  Future<void> _createEmployeeAccount() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    final bool isValid = _registrationFormKey.currentState?.validate() ?? false;

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

    final String email = _companyEmailController.text.trim().toLowerCase();

    try {
      final Map<String, dynamic> response = await AuthService.instance.register(
        name: _fullNameController.text.trim(),
        email: email,
        employeeId: _employeeIdController.text.trim().toUpperCase(),
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
            'Account created successfully. OTP sent to your email.',
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
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  void _showMessage({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? const Color(0xFFE5484D)
            : const Color(0xFF16A765),
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

  void _changeMode(bool showNewEmployeeForm) {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _showNewEmployeeForm = showNewEmployeeForm;
    });
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your company email';
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

    if (employeeId.length < 3) {
      return 'Employee ID must contain at least 3 characters';
    }

    if (employeeId.length > 50) {
      return 'Employee ID cannot exceed 50 characters';
    }

    final RegExp employeeIdPattern = RegExp(r'^[A-Za-z0-9_-]+$');

    if (!employeeIdPattern.hasMatch(employeeId)) {
      return 'Use only letters, numbers, underscore or hyphen';
    }

    return null;
  }

  String? _validateFullName(String? value) {
    final String fullName = value?.trim() ?? '';

    if (fullName.isEmpty) {
      return 'Please enter your full name';
    }

    if (fullName.length < 2) {
      return 'Please enter a valid full name';
    }

    return null;
  }

  String? _validateRequiredField(String? value, String fieldName) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your $fieldName';
    }

    if (text.length < 2) {
      return 'Please enter a valid $fieldName';
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

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1FF),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFF8F6FF),
                    Color(0xFFEDE8FF),
                    Color(0xFFF9F7FF),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -80,
            child: _buildGlowCircle(size: 280, color: const Color(0xFF7557F5)),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _buildGlowCircle(size: 330, color: const Color(0xFFB65CFF)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                          foregroundColor: const Color(0xFF302554),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Employee Access',
                        style: TextStyle(
                          color: Color(0xFF251D45),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to your existing account or create a new employee account.',
                        style: TextStyle(
                          color: Color(0xFF777084),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      _buildModeSelector(),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _showNewEmployeeForm
                            ? _buildRegistrationCard()
                            : _buildLoginCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DDF3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              title: 'Existing Employee',
              icon: Icons.login_rounded,
              selected: !_showNewEmployeeForm,
              onPressed: () {
                _changeMode(false);
              },
            ),
          ),
          Expanded(
            child: _buildModeButton(
              title: 'New Employee',
              icon: Icons.person_add_alt_1_rounded,
              selected: _showNewEmployeeForm,
              onPressed: () {
                _changeMode(true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6C4CF1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected ? Colors.white : const Color(0xFF777084),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF625B70),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      key: const ValueKey<String>('employee-login-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              icon: Icons.badge_outlined,
              title: 'Employee Sign In',
              description: 'Enter your registered company email and password.',
            ),
            const SizedBox(height: 28),
            _buildTextField(
              label: 'Company email',
              controller: _loginEmailController,
              hintText: 'Enter your company email',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildPasswordField(
              label: 'Password',
              controller: _loginPasswordController,
              hintText: 'Enter your password',
              hidePassword: _hideLoginPassword,
              onToggleVisibility: () {
                setState(() {
                  _hideLoginPassword = !_hideLoginPassword;
                });
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }

                return null;
              },
              onSubmitted: _signInEmployee,
            ),
            const SizedBox(height: 8),
            _buildPrimaryButton(
              text: 'Sign In as Employee',
              icon: Icons.arrow_forward_rounded,
              onPressed: _signInEmployee,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationCard() {
    return Container(
      key: const ValueKey<String>('employee-registration-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Form(
        key: _registrationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Create Employee Account',
              description:
                  'Use the same details available in your official employee record.',
            ),
            const SizedBox(height: 28),
            _buildTextField(
              label: 'Employee ID',
              controller: _employeeIdController,
              hintText: 'Example: EMP001',
              icon: Icons.badge_outlined,
              validator: _validateEmployeeId,
              textCapitalization: TextCapitalization.characters,
            ),
            _buildTextField(
              label: 'Full name',
              controller: _fullNameController,
              hintText: 'Enter your full name',
              icon: Icons.person_outline_rounded,
              validator: _validateFullName,
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              label: 'Company email',
              controller: _companyEmailController,
              hintText: 'Enter your company email',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildTextField(
              label: 'Phone number',
              controller: _phoneController,
              hintText: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                LengthLimitingTextInputFormatter(16),
              ],
            ),
            _buildTextField(
              label: 'Department',
              controller: _departmentController,
              hintText: 'Example: Information Technology',
              icon: Icons.business_outlined,
              validator: (String? value) {
                return _validateRequiredField(value, 'department');
              },
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              label: 'Designation',
              controller: _designationController,
              hintText: 'Example: Software Developer',
              icon: Icons.work_outline_rounded,
              validator: (String? value) {
                return _validateRequiredField(value, 'designation');
              },
              textCapitalization: TextCapitalization.words,
            ),
            _buildPasswordField(
              label: 'Create password',
              controller: _passwordController,
              hintText: 'Create a strong password',
              hidePassword: _hideRegistrationPassword,
              onToggleVisibility: () {
                setState(() {
                  _hideRegistrationPassword = !_hideRegistrationPassword;
                });
              },
              validator: _validatePassword,
            ),
            _buildPasswordField(
              label: 'Confirm password',
              controller: _confirmPasswordController,
              hintText: 'Re-enter your password',
              hidePassword: _hideConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _hideConfirmPassword = !_hideConfirmPassword;
                });
              },
              validator: _validateConfirmPassword,
              onSubmitted: _createEmployeeAccount,
            ),
            _buildTerms(),
            const SizedBox(height: 20),
            _buildPrimaryButton(
              text: 'Create Employee Account',
              icon: Icons.arrow_forward_rounded,
              onPressed: _createEmployeeAccount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF6C4CF1), Color(0xFF984DF5)],
            ),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF251D45),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF817A8D),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
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
            inputFormatters: inputFormatters,
            decoration: _inputDecoration(hintText: hintText, icon: icon),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool hidePassword,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    Future<void> Function()? onSubmitted,
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
            obscureText: hidePassword,
            textInputAction: onSubmitted == null
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: onSubmitted == null
                ? null
                : (String value) {
                    onSubmitted();
                  },
            decoration: _inputDecoration(
              hintText: hintText,
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: _isLoading ? null : onToggleVisibility,
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7364B4),
                ),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildTerms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          activeColor: const Color(0xFF6C4CF1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onChanged: _isLoading
              ? null
              : (bool? value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'I confirm that the information matches my official employee record and I accept the Terms and Privacy Policy.',
              style: TextStyle(
                color: Color(0xFF777084),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required Future<void> Function() onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading
            ? null
            : () {
                onPressed();
              },
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6C4CF1),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB8AFE1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Icon(icon, size: 21),
                ],
              ),
      ),
    );
  }

  Text _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF3D345E),
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
      hintStyle: const TextStyle(color: Color(0xFFA09AAA), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF7364B4)),
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
        borderSide: const BorderSide(color: Color(0xFF6C4CF1), width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5484D)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5484D), width: 1.7),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white, width: 1.4),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF584A88).withValues(alpha: 0.12),
          blurRadius: 36,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }

  Widget _buildGlowCircle({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.16),
              blurRadius: 90,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
