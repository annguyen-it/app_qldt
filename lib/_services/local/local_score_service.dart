import 'package:app_qldt/_models/score.dart';
import 'package:app_qldt/_services/web/exception/no_score_data_exception.dart';
import 'package:app_qldt/_services/web/score_service.dart';
import 'package:app_qldt/_utils/database/provider.dart';
import 'package:app_qldt/score/bloc/enum/subject_status.dart';
import 'package:app_qldt/_models/semester.dart';

class LocalScoreService {
  final String? userId;
  late DatabaseProvider _databaseProvider;
  late final ScoreService _scoreService;
  late bool connected;

  List<Score> scoreData = [];
  List<Semester> semester = [];

  LocalScoreService({DatabaseProvider? databaseProvider, this.userId}) {
    this._databaseProvider = databaseProvider ?? DatabaseProvider();

    if (userId != null) {
      _scoreService = ScoreService(userId!);
    }
  }

  Future<List<Score>?> refresh() async {
    try {
      List<Score>? data = await _scoreService.getScore();

      if (data != null) {
        await removeOld();
        await _saveNew(data);
      }

      scoreData = await _getScoreDataFromDb();
      semester = await _getSemesterFromDb();

      connected = true;

      return this.scoreData;

    } on NoScoreDataException catch (_) {
      connected = false;
      return null;
    }
  }

  Future<void> _saveNew(List<Score> rawData) async {
    for (var row in rawData) {
      await _databaseProvider.score.insert(row.toMap());
    }
  }

  Future<void> removeOld() async {
    await _databaseProvider.score.delete();
  }

  Future<List<Score>> _getScoreDataFromDb() async {
    final rawData = await _databaseProvider.score.all;

    return rawData.map((data) {
      return Score.fromMap(data);
    }).toList();
  }

  Future<List<Semester>> _getSemesterFromDb() async {
    final List<Map<String, dynamic>> rawData = await _databaseProvider.score.semester;
    final List<Semester> list = [Semester.all];

    rawData.forEach((data) {
      list.add(Semester(data['semester'].toString()));
    });

    return list;
  }

  List<Score> getScoreDataOfAllEvaluation(Semester semester) {
    return scoreData.where((score) => score.semester == semester.query).toList();
  }

  List<Score> getScoreDataOfAllSemester(SubjectEvaluation subjectEvaluation) {
    if (subjectEvaluation == SubjectEvaluation.pass) {
      return scoreData.where((score) => score.evaluation == SubjectEvaluation.pass.query).toList();
    }
    //  Fail
    else {
      List<Score> newScoreData = [];
      List<Score> passedScoreData =
          scoreData.where((score) => score.evaluation == SubjectEvaluation.pass.query).toList();

      scoreData.forEach((score) {
        if (score.evaluation == SubjectEvaluation.fail.query) {
          bool fail = true;

          passedScoreData.forEach((passedScore) {
            if (score.moduleName == passedScore.moduleName) {
              fail = false;
            }
          });

          if (fail) {
            newScoreData.add(score);
          }
        }
      });

      return newScoreData;
    }
  }

  List<Score> getSpecificScoreData(Semester semester, SubjectEvaluation subjectEvaluation) {
    return getScoreDataOfAllSemester(subjectEvaluation)
        .where((score) => score.semester == semester.query)
        .toList();
  }
}
