import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Login step model for flow diagram and console output
class LoginStep {
  final String message;
  final LoginStepType type;
  final DateTime timestamp;
  final FlowPhase phase;

  LoginStep({
    required this.message,
    required this.type,
    this.phase = FlowPhase.init,
  }) : timestamp = DateTime.now();
}

enum LoginStepType { info, success, warning, error, processing }

enum FlowPhase { init, activeLogin, autoLogin, logout, networkError }

/// SDK Auth service simulating full backend interaction
class AuthService {
  static const String _appId = 'APP_20240322_NEXUS';
  static const String _appKey = 'sk-nexus-9f3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c';

  // ─── Phase 0: SDK Initialization ───────────────────────────────────────────
  static Stream<LoginStep> initSDK() async* {
    yield LoginStep(
      message: '>>> [SDK] Business caller triggered SDK init...',
      type: LoginStepType.info,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message:
          '[SDK-CLIENT] Loading local environment (crypto/storage modules)...',
      type: LoginStepType.processing,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 600));

    yield LoginStep(
      message: '[SDK-CLIENT] Generating deviceID fingerprint...',
      type: LoginStepType.processing,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    final deviceId = _generateDeviceId();
    yield LoginStep(
      message: '[SDK-CLIENT] deviceID: $deviceId',
      type: LoginStepType.info,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-SERVER] POST /sdk/v2/init  { appKey, deviceID }',
      type: LoginStepType.info,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 700));

    yield LoginStep(
      message: '[SDK-SERVER] Validating appKey: ${_appKey.substring(0, 12)}...',
      type: LoginStepType.processing,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[SDK-SERVER] appKey valid ✓  appID: $_appId',
      type: LoginStepType.success,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-SERVER] Binding deviceID to session context...',
      type: LoginStepType.processing,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message: '[SDK-SERVER] Init result: SUCCESS  sessionCtx established ✓',
      type: LoginStepType.success,
      phase: FlowPhase.init,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '>>> [SDK] Initialization complete. Ready to show login UI.',
      type: LoginStepType.success,
      phase: FlowPhase.init,
    );
  }

  // ─── Phase 1: Active Login (password or SMS code) ──────────────────────────
  static Stream<LoginStep> activeLogin(
    String username,
    String password, {
    bool isSmsMode = false,
  }) async* {
    yield LoginStep(
      message:
          '>>> [SDK] Login interface called (type: ${isSmsMode ? "SMS_CODE" : "PASSWORD"})',
      type: LoginStepType.info,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message:
          '[SDK-CLIENT] User input received, starting front-end validation...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    // Encrypt credentials
    yield LoginStep(
      message: '[SDK-CLIENT] Encrypting sensitive credentials...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    final usernameHash = md5.convert(utf8.encode(username)).toString();
    yield LoginStep(
      message:
          '[SDK-CLIENT] Username hash (MD5): ${usernameHash.substring(0, 16)}...',
      type: LoginStepType.info,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    final credHash = sha256.convert(utf8.encode(password)).toString();
    yield LoginStep(
      message:
          '[SDK-CLIENT] Credential hash (SHA-256): ${credHash.substring(0, 20)}...',
      type: LoginStepType.info,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message:
          '[SDK-CLIENT] Applying RSA-2048 encryption with server pubKey...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 600));

    final deviceId = _generateDeviceId();
    yield LoginStep(
      message:
          '[SDK-CLIENT] Payload: { encryptedCredential + deviceID + appKey }',
      type: LoginStepType.info,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-SERVER] POST /sdk/v2/login  TLS 1.3',
      type: LoginStepType.info,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[SDK-SERVER] Decrypting payload with RSA private key...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 600));

    yield LoginStep(
      message: '[SDK-SERVER] Validating business permission scope...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    // Tech center validation
    yield LoginStep(
      message: '[TECH-CENTER] Credential validation request received...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 700));

    yield LoginStep(
      message: '[TECH-CENTER] Querying user database...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[TECH-CENTER] User record found, verifying credential hash...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message: '[TECH-CENTER] Credential verification passed ✓',
      type: LoginStepType.success,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    final userId = _generateUserId(username);
    yield LoginStep(
      message: '[TECH-CENTER] userID assigned: $userId',
      type: LoginStepType.info,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate gameToken
    yield LoginStep(
      message:
          '[SDK-SERVER] Generating gameToken (userID + deviceID + appKey)...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    final gameToken = _generateGameToken(userId, deviceId);
    yield LoginStep(
      message: '[SDK-SERVER] gameToken: ${gameToken.substring(0, 28)}...',
      type: LoginStepType.info,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[GAME-SERVER] Binding gameToken to user/device record...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[GAME-SERVER] Binding confirmed ✓',
      type: LoginStepType.success,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-SERVER] Login success → { userID, gameToken } returned',
      type: LoginStepType.success,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message:
          '[SDK-CLIENT] Encrypting & storing gameToken + userInfo locally...',
      type: LoginStepType.processing,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message: '[SDK-CLIENT] Local cache updated ✓',
      type: LoginStepType.success,
      phase: FlowPhase.activeLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message:
          '>>> [SDK] Login success callback → { userID, gameToken, coreInfo }',
      type: LoginStepType.success,
      phase: FlowPhase.activeLogin,
    );
  }

  // ─── Phase 2: Auto Login via gameToken ─────────────────────────────────────
  static Stream<LoginStep> autoLogin() async* {
    yield LoginStep(
      message: '>>> [SDK] Auto-login interface called (deviceID, appKey)',
      type: LoginStepType.info,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-CLIENT] Reading local cached gameToken...',
      type: LoginStepType.processing,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[SDK-CLIENT] gameToken found, checking validity...',
      type: LoginStepType.info,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message:
          '[SDK-SERVER] POST /sdk/v2/auto-login  { gameToken, deviceID, appKey }',
      type: LoginStepType.info,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 600));

    yield LoginStep(
      message:
          '[SDK-SERVER] Validating gameToken (Token + device + permission)...',
      type: LoginStepType.processing,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 700));

    yield LoginStep(
      message: '[SDK-SERVER] Token validation passed ✓',
      type: LoginStepType.success,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    final userId = 'USR_${_randomHex(8).toUpperCase()}';
    yield LoginStep(
      message: '[TECH-CENTER] userID confirmed: $userId',
      type: LoginStepType.info,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message: '[TECH-CENTER] Syncing auto-login result (userID, gameToken)...',
      type: LoginStepType.processing,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[GAME-SERVER] Business authorization check...',
      type: LoginStepType.processing,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 600));

    yield LoginStep(
      message:
          '[GAME-SERVER] Authorization passed ✓  Fetching game userInfo...',
      type: LoginStepType.success,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message: '[SDK-SERVER] Auto-login success → { userInfo + gameInfo }',
      type: LoginStepType.success,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[END-APP] Received auto-login result + launch params ✓',
      type: LoginStepType.success,
      phase: FlowPhase.autoLogin,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '>>> [SDK] Terminal app initialization complete ✓',
      type: LoginStepType.success,
      phase: FlowPhase.autoLogin,
    );
  }

  // ─── Phase 3: Logout ───────────────────────────────────────────────────────
  static Stream<LoginStep> logout(String userId) async* {
    yield LoginStep(
      message: '>>> [SDK] Logout interface called (userID: $userId)',
      type: LoginStepType.info,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-CLIENT] Preparing logout request...',
      type: LoginStepType.processing,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message: '[SDK-CLIENT] Reading local gameToken for invalidation...',
      type: LoginStepType.processing,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 350));

    yield LoginStep(
      message:
          '[SDK-SERVER] POST /sdk/v2/logout  { userID, gameToken, deviceID }',
      type: LoginStepType.info,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 600));

    yield LoginStep(
      message: '[SDK-SERVER] Revoking gameToken on server side...',
      type: LoginStepType.processing,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[GAME-SERVER] Notifying game server of session termination...',
      type: LoginStepType.processing,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    yield LoginStep(
      message: '[GAME-SERVER] Session terminated ✓  Game state saved.',
      type: LoginStepType.success,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[TECH-CENTER] Invalidating user session token...',
      type: LoginStepType.processing,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 450));

    yield LoginStep(
      message: '[TECH-CENTER] Session invalidated ✓',
      type: LoginStepType.success,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-SERVER] Logout confirmed → all tokens revoked',
      type: LoginStepType.success,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '[SDK-CLIENT] Clearing local cache (gameToken + userInfo)...',
      type: LoginStepType.processing,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield LoginStep(
      message: '[SDK-CLIENT] Local cache cleared ✓',
      type: LoginStepType.success,
      phase: FlowPhase.logout,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    yield LoginStep(
      message: '>>> [SDK] Logout complete. Callback → { success }',
      type: LoginStepType.success,
      phase: FlowPhase.logout,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  static String _generateDeviceId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'DEV_${md5.convert(utf8.encode(now.toString())).toString().substring(0, 12).toUpperCase()}';
  }

  static String _generateUserId(String username) {
    final hash = sha256.convert(utf8.encode(username)).toString();
    return 'USR_${hash.substring(0, 8).toUpperCase()}';
  }

  static String _generateGameToken(String userId, String deviceId) {
    final payload =
        '$userId:$deviceId:${DateTime.now().millisecondsSinceEpoch}';
    final hash = sha256.convert(utf8.encode(payload)).toString();
    return 'GT_${hash.toUpperCase()}';
  }

  static String _randomHex(int length) {
    final now = DateTime.now().microsecondsSinceEpoch;
    return md5
        .convert(utf8.encode(now.toString()))
        .toString()
        .substring(0, length);
  }
}
