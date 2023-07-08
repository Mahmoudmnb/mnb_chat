import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetInfo {
  static isconnected() async {
    InternetConnectionCheckerPlus netInfo = InternetConnectionCheckerPlus();
    return await netInfo.hasConnection;
  }
}
