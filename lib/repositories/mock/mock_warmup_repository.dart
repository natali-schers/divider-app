import 'dart:async';

import 'package:divider/repositories/warmup_repository.dart';

class MockWarmupRepository implements WarmupRepository {
  static final MockWarmupRepository instance = MockWarmupRepository();

  bool _isWarm = false;
  bool get isWarm => _isWarm;

  Completer<void>? _warmupCompleter;

  @override
  Future<void> warmUp() {
    if (_warmupCompleter != null) return _warmupCompleter!.future;

    _warmupCompleter = Completer<void>();

    Future.delayed(const Duration(milliseconds: 500), () {
      _isWarm = true;
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
