import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentMethodRepository {
  static const String _baseUrl = 'https://staging.fawaterk.com/api/v2';
  static const String _accessToken =
      'd83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd';

  Future<List<dynamic>> getPaymentMethods() async {
    final Uri url = Uri.parse('$_baseUrl/getPaymentmethods');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          return responseData['data'];
        } else {
          throw Exception(
              'Failed to load payment methods: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to load payment methods. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error occurred while fetching payment methods: $error');
    }
  }

  Future<dynamic> initiatePayment({
    required int paymentMethodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> customerData,
    required Map<String, String> redirectionUrls,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/invoiceInitPay');
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };

    final requestData = {
      'payment_method_id': paymentMethodId,
      'cartTotal': amount.toString(),
      'currency': currency,
      'customer': customerData,
      'redirectionUrls': redirectionUrls,
      'cartItems': [
        {'name': 'Product Name', 'price': amount.toString(), 'quantity': '1'},
      ],
    };

    try {
      final response = await http.post(url,
          headers: headers, body: json.encode(requestData));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'];
        } else {
          throw Exception('Payment failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Payment failed. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error occurred while initiating payment: $error');
    }
  }
}
