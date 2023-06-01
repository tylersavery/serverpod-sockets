import 'package:flutter_fridge_client/flutter_fridge_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fridge_flutter/src/fridge_container.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

var client = Client('http://localhost:8080/')..connectivityMonitor = FlutterConnectivityMonitor();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FridgeContainer(),
    );
  }
}
