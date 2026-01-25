import 'package:algoquest/core/constants/hive_type_ids.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../data/models/user_progress_model.dart';

class HiveBootstrap {
  static bool _initialized = false;

  const HiveBootstrap._();

  static Future<void> init() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    // Register adapters (only once)
    if (!Hive.isAdapterRegistered(HiveTypeIds.userProgressModel)) {
      Hive.registerAdapter(UserProgressModelAdapter());
    }

    _initialized = true;
  }
}
