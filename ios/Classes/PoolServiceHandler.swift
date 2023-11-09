import Flutter
import Foundation
import WaasSdkGo

class PoolServiceHandler: NSObject {
  // The URL of the PoolService when running in "direct mode".
  let poolServiceWaaSUrl = "https://api.developer.coinbase.com/waas/pools"

  // The error code for PoolService-related errors.
  let poolsErr = "E_POOL_SERVICE"

  // The handle to the Go PoolService client.
  var poolsClient: V1PoolServiceProtocol?

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "initialize":
        self.initialize(call, result: result)
        break;
      case "createPool":
        self.createPool(call, result: result)
        break;
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  /**
    * Initializes the PoolService with the given Cloud API Key parameters or proxy URL.
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

    let poolServiceUrl: String

    if apiKeyName as String == "" || privateKey as String == "" {
      poolServiceUrl = proxyUrl as String
      insecure = true
    } else {
      poolServiceUrl = poolServiceWaaSUrl
      insecure = false
    }

    poolsClient = V1NewPoolService(
      poolServiceUrl as String,
      apiKeyName as String,
      privateKey as String,
      insecure as Bool,
      &error)

    if error != nil {
      result(FlutterError(code: poolsErr, message: error!.localizedDescription, details: nil))
    } else {
      result("success" as NSString)
    }
  }

  /**
    Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
    otherwise.
    */
  private func createPool(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
        let displayName = args["displayName"] as? String,
        let poolID = args["poolID"] as? String else {
      result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types for createPool", details: nil))
      return
    }
    
    if self.poolsClient == nil {
      result(FlutterError(code: self.poolsErr, message: "pool service must be initialized", details: nil))
      return
    }

    var pool: V1Pool?

    do {
      try pool = self.poolsClient?.createPool(displayName as String, poolID: poolID as String)
      let res: NSDictionary = [
        "name": pool?.name as Any,
        "displayName": pool?.displayName as Any
      ]
      result(res)
    } catch {
      result(FlutterError(code: self.poolsErr, message: error.localizedDescription, details: nil))
    }
  }
}