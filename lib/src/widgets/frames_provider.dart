import 'package:flutter/material.dart';
import '../models/card_validation.dart';
import '../models/frames_config.dart';

/// Frames state provider
class FramesProvider extends InheritedWidget {
  final FramesState state;

  const FramesProvider({super.key, required this.state, required super.child});

  static FramesState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FramesProvider>()?.state;
  }

  @override
  bool updateShouldNotify(FramesProvider oldWidget) {
    return true;
  }
}

/// Frames state
class FramesState extends ChangeNotifier {
  final FramesConfig config;

  // Card data
  String? _cardNumber;
  String? _expiryMonth;
  String? _expiryYear;
  String? _cvv;

  // Validation state
  CardValidationState _validationState = const CardValidationState();

  // Payment method
  PaymentMethod? _paymentMethod;

  // Callbacks
  final void Function(FieldValidation validation, String fieldType)?
  onFrameValidationChanged;
  final void Function(PaymentMethodChanged event)? onPaymentMethodChanged;
  final void Function(CardValidationState state)? onCardValidationChanged;
  final void Function(CardBinInfo binInfo)? onCardBinChanged;

  FramesState({
    required this.config,
    this.onFrameValidationChanged,
    this.onPaymentMethodChanged,
    this.onCardValidationChanged,
    this.onCardBinChanged,
  });

  CardValidationState get validationState => _validationState;
  PaymentMethod? get paymentMethod => _paymentMethod;
  String? get cardNumber => _cardNumber;
  String? get expiryMonth => _expiryMonth;
  String? get expiryYear => _expiryYear;
  String? get cvv => _cvv;

  void updateCardNumberValidation(
    FieldValidation validation,
    String cardNumber,
  ) {
    _cardNumber = cardNumber;
    _validationState = _validationState.copyWith(cardNumber: validation);
    onFrameValidationChanged?.call(validation, 'card-number');
    onCardValidationChanged?.call(_validationState);
    notifyListeners();
  }

  void updateExpiryDateValidation(
    FieldValidation validation,
    String? month,
    String? year,
  ) {
    _expiryMonth = month;
    _expiryYear = year;
    _validationState = _validationState.copyWith(expiryDate: validation);
    onFrameValidationChanged?.call(validation, 'expiry-date');
    onCardValidationChanged?.call(_validationState);
    notifyListeners();
  }

  void updateCvvValidation(FieldValidation validation, String cvv) {
    _cvv = cvv;
    _validationState = _validationState.copyWith(cvv: validation);
    onFrameValidationChanged?.call(validation, 'cvv');
    onCardValidationChanged?.call(_validationState);
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethodChanged event) {
    _paymentMethod = event.paymentMethod;
    onPaymentMethodChanged?.call(event);
    notifyListeners();
  }

  void setCardBinChanged(String bin) {
    onCardBinChanged?.call(CardBinInfo(bin: bin));
    notifyListeners();
  }
}
