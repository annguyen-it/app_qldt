import 'package:app_qldt/models/schedule.dart';
import 'package:app_qldt/services/DatabaseProvider.dart';

class OfflineCalendarService {
  static Future<void> saveCalendar(List<Schedule> rawData) async {
    rawData.forEach((row) async {
      await DatabaseProvider.db.insertSchedule(row.toMap());
    });
  }

  static Future<Map<DateTime, List>> getCalendar() async {
    List<Map<String, dynamic>> rawData = await DatabaseProvider.db.schedule;
    Map<DateTime, dynamic> data = _parseToStandardStructure(rawData);
    return data;
  }

  static Future<void> removeSavedCalendar() async {
    print('Trying to remove saved calendar');
    await DatabaseProvider.db.deleteSchedule();
  }

  static Map<DateTime, List> _parseToStandardStructure(
      List<Map<String, dynamic>> maps) {
    List<Schedule> rawData = List.generate(
      maps.length,
      (index) => Schedule.fromMap(maps[index]),
    );

    Map<DateTime, List> events = new Map();

    rawData.forEach((schedule) {
      if (events[schedule.daySchedules] == null) {
        events[schedule.daySchedules] = [];
      }
      events[schedule.daySchedules].add(schedule);
    });

    return events;
  }
}
