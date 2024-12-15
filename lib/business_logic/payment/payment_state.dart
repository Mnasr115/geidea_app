abstract class PaymentMethodState {}

class PaymentMethodInitial extends PaymentMethodState {}

class PaymentMethodLoading extends PaymentMethodState {}

class PaymentMethodLoaded extends PaymentMethodState {
  final List<dynamic> paymentMethods;
  PaymentMethodLoaded(this.paymentMethods);
}

class PaymentMethodError extends PaymentMethodState {
  final String message;
  PaymentMethodError(this.message);
}
class PaymentInitiated extends PaymentMethodState {
  final String redirectUrl;
  PaymentInitiated(this.redirectUrl);
}

class PaymentInitiatedFawry extends PaymentMethodState {
  final String fawryCode;
  final String expireDate;
  PaymentInitiatedFawry({required this.fawryCode, required this.expireDate});
}