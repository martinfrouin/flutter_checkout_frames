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

  /// Controller to access Frames methods imperatively (optional)
  /// Use this to submit the card programmatically with your own button
  final FramesController? controller;

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
    this.controller,
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

/// Controller for Frames widget to access methods imperatively
///
/// This controller allows you to programmatically submit the card for tokenization
/// and check validation state from anywhere in your widget tree.
///
/// Example:
/// ```dart
/// final controller = FramesController();
///
/// // Later, in your build method:
/// Frames(
///   controller: controller,
///   config: FramesConfig(publicKey: 'pk_...'),
///   child: YourFormFields(),
/// )
///
/// // And in your custom button:
/// ElevatedButton(
///   onPressed: () => controller.submitCard(),
///   child: Text('Pay'),
/// )
///
/// // Don't forget to dispose when done:
/// @override
/// void dispose() {
///   controller.dispose();
///   super.dispose();
/// }
/// ```
class FramesController {
  FramesWidgetState? _state;
  bool _isDisposed = false;

  void _attach(FramesWidgetState state) {
    _assertNotDisposed();
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError(
        'A FramesController was used after being disposed. '
        'Once you have called dispose() on a FramesController, it can no longer be used.',
      );
    }
  }

  /// Submit card for tokenization
  /// Returns a Future that completes when tokenization finishes
  Future<void> submitCard() async {
    _assertNotDisposed();
    if (_state == null) {
      throw StateError(
        'FramesController is not attached to any Frames widget. '
        'Make sure to pass the controller to the Frames widget.',
      );
    }
    return _state!.submitCard();
  }

  /// Check if the card is currently valid
  bool get isValid {
    _assertNotDisposed();
    return _state?.isValid ?? false;
  }

  /// Check if tokenization is in progress
  bool get isTokenizing {
    _assertNotDisposed();
    return _state?.isTokenizing ?? false;
  }

  /// Dispose the controller
  ///
  /// Call this when the controller is no longer needed to free up resources.
  /// After calling dispose(), the controller can no longer be used.
  void dispose() {
    _state = null;
    _isDisposed = true;
  }
}

class FramesWidgetState extends State<Frames> {
  late FramesState _framesState;
  late CheckoutApiService _apiService;
  bool _isTokenizing = false;
  FramesController? _controller;

  /// Get validation state
  bool get isValid => _framesState.validationState.isValid;

  /// Get tokenization state
  bool get isTokenizing => _isTokenizing;

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

    // Attach controller if provided
    _controller = widget.controller;
    _controller?._attach(this);

    // Log frames initialization
    _apiService.logger.logFramesInit();

    // Log frames ready after next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService.logger.logFramesReady();
    });
  }

  @override
  void dispose() {
    _controller?._detach();
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
