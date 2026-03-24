import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/user_progress_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [UserProgressTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Used in tests to create an in-memory database.
  AppDatabase.test(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'algoquest.sqlite'));
    return NativeDatabase(file);
  });
}
