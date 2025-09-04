import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_it/domain/models/habit.dart';
import 'package:habit_it/domain/models/habit_log.dart';
import 'package:habit_it/services/database_service.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

class HabitRepository {
  Isar get _isar => DatabaseService.instance;
  final _uuid = const Uuid();
  
  // Get all habits (non-archived)
  Future<List<Habit>> getHabits() async {
    return await _isar.habits
        .filter()
        .archivedEqualTo(false)
        .sortByCreatedAt()
        .findAll();
  }
  
  // Stream of habits for real-time updates
  Stream<List<Habit>> watchHabits() {
    return _isar.habits
        .filter()
        .archivedEqualTo(false)
        .sortByCreatedAt()
        .watch(fireImmediately: true);
  }
  
  // Get habit count (for free user limit)
  Future<int> getHabitCount() async {
    return await _isar.habits
        .filter()
        .archivedEqualTo(false)
        .count();
  }
  
  // Check if user can add more habits (free limit: 3)
  Future<bool> canAddHabit({bool isPro = false}) async {
    if (isPro) return true;
    final count = await getHabitCount();
    return count < 3;
  }
  
  // Create new habit
  Future<Habit> createHabit({
    required String title,
    required ScheduleType scheduleType,
    List<int> scheduleDays = const [],
    int scheduleInterval = 1,
    HabitColor color = HabitColor.blue,
  }) async {
    final habit = Habit.create(
      habitId: _uuid.v4(),
      title: title,
      scheduleType: scheduleType,
      scheduleDays: scheduleDays,
      scheduleInterval: scheduleInterval,
      color: color,
    );
    
    await _isar.writeTxn(() async {
      await _isar.habits.put(habit);
    });
    
    return habit;
  }
  
  // Update habit
  Future<void> updateHabit(Habit habit) async {
    habit.updatedAt = DateTime.now();
    
    await _isar.writeTxn(() async {
      await _isar.habits.put(habit);
    });
  }
  
  // Delete habit (archive it)
  Future<void> deleteHabit(String habitId) async {
    final habit = await _isar.habits
        .filter()
        .habitIdEqualTo(habitId)
        .findFirst();
    
    if (habit != null) {
      habit.archived = true;
      habit.updatedAt = DateTime.now();
      
      await _isar.writeTxn(() async {
        await _isar.habits.put(habit);
      });
    }
  }
  
  // Toggle habit completion for today
  Future<void> toggleHabitCompletion(String habitId) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final existingLog = await _isar.habitLogs
        .filter()
        .habitIdEqualTo(habitId)
        .and()
        .dateEqualTo(dateStr)
        .findFirst();
    
    await _isar.writeTxn(() async {
      if (existingLog != null) {
        // Toggle existing log
        existingLog.value = existingLog.value == 1 ? 0 : 1;
        existingLog.updatedAt = DateTime.now();
        await _isar.habitLogs.put(existingLog);
      } else {
        // Create new completed log
        final log = HabitLog.create(
          habitId: habitId,
          date: dateStr,
          value: 1,
        );
        await _isar.habitLogs.put(log);
      }
    });
  }
  
  // Get habit completion status for today
  Future<bool> isHabitCompletedToday(String habitId) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final log = await _isar.habitLogs
        .filter()
        .habitIdEqualTo(habitId)
        .and()
        .dateEqualTo(dateStr)
        .findFirst();
    
    return log?.value == 1;
  }
  
  // Get habit streak
  Future<int> getHabitStreak(String habitId) async {
    final logs = await _isar.habitLogs
        .filter()
        .habitIdEqualTo(habitId)
        .sortByDateDesc()
        .findAll();
    
    if (logs.isEmpty) return 0;
    
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 365; i++) { // Check up to 365 days back
      final checkDate = today.subtract(Duration(days: i));
      final dateStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      
      final log = logs.where((l) => l.date == dateStr).firstOrNull;
      
      if (log?.value == 1) {
        streak++;
      } else if (i == 0) {
        // If today is not completed, check yesterday
        continue;
      } else {
        break;
      }
    }
    
    return streak;
  }
}
