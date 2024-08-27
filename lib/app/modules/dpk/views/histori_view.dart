import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import the chart package

import '../../../data/login_provider.dart';
import '../controllers/dpk_controller.dart';

class HistoriView extends GetView<DpkController> {
  const HistoriView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = Get.arguments ?? {};
    String? selectedKPI = args['selectedKPI'];

    return Scaffold(
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
                  Color(0xFF4682B4), // Blue
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: histori(selectedKPI),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Map<String, dynamic>> data = snapshot.data ?? [];

                    List<ChartData> chartData = [];
                    String cabang = '';

                    if (data.isNotEmpty) {
                      cabang = data.first['Wilayah'];
                    }

                    data.forEach((item) {
                      chartData.add(ChartData(
                        abbreviateCabang(item['Periode']),
                        item['Value'],
                        formatValue(selectedKPI ?? '', item['Value']),
                      ));
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (chartData.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF06487E).withOpacity(0.2),
                                  spreadRadius: 3,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'GRAFIK ${selectedKPI ?? ''}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF06487E),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 350, // Adjust height as needed
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: chartData.length *
                                          20.0, // Width based on number of data points
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(
                                          labelStyle: const TextStyle(
                                            fontSize: 8,
                                            color: Color(0xFF06487E),
                                          ),
                                        ),
                                        primaryYAxis: NumericAxis(
                                          numberFormat: NumberFormat.compact(),
                                          labelStyle: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF06487E),
                                          ),
                                          isVisible:
                                              true, // Ensure y-axis is visible
                                          anchorRangeToVisiblePoints:
                                              true, // Keep Y-axis labels in place
                                        ),
                                        series: <ChartSeries>[
                                          LineSeries<ChartData, String>(
                                            dataSource: chartData,
                                            xValueMapper: (ChartData data, _) =>
                                                data.cabang,
                                            yValueMapper: (ChartData data, _) =>
                                                data.value,
                                            color: const Color(
                                                0xFF4682B4), // Line color
                                            width: 2.0, // Line width
                                            // ignore: prefer_const_constructors
                                            markerSettings: MarkerSettings(
                                              isVisible: true,
                                              color: const Color(0xFF4682B4),
                                              borderColor: Colors.white,
                                              borderWidth: 2,
                                            ),
                                            dataLabelSettings:
                                                DataLabelSettings(
                                              isVisible: true,
                                              textStyle: const TextStyle(
                                                color: Color(0xFF06487E),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              builder: (context, point, series,
                                                  pointIndex, seriesIndex) {
                                                return Text(
                                                  chartData[pointIndex]
                                                      .formattedLabel,
                                                  style: const TextStyle(
                                                    color: Color(0xFF06487E),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              },
                                            ),
                                            animationDuration: 1500,
                                          ),
                                        ],
                                        tooltipBehavior: TooltipBehavior(
                                          enable: true,
                                          tooltipPosition:
                                              TooltipPosition.pointer,
                                          color: Colors.blueGrey,
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (data.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        width: 1.0, color: Colors.black),
                                  ),
                                ),
                                child: Text(
                                  'RINCIAN DATA TABEL ' +
                                      (data[0]['KPI'] ?? ''),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF06487E),
                                  ),
                                ),
                              ),
                              _buildDataTable(data, cabang),
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
    );
  }

  // Fungsi untuk memformat tanggal menjadi dd-MM-yyyy
  String formatDateForTable(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data, String cabang) {
    List<Map<String, dynamic>> prioritizedData = [];
    List<Map<String, dynamic>> otherData = [];

    // Separate data into prioritized and other data
    for (var item in data) {
      if (item['Cabang'] == cabang) {
        prioritizedData.add(item);
      } else {
        otherData.add(item);
      }
    }

    // Combine prioritized data at the top with other data
    List<Map<String, dynamic>> finalData = prioritizedData + otherData;

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
          headingRowHeight: 60, // Tinggi baris heading tabel
          columns: [
            DataColumn(
              label: SizedBox(
                width: 100, // Menetapkan lebar kolom
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Cabang',
                      style: GoogleFonts.roboto(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100, // Menetapkan lebar kolom
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Jumlah',
                      style: GoogleFonts.roboto(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          rows: finalData.map<DataRow>((item) {
            return DataRow(
              cells: [
                DataCell(
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        formatDateForTable(item['Periode'] ?? ''),
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        formatValue(item['KPI'] ?? '', item['Value']),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                        ),
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

class ChartData {
  ChartData(this.cabang, this.value, this.formattedLabel);
  final String cabang;
  final dynamic value;
  final String formattedLabel;
}

Future<List<Map<String, dynamic>>> histori(String? selectedKPI) async {
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
      var cabang = userData['Cabang'];

      var histori = HistoriDpk();
      var response = await histori.dataHistoridpk(cabang, selectedKPI!);
      List<dynamic> dataList = response.body['db_kpi_real_mm'];
      List<Map<String, dynamic>> filteredDataList = [];

      dataList.forEach((item) {
        // Filter data untuk cabang tertentu
        if (item['KPI'] == selectedKPI && item['Cabang'] == cabang) {
          filteredDataList.add({
            'Level': item['Level'],
            'KodeWilayah': item['KodeWilayah'],
            'Wilayah': item['Wilayah'],
            'KodeCabang': item['KodeCabang'],
            'Cabang': item['Cabang'],
            'KPI': item['KPI'],
            'Value': double.parse(item['Value']),
            'Periode': item['Periode'],
          });
        }
      });

      filteredDataList.sort((a, b) => b['Periode'].compareTo(a['Periode']));

      return filteredDataList;
    }
  } catch (e) {
    print('Error: $e');
  }

  return [];
}

String simplifyValue(double value, String selectedKPI) {
  bool isNegative = value < 0;
  double absValue = value.abs();

  if (selectedKPI == 'NIM' ||
      selectedKPI == 'LFR/RIM' ||
      selectedKPI == 'ROE' ||
      selectedKPI == 'ROA' ||
      selectedKPI == 'BOPO' ||
      selectedKPI == 'CAR') {
    // Untuk KPI tertentu, simpan dua angka desimal
    return "${isNegative ? '-' : ''}${absValue.toStringAsFixed(2)}";
  } else {
    // Lainnya tetap seperti biasa
    if (absValue >= 1000000000000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000000000000).floor()} T";
    } else if (absValue >= 1000000000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000000000).floor()} M";
    } else if (absValue >= 1000000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000000).floor()} JT";
    } else if (absValue >= 1000) {
      return "${isNegative ? '-' : ''}${(absValue / 1000).floor()} Rb";
    } else {
      return "${isNegative ? '-' : ''}${absValue.floor()}";
    }
  }
}

String formatValue(String selectedKPI, double value) {
  String formattedValue = simplifyValue(value, selectedKPI);
  if (selectedKPI == 'NIM' ||
      selectedKPI == 'LFR/RIM' ||
      selectedKPI == 'ROE' ||
      selectedKPI == 'ROA' ||
      selectedKPI == 'BOPO' ||
      selectedKPI == 'CAR') {
    formattedValue += '%';
  }
  return formattedValue;
}

// Fungsi untuk memformat tanggal menjadi dd-MM-yy
String formatDateForChart(String date) {
  try {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yy').format(parsedDate);
  } catch (e) {
    return date; // Return original if parsing fails
  }
}

// Perbarui fungsi abbreviateCabang
String abbreviateCabang(String cabang) {
  if (cabang.length <= 14) {
    return formatDateForChart(cabang);
  }
  // For simplicity, let's truncate the string if it's longer than 14 characters
  return formatDateForChart(cabang.substring(0, 14));
}

void main() {
  runApp(const GetMaterialApp(
    home: HistoriView(),
  ));
}
