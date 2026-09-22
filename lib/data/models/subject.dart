class Subject {
  const Subject({
    required this.id,
    required this.name,
    this.color,
    this.icon,
  });

  final String id;
  final String name;
  final String? color;
  final String? icon;

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
        id: map['id'] as String,
        name: map['name'] as String,
        color: map['color'] as String?,
        icon: map['icon'] as String?,
      );
}
