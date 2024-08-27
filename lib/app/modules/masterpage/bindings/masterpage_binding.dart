import 'package:get/get.dart';

import '../controllers/masterpage_controller.dart';

class MasterpageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasterpageController>(
      () => MasterpageController(),
    );
  }
}
