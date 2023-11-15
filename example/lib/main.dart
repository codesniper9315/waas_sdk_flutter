import 'package:flutter/material.dart';
import 'package:waas_sdk_flutter_example/demos/mpc_key_service_page.dart';
import 'package:waas_sdk_flutter_example/demos/mpc_transaction_page.dart';
import 'package:waas_sdk_flutter_example/demos/mpc_wallet_service_page.dart';
import 'package:waas_sdk_flutter_example/demos/pool_service_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/poolService':
            return MaterialPageRoute(
              builder: (_) => const PoolServicePage(),
              settings: settings,
            );
          case '/mpcKeyService':
            return MaterialPageRoute(
              builder: (_) => const MPCKeyServicePage(),
              settings: settings,
            );
          case '/mpcWalletService':
            return MaterialPageRoute(
              builder: (_) => const MPCWalletServicePage(),
              settings: settings,
            );
          case '/mpcTransactionService':
            return MaterialPageRoute(
              builder: (_) => const MPCTransactionPage(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
              settings: settings,
            );
        }
      },
      initialRoute: '/',
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/poolService'),
            title: const Text(
              'Pool Service Demo',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/mpcKeyService'),
            title: const Text(
              'MPCKey Service Demo',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/mpcWalletService'),
            title: const Text(
              'MPCWallet Service Demo',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/mpcTransaction'),
            title: const Text(
              'MPCTransaction Demo',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
