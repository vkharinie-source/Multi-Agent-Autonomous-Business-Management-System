import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'employee_auth_screen.dart';
import 'manager_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const Color _primaryPurple = Color(0xFF6C4CF1);
  static const Color _darkPurple = Color(0xFF241B45);
  static const Color _employeeBlue = Color(0xFF2563EB);
  static const Color _managerPurple = Color(0xFF8B3DFF);

  void _openEmployeeLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const EmployeeAuthScreen();
        },
      ),
    );
  }

  void _openManagerLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const ManagerLoginScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF7F4FF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F4FF),
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFF9F7FF),
                      Color(0xFFEDE8FF),
                      Color(0xFFF8F6FF),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -130,
              right: -100,
              child: _buildGlowCircle(
                size: 330,
                color: const Color(0xFF7C5CFC),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -120,
              child: _buildGlowCircle(
                size: 380,
                color: const Color(0xFFB35CFF),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Desktop layout is shown only when enough width is available.
                  // Smaller browser windows use the stacked mobile/tablet layout.
                  final bool isDesktop = constraints.maxWidth >= 1100;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 38 : 18,
                      vertical: isDesktop ? 30 : 18,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          children: [
                            _buildTopBar(context),
                            SizedBox(height: isDesktop ? 36 : 24),
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: _buildBrandPanel()),
                                  const SizedBox(width: 28),
                                  Expanded(
                                    flex: 6,
                                    child: _buildRolePanel(
                                      context,
                                      compact: false,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildMobileHeader(),
                                  const SizedBox(height: 24),
                                  _buildRolePanel(context, compact: true),
                                ],
                              ),
                            const SizedBox(height: 30),
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
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF554A83).withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.arrow_back_rounded, color: _darkPurple),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE8E1FF)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, color: _primaryPurple, size: 18),
              SizedBox(width: 7),
              Text(
                'Secure Access',
                style: TextStyle(
                  color: Color(0xFF5F5872),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF6C4CF1), Color(0xFF9A4DFF)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withValues(alpha: 0.28),
                blurRadius: 26,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 39,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Choose your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _darkPurple,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Select how you want to sign in to Autonomous Business AI.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF777084), fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      width: double.infinity,

      // No fixed height. The panel automatically grows based on its content.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF100934),
            Color(0xFF4730B8),
            Color(0xFF7A42E8),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6040D0).withValues(alpha: 0.28),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: -90, right: -80, child: _buildPanelCircle(size: 250)),
          Positioned(
            bottom: -110,
            left: -90,
            child: _buildPanelCircle(size: 290),
          ),
          Padding(
            padding: const EdgeInsets.all(38),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 57,
                      height: 57,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: _primaryPurple,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUTONOMOUS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'BUSINESS AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 54),
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_tree_outlined,
                    color: Colors.white,
                    size: 53,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'The right dashboard for every role.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Employees and management users have separate access permissions, tools and dashboards.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 30),
                const _BrandFeature(
                  icon: Icons.verified_user_outlined,
                  text: 'Backend verified account roles',
                ),
                const _BrandFeature(
                  icon: Icons.dashboard_customize_outlined,
                  text: 'Separate role-based dashboards',
                ),
                const _BrandFeature(
                  icon: Icons.lock_outline_rounded,
                  text: 'Secure authentication and access',
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: Colors.greenAccent,
                        size: 23,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your actual account role will be verified securely after sign in.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePanel(BuildContext context, {required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 20 : 26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF544D77).withValues(alpha: 0.13),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who are you signing in as?',
            style: TextStyle(
              color: _darkPurple,
              fontSize: compact ? 25 : 28,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choose your account type to continue to the correct sign-in page.',
            style: TextStyle(
              color: Color(0xFF777084),
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 26),
          _AccountTypeCard(
            icon: Icons.badge_outlined,
            iconColor: _employeeBlue,
            iconBackground: const Color(0xFFEAF0FF),
            title: 'Employee',
            description:
                'Access your attendance, tasks, leave, salary and employee profile.',
            buttonText: 'Continue as Employee',
            buttonColor: _employeeBlue,
            features: const <String>[
              'Employee dashboard',
              'QR attendance and location verification',
              'Leave, salary and profile information',
            ],
            onPressed: () {
              _openEmployeeLogin(context);
            },
          ),
          const SizedBox(height: 20),
          _AccountTypeCard(
            icon: Icons.admin_panel_settings_outlined,
            iconColor: _managerPurple,
            iconBackground: const Color(0xFFF1E9FF),
            title: 'Manager / Admin',
            description:
                'Manage employees, attendance, inventory, reports and business operations.',
            buttonText: 'Continue as Manager / Admin',
            buttonColor: _managerPurple,
            features: const <String>[
              'Management dashboard',
              'Employee and device approvals',
              'Attendance, inventory and reports',
            ],
            onPressed: () {
              _openManagerLogin(context);
            },
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6FC),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: _primaryPurple,
                  size: 21,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Manager and Admin accounts are created only by authorized management.',
                    style: TextStyle(
                      color: Color(0xFF777084),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGlowCircle({required double size, required Color color}) {
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
              blurRadius: 100,
              spreadRadius: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelCircle({required double size}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    required this.features,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  final String title;
  final String description;
  final String buttonText;

  final Color buttonColor;
  final List<String> features;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FD),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: buttonColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 29),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF241B45),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF777084),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          ...features.map((String feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: buttonColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: Color(0xFF554F63),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Icon(Icons.arrow_forward_rounded, size: 21),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandFeature extends StatelessWidget {
  const _BrandFeature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
