import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// A PKCE (RFC 7636) pair for the Steam login.
///
/// The app sends only the [challenge] when it starts the login and keeps the
/// [verifier] to itself. The one-time code that comes back in the deep link is
/// worthless to another app that intercepts it: exchanging it needs the
/// verifier.
class Pkce {
  final String verifier;
  final String challenge;

  const Pkce._(this.verifier, this.challenge);

  /// Creates a pair from 32 random bytes.
  factory Pkce.generate() {
    final random = Random.secure();
    final verifier = _base64Url([
      for (var i = 0; i < 32; i++) random.nextInt(256),
    ]);
    return Pkce._(verifier, challengeFor(verifier));
  }

  /// Returns the S256 challenge of [verifier].
  static String challengeFor(String verifier) {
    return _base64Url(sha256.convert(ascii.encode(verifier)).bytes);
  }

  static String _base64Url(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
