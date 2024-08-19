import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';

import '../routes/app_pages.dart';

class MyAppLifecycleObserver extends NavigatorObserver
    with WidgetsBindingObserver {
  DateTime? _lastPausedTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null &&
          DateTime.now().difference(_lastPausedTime!).inMinutes > 5) {
        // Clear token and redirect to login
        SpUtil.clear();
        Get.offAllNamed(Routes.LOGIN);
      }
      _lastPausedTime = null;
    }
  }
}
