import Flutter
import UIKit
import WaasSdkGo

class ApiResponseReceiverWrapper: NSObject, V1ApiResponseReceiverProtocol {
    private let callback: (String?, Error?) -> Void

    init(callback: @escaping (String?, Error?) -> Void) {
        self.callback = callback
        super.init()
    }

    func returnValue(_ data: String?, err: Error?) {
        callback(data, err)
    }
}

func wrapGo(_ callback: @escaping (String?, Error?) -> Void) -> ApiResponseReceiverWrapper {
    return ApiResponseReceiverWrapper(callback: callback)
}

public class MPCSdkHandler {
  // The config to be used for MPCSdk initialization.
  let mpcSdkConfig = "default"

  // The error code for MPC-SDK related errors.
  let mpcSdkErr = "E_MPC_SDK"

  // The error message for calls made without initializing SDK.
  let uninitializedErr = "MPCSdk must be initialized"

  // The handle to the Go MPCSdk class.
  var sdk: V1MPCSdkProtocol?

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "initialize":
        self.initialize(call, result: result)
        break;
      case "bootstrapDevice":
        self.bootstrapDevice(call, result: result)
        break;
      case "resetPasscode":
        self.resetPasscode(call, result: result)
        break;
      case "getRegistrationData":
        self.getRegistrationData(call, result: result)
        break;
      case "computeMPCOperation":
        self.computeMPCOperation(call, result: result)
        break;
      case "computePrepareDeviceArchiveMPCOperation":
        self.computePrepareDeviceArchiveMPCOperation(call, result: result)
        break;
      case "computePrepareDeviceBackupMPCOperation":
        self.computePrepareDeviceBackupMPCOperation(call, result: result)
        break;
      case "computeAddDeviceMPCOperation":
        self.computeAddDeviceMPCOperation(call, result: result)
        break;
      case "exportPrivateKeys":
        self.exportPrivateKeys(call, result: result)
        break;
      case "exportDeviceBackup":
        self.exportDeviceBackup(call, result: result)
        break;
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  /**
    Initializes the MPCSdk  with the given parameters.
    Resolves with the string "success" on success; rejects with an error otherwise.
    */
  private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let isSimulator = args["isSimulator"] as? Bool else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for initialize", details: nil))
      return
    }

    var error: NSError?
    sdk = V1NewMPCSdk(
      mpcSdkConfig,
      isSimulator,
      nil,
      &error
    )

    if let error = error {
      result(FlutterError(code: "MPC_SDK_ERROR", message: error.localizedDescription, details: nil))
    } else {
      result("success")
    }
  }

  /**
    Initializes the Device with the given passcode. The passcode is used to generate a private/public
    key pair that encrypts the backups and archives of the DeviceGroups containing this Device. This function should be called
    exactly once per Device per application, and should be called before the Device is registered with
    GetRegistrationData. It is the responsibility of the application to track whether BootstrapDevice
    has been called for the Device. It resolves with the string "bootstrap complete" on successful initialization;
    or a rejection otherwise.
    */
  private func bootstrapDevice(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let passcode = args["passcode"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for bootstrapDevice", details: nil))
      return
    }

    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.sdk?.bootstrapDevice(passcode as String, receiver: wrapGo(callback))
  }

  /**
    Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
    While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
    PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
    This function can be used when/if the end user forgets their old passcode.
    It resolves with the string "passcode reset" on success; a rejection otherwise.
    */
  private func resetPasscode(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let newPasscode = args["newPasscode"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for resetPasscode", details: nil))
      return
    }

    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      try self.sdk?.resetPasscode(newPasscode as String)
      result("passcode reset")
    } catch {
      result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Returns the data required to call RegisterDeviceAPI on MPCKeyService.
    Resolves with the RegistrationData on success; rejects with an error otherwise.
    */
  private func getRegistrationData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.sdk?.getRegistrationData(wrapGo(callback))
  }

  /**
    Computes an MPC operation, given mpcData from the response of ListMPCOperations API on
    MPCKeyService. This function can be used to compute MPCOperations of types: CreateDeviceGroup and CreateSignature.
    Resolves with the string "success" on success; rejects with an error otherwise.
    */
  private func computeMPCOperation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let mpcData = args["mpcData"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for computeMPCOperation", details: nil))
      return
    }

    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      try self.sdk?.computeMPCOperation(mpcData as String)
      result("success" as NSString)
    } catch {
      result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
    MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
    */
  private func computePrepareDeviceArchiveMPCOperation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let mpcData = args["mpcData"] as? String,
        let passcode = args["passcode"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for computePrepareDeviceArchiveMPCOperation", details: nil))
      return
    }

    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      try self.sdk?.computePrepareDeviceArchiveMPCOperation(mpcData as String, passcode: passcode as String)
      result("success" as NSString)
    } catch {
      result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
    MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
    */
  private func computePrepareDeviceBackupMPCOperation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let mpcData = args["mpcData"] as? String,
        let passcode = args["passcode"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for computePrepareDeviceBackupMPCOperation", details: nil))
      return
    }

    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      try self.sdk?.computePrepareDeviceBackupMPCOperation(mpcData as String, passcode: passcode as String)
      result("success" as NSString)
    } catch {
      result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
    MPCKeyService, passcode of the Device and device backup created with PrepareDeviceBackup operation. Resolves with the string "success" on success; rejects with an error otherwise.
    */
  private func computeAddDeviceMPCOperation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let mpcData = args["mpcData"] as? String,
        let passcode = args["passcode"] as? String,
        let deviceBackup = args["deviceBackup"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for computeAddDeviceMPCOperation", details: nil))
      return
    }

    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      try self.sdk?.computeAddDeviceMPCOperation(
        mpcData as String,
        passcode: passcode as String,
        deviceBackup: deviceBackup as String)
      result("success" as NSString)
    } catch {
      result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
    exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
    rejects with an error otherwise.
    */
  private func exportPrivateKeys(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let mpcKeyExportMetadata = args["mpcKeyExportMetadata"] as? String,
        let passcode = args["passcode"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for exportPrivateKeys", details: nil))
      return
    }

    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      let response = try self.sdk?.exportPrivateKeys(
        mpcKeyExportMetadata as String,
        passcode: passcode as String)
      // swiftlint:disable force_cast
      let res = try JSONSerialization.jsonObject(with: response!) as! NSArray
      // swiftlint:enable force_cast
      result(res)
    } catch {
      result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
    Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
    */
  private func exportDeviceBackup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if self.sdk == nil {
      result(FlutterError(code: self.mpcSdkErr, message: self.uninitializedErr, details: nil))
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcSdkErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.sdk?.exportDeviceBackup(wrapGo(callback))
  }
}
