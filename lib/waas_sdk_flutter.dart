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

  Future<void> initMPCKeyService(
    String? apiKeyName,
    String? privateKey,
    String? proxyUrl,
  ) {
    return WaasSdkFlutterPlatform.instance
        .initMPCKeyService(apiKeyName, privateKey, proxyUrl);
  }

  Future<dynamic> registerDevice() {
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

  Future<dynamic> waitPendingSignature(String operation) {
    return WaasSdkFlutterPlatform.instance.waitPendingSignature(operation);
  }

  Future<dynamic> getSignedTransaction(
    Map<String, dynamic> transaction,
    Map<String, dynamic> signature,
  ) {
    return WaasSdkFlutterPlatform.instance
        .getSignedTransaction(transaction, signature);
  }

  Future<dynamic> getDeviceGroup(String name) {
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

  Future<void> initMPCWalletService(
    String? apiKeyName,
    String? privateKey,
    String? proxyUrl,
  ) {
    return WaasSdkFlutterPlatform.instance
        .initMPCWalletService(apiKeyName, privateKey, proxyUrl);
  }

  Future<dynamic> createMPCWallet(String poolID, String device) {
    return WaasSdkFlutterPlatform.instance.createMPCWallet(poolID, device);
  }

  Future<void> computeMPCWallet(String deviceGroup, String passcode) async {
    final pendingDeviceGroup = await pollForPendingDeviceGroup(deviceGroup, 0);

    if (pendingDeviceGroup != null) {
      for (int i = pendingDeviceGroup.length - 1; i >= 0; i--) {
        var deviceGroupOperation = pendingDeviceGroup[i];
        await computeMPCOperation(deviceGroupOperation['MPCData']);
      }
    }

    final pendingDeviceArchiveOperations =
        await pollForPendingDeviceArchives(deviceGroup, 0);

    for (int i = pendingDeviceArchiveOperations.length - 1; i >= 0; i--) {
      var pendingOperation = pendingDeviceArchiveOperations[i];
      await computePrepareDeviceArchiveMPCOperation(
          pendingOperation['MPCData'], passcode);
    }

    return;
  }

  Future<dynamic> waitPendingMPCWallet(String operation) {
    return WaasSdkFlutterPlatform.instance.waitPendingMPCWallet(operation);
  }

  Future<dynamic> generateAddress(
    String mpcWallet,
    String network,
  ) {
    return WaasSdkFlutterPlatform.instance.generateAddress(mpcWallet, network);
  }

  Future<dynamic> getAddress(String name) {
    return WaasSdkFlutterPlatform.instance.getAddress(name);
  }

  Future<void> initPoolService(
    String? apiKeyName,
    String? privateKey,
    String? proxyUrl,
  ) {
    return WaasSdkFlutterPlatform.instance
        .initPoolService(apiKeyName, privateKey, proxyUrl);
  }

  Future<dynamic> createPool(String displayName, String poolID) {
    return WaasSdkFlutterPlatform.instance.createPool(displayName, poolID);
  }
}
