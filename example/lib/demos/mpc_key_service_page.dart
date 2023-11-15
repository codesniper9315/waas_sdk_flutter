import 'package:flutter/material.dart';
import 'package:waas_sdk_flutter/waas_sdk_flutter.dart';
import 'package:waas_sdk_flutter_example/config.dart';

class MPCKeyServicePage extends StatefulWidget {
  const MPCKeyServicePage({super.key});

  @override
  State<MPCKeyServicePage> createState() => _MPCKeyServicePageState();
}

class _MPCKeyServicePageState extends State<MPCKeyServicePage> {
  final WaasSdkFlutter _waasSdkFlutterPlugin = WaasSdkFlutter();

  String registrationData = '';
  dynamic registeredDevice;

  @override
  void initState() {
    super.initState();

    _registerDevice();
  }

  void _registerDevice() async {
    try {
      await _waasSdkFlutterPlugin.initMPCSdk(true);
      await _waasSdkFlutterPlugin.initMPCKeyService(
        Config.apiKeyName,
        Config.privateKey,
        '',
      );
      await _waasSdkFlutterPlugin.bootstrapDevice('passcode123');

      registrationData = await _waasSdkFlutterPlugin.getRegistrationData();

      registeredDevice = await _waasSdkFlutterPlugin.registerDevice();

      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('MPCKey Service Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(registrationData),
          Text(registeredDevice.toString()),
        ],
      ),
    );
  }
}
