import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/card_validator.dart';
import '../models/card_validation.dart';
import 'frames_provider.dart';

/// Card number input field
class CardNumber extends StatefulWidget {
  /// Text style for the input
  final TextStyle? style;

  /// Placeholder text
  final String? placeholder;

  /// Placeholder text color
  final Color? placeholderTextColor;

  /// Whether to show the card scheme icon
  final bool showIcon;

  /// Input decoration
  final InputDecoration? decoration;

  /// Focus node
  final FocusNode? focusNode;

  const CardNumber({
    super.key,
    this.style,
    this.placeholder,
    this.placeholderTextColor,
    this.showIcon = true,
    this.decoration,
    this.focusNode,
  });

  @override
  State<CardNumber> createState() => _CardNumberState();
}

class _CardNumberState extends State<CardNumber> {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  PaymentMethod? _paymentMethod;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final cleaned = text.replaceAll(RegExp(r'\s+'), '');

    // Detect payment method
    final newPaymentMethod = CardValidator.detectPaymentMethod(cleaned);
    if (newPaymentMethod != _paymentMethod) {
      setState(() {
        _paymentMethod = newPaymentMethod;
      });

      // Notify payment method change
      if (newPaymentMethod != PaymentMethod.unknown) {
        final framesState = FramesProvider.of(context);
        framesState?.setPaymentMethod(
          PaymentMethodChanged(
            paymentMethod: newPaymentMethod,
            scheme: CardValidator.getPaymentMethodName(newPaymentMethod),
          ),
        );
      }
    }

    // Check for BIN change (first 6-8 digits)
    final cleanedPrevious = _previousText.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length >= 6 &&
        cleaned.substring(0, 6) !=
            cleanedPrevious.substring(0, cleanedPrevious.length >= 6 ? 6 : 0)) {
      final framesState = FramesProvider.of(context);
      final bin = cleaned.substring(0, cleaned.length >= 8 ? 8 : 6);
      framesState?.setCardBinChanged(bin);
    }

    // Format the card number
    final formattedText = CardValidator.formatCardNumber(
      cleaned,
      _paymentMethod,
    );
    if (formattedText != text) {
      _controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    // Validate
    final validation = CardValidator.validateCardNumber(cleaned);
    final framesState = FramesProvider.of(context);
    framesState?.updateCardNumberValidation(validation, cleaned);

    _previousText = text;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: widget.style,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19),
      ],
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.placeholder ?? 'Card number',
            hintStyle: widget.placeholderTextColor != null
                ? TextStyle(color: widget.placeholderTextColor)
                : null,
            suffixIcon: widget.showIcon ? _buildCardIcon() : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
    );
  }

  Widget? _buildCardIcon() {
    if (_paymentMethod == null || _paymentMethod == PaymentMethod.unknown) {
      return null;
    }

    IconData iconData;
    Color color;

    switch (_paymentMethod!) {
      case PaymentMethod.visa:
        iconData = Icons.credit_card;
        color = Colors.blue;
        break;
      case PaymentMethod.mastercard:
        iconData = Icons.credit_card;
        color = Colors.orange;
        break;
      case PaymentMethod.amex:
        iconData = Icons.credit_card;
        color = Colors.lightBlue;
        break;
      case PaymentMethod.discover:
        iconData = Icons.credit_card;
        color = Colors.orange.shade800;
        break;
      case PaymentMethod.dinersClub:
        iconData = Icons.credit_card;
        color = Colors.blue.shade800;
        break;
      case PaymentMethod.jcb:
        iconData = Icons.credit_card;
        color = Colors.blue;
        break;
      case PaymentMethod.maestro:
        iconData = Icons.credit_card;
        color = Colors.red;
        break;
      default:
        return null;
    }

    return Icon(iconData, color: color);
  }
}
