import 'package:isar/isar.dart';

part 'habit_log.g.dart';

@collection
class HabitLog {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String habitId;
  
  @Index()
  late String date; // YYYY-MM-DD format
  
  late int value; // 0 or 1 (incomplete/complete)
  
  late DateTime updatedAt;
  
  HabitLog();
  
  HabitLog.create({
    required this.habitId,
    required this.date,
    required this.value,
    DateTime? updatedAt,
  }) {
    this.updatedAt = updatedAt ?? DateTime.now();
  }
}
