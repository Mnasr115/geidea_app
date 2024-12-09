import 'package:flutter/material.dart';
import 'package:geidea_app/home_screen.dart';
import 'package:geideapay/geideapay.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = GeideapayPlugin();

  @override
  void initState() {
    super.initState();
    _plugin.initialize(
      publicKey: "<YOUR MERCHANT KEY>",
      apiPassword: "<YOUR MERCHANT PASSWORD>",
      serverEnvironment: ServerEnvironmentModel.EGY_PROD(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Geidea Demo App',
      home: HomeScreen(),
    );
  }
}