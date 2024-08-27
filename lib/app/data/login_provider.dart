import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:sp_util/sp_util.dart';

class CustomGetConnect extends GetConnect {
  @override
  void onInit() {
    httpClient.addRequestModifier<dynamic>((request) {
      var token = SpUtil.getString("JWT");
      if (token != null) {
        request.headers["X-Authorization"] = "Bearer $token";
      }
      return request;
    });
    super.onInit();
  }
}

class LoginProvider extends CustomGetConnect {
  Future<Response> auth(String jsonData) async {
    try {
      var response = await post(
        'https://tiara.bankaltimtara.co.id/api_eis/api/login',
        jsonData,
      );

      if (response.statusCode == 200) {
        // Autentikasi berhasil
        return response;
      } else if (response.statusCode == 401) {
        // Kata sandi salah
        throw Exception("Kata sandi salah. Silakan coba lagi.");
      } else {
        // Respon lainnya, mungkin terjadi kesalahan server
        throw Exception("Terjadi kesalahan saat melakukan autentikasi.");
      }
    } catch (e) {
      throw e;
    }
  }
}

// class UserDataProvider1 extends CustomGetConnect {
//   Future<Response> fetchUserData1() async {
//     var token = SpUtil.getString("JWT");
//     if (token == null || token.isEmpty) {
//       throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
//     }

//     var url = 'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_user';
//     var headers = {'X-Authorization': 'Bearer $token'};
//     var apiResponse = await get(url, headers: headers);

//     // Memastikan respons berhasil
//     if (apiResponse.statusCode == 200) {
//       var data = jsonDecode(apiResponse.bodyString ?? '{}');
//       // Misalnya, jika level berada di dalam objek data['user']
//       if (data.containsKey('user')) {
//         var user = data['user'];
//         if (user.containsKey('Level')) {
//           print('Level: ${user['Level']}');
//         } else {
//           print('Level tidak ditemukan dalam data pengguna.');
//         }
//       } else {
//         print('Data pengguna tidak ditemukan.');
//       }
//     } else {
//       throw Exception('Gagal memuat data pengguna.');
//     }

//     return apiResponse;
//   }
// }

class ApiProvider extends CustomGetConnect {
  Future<Response> fetchData() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_kpi_renbis_real_dd?recperpage=ALL';
    var headers = {'X-Authorization': 'Bearer $token'};
    var apiResponse = await get(url, headers: headers);
    // print(apiResponse.body);
    return apiResponse;
  }
}

class ApiProvider1 extends CustomGetConnect {
  Future<Response> fetchData1() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_kpi_dblm_renbis_real_dd?recperpage=ALL';
    var headers = {'X-Authorization': 'Bearer $token'};
    var apiResponse1 = await get(url, headers: headers);
    // print(apiResponse.body);
    return apiResponse1;
  }
}

class Keuangan extends CustomGetConnect {
  Future<Response> datakeuangan() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/v_keuangan?recperpage=ALL';
    var headers = {'X-Authorization': 'Bearer $token'};
    var responsekeuangan = await get(url, headers: headers);
    // print(apiResponse.body);
    return responsekeuangan;
  }
}

class HistoriKeuangan extends CustomGetConnect {
  Future<Response> dataHistorikeuangan(
      String cabang, String selectedKPI) async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_kpi_real_mm?x_Cabang=$cabang&x_KPI%5B%5D=$selectedKPI&order=Periode&ordertype=DESC';
    var headers = {'X-Authorization': 'Bearer $token'};
    var responsehistorikeuangan = await get(url, headers: headers);
    return responsehistorikeuangan;
  }
}

class Dpk extends CustomGetConnect {
  Future<Response> datadpk() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/v_dpk?recperpage=ALL';
    var headers = {'X-Authorization': 'Bearer $token'};
    var responsedpk = await get(url, headers: headers);
    // print(apiResponse.body);
    return responsedpk;
  }
}

class HistoriDpk extends CustomGetConnect {
  Future<Response> dataHistoridpk(String cabang, String selectedKPI) async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_kpi_real_mm?x_Cabang=$cabang&x_KPI%5B%5D=$selectedKPI&order=Periode&ordertype=DESC';
    var headers = {'X-Authorization': 'Bearer $token'};
    var responsehistorikeuangan = await get(url, headers: headers);
    return responsehistorikeuangan;
  }
}

class UserDataProvider extends CustomGetConnect {
  Future<Response> fetchUserData() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url = 'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_user';
    var headers = {'X-Authorization': 'Bearer $token'};
    var apiResponse = await get(url, headers: headers);

    return apiResponse;
  }
}

class Periode extends GetConnect {
  Future<Response> fetchperiode() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/view/sys_parameter/PeriodeData';
    var headers = {'X-Authorization': 'Bearer $token'};
    var apiResponse = await get(url, headers: headers);

    return apiResponse;
  }
}

class datahst extends GetConnect {
  Future<Response> fetchDataHst() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_kpi_laba_real_dd_hst?recperpage=ALL&order=Periode&ordertype=DESC';
    var headers = {'X-Authorization': 'Bearer $token'};
    var apiDataHst = await get(url, headers: headers);
    // print(apiDataHst.body);
    return apiDataHst;
  }
}

class LoanActivityProvider extends GetConnect {
  Future<Response> fetchLoanActivity() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/lhlon_dd_idx?recperpage=ALL&order=Jam+Entry&ordertype=DESC';
    var headers = {'X-Authorization': 'Bearer $token'};
    var activityProvider = await get(url,
        headers: headers); // Rubah variabel menjadi activityProvider
    return activityProvider;
  }
}

class LoanActivityProvider1 extends GetConnect {
  Future<Response> fetchLoanActivity1() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url =
        'https://tiara.bankaltimtara.co.id/api_eis/api/list/lhlon_dd_idx?recperpage=ALL&order=Jam+Entry&ordertype=DESC';
    var headers = {'X-Authorization': 'Bearer $token'};
    var activityProvider = await get(url,
        headers: headers); // Rubah variabel menjadi activityProvider
    return activityProvider;
  }
}

class downloadFile extends GetConnect {
  Future<List<Map<String, dynamic>>> fetchdownloadFile() async {
    var token = SpUtil.getString("JWT");
    if (token == null || token.isEmpty) {
      throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
    }

    var url = 'https://tiara.bankaltimtara.co.id/api_eis/api/list/bp_gen_file';
    var headers = {'X-Authorization': 'Bearer $token'};
    var response = await get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> rawData = response.body['bp_gen_file'];
      List<Map<String, dynamic>> data = rawData.map((item) {
        return {
          "file_name": item['file_name']['name'],
          "file_type": item['file_type'],
          "file_period": item['file_period'],
          "UPDATECREATED": item['UPDATECREATED'],
        };
      }).toList();
      return data;
    } else if (response.statusCode == 401) {
      // Handle unauthorized error
      throw Exception(
          "Unauthorized: Invalid or expired token. Please log in again.");
    } else {
      // Handle other errors
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  }
}

// class LoanActivityProvider extends GetConnect {
//   Future<Response> fetchLoanActivity() async {
//     var token = SpUtil.getString("JWT");
//     if (token == null || token.isEmpty) {
//       throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
//     }

//     var url =
//         'https://tiara.bankaltimtara.co.id/api_eis/api/list/lhlon_dd_idx?recperpage=ALL&order=Jam+Entry&ordertype=DESC';
//     var headers = {'X-Authorization': 'Bearer $token'};
//     var activityProvider = await get(url,
//         headers: headers); // Rubah variabel menjadi activityProvider
//     print(activityProvider.body);
//     return activityProvider;
//   }
// }

//filter berdasarkan tanggal hari ini
// class LoanActivityProvider extends GetConnect {
//   Future<String> fetchLoanActivity(String date) async {
//     var token = SpUtil.getString("JWT");
//     if (token == null || token.isEmpty) {
//       throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
//     }

//     var url =
//         'https://tiara.bankaltimtara.co.id/api_eis/api/list/lhlon_dd_idx?recperpage=ALL&order=Periode&ordertype=DESC';
//     var headers = {'X-Authorization': 'Bearer $token'};
//     var query = {'PERIODE': date};

//     var activityProvider = await get(url, headers: headers, query: query);

//     // Periksa apakah ada data yang ditemukan dalam respons
//     if (activityProvider.body == null || activityProvider.body.isEmpty) {
//       return "Tidak Ada Data Kredit Hari Ini";
//     }

//     // Jika ada data, kembalikan respons sebagai string
//     return activityProvider.body.toString();
//   }
// }








//ini filter by cabang
// class UserDataProvider extends GetConnect {
//   Future<Response> fetchUserData() async {
//     var token = SpUtil.getString("JWT");
//     if (token == null || token.isEmpty) {
//       throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
//     }

//     var url = 'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_user';
//     var headers = {'X-Authorization': 'Bearer $token'};
//     var apiResponse = await get(url, headers: headers);

//     return apiResponse;
//   }

//   Future<String> fetchUserRegion() async {
//     var response = await fetchUserData();
//     if (response.status.hasError) {
//       throw Exception("Gagal mengambil data user");
//     }

//     var userData = response.body;
//     // Asumsikan data wilayah ada dalam field 'wilayah' di response body
//     var region = userData['wilayah'];
//     return region;
//   }
// }

// class datahst extends GetConnect {
//   UserDataProvider userDataProvider = UserDataProvider();

//   Future<Response> fetchDataHst() async {
//     var token = SpUtil.getString("JWT");
//     if (token == null || token.isEmpty) {
//       throw Exception("Token JWT tidak tersedia. Harap login terlebih dahulu.");
//     }

//     // Ambil data wilayah dari UserDataProvider
//     var region = await userDataProvider.fetchUserRegion();

//     var url =
//         'https://tiara.bankaltimtara.co.id/api_eis/api/list/db_kpi_real_dd_hst?recperpage=ALL&order=Periode&ordertype=DESC&Cabang=$region';
//     var headers = {'X-Authorization': 'Bearer $token'};
//     var apiDataHst = await get(url, headers: headers);
//     // print(apiDataHst.body);
//     return apiDataHst;
//   }
// }


