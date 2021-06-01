import 'package:app_qldt/_models/exam_schedule_model.dart';
import 'package:app_qldt/_services/local/local_service.dart';
import 'package:app_qldt/_services/web/exam_schedule_service.dart';
import 'package:app_qldt/_services/web/exception/no_exam_schedule_data_exception.dart';
import 'package:app_qldt/_utils/database/provider.dart';
import 'package:app_qldt/_models/semester_model.dart';
import 'package:intl/intl.dart';

class LocalExamScheduleService extends LocalService {
  late final ExamScheduleService _examScheduleService;

  List<ExamScheduleModel> examScheduleData = [];
  List<SemesterModel> semester = [];

  LocalExamScheduleService({DatabaseProvider? databaseProvider, required String userId})
      : _examScheduleService = ExamScheduleService(userId),
        super(databaseProvider);

  SemesterModel? get lastSemester => semester.length == 0 ? null : semester[semester.length - 1];

  Future<List<ExamScheduleModel>?> refresh() async {
    try {
      List<ExamScheduleModel>? data = await _examScheduleService.getExamSchedule();

      if (data != null) {
        await _removeOld();
        await _saveNew(data);
      }

      examScheduleData = await _getExamScheduleDataFromDb();
      semester = await _getSemesterFromDb();

      connected = true;

      return this.examScheduleData;
    } on NoExamScheduleDataException catch (_) {
      connected = false;
      return null;
    }
  }

  Future<void> _saveNew(List<ExamScheduleModel> rawData) async {
    for (var row in rawData) {
      await databaseProvider.examSchedule.insert(row.toMap());
    }
  }

  Future<void> _removeOld() async {
    await databaseProvider.examSchedule.delete();
  }

  Future<List<ExamScheduleModel>> _getExamScheduleDataFromDb() async {
    final rawData = await databaseProvider.examSchedule.all;

    return rawData.map((data) {
      return ExamScheduleModel.fromMap(data);
    }).toList();
  }

  Future<List<SemesterModel>> _getSemesterFromDb() async {
    final List<Map<String, dynamic>> rawData = await databaseProvider.examSchedule.semester;
    final List<SemesterModel> list = [];

    rawData.forEach((data) {
      list.add(SemesterModel(data['semester'].toString()));
    });

    return list;
  }

  List<ExamScheduleModel> getExamScheduleOfSemester(SemesterModel semester) {
    List<ExamScheduleModel> res = examScheduleData.where((examSchedule) {
      return examSchedule.semester == semester.query;
    }).toList();

    res.sort((a, b) => DateFormat('d-M-yyyy').parse(a.dateStart).compareTo(DateFormat('d-M-yyyy').parse(b.dateStart)));

    return res;
  }
}
