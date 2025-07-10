//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Source code by dev-cetera.com & contributors. The use of this source code is
// governed by an MIT-style license described in the LICENSE file located in
// this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:convert' show jsonDecode, jsonEncode, base64UrlEncode;
import 'dart:math' show Random;
import 'package:crypto/crypto.dart' show sha256;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart' show protected;

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An abstract base class for implementing OAuth 2.0 authentication providers
/// that can sign into Firebase.
abstract base class OAuth2Provider {
  /// The URL of the backend service that will exchange the authorization code
  /// for an access token.
  final Uri backendUrl;

  /// The explicit redirect URI to be used in the OAuth flow.
  /// If null, a URI is generated based on the current context.
  final String? redirectUri;

  /// The custom URL scheme that the app will listen for during the OAuth redirect.
  final String callbackUrlScheme;

  /// A flag to enable or disable the Proof Key for Code Exchange (PKCE) extension.
  final bool usePkce;

  /// The client ID issued by the OAuth provider.
  final String clientId;

  /// The client secret issued by the OAuth provider.
  /// Should only be used in secure server environments, not in public clients.
  final String? clientSecret;

  const OAuth2Provider({
    required this.backendUrl,
    required this.clientId,
    this.redirectUri,
    required this.callbackUrlScheme,
    this.usePkce = false,
    this.clientSecret,
  });

  /// Builds the provider-specific authentication URL.
  @protected
  Uri buildAuthUrl({required String state, String? codeChallenge});

  /// Creates a Firebase [AuthCredential] from the token data received from the backend.
  AuthCredential createFirebaseCredential(Map<String, dynamic> tokenData);

  /// Initiates the full sign-in flow.
  Future<void> signIn() async {
    final authCodeData = await getAuthorizationCode();
    final tokenData = await getTokenData(
      code: authCodeData.code,
      codeVerifier: authCodeData.codeVerifier,
    );
    final credential = createFirebaseCredential(tokenData);
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Handles the first leg of the OAuth 2.0 flow to get an authorization code.
  @protected
  Future<({String code, String? codeVerifier})> getAuthorizationCode() async {
    if (clientId.isEmpty) {
      throw Exception('OAuthProvider Error: clientId cannot be empty.');
    }

    /// [codeVerifier] is a secret created by the client for PKCE.
    String? codeVerifier;

    /// [codeChallenge] is a transformed version of the verifier sent to the server.
    String? codeChallenge;
    if (usePkce) {
      codeVerifier = generateNewSecureRandomString();
      codeChallenge = generateCodeChallengeFrom(codeVerifier);
    }

    /// A random string to prevent Cross-Site Request Forgery (CSRF) attacks.
    final newState = generateNewSecureRandomString();
    final authUrl = buildAuthUrl(state: newState, codeChallenge: codeChallenge);

    /// Launches the web browser for user authentication.
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: callbackUrlScheme,
    );

    /// Parses the returned URL and validates the state parameter.
    final uri = Uri.parse(result);
    final state = uri.queryParameters['state'];
    if (state != newState) {
      throw Exception('Invalid state parameter. Possible CSRF attack.');
    }

    /// Extracts the authorization code from the URL.
    final code = uri.queryParameters['code'];
    if (code == null) {
      throw Exception('Sign-in failed or was cancelled by the user.');
    }
    return (code: code, codeVerifier: codeVerifier);
  }

  /// Exchanges the authorization code for an access token via the backend service.
  @protected
  Future<Map<String, dynamic>> getTokenData({required String code, String? codeVerifier}) async {
    // Correctly handle adding optional parameters to the request body.
    final body = <String, dynamic>{
      'code': code,
      'redirect_uri': createRedirectUrl().toString(),
      'client_id': clientId,
    };
    if (clientSecret != null) {
      body['client_secret'] = clientSecret;
    }
    if (codeVerifier != null) {
      body['code_verifier'] = codeVerifier;
    }

    final response = await http.post(
      backendUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to exchange code. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  /// Constructs the redirect URL, using the provided [redirectUri] or a default.
  Uri createRedirectUrl({
    String pathSegment = 'auth-callback.html',
    Map<String, String>? queryParameters,
  }) {
    return (redirectUri != null ? Uri.tryParse(redirectUri!) : null) ??
        Uri.base.replace(path: pathSegment, queryParameters: queryParameters);
  }

  /// Generates a cryptographically secure, URL-safe random string.
  String generateNewSecureRandomString([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// Creates a SHA-256 hash of the verifier for the PKCE code challenge.
  String generateCodeChallengeFrom(String verifier) {
    final bytes = verifier.codeUnits;
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
