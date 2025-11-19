import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/card_validator.dart';
import '../models/card_validation.dart';
import 'frames_provider.dart';

/// CVV input field
class Cvv extends StatefulWidget {
  /// Text style for the input
  final TextStyle? style;

  /// Placeholder text
  final String? placeholder;

  /// Placeholder text color
  final Color? placeholderTextColor;

  /// Input decoration
  final InputDecoration? decoration;

  /// Focus node
  final FocusNode? focusNode;

  const Cvv({
    super.key,
    this.style,
    this.placeholder,
    this.placeholderTextColor,
    this.decoration,
    this.focusNode,
  });

  @override
  State<Cvv> createState() => _CvvState();
}

class _CvvState extends State<Cvv> {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;

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
    final framesState = FramesProvider.of(context);

    // Get current payment method for validation
    final paymentMethod = framesState?.paymentMethod;

    // Validate
    final validation = CardValidator.validateCvv(
      text,
      paymentMethod: paymentMethod,
    );
    framesState?.updateCvvValidation(validation, text);
  }

  @override
  Widget build(BuildContext context) {
    final framesState = FramesProvider.of(context);
    final maxLength =
        framesState?.paymentMethod == null ||
            framesState?.paymentMethod == PaymentMethod.amex
        ? 4
        : 3;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: widget.style,
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.placeholder ?? 'CVV',
            hintStyle: widget.placeholderTextColor != null
                ? TextStyle(color: widget.placeholderTextColor)
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
    );
  }
}
