import '../models/card_validation.dart';

/// Card validation utilities
class CardValidator {
  /// Luhn algorithm for card number validation
  static bool luhnCheck(String cardNumber) {
    if (cardNumber.isEmpty) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.tryParse(cardNumber[i]) ?? 0;

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validate card number
  static FieldValidation validateCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty) {
      return FieldValidation.invalid('Card number is required');
    }

    if (cleaned.length < 13 || cleaned.length > 19) {
      return FieldValidation.invalid('Invalid card number length');
    }

    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return FieldValidation.invalid('Card number must contain only digits');
    }

    if (!luhnCheck(cleaned)) {
      return FieldValidation.invalid('Invalid card number');
    }

    return FieldValidation.valid;
  }

  /// Validate expiry date (MM/YY format)
  static FieldValidation validateExpiryDate(String expiryDate) {
    final cleaned = expiryDate.replaceAll(RegExp(r'\s+|/'), '');

    if (cleaned.isEmpty) {
      return FieldValidation.invalid('Expiry date is required');
    }

    if (cleaned.length != 4) {
      return FieldValidation.invalid('Invalid expiry date format');
    }

    final month = int.tryParse(cleaned.substring(0, 2));
    final year = int.tryParse(cleaned.substring(2, 4));

    if (month == null || year == null) {
      return FieldValidation.invalid('Invalid expiry date');
    }

    if (month < 1 || month > 12) {
      return FieldValidation.invalid('Invalid month');
    }

    // Check if card is expired
    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return FieldValidation.invalid('Card has expired');
    }

    return FieldValidation.valid;
  }

  /// Validate CVV
  static FieldValidation validateCvv(String cvv, {PaymentMethod? paymentMethod}) {
    final cleaned = cvv.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty) {
      return FieldValidation.invalid('CVV is required');
    }

    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return FieldValidation.invalid('CVV must contain only digits');
    }

    // American Express has 4-digit CVV, others have 3
    final expectedLength = paymentMethod == PaymentMethod.amex ? 4 : 3;

    if (cleaned.length != expectedLength) {
      return FieldValidation.invalid('Invalid CVV length');
    }

    return FieldValidation.valid;
  }

  /// Detect payment method from card number
  static PaymentMethod detectPaymentMethod(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty) return PaymentMethod.unknown;

    // Visa: starts with 4
    if (RegExp(r'^4').hasMatch(cleaned)) {
      return PaymentMethod.visa;
    }

    // Mastercard: starts with 51-55 or 2221-2720
    if (RegExp(r'^5[1-5]').hasMatch(cleaned) ||
        RegExp(r'^2(22[1-9]|2[3-9]\d|[3-6]\d{2}|7[01]\d|720)').hasMatch(cleaned)) {
      return PaymentMethod.mastercard;
    }

    // American Express: starts with 34 or 37
    if (RegExp(r'^3[47]').hasMatch(cleaned)) {
      return PaymentMethod.amex;
    }

    // Discover: starts with 6011, 622126-622925, 644-649, or 65
    if (RegExp(r'^(6011|65|64[4-9]|622)').hasMatch(cleaned)) {
      return PaymentMethod.discover;
    }

    // Diners Club: starts with 36 or 38 or 300-305
    if (RegExp(r'^(36|38|30[0-5])').hasMatch(cleaned)) {
      return PaymentMethod.dinersClub;
    }

    // JCB: starts with 35
    if (RegExp(r'^35').hasMatch(cleaned)) {
      return PaymentMethod.jcb;
    }

    // Maestro: starts with 50, 56-58, 6
    if (RegExp(r'^(5[0678]|6[^011])').hasMatch(cleaned)) {
      return PaymentMethod.maestro;
    }

    return PaymentMethod.unknown;
  }

  /// Get payment method name
  static String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.visa:
        return 'Visa';
      case PaymentMethod.mastercard:
        return 'Mastercard';
      case PaymentMethod.amex:
        return 'American Express';
      case PaymentMethod.discover:
        return 'Discover';
      case PaymentMethod.dinersClub:
        return 'Diners Club';
      case PaymentMethod.jcb:
        return 'JCB';
      case PaymentMethod.maestro:
        return 'Maestro';
      case PaymentMethod.unknown:
        return 'Unknown';
    }
  }

  /// Format card number with spaces
  static String formatCardNumber(String cardNumber, PaymentMethod? paymentMethod) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty) return '';

    // American Express: 4-6-5 format
    if (paymentMethod == PaymentMethod.amex) {
      final buffer = StringBuffer();
      for (int i = 0; i < cleaned.length; i++) {
        if (i == 4 || i == 10) {
          buffer.write(' ');
        }
        buffer.write(cleaned[i]);
      }
      return buffer.toString();
    }

    // Default: 4-4-4-4 format
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// Format expiry date as MM/YY
  static String formatExpiryDate(String expiryDate) {
    final cleaned = expiryDate.replaceAll(RegExp(r'\s+|/'), '');

    if (cleaned.isEmpty) return '';
    if (cleaned.length <= 2) return cleaned;

    return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
  }
}
