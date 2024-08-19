import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

import '../../../data/login_provider.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  bool isPasswordVisible = false;
  final TextEditingController txtusername = TextEditingController();
  final TextEditingController txtpassword = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSavedLogin();
  }

  String get username => txtusername.text;
  String get password => txtpassword.text;

  void auth() {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Username dan Password tidak boleh kosong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    EasyLoading.show();

    var data = {"username": username, "password": password};
    String jsonData = jsonEncode(data);

    LoginProvider().auth(jsonData).then((value) async {
      if (value.statusCode == 200) {
        var responseBody = value.body;
        var JWT = responseBody['JWT'];
        if (JWT != null) {
          SpUtil.putString('JWT', JWT);
          final prefs = await SharedPreferences.getInstance();
          final savedUsername = prefs.getString('saved_username') ?? '';

          if (savedUsername != username) {
            showSaveLoginDialog();
          } else {
            Get.offAllNamed(Routes.MENU_BARU);
          }
        } else {
          Get.snackbar(
            "Error",
            "Token JWT tidak ditemukan dalam respons",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        var error1 = value.statusCode;
        Get.snackbar(
          "Error",
          "Login Gagal $error1",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      EasyLoading.dismiss();
    }).catchError((error) {
      Get.snackbar(
        "Error",
        " $error",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      EasyLoading.dismiss();
    });
  }

  void showSaveLoginDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Row(
          children: [
            Icon(Icons.save, color: Colors.blue),
            SizedBox(width: 10),
            Text("Simpan Login"),
          ],
        ),
        content:
            const Text("Apakah Anda ingin menyimpan username dan password?"),
        actions: [
          TextButton(
            onPressed: () => Get.offAllNamed(Routes.MENU_BARU),
            child: const Text(
              "Tidak",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await saveLogin(username, password);
              Get.offAllNamed(Routes.MENU_BARU);
            },
            child: const Text("Ya"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
  }

  Future<void> loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';

    txtusername.text = savedUsername;
    txtpassword.text = savedPassword;
  }
}
