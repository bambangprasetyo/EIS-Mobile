import 'package:get/get.dart';

class MainMenuController extends GetxController {
  final count = 0.obs;
  final dataList = <Map<String, dynamic>>[].obs;

  void increment() => count.value++;

  void reorderCards(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = dataList.removeAt(oldIndex);
    dataList.insert(newIndex, item);
  }

  // void logout() {
  //   SpUtil.remove("JWT");
  //   // SpUtil.remove("userData");
  //   Get.offAllNamed(Routes.HOME);
  // }
}
