import 'dart:async';

import 'package:divider/config/app_config.dart';
import 'package:divider/repositories/warmup_repository.dart';
import 'package:http/http.dart' as http;

class ApiWarmupRepository implements WarmupRepository {
  String get _baseUrl => AppConfig.apiBaseUrl;

  bool _isWarm = false;
  bool get isWarm => _isWarm;

  Completer<void>? _warmupCompleter;

  @override
  Future<void> warmUp() {
    if (_warmupCompleter != null) return _warmupCompleter!.future;

    _warmupCompleter = Completer<void>();

    http
        .get(Uri.parse('$_baseUrl/health'))
        .timeout(const Duration(seconds: 70))
        .then((response) {
          _isWarm = true;
          _warmupCompleter!.complete();
        })
        .catchError((e) {
          _isWarm = false;
          _warmupCompleter!.complete();
        });

    return _warmupCompleter!.future;
  }

  @override
  Future<void> waitUntilWarm({
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (_isWarm) return;
    if (_warmupCompleter == null) return warmUp();
    return _warmupCompleter!.future.timeout(timeout, onTimeout: () {});
  }
}
