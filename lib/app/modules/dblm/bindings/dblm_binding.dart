import 'package:get/get.dart';

import '../controllers/dblm_controller.dart';

class DblmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DblmController>(
      () => DblmController(),
    );
  }
}
