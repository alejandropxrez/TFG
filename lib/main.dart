import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:algoquest/data/models/user_progress_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserProgressModelAdapter());

  runApp(GameWidget(game: FlameGame()));
}
