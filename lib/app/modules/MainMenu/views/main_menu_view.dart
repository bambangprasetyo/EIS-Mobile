import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../data/login_provider.dart';
import '../../Getdata/views/getdata_view.dart';
import '../../menu_baru/views/menu_baru_view.dart';
import '../controllers/main_menu_controller.dart';

class MainMenuView extends GetView<MainMenuController> {
  const MainMenuView({Key? key});

  @override
  Widget build(BuildContext context) {
    String? jwtToken = SpUtil.getString("JWT");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hallo, $jwtToken',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE1F7F5), // Warna biru tua
          ),
        ),
        actions: [
          PopupMenuButton(itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: Text(
                  'Hello, $jwtToken',
                  style: const TextStyle(
                    color: Color(0xFF06487E), // Warna biru tua
                  ),
                ),
                enabled: false,
              )
            ];
            //     const PopupMenuItem(
            //       child: Text('Logout'),
            //       value: 'logout',
            //     ),
            //   ];
            // },
            // onSelected: (value) {
            //   if (value == 'logout') {
            //     controller.logout();
            //   }
            // },
          }),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xFF1E0342), // Warna putih
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFF1E0342), // Warna abu-abu muda
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Menu
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      _buildMenuButton(
                        icon: Icons.dashboard,
                        label: 'Dashboard',
                        onTap: () {
                          // Get.to(() => DashboardView());
                        },
                      ),
                      _buildMenuButton(
                        icon: Icons.report,
                        label: 'Reports',
                        onTap: () {
                          // Get.to(() => ReportsView());
                        },
                      ),
                      _buildMenuButton(
                        icon: Icons.settings,
                        label: 'Settings',
                        onTap: () {
                          // Get.to(() => SettingsView());
                        },
                      ),
                      _buildMenuButton(
                        icon: Icons.person,
                        label: 'Profile',
                        onTap: () {
                          // Get.to(() => ProfileView());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 280,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: loadData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Map<String, dynamic>> data = snapshot.data ?? [];
                      return SlideShow(data: data);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'KPI Deviasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9AC8CD), // Warna biru tua
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: loadData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          List<Map<String, dynamic>> data = snapshot.data ?? [];
                          double screenWidth =
                              MediaQuery.of(context).size.width;

                          return Padding(
                            padding:
                                const EdgeInsets.all(8.0), // Margin untuk tabel
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFF06487E), // Warna abu-abu muda
                                borderRadius:
                                    BorderRadius.circular(10), // Sudut border
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing:
                                      20, // Mengatur ruang antara kolom
                                  dataRowColor: MaterialStateColor.resolveWith(
                                      (states) => const Color.fromARGB(
                                          255, 222, 222, 222)),
                                  // Warna abu-abu muda
                                  columns: [
                                    DataColumn(
                                      label: SizedBox(
                                        width: screenWidth *
                                            0.2, // Lebar kolom Cabang
                                        child: Text(
                                          'Cabang',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            // Warna biru tua
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: screenWidth *
                                            0.3, // Lebar kolom KPI
                                        child: Text(
                                          'KPI',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            // Warna biru tua
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: screenWidth *
                                            0.3, // Lebar kolom Deviasi
                                        child: Text(
                                          'Deviasi',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            // Warna biru tua
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: data.map((data) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(data['Cabang'])),
                                        DataCell(Text(data['KPI'])),
                                        DataCell(
                                          // Menambahkan tanda % di belakang angka deviasi
                                          Text(
                                              '${data['Deviasi'].toStringAsFixed(2)}%'),
                                        ),
                                      ],
                                      onSelectChanged: (isSelected) {
                                        if (isSelected != null && isSelected) {
                                          // Ketika data di tabel diklik, navigasi ke halaman detail (GetdataView)
                                          String selectedKPI = data['KPI'];
                                          Get.to(() => GetdataView(),
                                              arguments: {
                                                'selectedKPI': selectedKPI
                                              });
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60, // Atur tinggi bottom menu sesuai kebutuhan
        color: const Color.fromARGB(255, 228, 235, 182), // Warna putih
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Navigasi ke halaman utama (misalnya, MainMenuView)
                Get.offAll(MainMenuView());
              },
              color: const Color(0xFF06487E), // Warna biru tua
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Navigasi ke halaman utama (misalnya, MainMenuView)
                Get.offAll(MenuBaruView());
              },
              color: const Color(0xFF06487E), // Warna biru tua
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlideShow extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const SlideShow({required this.data, Key? key}) : super(key: key);

  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<SlideShow> {
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.page!.round() < widget.data.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        return _buildCardContent(widget.data[index]);
      },
    );
  }

  Widget _buildCardContent(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.white, // Warna putih
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildConnectingLine(
                      item['KPI'], item['Deviasi'], context),
                ),
                const SizedBox(height: 10), // Sesuaikan kebutuhan Anda
                SizedBox(
                  height: 150, // Atur tinggi grafik sesuai kebutuhan
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: _buildPieChart(item['Deviasi'], constraints),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(double deviasi, BoxConstraints constraints) {
    double maxMeasure = 100;
    double measurePercentage = (deviasi / maxMeasure) * 100;
    double gaugeSize = 150; // Adjust gauge size as needed

    return GestureDetector(
      onTap: () {
        _showDeviasiDialog(measurePercentage, context);
      },
      child: Align(
        alignment: Alignment.topCenter, // Align chart to the top
        child: SizedBox(
          width: gaugeSize,
          height: gaugeSize,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: 50,
                    color: Colors.red,
                  ),
                  GaugeRange(
                    startValue: 50,
                    endValue: 75,
                    color: Colors.yellow,
                  ),
                  GaugeRange(
                    startValue: 75,
                    endValue: 90,
                    color: Colors.lightGreen,
                  ),
                  GaugeRange(
                    startValue: 90,
                    endValue: 100,
                    color: Colors.green,
                  ),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: deviasi,
                    enableAnimation: true,
                    animationType: AnimationType.ease,
                    needleStartWidth: 1,
                    needleEndWidth: 5,
                    needleLength: 0.8,
                    needleColor: Colors.black,
                    knobStyle: const KnobStyle(knobRadius: 0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeviasiDialog(double deviasi, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return AlertDialog(
              title: const Text('Deviasi'),
              content: Text(
                'Nilai Realisasi: ${deviasi.toStringAsFixed(2)}%',
                textAlign: TextAlign.center, // Posisikan teks ke tengah
                style: const TextStyle(
                  color: Color(0xFF06487E), // Warna teks biru
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xFF06487E), // Warna latar belakang tombol biru
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white, // Warna teks putih
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildConnectingLine(
      String kpi, double deviasi, BuildContext context) {
    return Center(
      child: Text(
        '$kpi\nDeviasi: ${deviasi.toStringAsFixed(2)}%',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF06487E), // Warna biru tua
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> loadData() async {
  try {
    var userDataProvider = UserDataProvider();
    var userDataResponse = await userDataProvider.fetchUserData();

    print('UserDataResponse: ${userDataResponse.body}');

    if (userDataResponse.body == null) {
      throw Exception("Respons data pengguna kosong");
    }

    var userDataBody = userDataResponse.body;
    if (userDataBody['success'] == true) {
      var userData = userDataBody['db_user'][0];
      var cabang = userData['Wilayah'];

      if (cabang == null) {
        throw Exception("Data 'Cabang' tidak ditemukan dalam respons");
      }

      var apiProvider = ApiProvider();
      var apiResponse = await apiProvider.fetchData();
      List<dynamic> dataList = apiResponse.body['db_kpi_renbis_real_dd'];
      List<Map<String, dynamic>> kpiDeviasiList = [];

      // Menyaring data untuk hanya mengambil data dengan Cabang yang sama dengan nilai Cabang dari data pengguna
      dataList.forEach((item) {
        if (item['Cabang'] == cabang) {
          kpiDeviasiList.add({
            'KPI': item['KPI'],
            'Cabang': item['Cabang'],
            'Deviasi': double.parse(item['Deviasi']),
          });
        }
      });

      // Urutkan data berdasarkan nilai deviasi secara menurun
      kpiDeviasiList.sort((a, b) => b['Deviasi'].compareTo(a['Deviasi']));

      return kpiDeviasiList;
    } else {
      throw Exception(
          "Respons data pengguna tidak memiliki struktur yang diharapkan");
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

void main() {
  runApp(GetMaterialApp(
    home: MainMenuView(),
  ));
}

// class DashboardView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//       ),
//       body: Center(
//         child: const Text('Dashboard Page'),
//       ),
//     );
//   }
// }

// class ReportsView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reports'),
//       ),
//       body: Center(
//         child: const Text('Reports Page'),
//       ),
//     );
//   }
// }

// class SettingsView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: Center(
//         child: const Text('Settings Page'),
//       ),
//     );
//   }
// }

// class ProfileView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//       ),
//       body: Center(
//         child: const Text('Profile Page'),
//       ),
//     );
//   }
// }
