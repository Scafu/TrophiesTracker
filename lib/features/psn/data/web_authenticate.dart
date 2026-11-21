import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// Opens [url] in the system browser and returns the address Sony sends the
/// user back to, which is the one that starts with [callbackScheme].
///
/// With [fresh] the browser session shares nothing with the user's browser, so
/// Sony asks who is logging in instead of recognizing the account of the last
/// time. Without it the session is shared, which skips the password.
typedef WebAuthenticate =
    Future<String> Function(String url, String callbackScheme, {bool fresh});

Future<String> systemBrowserAuthenticate(
  String url,
  String callbackScheme, {
  bool fresh = false,
}) => FlutterWebAuth2.authenticate(
  url: url,
  callbackUrlScheme: callbackScheme,
  options: FlutterWebAuth2Options(preferEphemeral: fresh),
);
