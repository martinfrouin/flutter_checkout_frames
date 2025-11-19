import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/card_validator.dart';
import 'frames_provider.dart';

/// Expiry date input field (MM/YY)
class ExpiryDate extends StatefulWidget {
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

  const ExpiryDate({
    super.key,
    this.style,
    this.placeholder,
    this.placeholderTextColor,
    this.decoration,
    this.focusNode,
  });

  @override
  State<ExpiryDate> createState() => _ExpiryDateState();
}

class _ExpiryDateState extends State<ExpiryDate> {
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
    final cleaned = text.replaceAll(RegExp(r'\s+|/'), '');

    // Format as MM/YY
    final formattedText = CardValidator.formatExpiryDate(cleaned);
    if (formattedText != text) {
      _controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    // Validate
    final validation = CardValidator.validateExpiryDate(cleaned);
    final framesState = FramesProvider.of(context);

    // Extract month and year
    String? month;
    String? year;
    if (cleaned.length >= 2) {
      month = cleaned.substring(0, 2);
    }
    if (cleaned.length == 4) {
      year = cleaned.substring(2, 4);
    }

    framesState?.updateExpiryDateValidation(validation, month, year);
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
        LengthLimitingTextInputFormatter(4),
      ],
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.placeholder ?? 'MM/YY',
            hintStyle: widget.placeholderTextColor != null
                ? TextStyle(color: widget.placeholderTextColor)
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
    );
  }
}
