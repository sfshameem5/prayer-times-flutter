import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isOnline = true;

  Future<void> initialize() async {
    final initial = await _connectivity.checkConnectivity();
    _isOnline = _mapToOnline(initial);

    _subscription ??= _connectivity.onConnectivityChanged.listen((result) {
      final online = _mapToOnline(result);
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

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
