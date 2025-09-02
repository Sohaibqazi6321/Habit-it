import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String habitId;
  
  late String title;
  
  @Enumerated(EnumType.name)
  late ScheduleType scheduleType;
  
  List<int> scheduleDays = []; // For weekly: 1=Mon, 7=Sun
  int scheduleInterval = 1; // For interval: every N days
  
  @Enumerated(EnumType.name)
  late HabitColor color;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  
  bool archived = false;
  
  Habit();
  
  Habit.create({
    required this.habitId,
    required this.title,
    required this.scheduleType,
    this.scheduleDays = const [],
    this.scheduleInterval = 1,
    this.color = HabitColor.blue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }
}

enum ScheduleType {
  daily,
  weekly,
  interval, // Every N days
}

enum HabitColor {
  blue,
  green,
  orange,
  purple,
  red,
  pink,
  teal,
  indigo,
}
