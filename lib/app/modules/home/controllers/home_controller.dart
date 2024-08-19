import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  // Method untuk menavigasi ke halaman login
  void onTapLogin() {
    Get.toNamed(Routes.LOGIN);
  }

  // Method untuk memuat data
  Future<void> loadData() async {
    // Anda dapat menambahkan logika untuk memuat data di sini
    // Sebagai contoh, menunggu 2 detik sebelum data selesai dimuat
    await Future.delayed(const Duration(seconds: 2));
  }
}
