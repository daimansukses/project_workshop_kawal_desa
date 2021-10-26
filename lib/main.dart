import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_workshop_kawal_desa/locator.dart';
import 'package:project_workshop_kawal_desa/services/navigation_service.dart';
import 'package:project_workshop_kawal_desa/ui/router.dart';
import 'package:project_workshop_kawal_desa/ui/views/login_view.dart';
import 'package:project_workshop_kawal_desa/ui/views/startup_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runZoned((){
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      home: StartUpView(),
      onGenerateRoute: generateRoute,
      navigatorKey: locator<NavigationService>().navigationKey,
    );
  }
}
