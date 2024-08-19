import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFD3D3D3), // Silver
                Color(0xFFD3D3D3), // Biru
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD3D3D3), // Silver
              Color(0xFF4682B4), // Biru
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hallo,",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Selamat Datang, Silahkan Login",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: controller.txtusername,
                decoration: const InputDecoration(
                  labelText: "username",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.txtpassword,
                decoration: const InputDecoration(
                  labelText: "password",
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => controller.auth(),
                  child: const Text(
                    "L O G I N",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 72, 126),
                    fixedSize: Size(Get.width, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
