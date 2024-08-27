import 'package:get/get.dart';

import '../controllers/dpk_controller.dart';

class DpkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DpkController>(
      () => DpkController(),
    );
  }
}
