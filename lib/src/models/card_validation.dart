/// Field validation state
class FieldValidation {
  /// Whether the field is valid
  final bool isValid;

  /// Error message if invalid
  final String? errorMessage;

  const FieldValidation({
    required this.isValid,
    this.errorMessage,
  });

  static const valid = FieldValidation(isValid: true);

  static FieldValidation invalid(String message) {
    return FieldValidation(isValid: false, errorMessage: message);
  }
}

/// Card validation state
class CardValidationState {
  /// Card number validation
  final FieldValidation cardNumber;

  /// Expiry date validation
  final FieldValidation expiryDate;

  /// CVV validation
  final FieldValidation cvv;

  /// Whether all fields are valid
  bool get isValid => cardNumber.isValid && expiryDate.isValid && cvv.isValid;

  const CardValidationState({
    this.cardNumber = const FieldValidation(isValid: false),
    this.expiryDate = const FieldValidation(isValid: false),
    this.cvv = const FieldValidation(isValid: false),
  });

  CardValidationState copyWith({
    FieldValidation? cardNumber,
    FieldValidation? expiryDate,
    FieldValidation? cvv,
  }) {
    return CardValidationState(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
    );
  }
}

/// Payment method type
enum PaymentMethod {
  visa,
  mastercard,
  amex,
  discover,
  dinersClub,
  jcb,
  maestro,
  unknown,
}

/// Payment method change event
class PaymentMethodChanged {
  /// Detected payment method
  final PaymentMethod paymentMethod;

  /// Card scheme name
  final String scheme;

  const PaymentMethodChanged({
    required this.paymentMethod,
    required this.scheme,
  });
}

/// Card BIN information
class CardBinInfo {
  /// First 6-8 digits of the card
  final String bin;

  /// Card scheme
  final String? scheme;

  /// Card type
  final String? cardType;

  const CardBinInfo({
    required this.bin,
    this.scheme,
    this.cardType,
  });
}
