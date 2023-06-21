import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetInfo {
  @override
  @override
  static isconnected() async {
    InternetConnectionCheckerPlus netInfo = InternetConnectionCheckerPlus();
    return await netInfo.hasConnection;
  }
}
