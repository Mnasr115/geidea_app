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
import 'package:webview_flutter/webview_flutter.dart';

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
  String? selectedPaymentMethod;
  final GeideapayPlugin _plugin = GeideapayPlugin();
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initializeGeideaPlugin();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          // Handle page loading here
        },
        onPageFinished: (url) {
          _handlePaymentResult(url);
        },
        onWebResourceError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Error: ${error.description}')),
          );
        },
      ));
  }

  void _handlePaymentResult(String url) {
    if (url.contains('success')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!')),
      );
    } else if (url.contains('fail')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Failed!')),
      );
    }
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
                    return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.red)),
                    );
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
                              onTap: () {
                                setState(() {
                                  selectedPaymentMethod = method['name_en'];
                                  final paymentId = method['paymentId'];
                                  final redirectionUrls = {
                                    'successUrl':
                                        'https://yourdomain.com/success',
                                    'failUrl': 'https://yourdomain.com/fail',
                                    'pendingUrl':
                                        'https://yourdomain.com/pending',
                                  };
                            
                                  final customerData = {
                                    'first_name': 'test',
                                    'last_name': 'test',
                                    'email': 'mhmud@gmail.com',
                                    'phone': '01223643717',
                                    'address': 'Cairo',
                                  };
                            
                                  BlocProvider.of<PaymentMethodCubit>(context)
                                      .initiatePayment(
                                    paymentMethodId: paymentId,
                                    amount: 150.0,
                                    currency: 'EGP',
                                    customerData: customerData,
                                    redirectionUrls: redirectionUrls,
                                  );
                                });
                              },
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is PaymentInitiated) {
                    return Expanded(
                      child: WebViewWidget(
                          controller: _controller
                            ..loadRequest(Uri.parse(state.redirectUrl))),
                    );
                  } else if (state is PaymentInitiatedFawry) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Fawry Payment Details',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xff6BB26B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Use the following Fawry code to complete your payment:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            state.fawryCode,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color(0xff6BB26B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'The payment code will expire on: ${state.expireDate}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
