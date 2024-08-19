import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modules/MainMenu/views/main_menu_view.dart';
import '../modules/home/views/home_view.dart';

class CheckAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: checkAuthenticationStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Menampilkan indikator loading jika masih dalam proses pengecekan
              return CircularProgressIndicator();
            } else {
              // Jika sudah selesai, periksa status otentikasi
              if (snapshot.data == true) {
                // Jika sudah login, arahkan ke MainMenuView
                return MainMenuView();
              } else {
                // Jika belum login, arahkan ke LoginScreen
                return HomeView();
              }
            }
          },
        ),
      ),
    );
  }

  Future<bool> checkAuthenticationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwtToken');
    // Jika jwtToken tidak null, berarti pengguna sudah login
    return jwtToken != null;
  }
}
