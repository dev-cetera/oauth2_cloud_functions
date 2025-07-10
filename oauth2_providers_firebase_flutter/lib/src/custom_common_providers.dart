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

import 'custom_token_provider.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Implements the custom token sign-in flow for Google.
final class CustomGoogleAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomGoogleAuthProvider({
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
final class CustomGitHubAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomGitHubAuthProvider({
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
final class CustomFacebookAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomFacebookAuthProvider({
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
final class CustomMicrosoftAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomMicrosoftAuthProvider({
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
final class CustomXTwitterAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomXTwitterAuthProvider({
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
final class CustomLinkedInAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomLinkedInAuthProvider({
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
final class CustomTikTokAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomTikTokAuthProvider({
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
final class CustomInstagramAuthProvider extends CustomTokenProvider {
  @override
  final Uri customTokenEndpoint;

  const CustomInstagramAuthProvider({
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
