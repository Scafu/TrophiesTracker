/// User-facing message for an operation blocked by [RateRequestLimiter].
const String rateLimitedMessage = 'Too many requests. Please try again later.';

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

  /// Forgets the last request for [key], so an operation that failed can be
  /// retried right away instead of waiting out the interval.
  void clear(String key) => _lastRequests.remove(key);
}
