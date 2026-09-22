class DailyCheckin {
  const DailyCheckin({required this.date, required this.completed});

  final DateTime date;
  final bool completed;

  factory DailyCheckin.fromMap(Map<String, dynamic> map) => DailyCheckin(
        date: DateTime.parse(map['date'] as String),
        completed: map['completed'] as bool? ?? false,
      );
}
