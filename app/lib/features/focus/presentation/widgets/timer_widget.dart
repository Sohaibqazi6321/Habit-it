import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_it/features/focus/providers/focus_provider.dart';

class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerData = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Duration selector (only when idle)
            if (timerData.timerState == TimerState.idle) ...[
              Text(
                'Focus Duration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DurationButton(
                    minutes: 15,
                    isSelected: timerData.totalSeconds == 15 * 60,
                    onTap: () => timerNotifier.setDuration(15),
                  ),
                  _DurationButton(
                    minutes: 25,
                    isSelected: timerData.totalSeconds == 25 * 60,
                    onTap: () => timerNotifier.setDuration(25),
                  ),
                  _DurationButton(
                    minutes: 45,
                    isSelected: timerData.totalSeconds == 45 * 60,
                    onTap: () => timerNotifier.setDuration(45),
                  ),
                  _DurationButton(
                    minutes: 60,
                    isSelected: timerData.totalSeconds == 60 * 60,
                    onTap: () => timerNotifier.setDuration(60),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Circular progress indicator with timer
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: timerData.progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTimerColor(context, timerData.timerState),
                      ),
                    ),
                  ),
                  // Timer text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timerData.formattedTime,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                        ),
                      ),
                      if (timerData.timerState == TimerState.completed)
                        Text(
                          'Completed!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (timerData.timerState == TimerState.idle) ...[
                  FilledButton.icon(
                    onPressed: timerNotifier.start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ] else if (timerData.timerState == TimerState.running) ...[
                  FilledButton.icon(
                    onPressed: timerNotifier.pause,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: timerNotifier.stop,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ] else if (timerData.timerState == TimerState.paused) ...[
                  FilledButton.icon(
                    onPressed: timerNotifier.resume,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: timerNotifier.stop,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ] else if (timerData.timerState == TimerState.completed) ...[
                  FilledButton.icon(
                    onPressed: timerNotifier.stop,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Session'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimerColor(BuildContext context, TimerState state) {
    switch (state) {
      case TimerState.idle:
        return Theme.of(context).colorScheme.primary;
      case TimerState.running:
        return Colors.green;
      case TimerState.paused:
        return Colors.orange;
      case TimerState.completed:
        return Colors.green;
    }
  }
}

class _DurationButton extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationButton({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${minutes}m',
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
