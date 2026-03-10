// core/services/rate_limiter.dart
class RateRequestLimiter {
  final Map<String, DateTime> _lastRequests = {};

  bool isAllowed(String key, Duration interval) {
    final last = _lastRequests[key];
    if (last == null) return true;
    return DateTime.now().difference(last) >= interval;
  }

  void markRequest(String key) {
    _lastRequests[key] = DateTime.now();
  }
}
