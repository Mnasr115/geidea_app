import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geidea_app/business_logic/payment/payment_cubit.dart';
import 'package:geidea_app/business_logic/payment/payment_state.dart';
import 'package:geidea_app/data/payment_repo/payment_repository.dart';
import 'package:geideapay/api/response/order_api_response.dart';
import 'package:geideapay/common/geidea.dart';
import 'package:geideapay/common/server_environments.dart';
import 'package:geideapay/models/address.dart';
import 'package:geideapay/widgets/checkout/checkout_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Demo App',
      home: BlocProvider(
        create: (context) => PaymentMethodCubit(PaymentMethodRepository()),
        child: const PaymentScreen(),
      ),
      debugShowCheckedModeBanner: false,
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

  Future<void> _startGeideaPayment(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _startGeideaPayment(context),
                child: const Text('Start Geidea Payment'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<PaymentMethodCubit>().getPaymentMethods();
                },
                child: const Text('Get Fawaterak Payment Methods'),
              ),
              const SizedBox(height: 20),
              BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                builder: (context, state) {
                  if (state is PaymentMethodLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is PaymentMethodError) {
                    return Text(state.message, style: const TextStyle(color: Colors.red));
                  } else if (state is PaymentMethodLoaded) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = state.paymentMethods[index];
                          return Card(
                            child: ListTile(
                              leading: Image.network(
                                method['logo'],
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                              title: Text(method['name_en']),
                              subtitle: Text(method['name_ar']),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}