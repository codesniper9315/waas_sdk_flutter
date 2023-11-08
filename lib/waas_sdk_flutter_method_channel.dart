import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'waas_sdk_flutter_platform_interface.dart';

/// An implementation of [WaasSdkFlutterPlatform] that uses method channels.
class MethodChannelWaasSdkFlutter extends WaasSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('waas_sdk_flutter');

  @visibleForTesting
  final mpcSDKMethodChannel = const MethodChannel('waas_sdk_flutter/mpc_sdk');

  @visibleForTesting
  final mpcKeyServiceMethodChannel =
      const MethodChannel('waas_sdk_flutter/mpc_key_service');

  @visibleForTesting
  final mpcWalletServiceMethodChannel =
      const MethodChannel('waas_sdk_flutter/mpc_wallet_service');

  @visibleForTesting
  final poolServiceMethodChannel =
      const MethodChannel('waas_sdk_flutter/pool_service');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initMPCSdk(bool isSimulator) async {
    await mpcSDKMethodChannel.invokeMethod<void>(
      'initialize',
      {'isSimulator': isSimulator},
    );
  }

  @override
  Future<void> bootstrapDevice(String passcode) async {
    await mpcSDKMethodChannel.invokeMethod<void>('bootstrapDevice', {
      'passcode': passcode,
    });
  }

  @override
  Future<String> getRegistrationData() async {
    return await mpcSDKMethodChannel.invokeMethod('getRegistrationData');
  }

  @override
  Future<void> computeMPCOperation(String mpcData) async {
    await mpcSDKMethodChannel.invokeMethod('computeMPCOperation', {
      'mpcData': mpcData,
    });
  }

  @override
  Future<dynamic> exportPrivateKeys(
    String mpcKeyExportMetadata,
    String passcode,
  ) async {
    return await mpcSDKMethodChannel.invokeMethod('exportPrivateKeys', {
      'mpcKeyExportMetadata': mpcKeyExportMetadata,
      'passcode': passcode,
    });
  }

  @override
  Future<void> computePrepareDeviceArchiveMPCOperation(
    String mpcData,
    String passcode,
  ) async {
    await mpcSDKMethodChannel.invokeMethod(
      'computePrepareDeviceArchiveMPCOperation',
      {'mpcData': mpcData, 'passcode': passcode},
    );
  }

  @override
  Future<void> computePrepareDeviceBackupMPCOperation(
    String mpcData,
    String passcode,
  ) async {
    return await mpcSDKMethodChannel.invokeMethod(
      'computePrepareDeviceBackupMPCOperation',
      {'mpcData': mpcData, 'passcode': passcode},
    );
  }

  @override
  Future<String> exportDeviceBackup() async {
    return await mpcSDKMethodChannel.invokeMethod('exportDeviceBackup');
  }

  @override
  Future<void> computeAddDeviceMPCOperation(
    String mpcData,
    String passcode,
    String deviceGroup,
  ) async {
    return await mpcSDKMethodChannel.invokeMethod(
      'computeAddDeviceMPCOperation',
      {'mpcData': mpcData, 'passcode': passcode, 'deviceGroup': deviceGroup},
    );
  }

  @override
  Future<void> resetPasscode(String newPasscode) async {
    return await mpcSDKMethodChannel.invokeMethod('resetPasscode', {
      'newPasscode': newPasscode,
    });
  }

  @override
  Future<void> initMPCKeyService(String apiKeyName, String privateKey) async {
    await mpcKeyServiceMethodChannel.invokeMethod(
      'initialize',
      {'apiKeyName': apiKeyName, 'privateKey': privateKey},
    );
  }

  @override
  Future<Map<String, dynamic>> registerDevice() async {
    return await mpcKeyServiceMethodChannel.invokeMethod('registerDevice');
  }

  @override
  Future<dynamic> pollForPendingDeviceGroup(
    String deviceGroup,
    int pollInterval,
  ) async {
    await mpcKeyServiceMethodChannel.invokeMethod(
      'pollForPendingDeviceGroup',
      {'deviceGroup': deviceGroup, 'pollInterval': pollInterval},
    );
  }

  @override
  Future<String> stopPollingPendingDeviceGroup() async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'stopPollingPendingDeviceGroup',
    );
  }

  @override
  Future<String> createSignatureFromTx(
    String parent,
    Map<String, dynamic> transaction,
  ) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'createSignatureFromTx',
      {'parent': parent, 'transaction': transaction},
    );
  }

  @override
  Future<dynamic> pollForPendingSignatures(
    String deviceGroup,
    int pollInterval,
  ) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'pollForPendingSignatures',
      {'deviceGroup': deviceGroup, 'pollInterval': pollInterval},
    );
  }

  @override
  Future<String> stopPollingForPendingSignatures() async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'stopPollingForPendingSignatures',
    );
  }

  @override
  Future<Map<String, dynamic>> waitPendingSignature(String operation) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'waitPendingSignature',
      {'operation': operation},
    );
  }

  @override
  Future<Map<String, dynamic>> getSignedTransaction(
    Map<String, dynamic> transaction,
    Map<String, dynamic> signature,
  ) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'getSignedTransaction',
      {'transaction': transaction, 'signature': signature},
    );
  }

  @override
  Future<Map<String, dynamic>> getDeviceGroup(String name) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'getDeviceGroup',
      {'name': name},
    );
  }

  @override
  Future<String> prepareDeviceArchive(String deviceGroup, String device) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'prepareDeviceArchive',
      {'deviceGroup': deviceGroup, 'device': device},
    );
  }

  @override
  Future<dynamic> pollForPendingDeviceArchives(
    String deviceGroup,
    int pollInterval,
  ) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'pollForPendingDeviceArchives',
      {'deviceGroup': deviceGroup, 'pollInterval': pollInterval},
    );
  }

  @override
  Future<String> stopPollingForPendingDeviceArchives() async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'stopPollingForPendingDeviceArchives',
    );
  }

  @override
  Future<dynamic> pollForPendingDeviceBackups(
    String deviceGroup,
    int pollInterval,
  ) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'pollForPendingDeviceBackups',
      {'deviceGroup': deviceGroup, 'pollInterval': pollInterval},
    );
  }

  @override
  Future<String> stopPollingForPendingDeviceBackups() async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'stopPollingForPendingDeviceBackups',
    );
  }

  @override
  Future<String> prepareDeviceBackup(String deviceGroup, String device) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'prepareDeviceBackup',
      {'deviceGroup': deviceGroup, 'device': device},
    );
  }

  @override
  Future<String> addDevice(String deviceGroup, String device) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'addDevice',
      {'deviceGroup': deviceGroup, 'device': device},
    );
  }

  @override
  Future<dynamic> pollForPendingDevices(
    String deviceGroup,
    int pollInterval,
  ) async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'pollForPendingDevices',
      {'deviceGroup': deviceGroup, 'pollInterval': pollInterval},
    );
  }

  @override
  Future<String> stopPollingForPendingDevices() async {
    return await mpcKeyServiceMethodChannel.invokeMethod(
      'stopPollingForPendingDevices',
    );
  }

  @override
  Future<void> initMPCWalletService(
    String apiKeyName,
    String privateKey,
  ) async {
    return await mpcWalletServiceMethodChannel.invokeMethod(
      'initialize',
      {'apiKeyName': apiKeyName, 'privateKey': privateKey},
    );
  }

  @override
  Future<Map<String, dynamic>> createMPCWallet(
    String parent,
    String device,
  ) async {
    return await mpcWalletServiceMethodChannel.invokeMethod(
      'createMPCWallet',
      {'parent': parent, 'device': device},
    );
  }

  @override
  Future<Map<String, dynamic>> waitPendingMPCWallet(String operation) async {
    return await mpcWalletServiceMethodChannel.invokeMethod(
      'waitPendingMPCWallet',
      {'operation': operation},
    );
  }

  @override
  Future<Map<String, dynamic>> generateAddress(
    String mpcWallet,
    String network,
  ) async {
    return await mpcWalletServiceMethodChannel.invokeMethod(
      'generateAddress',
      {'mpcWallet': mpcWallet, 'network': network},
    );
  }

  @override
  Future<Map<String, dynamic>> getAddress(String name) async {
    return await mpcWalletServiceMethodChannel.invokeMethod(
      'getAddress',
      {'name': name},
    );
  }

  @override
  Future<void> initPoolService(String apiKeyName, String privateKey) async {
    return await poolServiceMethodChannel.invokeMethod(
      'initialize',
      {'apiKeyName': apiKeyName, 'privateKey': privateKey},
    );
  }

  @override
  Future<Map<String, dynamic>> createPool(
    String displayName,
    String poolID,
  ) async {
    return await poolServiceMethodChannel.invokeMethod(
      'createPool',
      {'displayName': displayName, 'poolID': poolID},
    );
  }
}
