import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/masterpage_controller.dart';

class MasterpageView extends GetView<MasterpageController> {
  const MasterpageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MasterpageView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MasterpageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
