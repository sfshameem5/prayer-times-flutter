import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  Future<void> initialize() async {
    final initial = await _connectivity.checkConnectivity();
    _isOnline = _mapListToOnline(initial);

    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final online = _mapListToOnline(results);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(_isOnline);
      }
    });
  }

  bool get isOnline => _isOnline;

  Stream<bool> get onStatusChange => _controller.stream;

  bool _mapToOnline(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  bool _mapListToOnline(List<ConnectivityResult> results) {
    return results.any(_mapToOnline);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
