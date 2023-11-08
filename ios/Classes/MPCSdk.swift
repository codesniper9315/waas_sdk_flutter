import Flutter
import UIKit
import WaasSdkGo

public class MPCSdk: NSObject, FlutterPlugin {
    // The config to be used for MPCSdk initialization.
    let mpcSdkConfig = "default"

    // The error code for MPC-SDK related errors.
    let mpcSdkErr = "E_MPC_SDK"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCSdk must be initialized"

    // The handle to the Go MPCSdk class.
    var sdk: V1MPCSdkProtocol?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let mpcSdkChannel = FlutterMethodChannel(name: "waas_sdk_flutter/mpc_sdk", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(MPCSdk(), channel: mpcSdkChannel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "initialize":
                self.initialize(call: call, result: result)
            case "bootstrapDevice":
                self.bootstrapDevice(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(call: FlutterMethodCall, result: FlutterResult) {
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

    private func bootstrapDevice(call: FlutterMethodCall, result: FlutterResult) {
        if let args = call.arguments as? [String: Any],
            let passcode = args["passcode"] as? String {
            result("bootstrap complete")
        } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for 'bootstrapDevice'", details: nil))
        }
    }
}
