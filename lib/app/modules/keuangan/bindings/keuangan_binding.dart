import 'package:get/get.dart';

import '../controllers/keuangan_controller.dart';

class KeuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeuanganController>(
      () => KeuanganController(),
    );
  }
}
