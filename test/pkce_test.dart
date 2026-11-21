import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/utils/pkce/pkce.dart';

void main() {
  test('the challenge matches the RFC 7636 test vector', () {
    expect(
      Pkce.challengeFor('dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'),
      'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
    );
  });

  test('a generated pair is URL-safe, consistent and different each time', () {
    final a = Pkce.generate();
    final b = Pkce.generate();

    expect(a.verifier, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(a.challenge, Pkce.challengeFor(a.verifier));
    expect(a.verifier, isNot(b.verifier));
  });
}
