part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const MAIN_MENU = _Paths.MAIN_MENU;
  static const GETDATA = _Paths.GETDATA;
  static const MENU_BARU = _Paths.MENU_BARU;
  static const NOTIF = _Paths.NOTIF;
  static const DBLM = _Paths.DBLM;
  static const KEUANGAN = _Paths.KEUANGAN;
  static const MASTERPAGE = _Paths.MASTERPAGE;
  static const DPK = _Paths.DPK;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const MAIN_MENU = '/main-menu';
  static const GETDATA = '/getdata';
  static const MENU_BARU = '/menu-baru';
  static const NOTIF = '/notif';
  static const DBLM = '/dblm';
  static const KEUANGAN = '/keuangan';
  static const MASTERPAGE = '/masterpage';
  static const DPK = '/dpk';
}
