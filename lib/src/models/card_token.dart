/// Card token response
class CardTokenResponse {
  /// The card token
  final String token;

  /// Token type (usually 'card')
  final String type;

  /// Expiry date (MM/YY)
  final String expiryMonth;
  final String expiryYear;

  /// Card scheme (visa, mastercard, etc.)
  final String? scheme;

  /// Last 4 digits of the card
  final String? last4;

  /// BIN (first 6-8 digits)
  final String? bin;

  /// Card type (Credit, Debit, etc.)
  final String? cardType;

  /// Card category (Consumer, Commercial, etc.)
  final String? cardCategory;

  /// Issuer country
  final String? issuerCountry;

  /// Product ID
  final String? productId;

  /// Product type
  final String? productType;

  CardTokenResponse({
    required this.token,
    required this.type,
    required this.expiryMonth,
    required this.expiryYear,
    this.scheme,
    this.last4,
    this.bin,
    this.cardType,
    this.cardCategory,
    this.issuerCountry,
    this.productId,
    this.productType,
  });

  factory CardTokenResponse.fromJson(Map<String, dynamic> json) {
    return CardTokenResponse(
      token: json['token'] as String,
      type: json['type'] as String,
      expiryMonth: json['expiry_month'] as String,
      expiryYear: json['expiry_year'] as String,
      scheme: json['scheme'] as String?,
      last4: json['last4'] as String?,
      bin: json['bin'] as String?,
      cardType: json['card_type'] as String?,
      cardCategory: json['card_category'] as String?,
      issuerCountry: json['issuer_country'] as String?,
      productId: json['product_id'] as String?,
      productType: json['product_type'] as String?,
    );
  }
}

/// Card tokenization failure
class CardTokenizationFailure {
  /// Error type
  final String errorType;

  /// Error codes
  final List<String> errorCodes;

  /// Error message
  final String? message;

  CardTokenizationFailure({
    required this.errorType,
    required this.errorCodes,
    this.message,
  });

  factory CardTokenizationFailure.fromJson(Map<String, dynamic> json) {
    return CardTokenizationFailure(
      errorType: json['error_type'] as String,
      errorCodes: (json['error_codes'] as List?)?.cast<String>() ?? [],
      message: json['message'] as String?,
    );
  }
}
