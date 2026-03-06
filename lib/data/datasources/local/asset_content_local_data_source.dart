import 'dart:convert';

import 'package:algoquest/data/datasources/local/content_local_data_source.dart';

import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';

import 'package:flutter/services.dart';

class AssetContentLocalDataSource implements ContentLocalDataSource {
  static const String _levelsPath = 'assets/data/levels';
  static const String _challengesPath = 'assets/data/challenges';

  @override
  Future<LevelSyllabusModel> getLevelSyllabus(String levelId) async {
    final String path = '_$_levelsPath/$levelId.json';
    final String jsonString = await rootBundle.loadString(path);
    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected JSON object for level syllabus: $path');
    }

    return LevelSyllabusModel.fromJson(decoded);
  }

  @override
  Future<ChallengeModel> getChallenge(String challengeId) async {
    final String path = '_$_challengesPath/$challengeId.json';
    final String jsonString = await rootBundle.loadString(path);
    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected JSON object for challenge: $path');
    }

    return ChallengeModel.fromJson(decoded);
  }
}
