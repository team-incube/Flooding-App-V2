import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityChecker {
  Future<bool> hasConnection();
}

class ConnectivityService implements ConnectivityChecker {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
