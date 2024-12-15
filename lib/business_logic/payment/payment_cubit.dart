import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geidea_app/business_logic/payment/payment_state.dart';
import 'package:geidea_app/data/payment_repo/payment_repository.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final PaymentMethodRepository _repository;
  List<dynamic> _paymentMethods = [];

  PaymentMethodCubit(this._repository) : super(PaymentMethodInitial());

  Future<void> getPaymentMethods() async {
    try {
      emit(PaymentMethodLoading());
      final paymentMethods = await _repository.getPaymentMethods();
      _paymentMethods = paymentMethods;
      emit(PaymentMethodLoaded(paymentMethods));
    } catch (error) {
      emit(PaymentMethodError('Error loading payment methods: $error'));
    }
  }

  Future<void> initiatePayment({
    required int paymentMethodId,
    required double amount,
    required String currency,
    required Map<String, String> customerData,
    required Map<String, String> redirectionUrls,
  }) async {
    try {
      emit(PaymentMethodLoading());
      final data = await _repository.initiatePayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: currency,
        customerData: customerData,
        redirectionUrls: redirectionUrls,
      );
      final paymentData = data['payment_data'];

      if (paymentData.containsKey('redirectTo')) {
        final redirectUrl = paymentData['redirectTo'] ?? '';
        emit(PaymentInitiated(redirectUrl));
      } else if (paymentData.containsKey('fawryCode')) {
        final fawryCode = paymentData['fawryCode'];
        final expireDate = paymentData['expireDate'];
        emit(PaymentInitiatedFawry(fawryCode: fawryCode, expireDate: expireDate));
      } else {
        emit(PaymentMethodError('Unexpected payment method response'));
      }
    } catch (error) {
      emit(PaymentMethodError('Error initiating payment: $error'));
    }
  }

  void resetPayment() {
    if (_paymentMethods.isNotEmpty) {
      emit(PaymentMethodLoaded(_paymentMethods));
    } else {
      getPaymentMethods();
    }
  }
}
