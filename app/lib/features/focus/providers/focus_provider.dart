import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_it/domain/models/focus_session.dart';
import 'package:habit_it/data/repositories/focus_repository.dart';

// Timer state
enum TimerState { idle, running, paused, completed }

class TimerNotifier extends StateNotifier<TimerData> {
  TimerNotifier(this._repository) : super(TimerData.initial());
  
  final FocusRepository _repository;
  Timer? _timer;
  FocusSession? _currentSession;
  
  void setDuration(int minutes) {
    if (state.timerState == TimerState.idle) {
      state = state.copyWith(
        totalSeconds: minutes * 60,
        remainingSeconds: minutes * 60,
      );
    }
  }
  
  Future<void> start() async {
    if (state.timerState == TimerState.idle) {
      // Create new session
      _currentSession = await _repository.createSession(
        start: DateTime.now(),
        length: state.totalSeconds,
        label: 'Focus Session',
      );
    }
    
    state = state.copyWith(timerState: TimerState.running);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        _complete();
      }
    });
  }
  
  void pause() {
    _timer?.cancel();
    state = state.copyWith(timerState: TimerState.paused);
  }
  
  void resume() {
    start();
  }
  
  Future<void> stop() async {
    _timer?.cancel();
    
    if (_currentSession != null) {
      await _repository.completeSession(
        _currentSession!.sessionId,
        DateTime.now(),
      );
    }
    
    _reset();
  }
  
  Future<void> _complete() async {
    _timer?.cancel();
    
    if (_currentSession != null) {
      await _repository.completeSession(
        _currentSession!.sessionId,
        DateTime.now(),
      );
    }
    
    state = state.copyWith(timerState: TimerState.completed);
  }
  
  void _reset() {
    state = TimerData.initial();
    _currentSession = null;
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class TimerData {
  final TimerState timerState;
  final int totalSeconds;
  final int remainingSeconds;
  
  TimerData({
    required this.timerState,
    required this.totalSeconds,
    required this.remainingSeconds,
  });
  
  factory TimerData.initial() {
    return TimerData(
      timerState: TimerState.idle,
      totalSeconds: 25 * 60, // 25 minutes default
      remainingSeconds: 25 * 60,
    );
  }
  
  TimerData copyWith({
    TimerState? timerState,
    int? totalSeconds,
    int? remainingSeconds,
  }) {
    return TimerData(
      timerState: timerState ?? this.timerState,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
  
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }
}

// Providers
final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository();
});

final timerProvider = StateNotifierProvider<TimerNotifier, TimerData>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return TimerNotifier(repository);
});

final focusSessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.watchSessions();
});

final todayFocusTimeProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.getTodayFocusTime();
});

final todaySessionCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return repository.getTodaySessionCount();
});
