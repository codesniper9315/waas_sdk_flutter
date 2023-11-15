import 'package:flutter/material.dart';
import 'package:waas_sdk_flutter/waas_sdk_flutter.dart';
import 'package:waas_sdk_flutter_example/config.dart';

class PoolServicePage extends StatefulWidget {
  const PoolServicePage({super.key});

  @override
  State<PoolServicePage> createState() => _PoolServicePageState();
}

class _PoolServicePageState extends State<PoolServicePage> {
  final WaasSdkFlutter _waasSdkFlutterPlugin = WaasSdkFlutter();

  bool _isInitialized = false;

  final TextEditingController _poolNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _waasSdkFlutterPlugin
        .initPoolService(
          Config.apiKeyName,
          Config.privateKey,
          '',
        )
        .then((_) => setState(() => _isInitialized = true));
  }

  void _onCreatePoolPressed() {
    String poolName = _poolNameCtrl.text.trim();

    if (poolName.isEmpty) {
      return;
    }

    _waasSdkFlutterPlugin.createPool(poolName, '').then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pool Service Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
        child: Column(
          children: [
            TextFormField(controller: _poolNameCtrl),
            const SizedBox(height: 100),
            if (_isInitialized) ...[
              MaterialButton(
                onPressed: _onCreatePoolPressed,
                child: const Text('Create Pool'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
