import 'package:flutter/material.dart';
import 'frames_provider.dart';
import 'frames.dart';

/// Submit button for tokenization
class SubmitButton extends StatelessWidget {
  /// Button title
  final String title;

  /// Button style
  final ButtonStyle? style;

  /// Text style
  final TextStyle? textStyle;

  /// Additional action to perform when pressed (before tokenization)
  final VoidCallback? onPress;

  /// Whether the button is enabled
  final bool? enabled;

  const SubmitButton({
    super.key,
    required this.title,
    this.style,
    this.textStyle,
    this.onPress,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final framesState = FramesProvider.of(context);
    final isTokenizing = context.isFramesTokenizing;

    // Listen to validation state changes
    return ListenableBuilder(
      listenable: framesState!,
      builder: (context, child) {
        final isEnabled =
            enabled ?? framesState.validationState.isValid;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style:
                style ??
                ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            onPressed: isEnabled && !isTokenizing
                ? () {
                    onPress?.call();
                    context.submitFramesCard();
                  }
                : null,
            child: isTokenizing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    title,
                    style:
                        textStyle ??
                        const TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        );
      },
    );
  }
}
