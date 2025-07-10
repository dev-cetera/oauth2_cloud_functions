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

import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:firebase_auth/firebase_auth.dart' show AuthCredential, FirebaseAuth;
import 'package:http/http.dart' as http;

import 'oauth2_provider.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An abstract provider for a multi-step custom token authentication flow.
abstract base class CustomTokenProvider extends OAuth2Provider {
  const CustomTokenProvider({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    super.usePkce,
  });

  /// The backend endpoint for creating a Firebase custom token.
  Uri get customTokenEndpoint;

  /// Throws an error as this flow does not create a standard `OAuthCredential`.
  @override
  AuthCredential createFirebaseCredential(Map<String, dynamic> tokenData) {
    throw UnimplementedError('Custom providers use signInWithCustomToken.');
  }

  /// Overrides the default sign-in to implement the full custom token flow.
  @override
  Future<void> signIn() async {
    // Step 1: Get the OAuth authorization code from the provider.
    final authCodeData = await getAuthorizationCode();

    // Step 2: Exchange the code for the provider's access token.
    final tokenData = await getTokenData(
      code: authCodeData.code,
      codeVerifier: authCodeData.codeVerifier,
    );
    final accessToken = tokenData['access_token'] as String?;
    if (accessToken == null) {
      throw Exception('Provider did not return an access token.');
    }

    // Step 3: Send the access token to a backend function to mint a Firebase token.
    final response = await http.post(
      customTokenEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': accessToken}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Backend failed to create custom token. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    final responseBody = jsonDecode(response.body);
    final firebaseToken = responseBody['firebase_token'] as String?;
    if (firebaseToken == null) {
      throw Exception('Backend response did not include a firebase_token.');
    }

    // Step 4: Sign in to Firebase using the fetched custom token.
    await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
  }
}
