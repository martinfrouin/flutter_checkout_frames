import 'package:flutter/material.dart';
import '../models/card_token.dart';
import '../models/card_validation.dart';
import '../models/frames_config.dart';
import '../services/checkout_api_service.dart';
import 'frames_provider.dart';

/// Frames wrapper widget
class Frames extends StatefulWidget {
  /// Frames configuration
  final FramesConfig config;

  /// Child widgets (CardNumber, ExpiryDate, Cvv, SubmitButton, etc.)
  final Widget child;

  /// Called when a field's validation status changes
  final void Function(FieldValidation validation, String fieldType)?
  frameValidationChanged;

  /// Called when a valid payment method is detected
  final void Function(PaymentMethodChanged event)? paymentMethodChanged;

  /// Called when the card validation state changes
  final void Function(CardValidationState state)? cardValidationChanged;

  /// Called after a card is tokenized
  final void Function(CardTokenResponse token)? cardTokenized;

  /// Called after card tokenization fails
  final void Function(CardTokenizationFailure error)? cardTokenizationFailed;

  /// Called when the card BIN changes
  final void Function(CardBinInfo binInfo)? cardBinChanged;

  const Frames({
    super.key,
    required this.config,
    required this.child,
    this.frameValidationChanged,
    this.paymentMethodChanged,
    this.cardValidationChanged,
    this.cardTokenized,
    this.cardTokenizationFailed,
    this.cardBinChanged,
  });

  @override
  State<Frames> createState() => FramesWidgetState();
}

class FramesWidgetState extends State<Frames> {
  late FramesState _framesState;
  late CheckoutApiService _apiService;
  bool _isTokenizing = false;

  @override
  void initState() {
    super.initState();
    _framesState = FramesState(
      config: widget.config,
      onFrameValidationChanged: widget.frameValidationChanged,
      onPaymentMethodChanged: widget.paymentMethodChanged,
      onCardValidationChanged: widget.cardValidationChanged,
      onCardBinChanged: widget.cardBinChanged,
    );
    _apiService = CheckoutApiService(
      publicKey: widget.config.publicKey,
      debug: widget.config.debug,
      enableLogging: widget.config.enableLogging,
    );

    // Log frames initialization
    _apiService.logger.logFramesInit();

    // Log frames ready after next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService.logger.logFramesReady();
    });
  }

  @override
  void dispose() {
    _framesState.dispose();
    super.dispose();
  }

  /// Submit card for tokenization
  Future<void> submitCard() async {
    if (_isTokenizing) return;

    if (!_framesState.validationState.isValid) {
      if (widget.config.debug) {
        print('[Frames Debug] Cannot submit: Card validation failed');
      }
      return;
    }

    final cardNumber = _framesState.cardNumber;
    final expiryMonth = _framesState.expiryMonth;
    final expiryYear = _framesState.expiryYear;
    final cvv = _framesState.cvv;

    if (cardNumber == null ||
        expiryMonth == null ||
        expiryYear == null ||
        cvv == null) {
      if (widget.config.debug) {
        print('[Frames Debug] Cannot submit: Missing card data');
      }
      return;
    }

    setState(() {
      _isTokenizing = true;
    });

    try {
      final token = await _apiService.tokenizeCard(
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        cardholder: widget.config.cardholder,
      );

      widget.cardTokenized?.call(token);
    } on CardTokenizationFailure catch (error) {
      widget.cardTokenizationFailed?.call(error);
    } catch (error) {
      final failure = CardTokenizationFailure(
        errorType: 'unknown_error',
        errorCodes: ['unknown_error'],
        message: error.toString(),
      );
      widget.cardTokenizationFailed?.call(failure);
    } finally {
      if (mounted) {
        setState(() {
          _isTokenizing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FramesProvider(
      state: _framesState,
      child: _SubmitButtonListener(
        onSubmit: submitCard,
        isTokenizing: _isTokenizing,
        child: widget.child,
      ),
    );
  }
}

/// Internal widget to handle submit button presses
class _SubmitButtonListener extends InheritedWidget {
  final VoidCallback onSubmit;
  final bool isTokenizing;

  const _SubmitButtonListener({
    required this.onSubmit,
    required this.isTokenizing,
    required super.child,
  });

  static _SubmitButtonListener? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SubmitButtonListener>();
  }

  @override
  bool updateShouldNotify(_SubmitButtonListener oldWidget) {
    return isTokenizing != oldWidget.isTokenizing;
  }
}

/// Extension to access submit functionality from SubmitButton
extension FramesContext on BuildContext {
  void submitFramesCard() {
    _SubmitButtonListener.of(this)?.onSubmit();
  }

  bool get isFramesTokenizing {
    return _SubmitButtonListener.of(this)?.isTokenizing ?? false;
  }
}
