import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sp_util/sp_util.dart';

import '../../../data/login_provider.dart';
import '../../../routes/app_pages.dart';

class CustomAppBarWithMenu extends StatefulWidget
    implements PreferredSizeWidget {
  const CustomAppBarWithMenu({Key? key}) : super(key: key);

  @override
  _CustomAppBarWithMenuState createState() => _CustomAppBarWithMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

String formatDate(String date) {
  final DateTime parsedDate = DateTime.parse(date);
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  return formatter.format(parsedDate);
}

class _CustomAppBarWithMenuState extends State<CustomAppBarWithMenu> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkUserLevel();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _checkUserLevel() async {
    final response = await UserDataProvider().fetchUserData();
    final userData = response.body as Map<String, dynamic>;
    final user =
        (userData['db_user'] as List<dynamic>?)?.first as Map<String, dynamic>?;
    if (user != null) {
      final level = user['Level']?.toString() ?? 'N/A';
      if (level == '0') {
        _timer = Timer.periodic(Duration(seconds: 3), (timer) {
          Get.snackbar(
            'Akses Terbatas',
            'Harap Hubungin Divisi TI Untuk Meminta Hak Akses.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 2), // Durasi pesan snackbar
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Menyembunyikan tombol "back"
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Periode Data',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE1F7F5),
                ),
              ),
              FutureBuilder<Response>(
                future: Periode().fetchperiode(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      snapshot.hasError) {
                    return Container();
                  } else {
                    final responseData = snapshot.data?.body;
                    final periodeData =
                        responseData!['sys_parameter'] as Map<String, dynamic>;
                    final parameterValue =
                        periodeData['ParameterValue'] as String?;
                    final formattedDate = parameterValue != null
                        ? formatDate(parameterValue)
                        : 'ParameterValue';
                    return Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE1F7F5),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'EIS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE1F7F5),
            ),
          ),
          const Spacer(),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 6, 72, 126),
      elevation: 0,
      actions: [
        FutureBuilder<Response>(
          future: UserDataProvider().fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final userData = snapshot.data?.body as Map<String, dynamic>;
              final user = (userData['db_user'] as List<dynamic>?)?.first
                  as Map<String, dynamic>?;
              if (user != null) {
                final fullName = user['FullName'] ?? 'N/A';
                final level = user['Level']?.toString() ?? 'N/A';
                final cabang = user['Cabang'] ?? 'N/A';
                final wilayah = user['Wilayah'] ?? 'N/A';
                final picSmall = user['picSmall'] ?? 'N/A';
                return PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: Container(
                          width: double.infinity,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage('$picSmall'),
                            ),
                            title: Text(
                              'FullName: $fullName\nLevel: $level\nWilayah: $wilayah\nCabang: $cabang',
                              maxLines:
                                  4, // Batasi jumlah baris untuk menghindari overflow vertikal
                              overflow: TextOverflow
                                  .ellipsis, // Tambahkan elipsis jika teks melebihi batas
                            ),
                            onTap: () {
                              // Handle profile tap
                            },
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () async {
                            await SpUtil.remove("JWT");
                            Get.offAllNamed(Routes.LOGIN);
                          },
                        ),
                      ),
                    ];
                  },
                  icon: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage('$picSmall'),
                  ),
                );
              } else {
                return const SizedBox();
              }
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}
