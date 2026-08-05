import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() {
    return _OnboardingScreenState();
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color _primaryPurple = Color(0xFF6C4CF1);
  static const Color _darkPurple = Color(0xFF241B45);

  final PageController _pageController = PageController();

  int _currentPage = 0;

  static const List<_OnboardingItem> _pages = <_OnboardingItem>[
    _OnboardingItem(
      icon: Icons.business_center_rounded,
      title: 'Manage your business\nin one place',
      description:
          'Employees, attendance, inventory, sales and reports are connected through one intelligent business platform.',
      primaryColor: Color(0xFF6C4CF1),
      secondaryColor: Color(0xFF9A4DFF),
      badge: 'SMART BUSINESS MANAGEMENT',
      points: <String>[
        'Centralized business operations',
        'Role-based employee access',
        'Simple and secure management',
      ],
    ),
    _OnboardingItem(
      icon: Icons.auto_awesome_rounded,
      title: 'Make smarter decisions\nwith Business AI',
      description:
          'Use intelligent insights and AI-powered recommendations to improve sales, inventory, finance and employee management.',
      primaryColor: Color(0xFF2563EB),
      secondaryColor: Color(0xFF7C3AED),
      badge: 'AI-POWERED INSIGHTS',
      points: <String>[
        'Smart recommendations',
        'Business performance insights',
        'Sales and inventory predictions',
      ],
    ),
    _OnboardingItem(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Secure attendance\nfor every employee',
      description:
          'Protect employee attendance using approved devices, secure QR sessions and company location verification.',
      primaryColor: Color(0xFF0E7490),
      secondaryColor: Color(0xFF2563EB),
      badge: 'SECURE ATTENDANCE',
      points: <String>[
        'Approved employee devices',
        'Campus location verification',
        'Secure QR check-in and check-out',
      ],
    ),
  ];

  bool get _isFirstPage {
    return _currentPage == 0;
  }

  bool get _isLastPage {
    return _currentPage == _pages.length - 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_isLastPage) {
      _openRoleSelection();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _previousPage() async {
    if (_isFirstPage) {
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _openRoleSelection() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return const RoleSelectionScreen();
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
                      Color(0xFFFBFAFF),
                      Color(0xFFF0ECFF),
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
                color: const Color(0xFF8B5CF6),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -110,
              child: _buildGlowCircle(
                size: 360,
                color: const Color(0xFF6366F1),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return _buildPage(data: _pages[index]);
                      },
                    ),
                  ),
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 8),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF6C4CF1), Color(0xFF9A4DFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 11),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AUTONOMOUS',
                    style: TextStyle(
                      color: Color(0xFF888197),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.4,
                    ),
                  ),
                  Text(
                    'BUSINESS AI',
                    style: TextStyle(
                      color: _darkPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: _openRoleSelection,
            style: TextButton.styleFrom(
              foregroundColor: _primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required _OnboardingItem data}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWideScreen = constraints.maxWidth >= 850;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isWideScreen ? 42 : 20,
            isWideScreen ? 25 : 14,
            isWideScreen ? 42 : 20,
            25,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: isWideScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildVisualPanel(
                            data: data,
                            isWideScreen: true,
                          ),
                        ),
                        const SizedBox(width: 45),
                        Expanded(
                          flex: 5,
                          child: _buildInformationPanel(
                            data: data,
                            isWideScreen: true,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildVisualPanel(data: data, isWideScreen: false),
                        const SizedBox(height: 24),
                        _buildInformationPanel(data: data, isWideScreen: false),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisualPanel({
    required _OnboardingItem data,
    required bool isWideScreen,
  }) {
    return Container(
      width: double.infinity,
      height: isWideScreen ? 530 : 290,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            const Color(0xFF110A34),
            data.primaryColor,
            data.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(isWideScreen ? 38 : 30),
        boxShadow: [
          BoxShadow(
            color: data.primaryColor.withValues(alpha: 0.27),
            blurRadius: 45,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -55,
            child: _buildPanelCircle(size: isWideScreen ? 250 : 190),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: _buildPanelCircle(size: isWideScreen ? 290 : 220),
          ),
          Positioned(
            top: isWideScreen ? 38 : 24,
            left: isWideScreen ? 38 : 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 4,
                    backgroundColor: Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.badge,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: isWideScreen ? 205 : 145,
              height: isWideScreen ? 205 : 145,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.11),
                    blurRadius: 45,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                color: Colors.white,
                size: isWideScreen ? 105 : 72,
              ),
            ),
          ),
          Positioned(
            right: isWideScreen ? 32 : 20,
            bottom: isWideScreen ? 32 : 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.17)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Secure & Intelligent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationPanel({
    required _OnboardingItem data,
    required bool isWideScreen,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWideScreen ? 38 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(isWideScreen ? 34 : 28),
        border: Border.all(color: Colors.white, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF504675).withValues(alpha: 0.10),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: data.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'STEP ${_currentPage + 1} OF ${_pages.length}',
              style: TextStyle(
                color: data.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.title,
            style: TextStyle(
              color: _darkPurple,
              fontSize: isWideScreen ? 41 : 29,
              fontWeight: FontWeight.w900,
              height: 1.12,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            data.description,
            style: TextStyle(
              color: const Color(0xFF746D80),
              fontSize: isWideScreen ? 16 : 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 25),
          ...data.points.map((String point) {
            return _buildFeaturePoint(point: point, color: data.primaryColor);
          }),
          if (_isLastPage) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2FF),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFE4DEFF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: _primaryPurple, size: 23),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Your actual account role will be securely verified after sign in.',
                      style: TextStyle(
                        color: Color(0xFF6F687B),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturePoint({required String point, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              point,
              style: const TextStyle(
                color: Color(0xFF50495D),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 11, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        border: const Border(top: BorderSide(color: Color(0xFFEDE9F5))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 50,
            child: _isFirstPage
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Previous',
                    onPressed: _previousPage,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1EDFF),
                      foregroundColor: _primaryPurple,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(_pages.length, (int index) {
                final bool isSelected = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 29 : 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primaryPurple
                        : const Color(0xFFD6D0E3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: _isLastPage ? 145 : 112,
            height: 52,
            child: FilledButton(
              onPressed: _nextPage,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    _isLastPage
                        ? Icons.login_rounded
                        : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
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
          color: color.withValues(alpha: 0.10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 100,
              spreadRadius: 22,
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

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.badge,
    required this.points,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String badge;
  final List<String> points;
}
