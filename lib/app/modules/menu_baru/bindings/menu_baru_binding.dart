import 'package:get/get.dart';

import '../controllers/menu_baru_controller.dart';

class MenuBaruBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuBaruController>(
      () => MenuBaruController(),
    );
  }
}
