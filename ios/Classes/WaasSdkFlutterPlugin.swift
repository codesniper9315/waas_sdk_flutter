import Flutter
import UIKit

public class WaasSdkFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "waas_sdk_flutter", binaryMessenger: registrar.messenger())
    let instance = WaasSdkFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // let mpcSdkChannel = FlutterMethodChannel(name: "waas_sdk_flutter/mpc_sdk", binaryMessenger: registrar.messenger())
    // registra.addMethodCallDelegate(MPCSdk(), channel: mpcSdkChannel)
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
