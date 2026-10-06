import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/secure_storage_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _user = <String, dynamic>{};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      if (token == null || token.trim().isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Session expired. Please log in again.';
        });
        return;
      }

      final Map<String, dynamic> userData = <String, dynamic>{};

      // 1. Fetch from currentUser endpoint (/api/auth/me)
      try {
        final Map<String, dynamic> authResponse =
            await AuthService.instance.getCurrentUser(accessToken: token);
        final dynamic rawAuthUser = authResponse['user'] ?? authResponse;
        if (rawAuthUser is Map) {
          userData.addAll(Map<String, dynamic>.from(rawAuthUser));
        }
      } catch (_) {}

      // 2. Fetch from dedicated profile endpoint (/api/settings/profile) which has phone, department, designation
      try {
        final Map<String, dynamic> profileResponse =
            await AuthService.instance.getProfile(accessToken: token);
        final dynamic rawProfile =
            profileResponse['profile'] ?? profileResponse['user'] ?? profileResponse;
        if (rawProfile is Map) {
          userData.addAll(Map<String, dynamic>.from(rawProfile));
        }
      } catch (_) {}

      // 3. Fallback employee ID from SecureStorage if not present
      if ((userData['employee_id']?.toString().trim().isEmpty ?? true)) {
        final String? storedEmpId =
            await SecureStorageService.instance.readEmployeeId();
        if (storedEmpId != null && storedEmpId.isNotEmpty) {
          userData['employee_id'] = storedEmpId;
        }
      }

      if (userData.isNotEmpty) {
        setState(() {
          _user = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Could not load profile data.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '').trim();
      });
    }
  }

  String _get(String key, [String fallback = 'Not set']) {
    final String v = _user[key]?.toString().trim() ?? '';
    return v.isEmpty ? fallback : v;
  }

  String get _initials {
    final String name = _user['name']?.toString().trim() ?? '';
    if (name.isEmpty) return '?';
    final List<String> parts = name.split(' ')
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      body: SafeArea(
        child: Stack(
          children: [
            // Background ambient glow circles
            Positioned(
              top: -80,
              right: -60,
              child: _buildGlowCircle(
                size: 260,
                color: const Color(0xFF7B61FF).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _buildGlowCircle(
                size: 280,
                color: const Color(0xFFB66DFF).withValues(alpha: 0.10),
              ),
            ),

            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C5CE7),
                          ),
                        )
                      : _error != null
                          ? _buildErrorState()
                          : _buildContent(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFF6C5CE7),
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF756E8A),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadProfile();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final String role = _get('role', 'Employee');
    final String department = _get('department', '');
    final String designation = _get('designation', '');
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          _buildHeroProfileCard(role: role),
          const SizedBox(height: 22),
          _buildSectionHeader(
            title: 'Personal Information',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            items: [
              _InfoItem(
                title: 'Full Name',
                subtitle: _get('name'),
                icon: Icons.badge_outlined,
                iconColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
              ),
              _InfoItem(
                title: 'Email Address',
                subtitle: _get('email'),
                icon: Icons.alternate_email_rounded,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
              _InfoItem(
                title: 'Phone Number',
                subtitle: _get('phone', 'Not provided'),
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
              _InfoItem(
                title: 'Account Role',
                subtitle: role,
                icon: Icons.admin_panel_settings_outlined,
                iconColor: const Color(0xFF6C5CE7),
                bgColor: const Color(0xFFF0EBFF),
                isLast: department.isEmpty && designation.isEmpty,
              ),
            ],
          ),
          if (department.isNotEmpty || designation.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader(
              title: 'Work Details',
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              items: [
                if (_user['employee_id']?.toString().isNotEmpty == true)
                  _InfoItem(
                    title: 'Employee ID',
                    subtitle: _get('employee_id'),
                    icon: Icons.fingerprint_rounded,
                    iconColor: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEF2F2),
                  ),
                if (department.isNotEmpty)
                  _InfoItem(
                    title: 'Department',
                    subtitle: department,
                    icon: Icons.corporate_fare_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    bgColor: const Color(0xFFF5F3FF),
                  ),
                if (designation.isNotEmpty)
                  _InfoItem(
                    title: 'Designation',
                    subtitle: designation,
                    icon: Icons.work_history_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    bgColor: const Color(0xFFF0F9FF),
                    isLast: true,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildEditButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEBE6F8), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3EEFF),
              foregroundColor: const Color(0xFF4C3F91),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  color: Color(0xFF201A3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'User Account & Credentials',
                style: TextStyle(color: Color(0xFF756E8A), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF10B981),
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfileCard({required String role}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF35168A), Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Subtle background decorative pattern
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            children: [
              // Avatar Stack with glowing border & edit badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF55E6C1),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF55E6C1).withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 43,
                        backgroundColor: const Color(0xFFF3EEFF),
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF55E6C1), Color(0xFF10B981)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Name & Verified Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _get('name', 'Employee'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF55E6C1),
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                _get('email', ''),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Role Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$role Role',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C5CE7), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF201A3D),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required List<_InfoItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: items.map((_InfoItem item) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Color(0xFF8B849E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF201A3D),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFCBC6D8),
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (!item.isLast) const Divider(height: 1, color: Color(0xFFF0ECFA)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
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
        child: ElevatedButton.icon(
          onPressed: () async {
            final dynamic updated = await Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => EditProfileScreen(
                  initialUser: _user,
                ),
              ),
            );
            if (updated == true || mounted) {
              await _loadProfile();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.edit_rounded, size: 20),
          label: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool isLast;
}

