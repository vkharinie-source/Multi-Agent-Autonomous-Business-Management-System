import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/theme_controller.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    Navigator.of(context).popUntil((Route<dynamic> route) {
      return route.isFirst;
    });
  }

  Widget _sectionTitle(String title) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isDarkMode ? Colors.white70 : Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    final ThemeData theme = Theme.of(context);

    final bool isDarkMode = theme.brightness == Brightness.dark;

    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(
            alpha: isDarkMode ? 0.10 : 0.05,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 64,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
    );
  }

  Widget _leadingIcon({
    required IconData icon,
    required Color iconColor,
    required Color lightBackgroundColor,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CircleAvatar(
      backgroundColor: isDarkMode
          ? iconColor.withValues(alpha: 0.16)
          : lightBackgroundColor,
      child: Icon(icon, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4169E1), Color(0xFF6C63FF)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4169E1).withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage your profile and preferences',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Open profile',
                    onPressed: () {
                      _openPage(const ProfileScreen());
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle('ACCOUNT'),

            _settingsCard(
              children: [
                ListTile(
                  leading: _leadingIcon(
                    icon: Icons.person_outline,
                    iconColor: Colors.blue,
                    lightBackgroundColor: const Color(0xFFE8EFFF),
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('View and edit account details'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openPage(const ProfileScreen());
                  },
                ),

                _divider(),

                ListTile(
                  leading: _leadingIcon(
                    icon: Icons.lock_outline,
                    iconColor: Colors.orange,
                    lightBackgroundColor: const Color(0xFFFFF1E6),
                  ),
                  title: const Text(
                    'Change Password',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openPage(const ChangePasswordScreen());
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _sectionTitle('PREFERENCES'),

            _settingsCard(
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.instance,
                  builder:
                      (
                        BuildContext context,
                        ThemeMode currentTheme,
                        Widget? child,
                      ) {
                        final bool darkModeEnabled =
                            currentTheme == ThemeMode.dark;

                        return SwitchListTile(
                          secondary: CircleAvatar(
                            backgroundColor: darkModeEnabled
                                ? const Color(0xFF312E45)
                                : const Color(0xFFEEE9FF),
                            child: Icon(
                              darkModeEnabled
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_outlined,
                              color: darkModeEnabled
                                  ? Colors.amber
                                  : Colors.deepPurple,
                            ),
                          ),
                          title: const Text(
                            'Dark Mode',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            darkModeEnabled
                                ? 'Dark appearance is enabled'
                                : 'Use dark appearance',
                          ),
                          value: darkModeEnabled,
                          onChanged: (bool enabled) {
                            ThemeController.instance.setDarkMode(enabled);
                          },
                        );
                      },
                ),

                _divider(),

                SwitchListTile(
                  secondary: _leadingIcon(
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.green,
                    lightBackgroundColor: const Color(0xFFE9FFF2),
                  ),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Receive alerts and updates'),
                  value: _notificationsEnabled,
                  onChanged: (bool enabled) {
                    setState(() {
                      _notificationsEnabled = enabled;
                    });
                  },
                ),

                _divider(),

                ListTile(
                  leading: _leadingIcon(
                    icon: Icons.tune,
                    iconColor: Colors.amber,
                    lightBackgroundColor: const Color(0xFFFFF6DF),
                  ),
                  title: const Text(
                    'Notification Settings',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Customize notification preferences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openPage(const NotificationSettingsScreen());
                  },
                ),

                _divider(),

                ListTile(
                  leading: _leadingIcon(
                    icon: Icons.language,
                    iconColor: Colors.cyan,
                    lightBackgroundColor: const Color(0xFFE8F8FF),
                  ),
                  title: const Text(
                    'Language',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openPage(const LanguageSettingsScreen());
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _sectionTitle('SUPPORT'),

            _settingsCard(
              children: [
                ListTile(
                  leading: _leadingIcon(
                    icon: Icons.info_outline,
                    iconColor: Colors.indigo,
                    lightBackgroundColor: const Color(0xFFEDF2FF),
                  ),
                  title: const Text(
                    'About App',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Version and application details'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openPage(const AboutScreen());
                  },
                ),

                _divider(),

                ListTile(
                  leading: _leadingIcon(
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    lightBackgroundColor: const Color(0xFFFFE9E9),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Sign out from your account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _logout,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Center(
              child: Text(
                'Autonomous Business AI',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.blueGrey,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
