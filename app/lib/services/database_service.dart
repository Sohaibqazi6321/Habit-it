import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:habit_it/domain/models/habit.dart';
import 'package:habit_it/domain/models/habit_log.dart';
import 'package:habit_it/domain/models/focus_session.dart';

class DatabaseService {
  static late Isar _isar;
  
  static Isar get instance => _isar;
  
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [HabitSchema, HabitLogSchema, FocusSessionSchema],
      directory: dir.path,
    );
  }
  
  static Future<void> close() async {
    await _isar.close();
  }
}
