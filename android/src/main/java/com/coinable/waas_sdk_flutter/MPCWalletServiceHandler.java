package com.coinable.waas_sdk_flutter;

import com.coinbase.waassdk.WaasNetwork;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class MPCWalletServiceHandler implements MethodCallHandler {
    // The handle to the Go MPCWalletService client.
    com.coinbase.waassdk.MPCWalletService walletsClient;
    // The error code for MPCWalletService-related errors.
    private final String walletsErr = "E_MPC_WALLET_SERVICE";
    // The error message for calls made without initializing SDK.
    private final String uninitializedErr = "MPCWalletService must be initialized";

    ExecutorService executor;

    MPCWalletServiceHandler() {
        this.executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "initialize":
                initialize(call.argument("apiKeyName"), call.argument("privateKey"), result);
                break;
            case "createMPCWallet":
                createMPCWallet(call.argument("parent"), call.argument("device"), result);
                break;
            case "waitPendingMPCWallet":
                waitPendingMPCWallet(call.argument("operation"), result);
                break;
            case "generateAddress":
                generateAddress(call.argument("mpcWallet"), call.argument("network"), result);
                break;
            case "getAddress":
                getAddress(call.argument("name"), result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean failIfUninitialized(Result result) {
        if (walletsClient == null) {
            result.error(walletsErr, uninitializedErr, null);
            return true;
        }

        return false;
    }

    /**
     * Initializes the MPCWalletService with the given Cloud API Key parameters. Resolves
     * on success; rejects with an error otherwise.
     */
    public void initialize(String apiKeyName, String privateKey, Result result) {
        if (walletsClient != null) {
            result.success(null);
            return;
        }

        try {
            walletsClient = new com.coinbase.waassdk.MPCWalletService(apiKeyName, privateKey, null, executor);
            result.success(null);
        } catch (Exception e) {
            result.error(walletsErr,"initialize MPC wallet service failed : ", e);
        }
    }

    /**
     * Creates an MPCWallet with the given parameters.  Resolves with the response on success; rejects with an error
     * otherwise.
     */
    public void createMPCWallet(String parent, String device, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }

        WaasPromise.resolveMap(walletsClient.createMPCWallet(parent, device), result, (response) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("DeviceGroup", response.getDeviceGroup());
            map.put("Operation", response.getOperation());
            return map;
        }, executor);
    }

    /**
     * Waits for a pending MPCWallet with the given operation name. Resolves with the MPCWallet object on success;
     * rejects with an error otherwise.
     */
    public void waitPendingMPCWallet(String operation, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }

        WaasPromise.resolveMap(walletsClient.waitPendingMPCWallet(operation), result, (wallet) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("Name", wallet.getName());
            map.put("DeviceGroup", wallet.getDeviceGroup());
            return map;
        }, executor);
    }

    /**
     * Generates an Address within an MPCWallet. Resolves with the Address object on success;
     * rejects with an error otherwise.
     */
    public void generateAddress(String mpcWallet, String network, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }

        WaasPromise.resolveMap(walletsClient.generateAddress(mpcWallet, WaasNetwork.fromNetworkString(network)), result, (address) ->
                        Utils.convertJsonToMap(address.toJSON())
                , executor);
    }

    /**
     * Gets an Address with the given name. Resolves with the Address object on success; rejects with an error otherwise.
     */
    public void getAddress(String name, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }

        WaasPromise.resolveMap(walletsClient.getAddress(name), result, (address) ->
                        Utils.convertJsonToMap(address.toJSON())
                , executor);
    }
}
