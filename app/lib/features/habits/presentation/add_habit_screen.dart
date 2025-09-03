import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_it/domain/models/habit.dart';
import 'package:habit_it/features/habits/providers/habits_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  ScheduleType _scheduleType = ScheduleType.daily;
  HabitColor _selectedColor = HabitColor.blue;
  List<int> _selectedDays = [];
  int _intervalDays = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAddAsync = ref.watch(canAddHabitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: canAddAsync.when(
        data: (canAdd) {
          if (!canAdd) {
            return const _UpgradePrompt();
          }
          
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title field
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'e.g., Read 10 pages',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a habit name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Schedule type
          Text(
            'Schedule',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          Column(
            children: [
              RadioListTile<ScheduleType>(
                title: const Text('Daily'),
                subtitle: const Text('Every day'),
                value: ScheduleType.daily,
                groupValue: _scheduleType,
                onChanged: (value) => setState(() => _scheduleType = value!),
              ),
              RadioListTile<ScheduleType>(
                title: const Text('Weekly'),
                subtitle: const Text('Specific days of the week'),
                value: ScheduleType.weekly,
                groupValue: _scheduleType,
                onChanged: (value) => setState(() => _scheduleType = value!),
              ),
              RadioListTile<ScheduleType>(
                title: const Text('Interval'),
                subtitle: const Text('Every few days'),
                value: ScheduleType.interval,
                groupValue: _scheduleType,
                onChanged: (value) => setState(() => _scheduleType = value!),
              ),
            ],
          ),
          
          // Schedule options
          if (_scheduleType == ScheduleType.weekly) ...[
            const SizedBox(height: 16),
            Text(
              'Days of the week',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildDaySelector(),
          ],
          
          if (_scheduleType == ScheduleType.interval) ...[
            const SizedBox(height: 16),
            Text(
              'Repeat every',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: _intervalDays.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null && days > 0) {
                        _intervalDays = days;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('days'),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Color picker
          Text(
            'Color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildColorPicker(),
          
          const SizedBox(height: 32),
          
          // Create button
          FilledButton(
            onPressed: _isLoading ? null : _createHabit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Habit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = _selectedDays.contains(dayNumber);
        
        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(dayNumber);
              } else {
                _selectedDays.remove(dayNumber);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      children: HabitColor.values.map((color) {
        final isSelected = _selectedColor == color;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getColorValue(color),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Color _getColorValue(HabitColor color) {
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

  Future<void> _createHabit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_scheduleType == ScheduleType.weekly && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final actions = ref.read(habitActionsProvider);
      
      await actions.createHabit(
        title: _titleController.text.trim(),
        scheduleType: _scheduleType,
        scheduleDays: _scheduleType == ScheduleType.weekly ? _selectedDays : [],
        scheduleInterval: _scheduleType == ScheduleType.interval ? _intervalDays : 1,
        color: _selectedColor,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit created successfully!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating habit: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _UpgradePrompt extends StatelessWidget {
  const _UpgradePrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Pro',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve reached the free limit of 3 habits. Upgrade to Pro for unlimited habits and more features.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                // TODO: Navigate to paywall
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paywall coming in Phase 3!')),
                );
              },
              child: const Text('Upgrade Now'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }
}
