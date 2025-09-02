import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_it/domain/models/habit.dart';
import 'package:habit_it/data/repositories/habit_repository.dart';

// Stream provider for habits
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchHabits();
});

// Provider for habit count
final habitCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitCount();
});

// Provider to check if user can add more habits
final canAddHabitProvider = FutureProvider<bool>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.canAddHabit(isPro: false); // TODO: Get pro status from user service
});

// Provider for habit completion status
final habitCompletionProvider = FutureProvider.family<bool, String>((ref, habitId) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.isHabitCompletedToday(habitId);
});

// Provider for habit streak
final habitStreakProvider = FutureProvider.family<int, String>((ref, habitId) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitStreak(habitId);
});

// Notifier for habit actions
final habitActionsProvider = Provider<HabitActions>((ref) {
  return HabitActions(ref);
});

class HabitActions {
  final Ref _ref;
  
  HabitActions(this._ref);
  
  HabitRepository get _repository => _ref.read(habitRepositoryProvider);
  
  Future<void> toggleHabitCompletion(String habitId) async {
    await _repository.toggleHabitCompletion(habitId);
    // Invalidate providers to refresh UI
    _ref.invalidate(habitCompletionProvider(habitId));
    _ref.invalidate(habitStreakProvider(habitId));
  }
  
  Future<void> deleteHabit(String habitId) async {
    await _repository.deleteHabit(habitId);
    // Invalidate providers to refresh UI
    _ref.invalidate(habitsProvider);
    _ref.invalidate(habitCountProvider);
  }
  
  Future<Habit> createHabit({
    required String title,
    required ScheduleType scheduleType,
    List<int> scheduleDays = const [],
    int scheduleInterval = 1,
    HabitColor color = HabitColor.blue,
  }) async {
    final habit = await _repository.createHabit(
      title: title,
      scheduleType: scheduleType,
      scheduleDays: scheduleDays,
      scheduleInterval: scheduleInterval,
      color: color,
    );
    
    // Invalidate providers to refresh UI
    _ref.invalidate(habitsProvider);
    _ref.invalidate(habitCountProvider);
    _ref.invalidate(canAddHabitProvider);
    
    return habit;
  }
}
