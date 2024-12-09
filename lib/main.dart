import 'package:flutter/material.dart';
import 'package:geideapay/api/response/order_api_response.dart';
import 'package:geideapay/common/geidea.dart';
import 'package:geideapay/common/server_environments.dart';
import 'package:geideapay/models/address.dart';
import 'package:geideapay/widgets/checkout/checkout_options.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Geidea Demo App',
      home: PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GeideapayPlugin _plugin = GeideapayPlugin();

  @override
  void initState() {
    super.initState();
    _initializeGeideaPlugin();
  }

  void _initializeGeideaPlugin() {
    _plugin.initialize(
      publicKey: "<YOUR MERCHANT KEY>", 
      apiPassword: "<YOUR MERCHANT PASSWORD>", 
      serverEnvironment: ServerEnvironmentModel.EGY_PROD(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geidea Payment Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _startPayment(context);
          },
          child: const Text('Start Payment'),
        ),
      ),
    );
  }

  Future<void> _startPayment(BuildContext context) async {
    Address billingAddress = Address(
      city: "Cairo", 
      countryCode: "EGY", 
      street: "Tahrir Square",
      postCode: "11511", 
    );

    Address shippingAddress = Address(
      city: "Alexandria",
      countryCode: "EGY",
      street: "Corniche Road",
      postCode: "21519",
    );

    CheckoutOptions checkoutOptions = CheckoutOptions(
      1.00,
      "EGP",
      callbackUrl: "https://website.hook/", 
      returnUrl: "https://returnurl.com",
      lang: "AR", 
      billingAddress: billingAddress,
      shippingAddress: shippingAddress,
      customerEmail: "email@noreply.test",
      merchantReferenceID: "12345",
      paymentOperation: "Pay", 
      showAddress: true, 
      showEmail: true, 
      textColor: const Color(0xffffffff), 
      cardColor: const Color(0xffff4d00), 
      payButtonColor: const Color(0xffff4d00), 
      cancelButtonColor: const Color(0xff878787),
      backgroundColor: const Color(0xff2c2222),
    );

    try {
      OrderApiResponse response = await _plugin.checkout(
        context: context,
        checkoutOptions: checkoutOptions,
      );

      _updateStatus(response.detailedResponseMessage!, response.toString());
    } catch (e) {
      _showMessage(context, "Error: $e");
    }
  }

  void _updateStatus(String status, String responseMessage) {
    debugPrint("Status: $status");
    debugPrint("Response: $responseMessage");
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
