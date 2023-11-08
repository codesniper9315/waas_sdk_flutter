import 'waas_sdk_flutter_platform_interface.dart';

class WaasSdkFlutter {
  Future<String?> getPlatformVersion() {
    return WaasSdkFlutterPlatform.instance.getPlatformVersion();
  }

  Future<void> initMPCSdk(bool isSimulator) {
    return WaasSdkFlutterPlatform.instance.initMPCSdk(isSimulator);
  }

  Future<void> bootstrapDevice(String passcode) {
    return WaasSdkFlutterPlatform.instance.bootstrapDevice(passcode);
  }

  Future<String> getRegistrationData() {
    return WaasSdkFlutterPlatform.instance.getRegistrationData();
  }

  Future<void> computeMPCOperation(String mpcData) {
    return WaasSdkFlutterPlatform.instance.computeMPCOperation(mpcData);
  }

  Future<dynamic> exportPrivateKeys(
    String mpcKeyExportMetadata,
    String passcode,
  ) {
    return WaasSdkFlutterPlatform.instance.exportPrivateKeys(
      mpcKeyExportMetadata,
      passcode,
    );
  }

  Future<void> computePrepareDeviceArchiveMPCOperation(
    String mpcData,
    String passcode,
  ) {
    return WaasSdkFlutterPlatform.instance
        .computePrepareDeviceArchiveMPCOperation(mpcData, passcode);
  }

  Future<void> computePrepareDeviceBackupMPCOperation(
    String mpcData,
    String passcode,
  ) {
    return WaasSdkFlutterPlatform.instance
        .computePrepareDeviceBackupMPCOperation(mpcData, passcode);
  }

  Future<String> exportDeviceBackup() {
    return WaasSdkFlutterPlatform.instance.exportDeviceBackup();
  }

  Future<void> computeAddDeviceMPCOperation(
    String mpcData,
    String passcode,
    String deviceGroup,
  ) {
    return WaasSdkFlutterPlatform.instance
        .computeAddDeviceMPCOperation(mpcData, passcode, deviceGroup);
  }

  Future<void> resetPasscode(String newPasscode) {
    return WaasSdkFlutterPlatform.instance.resetPasscode(newPasscode);
  }

  Future<void> initMPCKeyService(String apiKeyName, String privateKey) {
    return WaasSdkFlutterPlatform.instance
        .initMPCKeyService(apiKeyName, privateKey);
  }

  Future<Map<String, dynamic>> registerDevice() {
    return WaasSdkFlutterPlatform.instance.registerDevice();
  }

  Future<dynamic> pollForPendingDeviceGroup(
    String deviceGroup,
    int pollInterval,
  ) {
    return WaasSdkFlutterPlatform.instance
        .pollForPendingDeviceGroup(deviceGroup, pollInterval);
  }

  Future<String> stopPollingPendingDeviceGroup() {
    return WaasSdkFlutterPlatform.instance.stopPollingPendingDeviceGroup();
  }

  Future<String> createSignatureFromTx(
    String parent,
    Map<String, dynamic> transaction,
  ) {
    return WaasSdkFlutterPlatform.instance
        .createSignatureFromTx(parent, transaction);
  }

  Future<dynamic> pollForPendingSignatures(
    String deviceGroup,
    int pollInterval,
  ) {
    return WaasSdkFlutterPlatform.instance
        .pollForPendingSignatures(deviceGroup, pollInterval);
  }

  Future<String> stopPollingForPendingSignatures() {
    return WaasSdkFlutterPlatform.instance.stopPollingForPendingSignatures();
  }

  Future<Map<String, dynamic>> waitPendingSignature(String operation) {
    return WaasSdkFlutterPlatform.instance.waitPendingSignature(operation);
  }

  Future<Map<String, dynamic>> getSignedTransaction(
    Map<String, dynamic> transaction,
    Map<String, dynamic> signature,
  ) {
    return WaasSdkFlutterPlatform.instance
        .getSignedTransaction(transaction, signature);
  }

  Future<Map<String, dynamic>> getDeviceGroup(String name) {
    return WaasSdkFlutterPlatform.instance.getDeviceGroup(name);
  }

  Future<String> prepareDeviceArchive(String deviceGroup, String device) {
    return WaasSdkFlutterPlatform.instance
        .prepareDeviceArchive(deviceGroup, device);
  }

  Future<dynamic> pollForPendingDeviceArchives(
    String deviceGroup,
    int pollInterval,
  ) {
    return WaasSdkFlutterPlatform.instance
        .pollForPendingDeviceArchives(deviceGroup, pollInterval);
  }

  Future<String> stopPollingForPendingDeviceArchives() {
    return WaasSdkFlutterPlatform.instance
        .stopPollingForPendingDeviceArchives();
  }

  Future<dynamic> pollForPendingDeviceBackups(
    String deviceGroup,
    int pollInterval,
  ) {
    return WaasSdkFlutterPlatform.instance
        .pollForPendingDeviceBackups(deviceGroup, pollInterval);
  }

  Future<String> stopPollingForPendingDeviceBackups() {
    return WaasSdkFlutterPlatform.instance.stopPollingForPendingDeviceBackups();
  }

  Future<String> prepareDeviceBackup(String deviceGroup, String device) {
    return WaasSdkFlutterPlatform.instance
        .prepareDeviceBackup(deviceGroup, device);
  }

  Future<String> addDevice(String deviceGroup, String device) {
    return WaasSdkFlutterPlatform.instance.addDevice(deviceGroup, device);
  }

  Future<dynamic> pollForPendingDevices(String deviceGroup, int pollInterval) {
    return WaasSdkFlutterPlatform.instance
        .pollForPendingDevices(deviceGroup, pollInterval);
  }

  Future<String> stopPollingForPendingDevices() {
    return WaasSdkFlutterPlatform.instance.stopPollingForPendingDevices();
  }

  Future<void> initMPCWalletService(String apiKeyName, String privateKey) {
    return WaasSdkFlutterPlatform.instance
        .initMPCWalletService(apiKeyName, privateKey);
  }

  Future<Map<String, dynamic>> createMPCWallet(String parent, String device) {
    return WaasSdkFlutterPlatform.instance.createMPCWallet(parent, device);
  }

  Future<Map<String, dynamic>> waitPendingMPCWallet(String operation) {
    return WaasSdkFlutterPlatform.instance.waitPendingMPCWallet(operation);
  }

  Future<Map<String, dynamic>> generateAddress(
    String mpcWallet,
    String network,
  ) {
    return WaasSdkFlutterPlatform.instance.generateAddress(mpcWallet, network);
  }

  Future<Map<String, dynamic>> getAddress(String name) {
    return WaasSdkFlutterPlatform.instance.getAddress(name);
  }

  Future<void> initPoolService(String apiKeyName, String privateKey) {
    return WaasSdkFlutterPlatform.instance
        .initPoolService(apiKeyName, privateKey);
  }

  Future<Map<String, dynamic>> createPool(String displayName, String poolID) {
    return WaasSdkFlutterPlatform.instance.createPool(displayName, poolID);
  }
}
