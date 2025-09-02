import 'package:isar/isar.dart';

part 'focus_session.g.dart';

@collection
class FocusSession {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String sessionId;
  
  late DateTime start;
  DateTime? end;
  
  late int length; // Duration in seconds
  
  String label = 'Focus Session';
  
  late DateTime updatedAt;
  
  FocusSession();
  
  FocusSession.create({
    required this.sessionId,
    required this.start,
    this.end,
    required this.length,
    this.label = 'Focus Session',
    DateTime? updatedAt,
  }) {
    this.updatedAt = updatedAt ?? DateTime.now();
  }
}
