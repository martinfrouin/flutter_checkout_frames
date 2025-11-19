import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_token.dart';
import '../models/frames_config.dart';

/// Checkout.com API service
class CheckoutApiService {
  static const String _baseUrl = 'https://api.checkout.com';
  static const String _sandboxUrl = 'https://api.sandbox.checkout.com';

  final String publicKey;
  final bool debug;

  CheckoutApiService({required this.publicKey, this.debug = false});

  /// Get the appropriate base URL based on the public key
  String get _apiUrl {
    // Sandbox keys start with 'pk_sbox_' or 'pk_test_'
    if (publicKey.startsWith('pk_sbox_') || publicKey.startsWith('pk_test_')) {
      return _sandboxUrl;
    }
    return _baseUrl;
  }

  /// Tokenize a card
  Future<CardTokenResponse> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    Cardholder? cardholder,
  }) async {
    final url = Uri.parse('$_apiUrl/tokens');

    final body = {
      'type': 'card',
      'number': cardNumber.replaceAll(RegExp(r'\s+'), ''),
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cvv': cvv,
      if (cardholder != null) ...cardholder.toJson(),
    };

    if (debug) {
      print('[Frames Debug] Tokenizing card...');
      print('[Frames Debug] URL: $url');
      print('[Frames Debug] Body: ${jsonEncode(body)}');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': publicKey,
        },
        body: jsonEncode(body),
      );

      if (debug) {
        print('[Frames Debug] Response status: ${response.statusCode}');
        print('[Frames Debug] Response body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return CardTokenResponse.fromJson(jsonResponse);
      } else {
        final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw CardTokenizationFailure.fromJson(errorResponse);
      }
    } catch (e) {
      if (debug) {
        print('[Frames Debug] Error: $e');
      }

      if (e is CardTokenizationFailure) {
        rethrow;
      }

      throw CardTokenizationFailure(
        errorType: 'network_error',
        errorCodes: ['network_error'],
        message: e.toString(),
      );
    }
  }

  /// Get BIN information (first 6-8 digits of card)
  Future<Map<String, dynamic>?> getBinInfo(String bin) async {
    if (bin.length < 6) return null;

    final url = Uri.parse('$_apiUrl/tokens/bin/$bin');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': publicKey},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      if (debug) {
        print('[Frames Debug] BIN lookup error: $e');
      }
    }

    return null;
  }
}
