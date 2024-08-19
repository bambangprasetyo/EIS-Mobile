import 'package:get/get.dart';

import '../controllers/getdata_controller.dart';

class GetdataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetdataController>(() => GetdataController());
  }
}
