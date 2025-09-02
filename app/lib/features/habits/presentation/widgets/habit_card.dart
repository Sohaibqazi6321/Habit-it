import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_it/domain/models/habit.dart';
import 'package:habit_it/features/habits/providers/habits_provider.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionAsync = ref.watch(habitCompletionProvider(habit.habitId));
    final streakAsync = ref.watch(habitStreakProvider(habit.habitId));
    final actions = ref.read(habitActionsProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Completion checkbox
            completionAsync.when(
              data: (isCompleted) => Checkbox(
                value: isCompleted,
                onChanged: (_) => actions.toggleHabitCompletion(habit.habitId),
                shape: const CircleBorder(),
              ),
              loading: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.error_outline),
            ),
            
            const SizedBox(width: 12),
            
            // Habit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getScheduleIcon(habit.scheduleType),
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getScheduleText(habit),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Streak
            Column(
              children: [
                streakAsync.when(
                  data: (streak) => Text(
                    '$streak',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _getHabitColor(habit.color),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('--'),
                ),
                Text(
                  'streak',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            // More options
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => actions.deleteHabit(habit.habitId),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getScheduleIcon(ScheduleType type) {
    switch (type) {
      case ScheduleType.daily:
        return Icons.today;
      case ScheduleType.weekly:
        return Icons.calendar_view_week;
      case ScheduleType.interval:
        return Icons.repeat;
    }
  }

  String _getScheduleText(Habit habit) {
    switch (habit.scheduleType) {
      case ScheduleType.daily:
        return 'Daily';
      case ScheduleType.weekly:
        if (habit.scheduleDays.isEmpty) return 'Weekly';
        final days = habit.scheduleDays.map((d) => _getDayName(d)).join(', ');
        return days;
      case ScheduleType.interval:
        return 'Every ${habit.scheduleInterval} days';
    }
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  Color _getHabitColor(HabitColor color) {
    switch (color) {
      case HabitColor.blue:
        return Colors.blue;
      case HabitColor.green:
        return Colors.green;
      case HabitColor.orange:
        return Colors.orange;
      case HabitColor.purple:
        return Colors.purple;
      case HabitColor.red:
        return Colors.red;
      case HabitColor.pink:
        return Colors.pink;
      case HabitColor.teal:
        return Colors.teal;
      case HabitColor.indigo:
        return Colors.indigo;
    }
  }
}
