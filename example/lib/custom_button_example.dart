import 'package:flutter/material.dart';
import 'package:checkout_frames/checkout_frames.dart';

/// Example demonstrating how to use a custom button with FramesController
class CustomButtonExample extends StatefulWidget {
  const CustomButtonExample({super.key});

  @override
  State<CustomButtonExample> createState() => _CustomButtonExampleState();
}

class _CustomButtonExampleState extends State<CustomButtonExample> {
  // Create a controller to access Frames methods
  final _framesController = FramesController();
  String? _tokenResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text('Custom Button Example'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Using Your Own Button',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Call framesController.submitCard() from any custom button',
              style: TextStyle(fontSize: 14, color: Color(0xFF9898A0)),
            ),
            const SizedBox(height: 30),
            Frames(
              config: FramesConfig(
                publicKey: 'pk_sbox_eo3yb3urja2ozf6ycgn5kuy7ke4',
                debug: true,
              ),
              controller: _framesController, // Pass the controller here
              cardTokenized: (token) {
                setState(() {
                  _tokenResult = token.token;
                  _errorMessage = null;
                });
              },
              cardTokenizationFailed: (error) {
                setState(() {
                  _errorMessage = error.message ?? 'Tokenization failed';
                  _tokenResult = null;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardNumber(
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    placeholderTextColor: const Color(0xFF9898A0),
                    decoration: InputDecoration(
                      hintText: 'Card number',
                      filled: true,
                      fillColor: const Color(0xFF1B1C1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ExpiryDate(
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          placeholderTextColor: const Color(0xFF9898A0),
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            filled: true,
                            fillColor: const Color(0xFF1B1C1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Cvv(
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          placeholderTextColor: const Color(0xFF9898A0),
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            filled: true,
                            fillColor: const Color(0xFF1B1C1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // YOUR CUSTOM BUTTON - Use the controller
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Call submitCard imperatively
                      await _framesController.submitCard();
                    },
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text(
                      'Pay with Custom Button',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Another custom button with different style
                  OutlinedButton(
                    onPressed: () async {
                      if (_framesController.isValid) {
                        await _framesController.submitCard();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields correctly'),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Alternative Payment Button',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results display
            if (_tokenResult != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade900.withAlpha(30),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ Success!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Token: $_tokenResult',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withAlpha(30),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✗ Error',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
