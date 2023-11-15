import 'package:flutter/material.dart';
import 'package:waas_sdk_flutter/waas_sdk_flutter.dart';
import 'package:waas_sdk_flutter_example/config.dart';

class MPCWalletServicePage extends StatefulWidget {
  const MPCWalletServicePage({super.key});

  @override
  State<MPCWalletServicePage> createState() => _MPCWalletServicePageState();
}

class _MPCWalletServicePageState extends State<MPCWalletServicePage> {
  final WaasSdkFlutter _waasSdkFlutterPlugin = WaasSdkFlutter();

  String deviceGroup = '';
  String walletName = '';
  dynamic ethAddress;

  @override
  void initState() {
    super.initState();

    createWallet();
  }

  void createWallet() async {
    await _waasSdkFlutterPlugin.initMPCSdk(true);
    await _waasSdkFlutterPlugin.initMPCKeyService(
      Config.apiKeyName,
      Config.privateKey,
      '',
    );
    await _waasSdkFlutterPlugin.initMPCWalletService(
      Config.apiKeyName,
      Config.privateKey,
      '',
    );

    final createMPCWalletResponse = await _waasSdkFlutterPlugin.createMPCWallet(
      'pools/9b2b7399-82e3-493a-a7a8-00cb6e4bcb96',
      'devices/28a65cfc-f3f7-4cf2-9b73-3abeafd3b59c',
    );

    setState(() {
      deviceGroup = createMPCWalletResponse['DeviceGroup'];
    });

    await _waasSdkFlutterPlugin.computeMPCWallet(deviceGroup, 'passcode123');

    final walletCreated = await _waasSdkFlutterPlugin
        .waitPendingMPCWallet(createMPCWalletResponse['Operation']);

    setState(() {
      walletName = walletCreated['Name'];
    });

    ethAddress = await _waasSdkFlutterPlugin.generateAddress(
        walletName, 'networks/ethereum-goerli');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('MPCWallet Service Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Device Group: $deviceGroup'),
          Text('Wallet Name: $walletName'),
          Text('Ehtereum Address: $ethAddress'),
        ],
      ),
    );
  }
}
