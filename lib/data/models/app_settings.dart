class AppSettings {
  const AppSettings({
    required this.availableHours,
    this.reminderTime,
    this.notificationsEnabled = true,
  });

  final Map<String, bool> availableHours;
  final String? reminderTime;
  final bool notificationsEnabled;

  static const _defaultHours = {'morning': false, 'mid_day': false, 'afternoon': false};

  factory AppSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AppSettings(availableHours: _defaultHours);
    final rawHours = map['available_hours'] as Map<String, dynamic>? ?? _defaultHours;
    return AppSettings(
      availableHours: rawHours.map((k, v) => MapEntry(k, v as bool? ?? false)),
      reminderTime: map['reminder_time'] as String?,
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
    );
  }

  AppSettings copyWithHour(String key, bool value) {
    final next = Map<String, bool>.from(availableHours);
    next[key] = value;
    return AppSettings(
      availableHours: next,
      reminderTime: reminderTime,
      notificationsEnabled: notificationsEnabled,
    );
  }
}
