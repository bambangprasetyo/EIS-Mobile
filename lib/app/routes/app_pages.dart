import 'package:get/get.dart';

import '../modules/Getdata/bindings/getdata_binding.dart';
import '../modules/Getdata/views/getdata_view.dart';
import '../modules/MainMenu/bindings/main_menu_binding.dart';
import '../modules/MainMenu/views/main_menu_view.dart';
import '../modules/dblm/bindings/dblm_binding.dart';
import '../modules/dblm/views/dblm_view.dart';
import '../modules/dpk/bindings/dpk_binding.dart';
import '../modules/dpk/views/dpk_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/keuangan/bindings/keuangan_binding.dart';
import '../modules/keuangan/views/keuangan_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/masterpage/bindings/masterpage_binding.dart';
import '../modules/masterpage/views/masterpage_view.dart';
import '../modules/menu_baru/bindings/menu_baru_binding.dart';
import '../modules/menu_baru/views/menu_baru_view.dart';
import '../modules/notif/bindings/notif_binding.dart';
import '../modules/notif/views/notif_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_MENU,
      page: () => const MainMenuView(),
      binding: MainMenuBinding(),
    ),
    GetPage(
      name: _Paths.GETDATA,
      page: () => const GetdataView(),
      binding: GetdataBinding(),
    ),
    GetPage(
      name: _Paths.MENU_BARU,
      page: () => const MenuBaruView(),
      binding: MenuBaruBinding(),
    ),
    GetPage(
      name: _Paths.NOTIF,
      page: () => const NotifView(),
      binding: NotifBinding(),
    ),
    GetPage(
      name: _Paths.DBLM,
      page: () => const DblmView(),
      binding: DblmBinding(),
    ),
    GetPage(
      name: _Paths.KEUANGAN,
      page: () => const KeuanganView(),
      binding: KeuanganBinding(),
    ),
    GetPage(
      name: _Paths.MASTERPAGE,
      page: () => const MasterpageView(),
      binding: MasterpageBinding(),
    ),
    GetPage(
      name: _Paths.DPK,
      page: () => const DhomeView(),
      binding: DpkBinding(),
    ),
  ];
}
