import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/constants/app_config.dart';
import 'package:eventsync_mobile/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure environment — change for physical device / production
  AppConfig.init(env: Environment.dev);
  // For physical device: AppConfig.init(baseUrl: 'http://192.168.x.x:8080/api/v1');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: EventSyncApp(),
    ),
  );
}
