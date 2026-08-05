import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  static const String _pushNotificationsKey = 'push_notifications';

  static const String _emailNotificationsKey = 'email_notifications';

  static const String _smsNotificationsKey = 'sms_notifications';

  static const String _salesUpdatesKey = 'sales_updates';

  static const String _inventoryAlertsKey = 'inventory_alerts';

  static const String _employeeUpdatesKey = 'employee_updates';

  static const String _aiRecommendationsKey = 'ai_recommendations';

  static const String _marketingMessagesKey = 'marketing_messages';

  static const String _notificationSoundKey = 'notification_sound';

  static const String _vibrationKey = 'vibration';

  static const String _languageKey = 'selected_language';

  static Future<SharedPreferences> _preferences() async {
    return SharedPreferences.getInstance();
  }

  // Dark mode

  static Future<void> saveDarkMode(bool value) async {
    final preferences = await _preferences();

    await preferences.setBool(_darkModeKey, value);
  }

  static Future<bool> getDarkMode() async {
    final preferences = await _preferences();

    return preferences.getBool(_darkModeKey) ?? false;
  }

  // General notifications

  static Future<void> saveNotificationsEnabled(bool value) async {
    final preferences = await _preferences();

    await preferences.setBool(_notificationsEnabledKey, value);
  }

  static Future<bool> getNotificationsEnabled() async {
    final preferences = await _preferences();

    return preferences.getBool(_notificationsEnabledKey) ?? true;
  }

  // Notification settings

  static Future<void> saveNotificationSettings({
    required bool pushNotifications,
    required bool emailNotifications,
    required bool smsNotifications,
    required bool salesUpdates,
    required bool inventoryAlerts,
    required bool employeeUpdates,
    required bool aiRecommendations,
    required bool marketingMessages,
    required bool notificationSound,
    required bool vibration,
  }) async {
    final preferences = await _preferences();

    await Future.wait([
      preferences.setBool(_pushNotificationsKey, pushNotifications),
      preferences.setBool(_emailNotificationsKey, emailNotifications),
      preferences.setBool(_smsNotificationsKey, smsNotifications),
      preferences.setBool(_salesUpdatesKey, salesUpdates),
      preferences.setBool(_inventoryAlertsKey, inventoryAlerts),
      preferences.setBool(_employeeUpdatesKey, employeeUpdates),
      preferences.setBool(_aiRecommendationsKey, aiRecommendations),
      preferences.setBool(_marketingMessagesKey, marketingMessages),
      preferences.setBool(_notificationSoundKey, notificationSound),
      preferences.setBool(_vibrationKey, vibration),
    ]);
  }

  static Future<Map<String, bool>> getNotificationSettings() async {
    final preferences = await _preferences();

    return {
      'pushNotifications': preferences.getBool(_pushNotificationsKey) ?? true,
      'emailNotifications': preferences.getBool(_emailNotificationsKey) ?? true,
      'smsNotifications': preferences.getBool(_smsNotificationsKey) ?? false,
      'salesUpdates': preferences.getBool(_salesUpdatesKey) ?? true,
      'inventoryAlerts': preferences.getBool(_inventoryAlertsKey) ?? true,
      'employeeUpdates': preferences.getBool(_employeeUpdatesKey) ?? true,
      'aiRecommendations': preferences.getBool(_aiRecommendationsKey) ?? true,
      'marketingMessages': preferences.getBool(_marketingMessagesKey) ?? false,
      'notificationSound': preferences.getBool(_notificationSoundKey) ?? true,
      'vibration': preferences.getBool(_vibrationKey) ?? true,
    };
  }

  // Language

  static Future<void> saveLanguage(String language) async {
    final preferences = await _preferences();

    await preferences.setString(_languageKey, language);
  }

  static Future<String> getLanguage() async {
    final preferences = await _preferences();

    return preferences.getString(_languageKey) ?? 'English';
  }

  // Clear settings during logout

  static Future<void> clearSettings() async {
    final preferences = await _preferences();

    await Future.wait([
      preferences.remove(_darkModeKey),
      preferences.remove(_notificationsEnabledKey),
      preferences.remove(_pushNotificationsKey),
      preferences.remove(_emailNotificationsKey),
      preferences.remove(_smsNotificationsKey),
      preferences.remove(_salesUpdatesKey),
      preferences.remove(_inventoryAlertsKey),
      preferences.remove(_employeeUpdatesKey),
      preferences.remove(_aiRecommendationsKey),
      preferences.remove(_marketingMessagesKey),
      preferences.remove(_notificationSoundKey),
      preferences.remove(_vibrationKey),
      preferences.remove(_languageKey),
    ]);
  }
}
