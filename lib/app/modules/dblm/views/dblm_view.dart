import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sp_util/sp_util.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../data/login_provider.dart';
import '../../menu_baru/views/appbar.dart';
import '../controllers/dblm_controller.dart';

class DblmView extends GetView<DblmController> {
  const DblmView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomAppBarWithMenu appBar = CustomAppBarWithMenu();

    void _showMenuAdd(BuildContext context) async {
      final value = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
          0,
          0,
        ),
        items: [
          const PopupMenuItem(
            value: 'add',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Tambah'),
            ),
          ),
        ],
      );

      if (value == 'add') {
        print('Menu Tambah dipilih');
      }
    }

    String? jwtToken = SpUtil.getString("JWT");
    Map<String, dynamic> args = Get.arguments ?? {};
    String? selectedKPI = args['selectedKPI'];

    return Scaffold(
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
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: loadDatadblm(selectedKPI),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Map<String, dynamic>> data = snapshot.data ?? [];

                      List<Map<String, dynamic>> consolidatedData = [];
                      List<Map<String, dynamic>> otherBranchesData = [];

                      data.forEach((item) {
                        if (item['Cabang'] == 'KONSOLIDASI' ||
                            item['Cabang'] == 'KONSOLIDASI KONVEN' ||
                            item['Cabang'] == 'KONSOLIDASI SYARIAH') {
                          consolidatedData.add(item);
                        } else {
                          otherBranchesData.add(item);
                        }
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 280,
                            child: SlideShow(
                                data: consolidatedData.isNotEmpty
                                    ? consolidatedData
                                    : otherBranchesData),
                          ),
                          if (consolidatedData.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          width: 1.0, color: Colors.black),
                                    ),
                                  ),
                                  child: Text(
                                    'KONSOLIDASI ' +
                                        (consolidatedData[0]['KPI'] ?? ''),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF06487E),
                                    ),
                                  ),
                                ),
                                _buildDataTable(consolidatedData),
                              ],
                            ),
                          if (otherBranchesData.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          width: 1.0, color: Colors.black),
                                    ),
                                  ),
                                  child: Text(
                                    'DATA TABEL RENBIS ' +
                                        (otherBranchesData[0]['KPI'] ?? ''),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF06487E),
                                    ),
                                  ),
                                ),
                                _buildDataTable(otherBranchesData),
                              ],
                            ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: SpeedDial(
      //   icon: Icons.add,
      //   backgroundColor: const Color.fromARGB(255, 6, 72, 126),
      //   foregroundColor: Colors.white,
      //   children: [
      //     SpeedDialChild(
      //       child: const Icon(Icons.home),
      //       backgroundColor: Colors.blue,
      //       label: 'Home',
      //       labelBackgroundColor: const Color(0xFF40A2E3),
      //       onTap: () {
      //         Get.offAllNamed(Routes.MENU_BARU);
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: const Icon(Icons.logout),
      //       backgroundColor: Colors.red,
      //       label: 'Logout',
      //       labelBackgroundColor: const Color(0xFF40A2E3),
      //       onTap: () {
      //         // Menghapus token JWT
      //         SpUtil.remove("JWT");
      //         Get.offAllNamed(Routes.LOGIN);
      //       },
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 6, 72, 126),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DataTable(
          dataRowColor: MaterialStateColor.resolveWith(
            (states) => const Color.fromARGB(255, 255, 255, 255),
          ),
          dataRowHeight: 60, // Tinggi baris tabel
          columnSpacing: 20, // Spasi antar kolom
          columns: [
            DataColumn(
              label: Text(
                'Cabang',
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Ukuran font di sini disesuaikan
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Renbis',
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Ukuran font di sini disesuaikan
                ),
              ),
              numeric: true, // Kolom ini akan memiliki alignment kanan
            ),
            DataColumn(
              label: Text(
                'Realisasi',
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Ukuran font di sini disesuaikan
                ),
              ),
              numeric: true, // Kolom ini akan memiliki alignment kanan
            ),
            DataColumn(
              label: Text(
                'Deviasi',
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Ukuran font di sini disesuaikan
                ),
              ),
              numeric: true, // Kolom ini akan memiliki alignment kanan
            ),
          ],
          rows: data.map((data) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    data['Cabang'],
                    textAlign: TextAlign.start, // Cabang berada di sebelah kiri
                    style: GoogleFonts.roboto(
                      fontSize: 11, // Ukuran font di sini disesuaikan
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      formatValue(data['KPI'], double.parse(data['Renbis'])),
                      textAlign: TextAlign.center, // Renbis berada di tengah
                      style: GoogleFonts.roboto(
                        fontSize: 11, // Ukuran font di sini disesuaikan
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      formatValue(data['KPI'], double.parse(data['Realisasi'])),
                      textAlign: TextAlign.center, // Realisasi berada di tengah
                      style: GoogleFonts.roboto(
                        fontSize: 11, // Ukuran font di sini disesuaikan
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      '${data['Deviasi'].toStringAsFixed(0)}%',
                      textAlign: TextAlign.center, // Deviasi berada di tengah
                      style: GoogleFonts.roboto(
                        fontSize: 11, // Ukuran font di sini disesuaikan
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
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
        width: 270, // Lebar kontainer grafik
        height: 250, // Tinggi kontainer grafik
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
          color: Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 180, // Tinggi grafik
                  width: 260, // Lebar grafik
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: _buildPieChart(item['Deviasi'], constraints),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  item['KPI'],
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06487E),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Deviasi: ${item['Deviasi'].toStringAsFixed(0)}%',
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    color: const Color(0xFF06487E),
                  ),
                  textAlign: TextAlign.center,
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
    double gaugeSize = 150;

    return GestureDetector(
      onTap: () {
        _showDeviasiDialog(measurePercentage, context);
      },
      child: Align(
        alignment: Alignment.topCenter,
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
        return AlertDialog(
          title: Text('Deviasi', style: GoogleFonts.roboto()),
          content: Text(
            'Nilai Realisasi: ${deviasi.toStringAsFixed(2)}%',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: const Color(0xFF06487E),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06487E),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConnectingLine(
      String kpi, double deviasi, BuildContext context) {
    return Center(
      child: Text(
        '$kpi\nDeviasi: ${deviasi.toStringAsFixed(2)}%',
        style: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF06487E),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> loadDatadblm(String? selectedKPI) async {
  try {
    var userDataProvider = UserDataProvider();
    var userDataResponse = await userDataProvider.fetchUserData();

    if (userDataResponse.body == null) {
      throw Exception("Respons data pengguna kosong");
    }

    print('UserDataResponse: ${userDataResponse.body}');
    var userDataBody = userDataResponse.body;

    if (userDataBody['success'] == true) {
      var userData = userDataBody['db_user'][0];
      var cabang = userData['Wilayah'];

      var apiProvider1 = ApiProvider1();
      var response = await apiProvider1.fetchData1();
      List<dynamic> dataList = response.body['db_kpi_dblm_renbis_real_dd'];
      List<Map<String, dynamic>> filteredDataList = [];

      dataList.forEach((item) {
        if (cabang == 'KONSOLIDASI') {
          if (item['KPI'] == selectedKPI) {
            filteredDataList.add({
              'Cabang': item['Cabang'],
              'KPI': item['KPI'],
              'Renbis': item['Renbis'],
              'Realisasi': item['Realisasi'],
              'Deviasi': double.parse(item['Deviasi']),
            });
          }
        } else {
          if (item['KPI'] == selectedKPI && item['Cabang'] == cabang) {
            filteredDataList.add({
              'Cabang': item['Cabang'],
              'KPI': item['KPI'],
              'Renbis': item['Renbis'],
              'Realisasi': item['Realisasi'],
              'Deviasi': double.parse(item['Deviasi']),
            });
          }
        }
      });

      filteredDataList.sort((a, b) => b['Deviasi'].compareTo(a['Deviasi']));

      return filteredDataList;
    }
  } catch (e) {
    print('Error: $e');
  }

  return [];
}

// String formatValue(String selectedKPI, double value) {
//   String formattedValue = simplifyValue(value);
//   if (selectedKPI == 'BOPO' ||
//       selectedKPI == 'NPL NETT' ||
//       selectedKPI == 'NPL GROSS') {
//     formattedValue += '%';
//   }
//   return formattedValue;
// }

String simplifyValue(double value, String selectedKPI) {
  bool isNegative = value < 0;
  double absValue = value.abs();

  if (selectedKPI == 'BOPO' ||
      selectedKPI == 'NPL NETT' ||
      selectedKPI == 'NPL GROSS') {
    // Untuk KPI tertentu, simpan dua angka desimal
    return "${isNegative ? '-' : ''}${absValue.toStringAsFixed(2)}";
  } else {
    // Lainnya tetap seperti biasa
    if (absValue >= 1000000000000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000000000000).toStringAsFixed(0)} T";
    } else if (absValue >= 1000000000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000000000).toStringAsFixed(0)} M";
    } else if (absValue >= 1000000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000000).toStringAsFixed(0)} JT";
    } else if (absValue >= 1000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000).toStringAsFixed(0)} Rb";
    } else {
      return "${isNegative ? '-' : ''}${absValue.toStringAsFixed(0)}";
    }
  }
}


String formatValue(String selectedKPI, double value) {
  String formattedValue = simplifyValue(value, selectedKPI);
  if (selectedKPI == 'BOPO' ||
      selectedKPI == 'NPL NETT' ||
      selectedKPI == 'NPL GROSS') {
    formattedValue += '%';
  }
  return formattedValue;
}

void main() {
  runApp(const GetMaterialApp(
    home: DblmView(),
  ));
}
