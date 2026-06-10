import 'dart:convert';

import 'package:drift/drift.dart';

class UserProgressTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text().unique()();

  IntColumn get level => integer()();

  RealColumn get experiencePoints => real()();

  IntColumn get livesRemaining => integer()();

  TextColumn get unlockedLevels => text().map(const StringListConverter())();

  TextColumn get currentLevelId => text().nullable()();

  TextColumn get completedLevels => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.cast<String>();
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}
