import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl({InternetConnectionChecker? connectionChecker})
      : connectionChecker = connectionChecker ?? InternetConnectionChecker();

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}