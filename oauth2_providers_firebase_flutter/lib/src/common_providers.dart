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

import 'package:firebase_auth/firebase_auth.dart' show AuthCredential, OAuthCredential;

import 'oauth2_provider.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Implements the sign-in flow for Google using a standard Firebase OAuth credential.
final class GoogleAuthProvider extends OAuth2Provider {
  const GoogleAuthProvider({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
  });

  @override
  AuthCredential createFirebaseCredential(Map<String, dynamic> tokenData) {
    final idToken = tokenData['id_token'] as String?;
    final accessToken = tokenData['access_token'] as String?;
    if (idToken == null || accessToken == null) {
      throw Exception('Google token response did not include id_token or access_token.');
    }
    return OAuthCredential(
      providerId: 'google.com',
      signInMethod: 'google.com',
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': createRedirectUrl().toString(),
      'scope': 'email profile',
      'state': state,
    });
  }
}

/// Implements the sign-in flow for GitHub using a standard Firebase OAuth credential.
final class GitHubAuthProvider extends OAuth2Provider {
  const GitHubAuthProvider({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
  });

  @override
  AuthCredential createFirebaseCredential(Map<String, dynamic> tokenData) {
    final accessToken = tokenData['access_token'] as String?;
    if (accessToken == null) {
      throw Exception('GitHub token response did not include an access_token.');
    }
    return OAuthCredential(
      providerId: 'github.com',
      signInMethod: 'github.com',
      accessToken: accessToken,
    );
  }

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': clientId,
      'redirect_uri': createRedirectUrl().toString(),
      'scope': 'read:user user:email',
      'state': state,
    });
  }
}

/// Implements the sign-in flow for Facebook using a standard Firebase OAuth credential.
final class FacebookAuthProvider extends OAuth2Provider {
  const FacebookAuthProvider({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
  });

  @override
  AuthCredential createFirebaseCredential(Map<String, dynamic> tokenData) {
    final accessToken = tokenData['access_token'] as String?;
    if (accessToken == null) {
      throw Exception('Facebook token response did not include an access_token.');
    }
    return OAuthCredential(
      providerId: 'facebook.com',
      signInMethod: 'facebook.com',
      accessToken: accessToken,
    );
  }

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('www.facebook.com', '/v19.0/dialog/oauth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': createRedirectUrl().toString(),
      'scope': 'email,public_profile',
      'state': state,
    });
  }
}

/// Implements the sign-in flow for Microsoft using a standard Firebase OAuth credential.
final class MicrosoftAuthProvider extends OAuth2Provider {
  const MicrosoftAuthProvider({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
  });

  @override
  AuthCredential createFirebaseCredential(Map<String, dynamic> tokenData) {
    final accessToken = tokenData['access_token'] as String?;

    if (accessToken == null) {
      throw Exception('Microsoft token response did not include an access_token.');
    }

    final idToken = tokenData['id_token'] as String?;

    if (idToken == null) {
      throw Exception(
        'Microsoft token response did not include an id_token. Ensure "openid" scope is requested.',
      );
    }

    print('DEBUG: Sending this body to backend: $tokenData');

    return OAuthCredential(
      providerId: 'microsoft.com',
      signInMethod: 'microsoft.com',
      accessToken: accessToken,
      idToken: idToken,
    );
  }

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('login.microsoftonline.com', '/common/oauth2/v2.0/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': createRedirectUrl().toString(),
      'response_mode': 'query',
      'scope': 'openid profile email User.Read',
      'state': state,
    });
  }
}

/// Implements the sign-in flow for X (Twitter) using a standard Firebase OAuth credential.
/// It enables PKCE as required by the X API.
final class XTwitterAuthProvider extends OAuth2Provider {
  const XTwitterAuthProvider({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
  }) : super(usePkce: true);

  @override
  AuthCredential createFirebaseCredential(Map<String, dynamic> tokenData) {
    final accessToken = tokenData['access_token'] as String?;
    final secret = tokenData['oauth_token_secret'] as String?;
    if (accessToken == null) {
      throw Exception('X token response did not include an access_token.');
    }
    return OAuthCredential(
      providerId: 'twitter.com',
      signInMethod: 'twitter.com',
      accessToken: accessToken,
      secret: secret,
    );
  }

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('twitter.com', '/i/oauth2/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': createRedirectUrl().toString(),
      'scope': 'tweet.read users.read offline.access',
      'state': state,
      'code_challenge': codeChallenge!,
      'code_challenge_method': 'S256',
    });
  }
}
