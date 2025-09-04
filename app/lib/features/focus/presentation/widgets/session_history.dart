import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:habit_it/features/focus/providers/focus_provider.dart';
import 'package:habit_it/domain/models/focus_session.dart';

class SessionHistory extends ConsumerWidget {
  const SessionHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(focusSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const _EmptyHistory();
            }
            
            // Show only completed sessions and limit to 10
            final completedSessions = sessions
                .where((s) => s.end != null)
                .take(10)
                .toList();
            
            if (completedSessions.isEmpty) {
              return const _EmptyHistory();
            }
            
            return Column(
              children: completedSessions.map((session) {
                return _SessionCard(session: session);
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading sessions: $error'),
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final FocusSession session;
  
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = session.end != null 
        ? session.end!.difference(session.start)
        : Duration.zero;
    
    final durationText = duration.inMinutes > 0 
        ? '${duration.inMinutes}m ${duration.inSeconds % 60}s'
        : '${duration.inSeconds}s';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.timer,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(session.label),
        subtitle: Text(
          DateFormat('MMM d, h:mm a').format(session.start),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              durationText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (duration.inMinutes >= session.length ~/ 60)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first focus session to see it here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
