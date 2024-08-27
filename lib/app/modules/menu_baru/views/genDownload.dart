import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileDataTable extends StatefulWidget {
  @override
  _FileDataTableState createState() => _FileDataTableState();
}

class _FileDataTableState extends State<FileDataTable> {
  final downloadFile apiService = downloadFile();

  // Filters
  String searchFileName = '';
  String searchFilePeriod = '';
  String? selectedFileType;

  // List of file types for the combo box
  final List<String> fileTypes = ['Type 1', 'Type 2', 'Type 3'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search fields
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // File Name search field
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search by File Name',
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchFileName = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8.0),

              // File Period search field
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search by File Period',
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchFilePeriod = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8.0),

              // File Type combo box
              Expanded(
                child: DropdownButton<String>(
                  value: selectedFileType,
                  hint: Text('Select File Type'),
                  onChanged: (newValue) {
                    setState(() {
                      selectedFileType = newValue;
                    });
                  },
                  items: fileTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Data table
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

                // Apply filters to the data
                data = data.where((item) {
                  final fileNameData = item['file_name'];
                  String fileName;
                  if (fileNameData is Map<String, dynamic>) {
                    fileName = fileNameData['name'] ?? '';
                  } else if (fileNameData is String) {
                    fileName = fileNameData;
                  } else {
                    fileName = 'Unknown';
                  }

                  return (searchFileName.isEmpty ||
                          fileName
                              .toLowerCase()
                              .contains(searchFileName.toLowerCase())) &&
                      (searchFilePeriod.isEmpty ||
                          (item['file_period'] ?? '')
                              .toLowerCase()
                              .contains(searchFilePeriod.toLowerCase())) &&
                      (selectedFileType == null ||
                          (item['file_type'] ?? '') == selectedFileType);
                }).toList();

                return Container(
                  height: 400,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('File Name')),
                          DataColumn(label: Text('File Period')),
                          DataColumn(label: Text('Download')),
                        ],
                        rows: data.map((item) {
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

                          // Construct the full URL
                          String downloadUrl = url + fileName;

                          return DataRow(cells: [
                            DataCell(Text(fileName)),
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
          ),
        ),
      ],
    );
  }
}

// Dummy class representing the API service
class downloadFile {
  Future<List<Map<String, dynamic>>> fetchdownloadFile() async {
    // Replace with your actual API call
    return [
      {
        'file_name': 'Report1.pdf',
        'file_period': '2023 Q1',
        'file_type': 'Type 1',
      },
      {
        'file_name': 'Report2.pdf',
        'file_period': '2023 Q2',
        'file_type': 'Type 2',
      },
      // Add more file data here
    ];
  }
}
