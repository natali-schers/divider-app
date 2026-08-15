import 'package:divider/repositories/warmup_repository.dart';
import 'package:divider/repositories/warmup_repository_factory.dart';
import 'package:flutter/foundation.dart';

class WarmupProvider extends ChangeNotifier {
  final WarmupRepository _warmupRepository = WarmupRepositoryFactory.create();

  bool _isLoading = false;
  bool _isReady = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isReady => _isReady;
  bool get isWarm => _isReady;
  String? get errorMessage => _errorMessage;

  Future<void> warmUp() async {
    if (_isReady || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _warmupRepository.warmUp();
      _isReady = true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isReady = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> waitUntilWarm({
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (_isReady) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _warmupRepository.waitUntilWarm(timeout: timeout);
      _isReady = true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isReady = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}