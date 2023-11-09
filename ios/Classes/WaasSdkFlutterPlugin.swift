import Flutter
import UIKit

public class WaasSdkFlutterPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "waas_sdk_flutter", binaryMessenger: registrar.messenger())
    let instance = WaasSdkFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let mpcSdkChannel = FlutterMethodChannel(name: "waas_sdk_flutter/mpc_sdk", binaryMessenger: registrar.messenger())
    let mpcSdkHandler = MPCSdkHandler()
    mpcSdkChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      mpcSdkHandler.handle(call, result: result)
    })

    let mpcKeyServiceChannel = FlutterMethodChannel(name: "waas_sdk_flutter/mpc_key_service", binaryMessenger: registrar.messenger())
    let mpcKeyServiceHandler = MPCKeyServiceHandler()
    mpcKeyServiceChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      mpcKeyServiceHandler.handle(call, result: result)
    })

    let mpcWalletServiceChannel = FlutterMethodChannel(name: "waas_sdk_flutter/mpc_wallet_service", binaryMessenger: registrar.messenger())
    let mpcWalletServiceHandler = MPCWalletServiceHandler()
    mpcWalletServiceChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      mpcWalletServiceHandler.handle(call, result: result)
    })

    let poolServiceChannel = FlutterMethodChannel(name: "waas_sdk_flutter/pool_service", binaryMessenger: registrar.messenger())
    let poolServiceHandler = PoolServiceHandler()
    poolServiceChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      poolServiceHandler.handle(call, result: result)
    })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
