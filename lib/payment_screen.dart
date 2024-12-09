 import 'package:flutter/material.dart';
import 'package:geideapay/api/response/order_api_response.dart';
import 'package:geideapay/common/geidea.dart';
import 'package:geideapay/models/address.dart';
import 'package:geideapay/widgets/checkout/checkout_options.dart';

class PaymentScreen extends StatelessWidget {
  final GeideapayPlugin _plugin = GeideapayPlugin();

  PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define billing and shipping address details
    Address billingAddress = Address(
      city: "Riyadh",
      countryCode: "SAU",
      street: "Street 1",
      postCode: "1000",
    );

    Address shippingAddress = Address(
      city: "Riyadh",
      countryCode: "SAU",
      street: "Street 1",
      postCode: "1000",
    );

    // Set up checkout options
    CheckoutOptions checkoutOptions = CheckoutOptions(
      "123.45" as double,
      "SAR",
      callbackUrl: "https://website.hook/", 
      returnUrl: "https://returnurl.com", 
      lang: "AR",
      billingAddress: billingAddress, 
      shippingAddress: shippingAddress, 
      customerEmail: "email@noreply.test", 
      merchantReferenceID: "1234", 
      paymentOperation: "Pay", 
      showAddress: true, 
      showEmail: true, 
      textColor: const Color(0xffffffff), 
      cardColor: const Color(0xffff4d00), 
      payButtonColor: const Color(0xffff4d00), 
      cancelButtonColor: const Color(0xff878787),
      backgroundColor: const Color(0xff2c2222),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              OrderApiResponse response = await _plugin.checkout(
                  context: context, checkoutOptions: checkoutOptions);

              debugPrint('Response = $response');
              // Handle successful payment response
              _updateStatus(
                  response.detailedResponseMessage!, response.toString());
            } catch (e) {
              debugPrint("Error: $e");
              _showMessage(context,e.toString());
            }
          },
          child: const Text('Proceed to Checkout'),
        ),
      ),
    );
  }

  void _updateStatus(String status, String responseMessage) {
    // Update UI with response status
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