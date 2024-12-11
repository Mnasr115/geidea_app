
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geidea_app/business_logic/payment/payment_state.dart';
import 'package:geidea_app/data/payment_repo/payment_repository.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final PaymentMethodRepository _repository;

  PaymentMethodCubit(this._repository) : super(PaymentMethodInitial());

  Future<void> getPaymentMethods() async {
    try {
      emit(PaymentMethodLoading()); 
      
      final paymentMethods = await _repository.getPaymentMethods();
      
      emit(PaymentMethodLoaded(paymentMethods)); 
    } catch (error) {
      emit(PaymentMethodError('Error loading payment methods: $error')); 
    }
  }
}

