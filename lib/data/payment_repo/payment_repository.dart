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
}
