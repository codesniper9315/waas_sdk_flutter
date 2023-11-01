package com.coinable.waas_sdk_flutter;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** WaasSdkFlutterPlugin */
public class WaasSdkFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private Context applicationContext;

  private MethodChannel channel;
  private MethodChannel mpcSdkChannel;
  private MethodChannel mpcKeyServiceChannel;
  private MethodChannel poolServiceChannel;
  private MethodChannel mpcWalletServiceChannel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.applicationContext = flutterPluginBinding.getApplicationContext();

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "waas_sdk_flutter");
    channel.setMethodCallHandler(this);

    mpcSdkChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "waas_sdk_flutter/mpc_sdk");
    mpcSdkChannel.setMethodCallHandler(new MPCSdkHandler(applicationContext));

    mpcKeyServiceChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "waas_sdk_flutter/mpc_key_service");
    mpcKeyServiceChannel.setMethodCallHandler(new MPCKeyServiceHandler());

    poolServiceChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "waas_sdk_flutter/pool_service");
    poolServiceChannel.setMethodCallHandler(new PoolServiceHandler());

    mpcWalletServiceChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "waas_sdk_flutter/mpc_wallet_service");
    mpcWalletServiceChannel.setMethodCallHandler(new MPCWalletServiceHandler());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
