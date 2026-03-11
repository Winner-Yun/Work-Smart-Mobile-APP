import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/app.dart';
import 'package:flutter_worksmart_mobile_app/core/bootstrap.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/user/restartwidget.dart';

void main() async {
  // Setup app and launch.
  final initialRoute = await AppBootstrap.init();

  runApp(RestartWidget(child: MainApp(initialRoute: initialRoute)));
}
