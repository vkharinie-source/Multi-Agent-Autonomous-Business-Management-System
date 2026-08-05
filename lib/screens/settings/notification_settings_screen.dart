import 'package:flutter/material.dart';
import '../../core/services/settings_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _salesUpdates = true;
  bool _inventoryAlerts = true;
  bool _employeeUpdates = true;
  bool _aiRecommendations = true;
  bool _marketingMessages = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getNotificationSettings();

    if (!mounted) return;

    setState(() {
      _pushNotifications = settings['pushNotifications']!;
      _emailNotifications = settings['emailNotifications']!;
      _smsNotifications = settings['smsNotifications']!;
      _salesUpdates = settings['salesUpdates']!;
      _inventoryAlerts = settings['inventoryAlerts']!;
      _employeeUpdates = settings['employeeUpdates']!;
      _aiRecommendations = settings['aiRecommendations']!;
      _marketingMessages = settings['marketingMessages']!;
      _soundEnabled = settings['notificationSound']!;
      _vibrationEnabled = settings['vibration']!;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Notification settings saved successfully'),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 10, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 64);
  }

  Widget _notificationSwitch({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff4169e1), Color(0xff6c63ff)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stay Updated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Choose how you want to receive business updates.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle('DELIVERY METHOD'),

            _settingsCard(
              children: [
                _notificationSwitch(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.blue,
                  backgroundColor: const Color(0xffe8efff),
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts directly on your device',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                _divider(),
                _notificationSwitch(
                  icon: Icons.email_outlined,
                  iconColor: Colors.orange,
                  backgroundColor: const Color(0xfffff1e6),
                  title: 'Email Notifications',
                  subtitle: 'Receive important updates through email',
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
                _divider(),
                _notificationSwitch(
                  icon: Icons.sms_outlined,
                  iconColor: Colors.green,
                  backgroundColor: const Color(0xffe9fff2),
                  title: 'SMS Notifications',
                  subtitle: 'Receive critical alerts by text message',
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _sectionTitle('BUSINESS ALERTS'),

            _settingsCard(
              children: [
                _notificationSwitch(
                  icon: Icons.trending_up,
                  iconColor: Colors.indigo,
                  backgroundColor: const Color(0xffedf2ff),
                  title: 'Sales Updates',
                  subtitle: 'Daily sales and revenue notifications',
                  value: _salesUpdates,
                  onChanged: (value) {
                    setState(() {
                      _salesUpdates = value;
                    });
                  },
                ),
                _divider(),
                _notificationSwitch(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.deepOrange,
                  backgroundColor: const Color(0xffffeee8),
                  title: 'Inventory Alerts',
                  subtitle: 'Low stock and inventory status updates',
                  value: _inventoryAlerts,
                  onChanged: (value) {
                    setState(() {
                      _inventoryAlerts = value;
                    });
                  },
                ),
                _divider(),
                _notificationSwitch(
                  icon: Icons.groups_outlined,
                  iconColor: Colors.teal,
                  backgroundColor: const Color(0xffe7faf7),
                  title: 'Employee Updates',
                  subtitle: 'Attendance, leave and HR notifications',
                  value: _employeeUpdates,
                  onChanged: (value) {
                    setState(() {
                      _employeeUpdates = value;
                    });
                  },
                ),
                _divider(),
                _notificationSwitch(
                  icon: Icons.auto_awesome_outlined,
                  iconColor: Colors.deepPurple,
                  backgroundColor: const Color(0xffeee9ff),
                  title: 'AI Recommendations',
                  subtitle: 'Business insights and smart suggestions',
                  value: _aiRecommendations,
                  onChanged: (value) {
                    setState(() {
                      _aiRecommendations = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _sectionTitle('OTHER PREFERENCES'),

            _settingsCard(
              children: [
                _notificationSwitch(
                  icon: Icons.campaign_outlined,
                  iconColor: Colors.pink,
                  backgroundColor: const Color(0xffffeaf2),
                  title: 'Marketing Messages',
                  subtitle: 'Promotional news and product announcements',
                  value: _marketingMessages,
                  onChanged: (value) {
                    setState(() {
                      _marketingMessages = value;
                    });
                  },
                ),
                _divider(),
                _notificationSwitch(
                  icon: Icons.volume_up_outlined,
                  iconColor: Colors.cyan,
                  backgroundColor: const Color(0xffe8f8ff),
                  title: 'Notification Sound',
                  subtitle: 'Play a sound when an alert arrives',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                _divider(),
                _notificationSwitch(
                  icon: Icons.vibration,
                  iconColor: Colors.brown,
                  backgroundColor: const Color(0xfffff3e9),
                  title: 'Vibration',
                  subtitle: 'Vibrate the device for notifications',
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save_outlined),
                label: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
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
