abstract class WarmupRepository {
  Future<void> warmUp();

  Future<void> waitUntilWarm({Duration timeout = const Duration(seconds: 60)});
}