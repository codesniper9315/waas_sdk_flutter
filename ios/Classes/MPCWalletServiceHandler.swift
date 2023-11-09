import Flutter
import Foundation
import WaasSdkGo

class MPCWalletServiceHandler: NSObject {
  // The URL of the MPCWalletService when running in "direct mode".
  let mpcWalletServiceWaaSUrl = "https://api.developer.coinbase.com/waas/mpc_wallets"

  // The error code for MPCWalletService-related errors.
  let walletsErr = "E_MPC_WALLET_SERVICE"

  // The error message for calls made without initializing SDK.
  let uninitializedErr = "MPCWalletService must be initialized"

  // The handle to the Go MPCWalletService client.
  var walletsClient: V1MPCWalletServiceProtocol?

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "initialize":
        self.initialize(call, result: result)
        break;
      case "createMPCWallet":
        self.createMPCWallet(call, result: result)
        break;
      case "waitPendingMPCWallet":
        self.waitPendingMPCWallet(call, result: result)
        break;
      case "generateAddress":
        self.generateAddress(call, result: result)
        break;
      case "getAddress":
        self.getAddress(call, result: result)
        break;
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  /**
    * Initializes the MPCWalletService with the given Cloud API Key parameters or proxy URL.
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

    let mpcWalletServiceUrl: String

    if apiKeyName as String == "" || privateKey as String == "" {
      mpcWalletServiceUrl = proxyUrl as String
      insecure = true
    } else {
      mpcWalletServiceUrl = mpcWalletServiceWaaSUrl
      insecure = false
    }

    walletsClient = V1NewMPCWalletService(
      mpcWalletServiceUrl as String,
      apiKeyName as String,
      privateKey as String,
      insecure as Bool,
      &error)

    if error != nil {
      result(FlutterError(code: walletsErr, message: error!.localizedDescription, details: nil))
    } else {
      result("success" as NSString)
    }
  }

  /**
    Creates an MPCWallet with the given parameters.  Resolves with the response on success; rejects with an error
    otherwise.
    */
  private func createMPCWallet(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let parent = args["parent"] as? String,
        let device = args["device"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for createMPCWallet", details: nil))
      return
    }
    
    if self.walletsClient == nil {
      result(FlutterError(code: self.walletsErr, message: self.uninitializedErr, details: nil))
      return
    }

    var response: V1CreateMPCWalletResponse?

    do {
      response = try self.walletsClient?.createMPCWallet(parent as String, device: device as String)
      let res: NSDictionary = [
        "DeviceGroup": response?.deviceGroup as Any,
        "Operation": response?.operation as Any
      ]
      result(res)
    } catch {
      result(FlutterError(code: self.walletsErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Waits for a pending MPCWallet with the given operation name. Resolves with the MPCWallet object on success;
    rejects with an error otherwise.
    */
  private func waitPendingMPCWallet(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let operation = args["operation"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for waitPendingMPCWallet", details: nil))
      return
    }
    
    if self.walletsClient == nil {
      result(FlutterError(code: self.walletsErr, message: self.uninitializedErr, details: nil))
      return
    }

    var mpcWallet: V1MPCWallet?

    do {
      mpcWallet = try self.walletsClient?.waitPendingMPCWallet(operation as String)
      let res: NSDictionary = [
        "Name": mpcWallet?.name as Any,
        "DeviceGroup": mpcWallet?.deviceGroup as Any
      ]
      result(res)
    } catch {
      result(FlutterError(code: self.walletsErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Generates an Address within an MPCWallet. Resolves with the Address object on success;
    rejects with an error otherwise.
    */
  private func generateAddress(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let mpcWallet = args["mpcWallet"] as? String,
        let network = args["network"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for generateAddress", details: nil))
      return
    }
    
    if self.walletsClient == nil {
      result(FlutterError(code: self.walletsErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      let addressData = try self.walletsClient?.generateAddress(mpcWallet as String, network: network as String)
      let res = try JSONSerialization.jsonObject(with: addressData!) as? NSDictionary
      result(res)
    } catch {
      result(FlutterError(code: self.walletsErr, message: error.localizedDescription, details: nil))
    }
  }

  /**
    Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
    */
  private func getAddress(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let name = args["name"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for getAddress", details: nil))
      return
    }
    
    if self.walletsClient == nil {
      result(FlutterError(code: self.walletsErr, message: self.uninitializedErr, details: nil))
      return
    }

    do {
      let addressData = try self.walletsClient?.getAddress(name as String)
      let res = try JSONSerialization.jsonObject(with: addressData!) as? NSDictionary
      result(res)
    } catch {
      result(FlutterError(code: self.walletsErr, message: error.localizedDescription, details: nil))
    }
  }
}