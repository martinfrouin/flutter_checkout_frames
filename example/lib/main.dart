import 'package:flutter/material.dart';
import 'package:checkout_frames/checkout_frames.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkout Frames Demo',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _tokenResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text('Checkout Frames Demo'),
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
              'Enter Card Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Frames(
              config: FramesConfig(
                publicKey: "PUBLIC_KEY",
                debug: true,
                cardholder: const Cardholder(
                  name: 'John Doe',
                  billingAddress: BillingAddress(
                    addressLine1: '123 Main St',
                    city: 'London',
                    zip: 'SW1A 1AA',
                    country: 'GB',
                  ),
                ),
              ),
              cardTokenized: (token) {
                setState(() {
                  _tokenResult = token.token;
                  _errorMessage = null;
                });
                _showSuccessDialog(token);
              },
              cardTokenizationFailed: (error) {
                setState(() {
                  _errorMessage = error.message ?? 'Tokenization failed';
                  _tokenResult = null;
                });
                _showErrorDialog(error);
              },
              paymentMethodChanged: (event) {
                print('Payment method changed: ${event.scheme}');
              },
              cardValidationChanged: (state) {
                print('Card validation: ${state.isValid}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardNumber(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFEFFFF),
                    ),
                    placeholderTextColor: const Color(0xFF9898A0),
                    decoration: InputDecoration(
                      hintText: 'Card number',
                      hintStyle: const TextStyle(color: Color(0xFF9898A0)),
                      filled: true,
                      fillColor: const Color(0xFF1B1C1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ExpiryDate(
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFFEFFFF),
                          ),
                          placeholderTextColor: const Color(0xFF9898A0),
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9898A0),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1B1C1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Cvv(
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFFEFFFF),
                          ),
                          placeholderTextColor: const Color(0xFF9898A0),
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9898A0),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1B1C1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SubmitButton(
                    title: 'Pay Now',
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onPress: () {
                      print('Processing payment...');
                    },
                  ),
                ],
              ),
            ),
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
            const SizedBox(height: 30),
            const Divider(color: Color(0xFF3A4452)),
            const SizedBox(height: 20),
            const Text(
              'Test Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            _buildTestCard('Visa', '4242 4242 4242 4242'),
            _buildTestCard('Mastercard', '5436 0310 3060 6378'),
            _buildTestCard('American Express', '3782 822463 10005'),
            const SizedBox(height: 10),
            const Text(
              'Use any future expiry date (e.g., 12/25)\nUse any 3-digit CVV (4 digits for Amex)',
              style: TextStyle(fontSize: 12, color: Color(0xFF9898A0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String name, String number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFF9898A0),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(CardTokenResponse token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Token: ${token.token}'),
            if (token.scheme != null) Text('Scheme: ${token.scheme}'),
            if (token.last4 != null) Text('Last 4: ${token.last4}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(CardTokenizationFailure error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error.message ?? 'Tokenization failed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
