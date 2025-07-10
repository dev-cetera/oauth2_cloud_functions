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

import 'custom_token_client.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Implements the custom token sign-in flow for Google.
final class CustomGoogleAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomGoogleAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  });

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': createRedirectUrl().toString(),
      'scope': 'email profile openid',
      'state': state,
    });
  }
}

/// Implements the custom token sign-in flow for GitHub.
final class CustomGitHubAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomGitHubAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  });

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

/// Implements the custom token sign-in flow for Facebook.
final class CustomFacebookAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomFacebookAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  });

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

/// Implements the custom token sign-in flow for Microsoft.
final class CustomMicrosoftAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomMicrosoftAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  });

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

/// Implements the custom token sign-in flow for X (Twitter).
final class CustomXTwitterAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomXTwitterAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  }) : super(usePkce: true);

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

/// Implements the custom token sign-in flow for LinkedIn.
final class CustomLinkedInAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomLinkedInAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  });

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('www.linkedin.com', '/oauth/v2/authorization', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': createRedirectUrl().toString(),
      'scope': 'openid profile email',
      'state': state,
    });
  }
}

/// Implements the custom token sign-in flow for TikTok.
final class CustomTikTokAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomTikTokAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  });

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('www.tiktok.com', '/v2/auth/authorize/', {
      'client_key': clientId,
      'scope': 'user.info.basic',
      'response_type': 'code',
      'redirect_uri': createRedirectUrl().toString(),
      'state': state,
    });
  }
}

/// Implements the custom token sign-in flow for Instagram.
final class CustomInstagramAuthClient extends CustomTokenClient {
  @override
  final Uri customTokenEndpoint;

  const CustomInstagramAuthClient({
    required super.backendUrl,
    required super.clientId,
    super.redirectUri,
    required super.callbackUrlScheme,
    super.clientSecret,
    required this.customTokenEndpoint,
  });

  @override
  Uri buildAuthUrl({required String state, String? codeChallenge}) {
    return Uri.https('api.instagram.com', '/oauth/authorize', {
      'client_id': clientId,
      'redirect_uri': createRedirectUrl().toString(),
      'scope': 'user_profile,user_media',
      'response_type': 'code',
      'state': state,
    });
  }
}
