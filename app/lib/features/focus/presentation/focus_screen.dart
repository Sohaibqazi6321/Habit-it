import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_it/features/focus/providers/focus_provider.dart';
import 'package:habit_it/features/focus/presentation/widgets/timer_widget.dart';
import 'package:habit_it/features/focus/presentation/widgets/session_history.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayFocusTime = ref.watch(todayFocusTimeProvider);
    final todaySessionCount = ref.watch(todaySessionCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Today's stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          todayFocusTime.when(
                            data: (seconds) {
                              final minutes = seconds ~/ 60;
                              return Text(
                                '${minutes}m',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('--'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          todaySessionCount.when(
                            data: (count) => Text(
                              '$count',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('--'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sessions',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Timer widget
            const TimerWidget(),
            
            const SizedBox(height: 32),
            
            // Session history
            const SessionHistory(),
          ],
        ),
      ),
    );
  }
}
