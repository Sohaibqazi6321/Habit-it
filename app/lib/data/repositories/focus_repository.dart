import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_it/domain/models/focus_session.dart';
import 'package:habit_it/services/database_service.dart';

final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository();
});

class FocusRepository {
  Isar get _isar => DatabaseService.instance;
  final _uuid = const Uuid();
  
  // Get all focus sessions
  Future<List<FocusSession>> getSessions() async {
    return await _isar.focusSessions
        .where()
        .sortByStartDesc()
        .findAll();
  }
  
  // Stream of sessions for real-time updates
  Stream<List<FocusSession>> watchSessions() {
    return _isar.focusSessions
        .where()
        .sortByStartDesc()
        .watch(fireImmediately: true);
  }
  
  // Create new focus session
  Future<FocusSession> createSession({
    required DateTime start,
    required int length,
    String label = 'Focus Session',
  }) async {
    final session = FocusSession.create(
      sessionId: _uuid.v4(),
      start: start,
      length: length,
      label: label,
    );
    
    await _isar.writeTxn(() async {
      await _isar.focusSessions.put(session);
    });
    
    return session;
  }
  
  // Complete a session
  Future<void> completeSession(String sessionId, DateTime endTime) async {
    final session = await _isar.focusSessions
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
    
    if (session != null) {
      session.end = endTime;
      session.updatedAt = DateTime.now();
      
      await _isar.writeTxn(() async {
        await _isar.focusSessions.put(session);
      });
    }
  }
  
  // Get total focus time for today
  Future<int> getTodayFocusTime() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final sessions = await _isar.focusSessions
        .filter()
        .startBetween(startOfDay, endOfDay)
        .and()
        .endIsNotNull()
        .findAll();
    
    return sessions.fold<int>(0, (total, session) {
      if (session.end != null) {
        return total + session.end!.difference(session.start).inSeconds;
      }
      return total;
    });
  }
  
  // Get session count for today
  Future<int> getTodaySessionCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await _isar.focusSessions
        .filter()
        .startBetween(startOfDay, endOfDay)
        .and()
        .endIsNotNull()
        .count();
  }
}
