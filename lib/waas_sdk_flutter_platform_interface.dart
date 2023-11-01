import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'waas_sdk_flutter_method_channel.dart';

abstract class WaasSdkFlutterPlatform extends PlatformInterface {
  /// Constructs a WaasSdkFlutterPlatform.
  WaasSdkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static WaasSdkFlutterPlatform _instance = MethodChannelWaasSdkFlutter();

  /// The default instance of [WaasSdkFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelWaasSdkFlutter].
  static WaasSdkFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WaasSdkFlutterPlatform] when
  /// they register themselves.
  static set instance(WaasSdkFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> initMPCSdk() {
    throw UnimplementedError('initMPCSdk() has not been implemented');
  }

  Future<void> bootstrapDevice(String passcode) {
    throw UnimplementedError('bootstrapDevice() has not been implemented');
  }

  Future<String> getRegistrationData() {
    throw UnimplementedError('getRegistrationData() has not been implemented');
  }

  Future<void> computeMPCOperation(String mpcData) {
    throw UnimplementedError('computeMPCOperation() has not been implemented');
  }

  Future<dynamic> exportPrivateKeys(
    String mpcKeyExportMetadata,
    String passcode,
  ) {
    throw UnimplementedError('exportPrivateKeys() has not been implemented');
  }

  Future<void> computePrepareDeviceArchiveMPCOperation(
    String mpcData,
    String passcode,
  ) {
    throw UnimplementedError(
        'computePrepareDeviceArchiveMPCOperation() has not been implemented');
  }

  Future<void> computePrepareDeviceBackupMPCOperation(
    String mpcData,
    String passcode,
  ) {
    throw UnimplementedError(
        'computePrepareDeviceBackupMPCOperation() has not been implemented');
  }

  Future<String> exportDeviceBackup() {
    throw UnimplementedError('exportDeviceBackup() has not been implemented');
  }

  Future<void> computeAddDeviceMPCOperation(
    String mpcData,
    String passcode,
    String deviceGroup,
  ) {
    throw UnimplementedError(
        'computeAddDeviceMPCOperation() has not been implemented');
  }

  Future<void> resetPasscode(String newPasscode) {
    throw UnimplementedError('resetPasscode() has not been implemented');
  }

  Future<void> initMPCKeyService(String apiKeyName, String privateKey) {
    throw UnimplementedError('initMPCKeyService() has not been implemented');
  }

  Future<Map<String, dynamic>> registerDevice() {
    throw UnimplementedError('registerDevice() has not been implemented');
  }

  Future<dynamic> pollForPendingDeviceGroup(
    String deviceGroup,
    int pollInterval,
  ) {
    throw UnimplementedError(
        'pollForPendingDeviceGroup() has not been implemented');
  }

  Future<String> stopPollingPendingDeviceGroup() {
    throw UnimplementedError(
        'stopPollingPendingDeviceGroup() has not been implemented');
  }

  Future<String> createSignatureFromTx(
    String parent,
    Map<String, dynamic> transaction,
  ) {
    throw UnimplementedError(
        'createSignatureFromTx() has not been implemented');
  }

  Future<dynamic> pollForPendingSignatures(
    String deviceGroup,
    int pollInterval,
  ) {
    throw UnimplementedError(
        'pollForPendingSignatures() has not been implemented');
  }

  Future<String> stopPollingForPendingSignatures() {
    throw UnimplementedError(
        'stopPollingForPendingSignatures() has not been implemented');
  }

  Future<Map<String, dynamic>> waitPendingSignature(String operation) {
    throw UnimplementedError('waitPendingSignature() has not been implemented');
  }

  Future<Map<String, dynamic>> getSignedTransaction(
    Map<String, dynamic> transaction,
    Map<String, dynamic> signature,
  ) {
    throw UnimplementedError('getSignedTransaction() has not been implemented');
  }

  Future<Map<String, dynamic>> getDeviceGroup(String name) {
    throw UnimplementedError('getDeviceGroup() has not been implemented');
  }

  Future<String> prepareDeviceArchive(String deviceGroup, String device) {
    throw UnimplementedError('prepareDeviceArchive() has not been implemented');
  }

  Future<dynamic> pollForPendingDeviceArchives(
    String deviceGroup,
    int pollInterval,
  ) {
    throw UnimplementedError(
        'pollForPendingDeviceArchives() has not been implemented');
  }

  Future<String> stopPollingForPendingDeviceArchives() {
    throw UnimplementedError(
        'stopPollingForPendingDeviceArchives() has not been implemented');
  }

  Future<dynamic> pollForPendingDeviceBackups(
    String deviceGroup,
    int pollInterval,
  ) {
    throw UnimplementedError(
        'pollForPendingDeviceBackups() has not been implemented');
  }

  Future<String> stopPollingForPendingDeviceBackups() {
    throw UnimplementedError(
        'stopPollingForPendingDeviceBackups() has not been implemented');
  }

  Future<String> prepareDeviceBackup(String deviceGroup, String device) {
    throw UnimplementedError('prepareDeviceBackup() has not been implemented');
  }

  Future<String> addDevice(String deviceGroup, String device) {
    throw UnimplementedError('addDevice() has not been implemented');
  }

  Future<dynamic> pollForPendingDevices(String deviceGroup, int pollInterval) {
    throw UnimplementedError(
        'pollForPendingDevices() has not been implemented');
  }

  Future<String> stopPollingForPendingDevices() {
    throw UnimplementedError(
        'stopPollingForPendingDevices() has not been implemented');
  }

  Future<void> initMPCWalletService(String apiKeyName, String privateKey) {
    throw UnimplementedError('initMPCWalletService() has not been implemented');
  }

  Future<Map<String, dynamic>> createMPCWallet(String parent, String device) {
    throw UnimplementedError('createMPCWallet() has not been implemented');
  }

  Future<Map<String, dynamic>> waitPendingMPCWallet(String operation) {
    throw UnimplementedError('waitPendingMPCWallet() has not been implemented');
  }

  Future<Map<String, dynamic>> generateAddress(
    String mpcWallet,
    String network,
  ) {
    throw UnimplementedError('generateAddress() has not been implemented');
  }

  Future<Map<String, dynamic>> getAddress(String name) {
    throw UnimplementedError('getAddress() has not been implemented');
  }

  Future<void> initPoolService(String apiKeyName, String privateKey) {
    throw UnimplementedError('initPoolService() has not been implemented');
  }

  Future<Map<String, dynamic>> createPool(String displayName, String poolID) {
    throw UnimplementedError('createPool() has not been implemented');
  }
}
