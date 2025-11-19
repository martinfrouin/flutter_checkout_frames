import 'package:flutter_test/flutter_test.dart';
import 'package:checkout_frames/checkout_frames.dart';

void main() {
  group('CardValidator', () {
    test('validates correct card numbers', () {
      // Visa
      expect(
        CardValidator.validateCardNumber('4242424242424242').isValid,
        true,
      );

      // Mastercard
      expect(
        CardValidator.validateCardNumber('5436031030606378').isValid,
        true,
      );

      // Amex
      expect(
        CardValidator.validateCardNumber('378282246310005').isValid,
        true,
      );
    });

    test('rejects invalid card numbers', () {
      expect(
        CardValidator.validateCardNumber('1234567890123456').isValid,
        false,
      );

      expect(
        CardValidator.validateCardNumber('').isValid,
        false,
      );

      expect(
        CardValidator.validateCardNumber('123').isValid,
        false,
      );
    });

    test('detects payment methods correctly', () {
      expect(
        CardValidator.detectPaymentMethod('4242424242424242'),
        PaymentMethod.visa,
      );

      expect(
        CardValidator.detectPaymentMethod('5436031030606378'),
        PaymentMethod.mastercard,
      );

      expect(
        CardValidator.detectPaymentMethod('378282246310005'),
        PaymentMethod.amex,
      );
    });

    test('validates expiry dates', () {
      // Valid future date
      expect(
        CardValidator.validateExpiryDate('1225').isValid,
        true,
      );

      // Invalid format
      expect(
        CardValidator.validateExpiryDate('13').isValid,
        false,
      );

      // Invalid month
      expect(
        CardValidator.validateExpiryDate('1325').isValid,
        false,
      );

      // Expired date
      expect(
        CardValidator.validateExpiryDate('0120').isValid,
        false,
      );
    });

    test('validates CVV', () {
      // Valid 3-digit CVV
      expect(
        CardValidator.validateCvv('123').isValid,
        true,
      );

      // Valid 4-digit CVV for Amex
      expect(
        CardValidator.validateCvv('1234', paymentMethod: PaymentMethod.amex)
            .isValid,
        true,
      );

      // Invalid - empty
      expect(
        CardValidator.validateCvv('').isValid,
        false,
      );

      // Invalid - wrong length
      expect(
        CardValidator.validateCvv('12').isValid,
        false,
      );
    });

    test('formats card numbers correctly', () {
      // Visa/Mastercard - 4-4-4-4 format
      expect(
        CardValidator.formatCardNumber('4242424242424242', PaymentMethod.visa),
        '4242 4242 4242 4242',
      );

      // Amex - 4-6-5 format
      expect(
        CardValidator.formatCardNumber('378282246310005', PaymentMethod.amex),
        '3782 822463 10005',
      );
    });

    test('formats expiry dates correctly', () {
      expect(
        CardValidator.formatExpiryDate('1225'),
        '12/25',
      );

      expect(
        CardValidator.formatExpiryDate('12'),
        '12',
      );

      expect(
        CardValidator.formatExpiryDate(''),
        '',
      );
    });
  });

  group('FramesConfig', () {
    test('creates config with required fields', () {
      final config = FramesConfig(
        publicKey: 'pk_sbox_test',
        debug: true,
      );

      expect(config.publicKey, 'pk_sbox_test');
      expect(config.debug, true);
      expect(config.enableLogging, true); // Default value
      expect(config.cardholder, null);
    });

    test('creates config with logging disabled', () {
      final config = FramesConfig(
        publicKey: 'pk_sbox_test',
        enableLogging: false,
      );

      expect(config.enableLogging, false);
    });

    test('creates config with cardholder info', () {
      final config = FramesConfig(
        publicKey: 'pk_sbox_test',
        cardholder: const Cardholder(
          name: 'John Doe',
          phone: '+33612345678',
          billingAddress: BillingAddress(
            addressLine1: '123 Rue de la Paix',
            city: 'Paris',
            zip: '75001',
            country: 'FR',
          ),
        ),
      );

      expect(config.cardholder?.name, 'John Doe');
      expect(config.cardholder?.phone, '+33612345678');
      expect(config.cardholder?.billingAddress?.city, 'Paris');
    });
  });

  group('CardValidationState', () {
    test('reports invalid when fields are invalid', () {
      const state = CardValidationState();
      expect(state.isValid, false);
    });

    test('reports valid when all fields are valid', () {
      const state = CardValidationState(
        cardNumber: FieldValidation(isValid: true),
        expiryDate: FieldValidation(isValid: true),
        cvv: FieldValidation(isValid: true),
      );
      expect(state.isValid, true);
    });

    test('updates individual fields', () {
      const state = CardValidationState();
      final newState = state.copyWith(
        cardNumber: const FieldValidation(isValid: true),
      );

      expect(newState.cardNumber.isValid, true);
      expect(newState.expiryDate.isValid, false);
      expect(newState.cvv.isValid, false);
    });
  });
}
