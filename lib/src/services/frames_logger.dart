import 'dart:convert';
import 'package:http/http.dart' as http;

/// Frames logger service for CloudEvents
class FramesLogger {
  static const String liveBaseUrl = 'https://api.checkout.com';
  static const String sandboxBaseUrl = 'https://api.sandbox.checkout.com';

  static const String liveLoggerUrl =
      'https://cloudevents.integration.checkout.com/logging';
  static const String sandboxLoggerUrl =
      'https://cloudevents.integration.sandbox.checkout.com/logging';

  final String publicKey;
  final bool debug;
  final bool enableLogging;

  FramesLogger({
    required this.publicKey,
    this.debug = false,
    this.enableLogging = true,
  });

  /// Get the appropriate logger URL based on the public key
  String get _loggerUrl {
    // Sandbox keys start with 'pk_sbox_' or 'pk_test_'
    if (publicKey.startsWith('pk_sbox_') || publicKey.startsWith('pk_test_')) {
      return sandboxLoggerUrl;
    }
    return liveLoggerUrl;
  }

  /// Get the appropriate base URL
  String get baseUrl {
    if (publicKey.startsWith('pk_sbox_') || publicKey.startsWith('pk_test_')) {
      return sandboxBaseUrl;
    }
    return liveBaseUrl;
  }

  /// Log an event to CloudEvents
  Future<void> logEvent({
    required String eventType,
    required Map<String, dynamic> data,
  }) async {
    if (!enableLogging) return;

    try {
      final event = {
        'specversion': '1.0',
        'type': 'com.checkout.frames.$eventType',
        'source': 'frames-flutter',
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'time': DateTime.now().toIso8601String(),
        'datacontenttype': 'application/json',
        'data': data,
      };

      if (debug) {
        print('[Frames Logger] Logging event: $eventType');
        print('[Frames Logger] Data: ${jsonEncode(event)}');
      }

      final response = await http
          .post(
            Uri.parse(_loggerUrl),
            headers: {
              'Content-Type': 'application/cloudevents+json',
              'Authorization': publicKey,
            },
            body: jsonEncode(event),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              if (debug) {
                print('[Frames Logger] Timeout logging event: $eventType');
              }
              // Return a dummy response on timeout
              return http.Response('', 408);
            },
          );

      if (debug) {
        print('[Frames Logger] Response status: ${response.statusCode}');
      }
    } catch (e) {
      if (debug) {
        print('[Frames Logger] Error logging event: $e');
      }
      // Silently fail - logging should not affect the main flow
    }
  }

  /// Log card validation event
  Future<void> logCardValidation({
    required bool isValid,
    required Map<String, bool> fields,
  }) async {
    await logEvent(
      eventType: 'card-validation',
      data: {
        'is_valid': isValid,
        'fields': fields,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log tokenization attempt
  Future<void> logTokenizationAttempt() async {
    await logEvent(
      eventType: 'tokenization-attempt',
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Log tokenization success
  Future<void> logTokenizationSuccess({
    required String tokenType,
    String? scheme,
  }) async {
    await logEvent(
      eventType: 'tokenization-success',
      data: {
        'token_type': tokenType,
        if (scheme != null) 'scheme': scheme,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log tokenization failure
  Future<void> logTokenizationFailure({
    required String errorType,
    List<String>? errorCodes,
  }) async {
    await logEvent(
      eventType: 'tokenization-failure',
      data: {
        'error_type': errorType,
        if (errorCodes != null) 'error_codes': errorCodes,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log payment method change
  Future<void> logPaymentMethodChange({required String scheme}) async {
    await logEvent(
      eventType: 'payment-method-changed',
      data: {'scheme': scheme, 'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Log BIN lookup
  Future<void> logBinLookup({required String bin}) async {
    await logEvent(
      eventType: 'bin-lookup',
      data: {'bin': bin, 'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Log frames initialization
  Future<void> logFramesInit() async {
    await logEvent(
      eventType: 'frames-init',
      data: {
        'platform': 'flutter',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log frames ready
  Future<void> logFramesReady() async {
    await logEvent(
      eventType: 'frames-ready',
      data: {
        'platform': 'flutter',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
