import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../menu_baru/views/appbar.dart';
import '../controllers/keuangan_controller.dart';
import 'histori_view.dart'; // Import for the Histori tab content
import 'keuangan_view.dart'; // Import for the Detail tab content

class KhomeView extends GetView<KeuanganController> {
  const KhomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomAppBarWithMenu appBar = const CustomAppBarWithMenu();

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: appBar,
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              Get.back();
            }
          },
          child: Dismissible(
            key: const Key('dismissibleKey'),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              Get.back();
            },
            child: const Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Detail'),
                    Tab(text: 'Histori'),
                  ],
                  indicatorColor: Colors.blue,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Content for the "Detail" tab
                      KeuanganView(), // This should be the actual widget you use for Detail
                      // Content for the "Histori" tab
                      HistoriView(), // This should be the actual widget you use for Histori
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const GetMaterialApp(
    home: KhomeView(),
  ));
}
