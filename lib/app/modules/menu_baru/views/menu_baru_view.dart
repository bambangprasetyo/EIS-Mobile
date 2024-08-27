import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tab_container/tab_container.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/login_provider.dart';
import '../../Getdata/views/getdata_view.dart';
import '../../dblm/views/dblm_view.dart';
import '../../keuangan/views/khome.dart';
import '../controllers/menu_baru_controller.dart';
import 'appbar.dart';

class MenuBaruView extends GetView<MenuBaruController> {
  const MenuBaruView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWithMenu(),
      body: FutureBuilder<Response>(
        future: UserDataProvider().fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var userData = snapshot.data?.body['db_user'] ?? [];
            String cabang = userData.isNotEmpty ? userData[0]['Cabang'] : '';
            String wilayah = userData.isNotEmpty ? userData[0]['Wilayah'] : '';

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD3D3D3),
                    Color(0xFF4682B4),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChartCard(cabang),
                    _buildTabContainer(context, wilayah),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.offAll(const MenuBaruView());
        },
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTabContainer(BuildContext context, String wilayah) {
    return FutureBuilder<Map<String, dynamic>>(
      future: logaktivitas(wilayah),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return _buildTabs(context, snapshot.data!, wilayah);
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildTabs(BuildContext context, Map<String, dynamic> aktivitasData,
      String wilayah) {
    var aktivitasStatusCode = aktivitasData['statusCode'];

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var loadDataList = snapshot.data!;
          bool hidePencairan = aktivitasStatusCode == 401;
          bool hideRenbis = loadDataList.isEmpty;

          List<Tab> tabs = [
            if (!hideRenbis)
              const Tab(icon: Icon(Icons.business), text: 'RENBIS'),
            if (!hidePencairan)
              const Tab(icon: Icon(Icons.money), text: 'PENCAIRAN'),
            const Tab(icon: Icon(Icons.insert_chart), text: 'DBLM'),
            const Tab(icon: Icon(Icons.account_balance), text: 'KEUANGAN'),
            const Tab(icon: Icon(Icons.pie_chart), text: 'DPK'),
            const Tab(icon: Icon(Icons.file_download), text: 'FILE'),
          ];

          List<Color> colors =
              List<Color>.filled(tabs.length, const Color(0xFFADD8E6));

          return TabContainer(
            tabEdge: TabEdge.top,
            tabsStart: 0.1,
            tabsEnd: 0.9,
            tabMaxLength: 100,
            tabMinLength: 1,
            borderRadius: BorderRadius.circular(10),
            tabBorderRadius: BorderRadius.circular(10),
            childPadding: const EdgeInsets.all(20.0),
            selectedTextStyle: const TextStyle(
              color: Color.fromARGB(255, 6, 72, 126),
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
            ),
            unselectedTextStyle: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
            ),
            colors: colors,
            tabs: tabs,
            children: [
              if (!hideRenbis)
                SingleChildScrollView(child: _buildMenuCard(context)),
              if (!hidePencairan) _buildMainContent(wilayah),
              SingleChildScrollView(
                  child: _buildMenuCardDblm(context, wilayah)),
              SingleChildScrollView(
                  child: _buildMenuCardKeuangan(context, wilayah)),
              SingleChildScrollView(child: _buildMenuCardDpk(context, wilayah)),
              SizedBox(
                height: 400, // Fixed height for vertical scrolling
                child: FileDataTableWidget(),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  String formatRupiah(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount.abs());
  }

  Widget _buildTotalInfo(String wilayah, {double fontSize = 14.0}) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchTotalData(wilayah),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          Map<String, dynamic> result = snapshot.data ??
              {
                'total_count': 0,
                'total_org_amount': 0.0,
              };

          int totalCount = result['total_count'];
          double totalOrgAmount = result['total_org_amount'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pencairan: ${formatRupiah(totalOrgAmount)}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                    height:
                        8), // Spacing between total org amount text and line
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double
                            .infinity, // Ensure the line is as wide as possible
                        height: 20, // Set the desired height for the line
                        child: LinearProgressIndicator(
                          value: 0.5, // Adjust this value as needed
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 16), // Spacing between line and totalCount text
                    Column(
                      children: [
                        Text(
                          'Total: $totalCount',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildFileDataTable() {
    final downloadFile apiService = downloadFile();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: apiService.fetchdownloadFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> data = snapshot.data!;

          return Container(
            height: 400, // Set a fixed height for the vertical scrollable area
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 40, // Adjust this value as needed
                  columns: const [
                    DataColumn(label: Text('File Type')),
                    DataColumn(label: Text('File Periode')),
                    DataColumn(label: Text('Download')),
                  ],
                  rows: data.map((item) {
                    final fileNameData = item['file_name'];
                    String fileName;
                    String url = 'https://eis.bankaltimtara.co.id/data_neraca/';

                    if (fileNameData is Map<String, dynamic>) {
                      // If file_name is a map, extract the name
                      fileName = fileNameData['name'] ?? '';
                    } else if (fileNameData is String) {
                      // If file_name is a string, use it directly
                      fileName = fileNameData;
                    } else {
                      // Handle the case where file_name is null or unrecognized type
                      fileName = 'Unknown';
                    }

                    // Construct the full URL
                    String downloadUrl = url + fileName;

                    return DataRow(cells: [
                      DataCell(
                          Text(item['file_type'] ?? '')), // File type column
                      DataCell(Text(item['file_period'] ?? '')),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            if (await canLaunch(downloadUrl)) {
                              await launch(downloadUrl);
                            } else {
                              throw 'Could not launch $downloadUrl';
                            }
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildMainContent(String wilayah, {double fontSize = 14.0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalInfo(wilayah, fontSize: fontSize),
        // Wrap _buildAccordionTable with a SizedBox with defined height and SingleChildScrollView
        SizedBox(
          height: 300, // Adjust the height as needed
          child: SingleChildScrollView(
            child: _buildAccordionTable(wilayah, fontSize: fontSize),
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionTable(String wilayah, {double fontSize = 14.0}) {
    return FutureBuilder<Map<String, dynamic>>(
      future: logaktivitas(wilayah),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var dataMap = snapshot.data!;
          List<Map<String, dynamic>> data = dataMap['data'] ?? [];

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              double orgAmount = double.parse(item['Org Amount']);
              String formattedOrgAmount = formatRupiah(orgAmount);
              bool isSyariah = item['Cabang'].toLowerCase().contains('syariah');

              return Container(
                color: isSyariah
                    ? const Color.fromARGB(219, 0, 245, 163)
                    : Colors.transparent,
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['Entry Date & Time'],
                        style: const TextStyle(fontSize: 8),
                      ),
                      Text(
                        item['Keterangan'],
                        style: const TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedOrgAmount,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item['Cabang'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan Type: ${item['Loan Type']}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Wilayah: ${item['Wilayah']}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  // Widget _buildFloatingActionButton(BuildContext context) {
  //   return SpeedDial(
  //     icon: Icons.add,
  //     backgroundColor: const Color.fromARGB(255, 6, 72, 126),
  //     foregroundColor: Colors.white,
  //     children: [
  //       SpeedDialChild(
  //         child: const Icon(Icons.home),
  //         backgroundColor: Colors.blue,
  //         label: 'Home',
  //         labelBackgroundColor: const Color(0xFF40A2E3),
  //         onTap: () {
  //           Get.to(() => const MenuBaruView()); // Navigate to Home
  //         },
  //       ),
  //       SpeedDialChild(
  //         child: const Icon(Icons.logout),
  //         backgroundColor: Colors.red,
  //         label: 'Logout',
  //         labelBackgroundColor: const Color(0xFF40A2E3),
  //         onTap: () {
  //           controller.logout(); // Call the logout function from the controller
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildChartCard(String cabang) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadDataFromDataHst(cabang),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<SalesData> salesDataList = [];
          if (snapshot.hasData) {
            List<Map<String, dynamic>> data = snapshot.data ?? [];
            salesDataList = data.map((e) {
              double salesValue = e['Value'] ?? 0.0;
              String simplifiedValue1 = simplifyValue1(salesValue);

              // Mengonversi nilai yang telah disederhanakan kembali ke angka
              double simplifiedSalesValue = double.parse(
                  simplifiedValue1.replaceAll(RegExp(r'[^0-9]'), ''));

              String originalDate = e['Periode']; // Format: yyyy-mm-dd
              String year = originalDate.substring(0, 4);
              String month = originalDate.substring(5, 7);
              String day = originalDate.substring(8, 10);

              String formattedDate = '$day-$month'; // Format: dd-mm

              return SalesData(
                  formattedDate, simplifiedSalesValue, simplifiedValue1, 0.0);
            }).toList();

            // Urutkan data berdasarkan periode
            salesDataList.sort((a, b) => a.year.compareTo(b.year));
          }

          return Card(
            elevation: 8,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: const Color.fromARGB(255, 6, 72, 126),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "LABA/RUGI HARIAN",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      height: 250,
                      padding: const EdgeInsets.only(top: 20),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.1,
                        maxScale: 5,
                        child: SfCartesianChart(
                          zoomPanBehavior: ZoomPanBehavior(
                            enablePanning: true,
                            enablePinching: true,
                          ),
                          primaryXAxis: CategoryAxis(
                            majorGridLines: const MajorGridLines(
                              width: 0,
                            ),
                            labelStyle: const TextStyle(
                              color: Color(0xFF40A2E3),
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            numberFormat: NumberFormat.compact(
                              locale: 'id',
                            ),
                            labelStyle: const TextStyle(
                              color: Color(0xFF40A2E3),
                            ),
                          ),
                          series: <ChartSeries>[
                            ColumnSeries<SalesData, String>(
                              dataSource: salesDataList,
                              xValueMapper: (SalesData sales, _) => sales.year,
                              yValueMapper: (SalesData sales, _) => sales.sales,
                              color: const Color.fromARGB(255, 6, 72, 126),
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(
                                  color: Color(0xFF40A2E3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              dataLabelMapper: (SalesData sales, _) =>
                                  sales.simplifiedValue1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () {
                          _showFullScreenChart(context, salesDataList);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _showFullScreenChart(BuildContext context, List<SalesData> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color.fromARGB(255, 251, 253, 253),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "LABA/RUGI Harian",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF40A2E3),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                child: SfCartesianChart(
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                    enablePinching: true,
                  ),
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(
                      width: 0,
                    ),
                    labelStyle: const TextStyle(
                      color: Color(0xFF40A2E3),
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compact(locale: 'id'),
                    labelStyle: const TextStyle(
                      color: Color(0xFF40A2E3),
                    ),
                  ),
                  series: <ChartSeries>[
                    ColumnSeries<SalesData, String>(
                      dataSource: data,
                      xValueMapper: (SalesData sales, _) => sales.year,
                      yValueMapper: (SalesData sales, _) => sales.sales,
                      color: const Color.fromARGB(255, 6, 72, 126),
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: Color(0xFF40A2E3),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      dataLabelMapper: (SalesData sales, _) =>
                          sales.simplifiedValue1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menentukan jumlah kolom berdasarkan orientasi layar
  int _crossAxisCount(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      return 8; // Jumlah kolom saat orientasi landscape
    } else {
      return 3; // Jumlah kolom saat orientasi portrait
    }
  }

  Widget _buildMenuCard(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> data = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics:
                    const ClampingScrollPhysics(), // Ini memungkinkan GridView untuk di-scroll
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount(
                      context), // Menggunakan fungsi untuk menentukan jumlah kolom
                  mainAxisSpacing: 2.0, // Spacing between rows
                  crossAxisSpacing: 2.0, // Spacing between columns
                  childAspectRatio: 1.0, // Aspect ratio of each item
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  bool isPercentage = item['KPI'] == 'BOPO' ||
                      item['KPI'] == 'NPL GROSS' ||
                      item['KPI'] == 'NPL NETT';
                  return _buildMenuItem(
                    title: item['KPI'],
                    subtitle: item['Cabang'],
                    deviation: item['Deviasi'] ?? 0,
                    renbis: item['Renbis'],
                    realisasi: item['Realisasi'],
                    isPercentage: isPercentage,
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required double deviation,
    required String renbis,
    required String realisasi,
    required bool isPercentage,
  }) {
    // Fungsi untuk mengubah judul sesuai dengan permintaan
    String modifiedTitle(String originalTitle) {
      if (originalTitle == 'KREDIT YANG DIBERIKAN') {
        return 'KREDIT';
      } else if (originalTitle == 'LABA/RUGI SEBELUM PAJAK') {
        return 'LABA/RUGI';
      } else if (originalTitle == 'PENERIMAAN EXTRACOM') {
        return 'EXTRACOM';
      } else {
        return originalTitle;
      }
    }

    final bool isAbove100Percent = deviation > 100;

    return GestureDetector(
      onTap: () {
        String selectedKPI = title;
        Get.to(() => const GetdataView(),
            arguments: {'selectedKPI': selectedKPI});
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fontSize =
              constraints.maxWidth * 0.1; // Contoh penyesuaian ukuran teks
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: isAbove100Percent
                ? const Color.fromARGB(219, 0, 245, 163)
                : const Color.fromARGB(255, 211, 118, 118),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    modifiedTitle(
                        title), // Menggunakan judul yang telah dimodifikasi
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white, // Agar teks dapat dibaca dengan baik di latar belakang berwarna
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${deviation.toInt()}%', // Menggunakan toInt() untuk mengubahnya menjadi bilangan bulat
                    style: TextStyle(
                      fontSize: fontSize * 1.9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rencana: ${isPercentage ? '$renbis%' : simplifyValue(double.parse(renbis))}',
                    style: TextStyle(
                        fontSize: fontSize * 0.7, color: Colors.white),
                  ),
                  Text(
                    'Realisasi: ${isPercentage ? '$realisasi%' : simplifyValue(double.parse(realisasi))}',
                    style: TextStyle(
                        fontSize: fontSize * 0.7, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCardDblm(BuildContext context, String wilayah) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadDatadblm(wilayah),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> data = snapshot.data!['data'] ?? [];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount(
                    context), // Menggunakan fungsi untuk menentukan jumlah kolom
                mainAxisSpacing: 2.0, // Spacing antara baris
                crossAxisSpacing: 2.0, // Spacing antara kolom
                childAspectRatio: 1.0, // Aspect ratio setiap item
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                bool isPercentage = item['KPI'] == 'BOPO' ||
                    item['KPI'] == 'NPL GROSS' ||
                    item['KPI'] == 'NPL NETT';
                return _buildMenuItem1(
                  title: item['KPI'],
                  subtitle: item['Cabang'],
                  deviation: item['Deviasi'] ?? 0,
                  renbis: item['Renbis'],
                  realisasi: item['Realisasi'],
                  isPercentage: isPercentage,
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildMenuItem1({
    required String title,
    required String subtitle,
    required double deviation,
    required String renbis,
    required String realisasi,
    required bool isPercentage,
  }) {
    // Fungsi untuk mengubah judul sesuai dengan permintaan
    String modifiedTitle1(String originalTitle) {
      if (originalTitle == 'KREDIT YANG DIBERIKAN') {
        return 'KREDIT';
      } else if (originalTitle == 'LABA/RUGI SEBELUM PAJAK') {
        return 'LABA/RUGI';
      } else if (originalTitle == 'PENERIMAAN EXTRACOM') {
        return 'EXTRACOM';
      } else {
        return originalTitle;
      }
    }

    final bool isAbove100Percent = deviation > 100;

    return GestureDetector(
      onTap: () {
        String selectedKPI = title;
        Get.to(() => const DblmView(), arguments: {'selectedKPI': selectedKPI});
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fontSize =
              constraints.maxWidth * 0.1; // Contoh penyesuaian ukuran teks
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: isAbove100Percent
                ? const Color.fromARGB(219, 0, 245, 163)
                : const Color.fromARGB(255, 211, 118, 118),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    modifiedTitle1(
                        title), // Menggunakan judul yang telah dimodifikasi
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white, // Agar teks dapat dibaca dengan baik di latar belakang berwarna
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${deviation.toInt()}%', // Menggunakan toInt() untuk mengubahnya menjadi bilangan bulat
                    style: TextStyle(
                      fontSize: fontSize * 1.9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rencana: ${isPercentage ? '$renbis%' : simplifyValue(double.parse(renbis))}',
                    style: TextStyle(
                        fontSize: fontSize * 0.7, color: Colors.white),
                  ),
                  Text(
                    'Realisasi: ${isPercentage ? '$realisasi%' : simplifyValue(double.parse(realisasi))}',
                    style: TextStyle(
                        fontSize: fontSize * 0.7, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCardKeuangan(BuildContext context, String wilayah) {
    return FutureBuilder<Map<String, dynamic>>(
      future: keuangan(wilayah),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> data = snapshot.data!['data'] ?? [];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount(
                    context), // Menggunakan fungsi untuk menentukan jumlah kolom
                mainAxisSpacing: 2.0, // Spacing antara baris
                crossAxisSpacing: 2.0, // Spacing antara kolom
                childAspectRatio: 1.0, // Aspect ratio setiap item
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                bool isPercentage = item['KPI'] == 'NIM' ||
                    item['KPI'] == 'LFR/RIM' ||
                    item['KPI'] == 'ROE' ||
                    item['KPI'] == 'ROA' ||
                    item['KPI'] == 'BOPO' ||
                    item['KPI'] == 'CAR';
                return _buildMenuItemK(
                  title: item['KPI'],
                  subtitle: item['Cabang'],
                  deviation: item['Value'],
                  periode: item['Periode'],
                  isPercentage: isPercentage,
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildMenuItemK({
    required String title,
    required String subtitle,
    required double deviation,
    required String periode,
    required bool isPercentage,
  }) {
    String modifiedTitle1(String originalTitle) {
      if (originalTitle == 'KREDIT YANG DIBERIKAN') {
        return 'KREDIT';
      } else if (originalTitle == 'LABA/RUGI SEBELUM PAJAK') {
        return 'LABA/RUGI';
      } else if (originalTitle == 'PENERIMAAN EXTRACOM') {
        return 'EXTRACOM';
      } else {
        return originalTitle;
      }
    }

    final bool isAbove100Percent = deviation > 100;
    final String formattedValue =
        isPercentage ? '${deviation.toInt()}%' : simplifyValue1(deviation);

    return GestureDetector(
      onTap: () {
        String selectedKPI = title;
        Get.to(() => const KhomeView(),
            arguments: {'selectedKPI': selectedKPI});
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fontSize = constraints.maxWidth * 0.1;
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: isAbove100Percent
                ? const Color.fromARGB(219, 0, 245, 163)
                : const Color.fromARGB(255, 211, 118, 118),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    modifiedTitle1(title),
                    style: TextStyle(
                      fontSize: fontSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedValue,
                    style: TextStyle(
                      fontSize: fontSize * 1.9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Periode: $periode',
                    style: TextStyle(
                        fontSize: fontSize * 0.7, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCardDpk(BuildContext context, String wilayah) {
    return FutureBuilder<Map<String, dynamic>>(
      future: dpk(wilayah),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> data = snapshot.data!['data'] ?? [];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount(
                    context), // Menggunakan fungsi untuk menentukan jumlah kolom
                mainAxisSpacing: 2.0, // Spacing antara baris
                crossAxisSpacing: 2.0, // Spacing antara kolom
                childAspectRatio: 1.0, // Aspect ratio setiap item
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                bool isPercentage = item['KPI'] == 'NIM' ||
                    item['KPI'] == 'LFR/RIM' ||
                    item['KPI'] == 'ROE' ||
                    item['KPI'] == 'ROA' ||
                    item['KPI'] == 'BOPO' ||
                    item['KPI'] == 'CAR';
                return _buildMenuItemD(
                  title: item['KPI'],
                  subtitle: item['Cabang'],
                  deviation: item['Value'],
                  periode: item['Periode'],
                  isPercentage: isPercentage,
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildMenuItemD({
    required String title,
    required String subtitle,
    required double deviation,
    required String periode,
    required bool isPercentage,
  }) {
    String modifiedTitle1(String originalTitle) {
      if (originalTitle == 'KREDIT YANG DIBERIKAN') {
        return 'KREDIT';
      } else if (originalTitle == 'LABA/RUGI SEBELUM PAJAK') {
        return 'LABA/RUGI';
      } else if (originalTitle == 'PENERIMAAN EXTRACOM') {
        return 'EXTRACOM';
      } else {
        return originalTitle;
      }
    }

    final bool isAbove100Percent = deviation > 100;
    final String formattedValue =
        isPercentage ? '${deviation.toInt()}%' : simplifyValue1(deviation);

    return GestureDetector(
      onTap: () {
        String selectedKPI = title;
        Get.to(() => const KhomeView(),
            arguments: {'selectedKPI': selectedKPI});
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fontSize = constraints.maxWidth * 0.1;
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: isAbove100Percent
                ? const Color.fromARGB(219, 0, 245, 163)
                : const Color.fromARGB(255, 211, 118, 118),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    modifiedTitle1(title),
                    style: TextStyle(
                      fontSize: fontSize * 0.6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedValue,
                    style: TextStyle(
                      fontSize: fontSize * 1.9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Periode: $periode',
                    style: TextStyle(
                        fontSize: fontSize * 0.7, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Fungsi untuk mengubah format tanggal dari YYYY-MM-DD menjadi DD-MM-YYYY
String formatTanggal(String tanggal) {
  DateTime dateTime = DateTime.parse(tanggal);
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

Future<Map<String, dynamic>> logaktivitas(String wilayah) async {
  try {
    var loanActivityProvider = LoanActivityProvider();
    var loanActivityResponse = await loanActivityProvider.fetchLoanActivity();

    print('LoanActivityResponse: ${loanActivityResponse.body}');

    if (loanActivityResponse.statusCode == 401) {
      return {'statusCode': 401};
    }

    if (loanActivityResponse.body == null) {
      throw Exception("Respons data aktivitas pinjaman kosong");
    }

    var loanActivityBody = loanActivityResponse.body;
    if (loanActivityBody['success'] == true) {
      List<dynamic> dataList = loanActivityBody['lhlon_dd_idx'];
      List<Map<String, dynamic>> loanDataList = [];

      if (wilayah == "KONSOLIDASI") {
        dataList.forEach((item) {
          String formattedDate = formatTanggal(item['Tanggal Entry']);
          String entryDateTime = '$formattedDate ${item['Jam Entry']}';

          loanDataList.add({
            'Cabang': item['Cabang'] ?? 'Cabang Kosong/Tidak Diisi',
            'Loan Type': item['Loan Type'] ?? 'Loan Type Kosong/Tidak Diisi',
            'Entry Date & Time': entryDateTime,
            'Org Amount': item['Org Amount'],
            'Wilayah': item['Wilayah'] ?? 'Wilayah Kosong/Tidak Diisi',
            'Keterangan': item['Keterangan'] ?? 'Keterangan Kosong/Tidak Diisi',
          });
        });
      } else {
        dataList.forEach((item) {
          if (item['Wilayah'] == wilayah) {
            String formattedDate = formatTanggal(item['Tanggal Entry']);
            String entryDateTime = '$formattedDate ${item['Jam Entry']}';

            loanDataList.add({
              'Cabang': item['Cabang'],
              'Loan Type': item['Loan Type'],
              'Entry Date & Time': entryDateTime,
              'Org Amount': item['Org Amount'],
              'Wilayah': item['Wilayah'],
              'Keterangan': item['Keterangan'],
            });
          }
        });
      }

      return {
        'statusCode': loanActivityResponse.statusCode,
        'data': loanDataList
      };
    } else {
      throw Exception(
          "Respons data aktivitas pinjaman tidak sesuai dengan yang diharapkan");
    }
  } catch (e) {
    print('Error: $e');
    return {'statusCode': 500, 'data': []};
  }
}

Future<Map<String, dynamic>> fetchTotalData(String wilayah) async {
  try {
    var loanActivityProvider = LoanActivityProvider();
    var loanActivityResponse = await loanActivityProvider.fetchLoanActivity();

    print('LoanActivityResponse: ${loanActivityResponse.body}');

    if (loanActivityResponse.body == null) {
      throw Exception("Respons data aktivitas pinjaman kosong");
    }

    var loanActivityBody = loanActivityResponse.body;
    if (loanActivityBody['success'] == true) {
      List<dynamic> dataList = loanActivityBody['lhlon_dd_idx'];
      int totalCount = 0;
      double totalOrgAmount = 0.0;

      dataList.forEach((item) {
        if (wilayah == "KONSOLIDASI" || item['Wilayah'] == wilayah) {
          totalCount += 1;
          double orgAmount =
              double.tryParse(item['Org Amount'].toString()) ?? 0.0;
          print('Processing Org Amount: $orgAmount');
          totalOrgAmount += orgAmount;
        }
      });

      print('Total Count: $totalCount');
      print('Total Org Amount: $totalOrgAmount');

      return {
        'total_count': totalCount,
        'total_org_amount': totalOrgAmount,
      };
    } else {
      throw Exception(
          "Respons data aktivitas pinjaman tidak sesuai dengan yang diharapkan");
    }
  } catch (e) {
    print('Error: $e');
    return {
      'total_count': 0,
      'total_org_amount': 0.0,
    };
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

      var cabangValue =
          cabang as String; // Menyimpan nilai cabang dalam variabel

      var apiProvider = ApiProvider();
      var apiResponse = await apiProvider.fetchData();
      List<dynamic> dataList = apiResponse.body['db_kpi_renbis_real_dd'];
      List<Map<String, dynamic>> kpiDeviasiList = [];

      // Menyaring data untuk hanya mengambil data dengan Cabang yang sama dengan nilai Cabang dari data pengguna
      dataList.forEach((item) {
        if (item['Cabang'] == cabangValue) {
          kpiDeviasiList.add({
            'KPI': item['KPI'],
            'Cabang': item['Cabang'],
            'Deviasi': double.parse(item['Deviasi']),
            'Renbis': item['Renbis'],
            'Realisasi': item['Realisasi'],
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

Future<Map<String, dynamic>> loadDatadblm(String wilayah) async {
  try {
    var apiProvider1 = ApiProvider1();
    var apiResponse1 = await apiProvider1.fetchData1();

    print('ApiResponse1: ${apiResponse1.body}');

    if (apiResponse1.statusCode == 401) {
      return {'statusCode': 401, 'data': []};
    }

    if (apiResponse1.body == null) {
      throw Exception("Respons data kosong");
    }

    var apiBody = apiResponse1.body;
    if (apiBody['success'] == true) {
      List<dynamic> dataList = apiBody['db_kpi_dblm_renbis_real_dd'];
      List<Map<String, dynamic>> kpiDeviasiList = [];

      // Filter data berdasarkan wilayah
      dataList.forEach((item) {
        if (item['Cabang'] == wilayah) {
          kpiDeviasiList.add({
            'KPI': item['KPI'],
            'Cabang': item['Cabang'],
            'Deviasi': double.tryParse(item['Deviasi'].toString()) ?? 0.0,
            'Renbis': item['Renbis'],
            'Realisasi': item['Realisasi'],
          });
        }
      });

      // Urutkan data berdasarkan nilai deviasi secara menurun
      kpiDeviasiList.sort((a, b) => b['Deviasi'].compareTo(a['Deviasi']));

      return {'statusCode': apiResponse1.statusCode, 'data': kpiDeviasiList};
    } else {
      throw Exception("Respons data tidak memiliki struktur yang diharapkan");
    }
  } catch (e) {
    print('Error: $e');
    return {'statusCode': 500, 'data': []};
  }
}

Future<Map<String, dynamic>> keuangan(String wilayah) async {
  try {
    var keuangan1 = Keuangan();
    var responsekeuangan = await keuangan1.datakeuangan();

    print('Responsekeuangan: ${responsekeuangan.body}');

    if (responsekeuangan.statusCode == 401) {
      return {'statusCode': 401, 'data': []};
    }

    if (responsekeuangan.body == null) {
      throw Exception("Respons data keuangan kosong");
    }

    var apiBody = responsekeuangan.body;
    if (apiBody['success'] == true) {
      List<dynamic> dataList = apiBody['v_keuangan'];
      List<Map<String, dynamic>> kpiDeviasiList = [];

      dataList.forEach((item) {
        bool isCurrency = item['KPI'] == 'TOTAL ASET' ||
            item['KPI'] == 'BIAYA OPERASIONAL' ||
            item['KPI'] == 'LABA/RUGI';

        if (item['Cabang'] == wilayah) {
          kpiDeviasiList.add({
            'Level': item['Level'],
            'KodeWilayah': item['KodeWilayah'],
            'Wilayah': item['Wilayah'],
            'KodeCabang': item['KodeCabang'],
            'Cabang': item['Cabang'],
            'KPI': item['KPI'],
            'Value': double.tryParse(item['Value'].toString()) ?? 0.0,
            'Periode': item['Periode'],
            'isCurrency': isCurrency,
          });
        }
      });

      kpiDeviasiList.sort((a, b) => b['Value'].compareTo(a['Value']));

      return {
        'statusCode': responsekeuangan.statusCode,
        'data': kpiDeviasiList
      };
    } else {
      throw Exception(
          "Respons data keuangan tidak memiliki struktur yang diharapkan");
    }
  } catch (e) {
    print('Error: $e');
    return {'statusCode': 500, 'data': []};
  }
}

Future<Map<String, dynamic>> dpk(String wilayah) async {
  try {
    var dpk = Dpk();
    var responsedpk = await dpk.datadpk();

    print('responsedpk: ${responsedpk.body}');

    if (responsedpk.statusCode == 401) {
      return {'statusCode': 401, 'data': []};
    }

    if (responsedpk.body == null) {
      throw Exception("Respons data dpk kosong");
    }

    var apiBody = responsedpk.body;
    if (apiBody['success'] == true) {
      List<dynamic> dataList = apiBody['v_dpk'];
      List<Map<String, dynamic>> kpiDeviasiList = [];

      dataList.forEach((item) {
        if (item['Cabang'] == wilayah) {
          kpiDeviasiList.add({
            'Level': item['Level'],
            'KodeWilayah': item['KodeWilayah'],
            'Wilayah': item['Wilayah'],
            'KodeCabang': item['KodeCabang'],
            'Cabang': item['Cabang'],
            'KPI': item['KPI'],
            'Value': double.tryParse(item['Value'].toString()) ?? 0.0,
            'Periode': item['Periode'],
          });
        }
      });

      kpiDeviasiList.sort((a, b) => b['Value'].compareTo(a['Value']));

      return {'statusCode': responsedpk.statusCode, 'data': kpiDeviasiList};
    } else {
      throw Exception(
          "Respons data dpk tidak memiliki struktur yang diharapkan");
    }
  } catch (e) {
    print('Error: $e');
    return {'statusCode': 500, 'data': []};
  }
}

Future<List<Map<String, dynamic>>> loadDataFromDataHst(String cabang) async {
  try {
    var dataHstProvider = datahst();
    var dataHstResponse = await dataHstProvider.fetchDataHst();

    print('DataHstResponse: ${dataHstResponse.body}');

    if (dataHstResponse.body == null) {
      throw Exception("Respons data HST kosong");
    }

    var dataHstBody = dataHstResponse.body;
    if (dataHstBody['success'] == true) {
      List<dynamic> dataList = dataHstBody['db_kpi_laba_real_dd_hst'];

      // Filter data berdasarkan Cabang == cabang
      List<Map<String, dynamic>> kpiDataList = dataList
          .where((item) => item['Cabang'] == cabang)
          .take(7)
          .map((item) {
        double value = double.parse(item['Value']);
        String simplifiedValue1 = simplifyValue1(value);

        // Menghapus angka di belakang koma dari value
        value = double.parse(value.toStringAsFixed(0));

        return {
          'Periode': item['Periode'],
          'Value': value,
          'SimplifiedValue': simplifiedValue1,
        };
      }).toList();

      // Jika panjang dataList lebih dari 7, tambahkan pesan informasi
      if (dataList.length > 7) {
        print("Hanya 7 data pertama yang ditampilkan.");
      }

      return kpiDataList;
    } else {
      throw Exception(
          "Respons data HST tidak memiliki struktur yang diharapkan");
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

String simplifyValue(double value) {
  bool isNegative = value < 0;
  double absValue = value.abs();

  if (absValue >= 1000000000000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000000000000).toStringAsFixed(2)} T";
  } else if (absValue >= 1000000000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000000000).toStringAsFixed(2)} M";
  } else if (absValue >= 1000000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000000).toStringAsFixed(2)} JT";
  } else if (absValue >= 1000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000).toStringAsFixed(2)} Rb";
  } else {
    return value.toString();
  }
}

String simplifyValue1(double value) {
  bool isNegative = value < 0;
  double absValue = value.abs();

  if (absValue >= 1000000000000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000000000000).floor()} T";
  } else if (absValue >= 1000000000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000000000).floor()} M";
  } else if (absValue >= 1000000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000000).floor()} JT";
  } else if (absValue >= 1000) {
    return "${isNegative ? '-' : ''}${(absValue / 1000).floor()} Rb";
  } else {
    return value.toStringAsFixed(0); // Menampilkan angka bulat tanpa desimal
  }
}

// String simplifyValue1(double value) {
//   if (value >= 1000000000000) {
//     return "${(value / 1000000000000).toStringAsFixed(0)} T";
//   } else if (value >= 1000000000) {
//     return "${(value / 1000000000).toStringAsFixed(0)} M";
//   } else if (value >= 1000000) {
//     return "${(value / 1000000).toStringAsFixed(0)} JT";
//   } else if (value >= 1000) {
//     return "${(value / 1000).toStringAsFixed(0)} Rb";
//   } else {
//     return value.toString();
//   }
// }

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Enforce the format of "YYYY/MM/DD"
    if (text.length == 4 || text.length == 7) {
      if (oldValue.text.length < newValue.text.length) {
        return TextEditingValue(
          text: '${newValue.text}-',
          selection: TextSelection.fromPosition(
            TextPosition(offset: newValue.selection.end + 1),
          ),
        );
      }
    }
    return newValue;
  }
}

class SalesData {
  final String year;
  final double sales;
  final String simplifiedValue1;
  final double volume;

  SalesData(this.year, this.sales, this.simplifiedValue1, this.volume);
}

class FileDataTableWidget extends StatefulWidget {
  const FileDataTableWidget({Key? key}) : super(key: key);

  @override
  _FileDataTableWidgetState createState() => _FileDataTableWidgetState();
}

class _FileDataTableWidgetState extends State<FileDataTableWidget> {
  final downloadFile apiService = downloadFile();
  String searchQuery = '';
  bool isCheckbox1Checked = false;
  bool isCheckbox2Checked = false;
  bool isCheckbox3Checked = false;
  bool isCheckbox4Checked = false;
  String _currentDateHint = '';
  bool isMinimized = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _currentDateHint = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar and button
        Container(
          width: double.infinity, // Makes the container full width
          height: isMinimized ? 30 : 60, // Toggle height based on state
          padding: const EdgeInsets.symmetric(horizontal: 4), // Reduced padding
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.search, size: 18), // Smaller icon size
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText:
                        'Search By Period', // Adjust this according to your variable
                    contentPadding:
                        const EdgeInsets.all(8), // Minimized content padding
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [DateInputFormatter()],
                  style: TextStyle(fontSize: 14), // Smaller font size
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : '',
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.date_range, // Use the same icon for date picker
                  size: 24,
                ),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                      searchQuery =
                          DateFormat('yyyy-MM-dd').format(selectedDate!);
                    });
                  }
                },
              ),
            ],
          ),
        ),

        // Checkbox categories in two columns
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Column 1: Category 1 and 2
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isCheckbox1Checked,
                          onChanged: (value) {
                            setState(() {
                              isCheckbox1Checked = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(
                            width:
                                2), // Adjust spacing between checkbox and text
                        Text(
                          'Neraca Konsol',
                          style: TextStyle(fontSize: 14), // Smaller font size
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isCheckbox2Checked,
                          onChanged: (value) {
                            setState(() {
                              isCheckbox2Checked = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Neraca Konven',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Column 2: Category 3 and 4
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isCheckbox3Checked,
                          onChanged: (value) {
                            setState(() {
                              isCheckbox3Checked = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Neraca Syariah',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isCheckbox4Checked,
                          onChanged: (value) {
                            setState(() {
                              isCheckbox4Checked = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Neraca DBLM',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // DataTable
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: apiService.fetchdownloadFile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                List<Map<String, dynamic>> data = snapshot.data!;

                List<Map<String, dynamic>> filteredData = data.where((item) {
                  final filePeriod = item['file_period'] ?? '';
                  final fileCategory = item['file_type'] ?? '';

                  // Apply checkbox filters
                  if (isCheckbox1Checked && fileCategory != 'neraca_konsol')
                    return false;
                  if (isCheckbox2Checked && fileCategory != 'neraca_konven')
                    return false;
                  if (isCheckbox3Checked && fileCategory != 'neraca_syariah')
                    return false;
                  if (isCheckbox4Checked &&
                      fileCategory != 'neraca_dblm_konsol') return false;

                  return filePeriod
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                return ListView(
                  children: [
                    DataTable(
                      dataRowHeight: 40,
                      columnSpacing: 40,
                      columns: const [
                        DataColumn(label: Text('File')),
                        DataColumn(label: Text('Periode')),
                        DataColumn(label: Text('Download')),
                      ],
                      rows: filteredData.map((item) {
                        final fileNameData = item['file_name'];
                        String fileName;
                        String url =
                            'https://eis.bankaltimtara.co.id/data_neraca/';

                        if (fileNameData is Map<String, dynamic>) {
                          fileName = fileNameData['name'] ?? '';
                        } else if (fileNameData is String) {
                          fileName = fileNameData;
                        } else {
                          fileName = 'Unknown';
                        }

                        String downloadUrl = url + fileName;

                        return DataRow(cells: [
                          DataCell(Text(item['file_type'] ?? '')),
                          DataCell(Text(item['file_period'] ?? '')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () async {
                                if (await canLaunch(downloadUrl)) {
                                  await launch(downloadUrl);
                                } else {
                                  throw 'Could not launch $downloadUrl';
                                }
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(const GetMaterialApp(
    home: MenuBaruView(),
  ));
}
