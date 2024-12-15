import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geidea_app/business_logic/payment/payment_cubit.dart';
import 'package:geidea_app/business_logic/payment/payment_state.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
          builder: (context, state) {
            if (state is PaymentMethodLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PaymentMethodError) {
              return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)),
              );
            } else if (state is PaymentMethodLoaded) {
              return ListView.builder(
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
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
