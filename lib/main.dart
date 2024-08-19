import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sp_util/sp_util.dart';

import 'app/data/login_provider.dart';
import 'app/routes/app_pages.dart';

String? lastEntryTime;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Meminta izin notifikasi saat aplikasi pertama kali dijalankan
  await requestNotificationPermission();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize SPUtil
  await SpUtil.getInstance();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Hapus semua data di penyimpanan saat mengarahkan ke HOME
  await SpUtil.remove("JWT");

  // Mengatur initial route tanpa pengecekan token
  String initialRoute = Routes.HOME;

  runApp(GetMaterialApp(
    title: "Application",
    initialRoute: initialRoute,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
  ));

  // Menghapus pengecekan token untuk penjadwalan
  Timer.periodic(Duration(seconds: 1), (Timer timer) async {
    await fetchLatestLoanActivityAndNotify();
  });
}

Future<void> requestNotificationPermission() async {
  // Minta izin notifikasi
  var status = await Permission.notification.request();

  // Periksa apakah izin diberikan atau tidak
  if (status.isGranted) {
    print('Izin notifikasi diberikan');
  } else {
    print('Izin notifikasi ditolak');
    // Tampilkan penjelasan kepada pengguna mengapa izin notifikasi diperlukan
    // dan cara untuk mengizinkannya secara manual melalui pengaturan perangkat
    if (status.isPermanentlyDenied) {
      // Kasus ketika pengguna menolak izin secara permanen
      openAppSettings(); // Buka pengaturan aplikasi untuk mengizinkan notifikasi
    }
  }
}

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'EIS',
    'Pencairan Baru',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> fetchLatestLoanActivityAndNotify() async {
  try {
    // Periksa apakah token JWT tersedia
    final token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      print('Token JWT tidak tersedia.');
      return;
    }

    final response = await LoanActivityProvider1().fetchLoanActivity1();
    if (response.statusCode == 200 && response.body != null) {
      final data = response.body['lhlon_dd_idx'];
      final latestActivity = data.isNotEmpty ? data.first : null;
      if (latestActivity != null) {
        final latestEntryTime = latestActivity['Jam Entry'];
        if (latestEntryTime != lastEntryTime) {
          lastEntryTime = latestEntryTime;

          // Ambil wilayah dari UserDataProvider
          var userDataResponse = await UserDataProvider().fetchUserData();
          var userDataBody = userDataResponse
              .body; // Jangan lupa cek null sebelum mengakses body
          var userData = userDataBody['db_user']
              [0]; // Asumsi db_user adalah kunci yang berisi data pengguna
          var wilayahPengguna = userData['Wilayah'];

          if (wilayahPengguna == 'KONSOLIDASI') {
            // Tampilkan semua notifikasi jika wilayah sama dengan KONSOLIDASI
            final cabang = latestActivity['Cabang'];
            final tanggalEntry = latestActivity['Tanggal Entry'];
            final jamEntry = latestActivity['Jam Entry'];
            final loanType = latestActivity['Loan Type'];

            final title = 'Data Terbaru';
            final body =
                'Cabang: $cabang\nWilayah: $wilayahPengguna\nTanggal Entry: $tanggalEntry\nJam Entry: $jamEntry\nLoan Type: $loanType';
            await showNotification(title, body);
            print('Notification shown: $body');
          } else {
            // Filter notifikasi berdasarkan wilayah
            final wilayahKegiatan = latestActivity['Wilayah'];
            if (wilayahPengguna == wilayahKegiatan) {
              final cabang = latestActivity['Cabang'];
              final tanggalEntry = latestActivity['Tanggal Entry'];
              final jamEntry = latestActivity['Jam Entry'];
              final loanType = latestActivity['Loan Type'];

              final title = 'Data Terbaru';
              final body =
                  'Cabang: $cabang\nWilayah: $wilayahKegiatan\nTanggal Entry: $tanggalEntry\nJam Entry: $jamEntry\nLoan Type: $loanType';
              await showNotification(title, body);
              print('Notification shown: $body');
            } else {
              print(
                  'Wilayah pengguna bukan $wilayahPengguna, tidak menampilkan notifikasi.');
            }
          }
        } else {
          print('Tidak ada data baru.');
        }
      } else {
        print('Data tidak ditemukan');
      }
    } else {
      print('Gagal mengambil data terbaru');
    }
  } catch (e) {
    print('Error: $e');
  }
}
