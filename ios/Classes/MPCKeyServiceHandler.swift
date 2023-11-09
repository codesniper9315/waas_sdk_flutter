import Flutter
import Foundation
import WaasSdkGo

// swiftlint:disable type_body_length
class MPCKeyServiceHandler: NSObject {
  // The URL of the MPCKeyService when running in "direct mode".
  let mpcKeyServiceWaaSUrl = "https://api.developer.coinbase.com/waas/mpc_keys"

  // The URL of the MPCKeyService when running in "proxy mode".
  let mpcKeyServiceProxyUrl = "http://localhost:8091"

  // The error code for MPCKeyService-related errors.
  let mpcKeyServiceErr = "E_MPC_KEY_SERVICE"

  // The error message for calls made without initializing SDK.
  let uninitializedErr = "MPCKeyService must be initialized"

  // The handle to the Go MPCKeyService client.
  var keyClient: V1MPCKeyServiceProtocol?

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "initialize":
        self.initialize(call, result: result)
        break;
      case "registerDevice":
        self.registerDevice(result: result)
        break;
      case "pollForPendingDeviceGroup":
        self.pollForPendingDeviceGroup(call, result: result)
        break;
      case "stopPollingForPendingDeviceGroup":
        self.stopPollingForPendingDeviceGroup(result: result)
        break;
      case "createSignatureFromTx":
        self.createSignatureFromTx(call, result: result)
        break;
      case "pollForPendingSignatures":
        self.pollForPendingSignatures(call, result: result)
        break;
      case "stopPollingForPendingSignatures":
        self.stopPollingForPendingSignatures(result: result)
        break;
      case "waitPendingSignature":
        self.waitPendingSignature(call, result: result)
        break;
      case "getSignedTransaction":
        self.getSignedTransaction(call, result: result)
        break;
      case "getDeviceGroup":
        self.getDeviceGroup(call, result: result)
        break;
      case "prepareDeviceArchive":
        self.prepareDeviceArchive(call, result: result)
        break;
      case "pollForPendingDeviceArchives":
        self.pollForPendingDeviceArchives(call, result: result)
        break;
      case "stopPollingForPendingDeviceArchives":
        self.stopPollingForPendingDeviceArchives(result: result)
        break;
      case "prepareDeviceBackup":
        self.prepareDeviceBackup(call, result: result)
        break;
      case "pollForPendingDeviceBackups":
        self.pollForPendingDeviceBackups(call, result: result)
        break;
      case "stopPollingForPendingDeviceBackups":
        self.stopPollingForPendingDeviceBackups(result: result)
        break;
      case "addDevice":
        self.addDevice(call, result: result)
        break;
      case "pollForPendingDevices":
        self.pollForPendingDevices(call, result: result)
        break;
      case "stopPollingForPendingDevices":
        self.stopPollingForPendingDevices(result: result)
        break;
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  /**
    * Initializes the MPCKeyService with the given Cloud API Key parameters or proxy URL.
    * Utilizes `proxyUrl` and operates in insecure mode if either `apiKeyName` or `privateKey` is missing.
    * Uses direct WaaS URL with the API keys if both are provided.
    * Resolves with the string "success" on success; rejects with an error otherwise.
    */
  private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let apiKeyName = args["apiKeyName"] as? String,
        let privateKey = args["privateKey"] as? String,
        let proxyUrl = args["proxyUrl"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for initialize", details: nil))
      return
    }
    var error: NSError?

    let insecure: Bool

    let mpcKeyServiceUrl: String

    if apiKeyName as String == "" || privateKey as String == "" {
      mpcKeyServiceUrl = proxyUrl as String
      insecure = true
    } else {
      mpcKeyServiceUrl = mpcKeyServiceWaaSUrl
      insecure = false
    }

    keyClient = V1NewMPCKeyService(
      mpcKeyServiceUrl as String,
      apiKeyName as String,
      privateKey as String,
      insecure as Bool,
      &error)

    if error != nil {
      result(FlutterError(code: mpcKeyServiceErr, message: error!.localizedDescription, details: nil))
    } else {
      result("success" as NSString)
    }
  }

  /**
    Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
    */
  private func registerDevice(result: @escaping FlutterResult) {
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      let device = try self.keyClient?.registerDevice()
      let res: NSDictionary = [
          "Name": device?.name as Any
      ]
      result(res)
    } catch {
      result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
    Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
    stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
    Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
    */
  private func pollForPendingDeviceGroup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Polling occurs asynchronously, so dispatch it.
    let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
      guard let args = call.arguments as? [String: Any],
          let deviceGroup = args["deviceGroup"] as? String,
          let pollInterval = args["pollInterval"] as? NSNumber else {
        result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for pollForPendingDeviceGroup", details: nil))
        return
      }

      if self.keyClient == nil {
        result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
        return
      }

      do {
        let pendingDeviceGroupData = try self.keyClient?.pollPendingDeviceGroup(
          deviceGroup as String,
          pollInterval: pollInterval.int64Value)
        let res = try JSONSerialization.jsonObject(with: pendingDeviceGroupData!) as? NSArray
        result(res)
      } catch {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      }
    })

    DispatchQueue.global().async(execute: dispatchWorkItem)
  }

  /**
    Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
    screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
    Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
    resolves with the empty string otherwise.
    */
  private func stopPollingForPendingDeviceGroup(result: @escaping FlutterResult) {
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.stopPollingPendingDeviceBackups(wrapGo(callback))
  }

  /**
    Initiates an operation to create a Signature resource from the given transaction.
    Resolves with the resource name of the WaaS operation creating the Signature on successful initiation; rejects with an error otherwise.
    */
  private func createSignatureFromTx(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let parent = args["parent"] as? String,
        let transaction = args["transaction"] as? NSDictionary else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for createSignatureFromTx", details: nil))
      return
    }
    
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    do {
      let serializedTx = try JSONSerialization.data(withJSONObject: transaction)
      self.keyClient?.createTxSignature(parent as String, tx: serializedTx, receiver: wrapGo(callback))
    } catch {
      result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
    Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
    stopPollingForPendingSignatures or computeMPCOperaton before another call is made to this
    function. Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
    */
  private func pollForPendingSignatures(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Polling occurs asynchronously, so dispatch it.
    let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
      guard let args = call.arguments as? [String: Any],
          let deviceGroup = args["deviceGroup"] as? String,
          let pollInterval = args["pollInterval"] as? NSNumber else {
        result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for pollForPendingSignatures", details: nil))
        return
      }
      
      if self.keyClient == nil {
        result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
        return
      }

      do {
        let pendingSignaturesData = try self.keyClient?.pollPendingSignatures(
          deviceGroup as String,
          pollInterval: pollInterval.int64Value)
        let res = try JSONSerialization.jsonObject(with: pendingSignaturesData!) as? NSArray
        result(res)
      } catch {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      }
    })

    DispatchQueue.global().async(execute: dispatchWorkItem)
  }

  /**
    Stops polling for pending Signatures This function should be called, e.g., before your app exits,
    screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
    Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
    resolves with the empty string otherwise.
    */
  private func stopPollingForPendingSignatures(result: @escaping FlutterResult) {
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.stopPollingPendingSignatures(wrapGo(callback))
  }

  /**
    Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
    rejects with an error otherwise.
    */
  private func waitPendingSignature(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let operation = args["operation"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for waitPendingSignature", details: nil))
      return
    }

    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    var signature: V1Signature?

    do {
      signature = try self.keyClient?.waitPendingSignature(operation as String)
      let res: NSDictionary = [
        "Name": signature?.name as Any,
        "Payload": signature?.payload as Any,
        "SignedPayload": signature?.signedPayload as Any
      ]
      result(res)
    } catch {
      result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Gets the signed transaction using the given inputs.
    Resolves with the SignedTransaction on success; rejects with an error otherwise.
    */
  private func getSignedTransaction(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let transaction = args["transaction"] as? NSDictionary,
        let signature = args["signature"] as? NSDictionary else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for getSignedTransaction", details: nil))
      return
    }

    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      let serializedTx = try JSONSerialization.data(withJSONObject: transaction)

      let goSignature = V1Signature()
      // swiftlint:disable force_cast
      goSignature.name = signature["Name"] as! String
      goSignature.payload = signature["Payload"] as! String
      goSignature.signedPayload = signature["SignedPayload"] as! String
      // swiftlint:enable force_cast

      let signedTransaction = try self.keyClient?.getSignedTransaction(serializedTx, signature: goSignature)

      let res: NSDictionary = [
        "Transaction": transaction,
        "Signature": signature,
        "RawTransaction": signedTransaction?.rawTransaction as Any,
        "TransactionHash": signedTransaction?.transactionHash as Any
      ]
      result(res)
    } catch {
      result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Gets a DeviceGroup with the given name. Resolves with the DeviceGroup object on success; rejects with an error otherwise.
    */
  private func getDeviceGroup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let name = args["name"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for getDeviceGroup", details: nil))
      return
    }
    
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      let deviceGroupRes = try self.keyClient?.getDeviceGroup(name as String)

      let devices = try JSONSerialization.jsonObject(with: deviceGroupRes!.devices! as Data)

      let res: NSDictionary = [
        "Name": deviceGroupRes?.name as Any,
        "MPCKeyExportMetadata": deviceGroupRes?.mpcKeyExportMetadata as Any,
        "Devices": devices as Any
      ]
      result(res)
    } catch {
      result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Initiates an operation to prepare device archive for MPCKey export. Resolves with the resource name of the WaaS operation creating the Device Archive on successful initiation; rejects with
    an error otherwise.
    */
  private func prepareDeviceArchive(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let device = args["device"] as? String,
        let deviceGroup = args["deviceGroup"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for prepareDeviceArchive", details: nil))
      return
    }
    
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.prepareDeviceArchive(
      deviceGroup as String, device: device as String, receiver: wrapGo(callback))
  }

  /**
    Polls for pending DeviceArchives (i.e. DeviceArchiveOperations), and returns the first set that materializes.
    Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
    stopPollingForDeviceArchives or computePrepareDeviceArchiveMPCOperation) before another call is made to this function.
    Resolves with a list of the pending DeviceArchives on success; rejects with an error otherwise.
    */
  private func pollForPendingDeviceArchives(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let deviceGroup = args["deviceGroup"] as? String,
        let pollInterval = args["pollInterval"] as? NSNumber else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for pollForPendingDeviceArchives", details: nil))
      return
    }
    
    // Polling occurs asynchronously, so dispatch it.
    let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
      if self.keyClient == nil {
        result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
        return
      }

      do {
        let pendingDeviceArchiveData = try self.keyClient?.pollPendingDeviceArchives(
          deviceGroup as String,
          pollInterval: pollInterval.int64Value)
        // swiftlint:disable force_cast
        let res = try JSONSerialization.jsonObject(with: pendingDeviceArchiveData!) as! NSArray
        // swiftlint:enable force_cast
        result(res)
      } catch {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      }
    })

    DispatchQueue.global().async(execute: dispatchWorkItem)
  }

  /**
    Stops polling for pending DeviceArchive operations. This function should be called, e.g., before your app exits,
    screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchiveOperation.
    Resolves with string "stopped polling for pending Device Archives" if polling is stopped successfully; resolves with the empty string otherwise.
    */
  private func stopPollingForPendingDeviceArchives(result: @escaping FlutterResult) {
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.stopPollingPendingDeviceArchives(wrapGo(callback))
  }

  /**
    Initiates an operation to prepare device backup to add a new Device to the DeviceGroup. Resolves with the resource name of the WaaS operation creating the Device Backup on
    successful initiation; rejects with an error otherwise.
    */
  private func prepareDeviceBackup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let device = args["device"] as? String,
        let deviceGroup = args["deviceGroup"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for prepareDeviceBackup", details: nil))
      return
    }
    
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.prepareDeviceBackup(
      deviceGroup as String, device: device as String, receiver: wrapGo(callback))
  }

  /**
    Polls for pending DeviceBackups (i.e. DeviceBackupOperations), and returns the first set that materializes.
    Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
    stopPollingForDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made to this function.
    Resolves with a list of the pending DeviceBackups on success; rejects with an error otherwise.
    */
  private func pollForPendingDeviceBackups(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Polling occurs asynchronously, so dispatch it.
    let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
      guard let args = call.arguments as? [String: Any],
          let deviceGroup = args["deviceGroup"] as? String,
          let pollInterval = args["pollInterval"] as? NSNumber else {
        result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for pollForPendingDeviceBackups", details: nil))
        return
      }
      
      if self.keyClient == nil {
        result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
        return
      }

      do {
        let pendingDeviceBackupData = try self.keyClient?.pollPendingDeviceBackups(
          deviceGroup as String,
          pollInterval: pollInterval.int64Value)
        // swiftlint:disable force_cast
        let res = try JSONSerialization.jsonObject(with: pendingDeviceBackupData!) as! NSArray
        // swiftlint:enable force_cast
        result(res)
      } catch {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      }
    })

    DispatchQueue.global().async(execute: dispatchWorkItem)
  }

  /**
    Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
    screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackupOperation.
    Resolves with string "stopped polling for pending Device Backups" if polling is stopped successfully; resolves with the empty string otherwise.
    */
  private func stopPollingForPendingDeviceBackups(result: @escaping FlutterResult) {
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.stopPollingPendingDeviceBackups(wrapGo(callback))
  }

  /**
    Initiates an operation to add a Device to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
    an error otherwise.
    */
  private func addDevice(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let device = args["device"] as? String,
        let deviceGroup = args["deviceGroup"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for addDevice", details: nil))
      return
    }
    
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.addDevice(
      deviceGroup as String, device: device as String, receiver: wrapGo(callback))
  }

  /**
    Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
    Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
    stopPollingForPendingDevices or computeAddDeviceMPCOperation) before another call is made to this function.
    Resolves with a list of the pending Devices on success; rejects with an error otherwise.
    */
  private func pollForPendingDevices(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Polling occurs asynchronously, so dispatch it.
    let dispatchWorkItem = DispatchWorkItem.init(qos: DispatchQoS.userInitiated, block: {
      guard let args = call.arguments as? [String: Any],
          let deviceGroup = args["deviceGroup"] as? String,
          let pollInterval = args["pollInterval"] as? NSNumber else {
        result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for pollForPendingDevices", details: nil))
        return
      }
      
      if self.keyClient == nil {
        result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
        return
      }

      do {
        let pendingDeviceData = try self.keyClient?.pollPendingDevices(
          deviceGroup as String,
          pollInterval: pollInterval.int64Value)
        // swiftlint:disable force_cast
        let res = try JSONSerialization.jsonObject(with: pendingDeviceData!) as! NSArray
        // swiftlint:enable force_cast
        result(res)
      } catch {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      }
    })

    DispatchQueue.global().async(execute: dispatchWorkItem)
  }

  /**
    Stops polling for pending AddDevice operations. This function should be called, e.g., before your app exits,
    screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending AddDeviceOperation.
    Resolves with string "stopped polling for pending Devices" if polling is stopped successfully; resolves with the empty string otherwise.
    */
  private func stopPollingForPendingDevices(result: @escaping FlutterResult) {
    if self.keyClient == nil {
      result(FlutterError(code: self.mpcKeyServiceErr, message: self.uninitializedErr, details: nil))
      return
    }

    let callback: (String?, Error?) -> Void = { data, error in
      if let error = error {
        result(FlutterError(code: self.mpcKeyServiceErr, message: error.localizedDescription, details: nil))
      } else {
        result(data ?? "")
      }
    }

    self.keyClient?.stopPollingPendingDevices(wrapGo(callback))
  }
}