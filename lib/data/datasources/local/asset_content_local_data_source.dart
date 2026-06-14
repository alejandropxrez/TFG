import 'dart:convert';

import 'package:algoquest/data/datasources/local/content_local_data_source.dart';

import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';
import 'package:algoquest/data/models/syllabus_model.dart';

import 'package:flutter/services.dart';

class AssetContentLocalDataSource implements ContentLocalDataSource {
  static const String _levelsPath = 'assets/data/levels';
  static const String _challengesPath = 'assets/data/challenges';
  static const String _syllabusPath = 'assets/data/syllabus.json';

  @override
  Future<LevelSyllabusModel> getLevelSyllabus(String levelId) async {
    final String path = '$_levelsPath/$levelId.json';
    final decoded = await decode(path);

    return LevelSyllabusModel.fromJson(decoded);
  }

  @override
  Future<ChallengeModel> getChallenge(String challengeId) async {
    final String path = '$_challengesPath/$challengeId.json';
    final decoded = await decode(path);

    return ChallengeModel.fromJson(decoded);
  }

  @override
  Future<SyllabusModel> getSyllabus() async {
    final decoded = await decode(_syllabusPath);
    return SyllabusModel.fromJson(decoded);
  }

  Future<Map<String, dynamic>> decode(String path) async {
    final String jsonString = await rootBundle.loadString(path);
    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected JSON object for syllabus: $path');
    }

    return decoded;
  }
}
