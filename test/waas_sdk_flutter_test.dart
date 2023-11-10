import 'package:flutter_test/flutter_test.dart';
import 'package:waas_sdk_flutter/waas_sdk_flutter.dart';
import 'package:waas_sdk_flutter/waas_sdk_flutter_platform_interface.dart';
import 'package:waas_sdk_flutter/waas_sdk_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWaasSdkFlutterPlatform
    with MockPlatformInterfaceMixin
    implements WaasSdkFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String> addDevice(String deviceGroup, String device) {
    throw UnimplementedError();
  }

  @override
  Future<void> bootstrapDevice(String passcode) {
    throw UnimplementedError();
  }

  @override
  Future<void> computeAddDeviceMPCOperation(
      String mpcData, String passcode, String deviceGroup) {
    throw UnimplementedError();
  }

  @override
  Future<void> computeMPCOperation(String mpcData) {
    throw UnimplementedError();
  }

  @override
  Future<void> computePrepareDeviceArchiveMPCOperation(
      String mpcData, String passcode) {
    throw UnimplementedError();
  }

  @override
  Future<void> computePrepareDeviceBackupMPCOperation(
      String mpcData, String passcode) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createMPCWallet(String parent, String device) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createPool(String displayName, String poolID) {
    throw UnimplementedError();
  }

  @override
  Future<String> createSignatureFromTx(
      String parent, Map<String, dynamic> transaction) {
    throw UnimplementedError();
  }

  @override
  Future<String> exportDeviceBackup() {
    throw UnimplementedError();
  }

  @override
  Future exportPrivateKeys(String mpcKeyExportMetadata, String passcode) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> generateAddress(
      String mpcWallet, String network) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getAddress(String name) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getDeviceGroup(String name) {
    throw UnimplementedError();
  }

  @override
  Future<String> getRegistrationData() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getSignedTransaction(
      Map<String, dynamic> transaction, Map<String, dynamic> signature) {
    throw UnimplementedError();
  }

  @override
  Future<void> initMPCKeyService(
    String? apiKeyName,
    String? privateKey,
    String? proxyUrl,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> initMPCSdk(bool isSimulator) {
    throw UnimplementedError();
  }

  @override
  Future<void> initMPCWalletService(
    String? apiKeyName,
    String? privateKey,
    String? proxyUrl,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> initPoolService(
    String? apiKeyName,
    String? privateKey,
    String? proxyUrl,
  ) {
    throw UnimplementedError();
  }

  @override
  Future pollForPendingDeviceArchives(String deviceGroup, int pollInterval) {
    throw UnimplementedError();
  }

  @override
  Future pollForPendingDeviceBackups(String deviceGroup, int pollInterval) {
    throw UnimplementedError();
  }

  @override
  Future pollForPendingDeviceGroup(String deviceGroup, int pollInterval) {
    throw UnimplementedError();
  }

  @override
  Future pollForPendingDevices(String deviceGroup, int pollInterval) {
    throw UnimplementedError();
  }

  @override
  Future pollForPendingSignatures(String deviceGroup, int pollInterval) {
    throw UnimplementedError();
  }

  @override
  Future<String> prepareDeviceArchive(String deviceGroup, String device) {
    throw UnimplementedError();
  }

  @override
  Future<String> prepareDeviceBackup(String deviceGroup, String device) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> registerDevice() {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPasscode(String newPasscode) {
    throw UnimplementedError();
  }

  @override
  Future<String> stopPollingForPendingDeviceArchives() {
    throw UnimplementedError();
  }

  @override
  Future<String> stopPollingForPendingDeviceBackups() {
    throw UnimplementedError();
  }

  @override
  Future<String> stopPollingForPendingDevices() {
    throw UnimplementedError();
  }

  @override
  Future<String> stopPollingForPendingSignatures() {
    throw UnimplementedError();
  }

  @override
  Future<String> stopPollingPendingDeviceGroup() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> waitPendingMPCWallet(String operation) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> waitPendingSignature(String operation) {
    throw UnimplementedError();
  }
}

void main() {
  final WaasSdkFlutterPlatform initialPlatform =
      WaasSdkFlutterPlatform.instance;

  test('$MethodChannelWaasSdkFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWaasSdkFlutter>());
  });

  test('getPlatformVersion', () async {
    WaasSdkFlutter waasSdkFlutterPlugin = WaasSdkFlutter();
    MockWaasSdkFlutterPlatform fakePlatform = MockWaasSdkFlutterPlatform();
    WaasSdkFlutterPlatform.instance = fakePlatform;

    expect(await waasSdkFlutterPlugin.getPlatformVersion(), '42');
  });
}
