package com.coinable.waas_sdk_flutter;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.coinbase.waassdk.WaasException;
import com.waassdkinternal.v1.Device;
import com.waassdkinternal.v1.Signature;
import com.waassdkinternal.v1.SignedTransaction;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.Map;

public class MPCKeyServiceHandler implements MethodCallHandler {
    // The error code for MPCKeyService-related errors.
    private String mpcKeyServiceErr = "E_MPC_KEY_SERVICE";

    // The error message for calls made without initializing SDK.
    private String uninitializedErr = "MPCKeyService must be initialized";
    public static final String NAME = "MPCKeyService";

    private final ExecutorService executor;

    // The handle to the Go MPCKeyService client.
    private com.coinbase.waassdk.MPCKeyService keyClient;

    private static final int NUMBER_OF_CORES = Runtime.getRuntime().availableProcessors();

    MPCKeyServiceHandler() {
        this.executor = Executors.newFixedThreadPool(NUMBER_OF_CORES);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "initialize":
                initialize(call.argument("apiKeyName"), call.argument("privateKey"), call.argument("proxyUrl"), result);
                break;
            case "registerDevice":
                registerDevice(result);
                break;
            case "pollForPendingDeviceGroup":
                pollForPendingDeviceGroup(call.argument("deviceGroup"), call.argument("pollInterval"), result);
                break;
            case "stopPollingPendingDeviceGroup":
                stopPollingPendingDeviceGroup(result);
                break;
            case "createSignatureFromTx":
                createSignatureFromTx(call.argument("parent"), call.argument("transaction"), result);
                break;
            case "pollForPendingSignatures":
                pollForPendingSignatures(call.argument("deviceGroup"), call.argument("pollInterval"), result);
                break;
            case "stopPollingForPendingSignatures":
                stopPollingForPendingSignatures(result);
                break;
            case "waitPendingSignature":
                waitPendingSignature(call.argument("operation"), result);
                break;
            case "getSignedTransaction":
                getSignedTransaction(call.argument("transaction"), call.argument("signature"), result);
                break;
            case "getDeviceGroup":
                getDeviceGroup(call.argument("name"), result);
                break;
            case "prepareDeviceArchive":
                prepareDeviceArchive(call.argument("deviceGroup"), call.argument("device"), result);
                break;
            case "pollForPendingDeviceArchives":
                pollForPendingDeviceArchives(call.argument("deviceGroup"), call.argument("pollInterval"), result);
                break;
            case "stopPollingForPendingDeviceArchives":
                stopPollingForPendingDeviceArchives(result);
                break;
            case "pollForPendingDeviceBackups":
                pollForPendingDeviceBackups(call.argument("deviceGroup"), call.argument("pollInterval"), result);
                break;
            case "stopPollingForPendingDeviceBackups":
                stopPollingForPendingDeviceBackups(result);
                break;
            case "prepareDeviceBackup":
                prepareDeviceBackup(call.argument("deviceGroup"), call.argument("device"), result);
                break;
            case "addDevice":
                addDevice(call.argument("deviceGroup"), call.argument("device"), result);
                break;
            case "pollForPendingDevices":
                pollForPendingDevices(call.argument("deviceGroup"), call.argument("pollInterval"), result);
                break;
            case "stopPollingForPendingDevices":
                stopPollingForPendingDevices(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * Initializes the MPCKeyService  with the given parameters.
     * Resolves on success; rejects with an error otherwise.
     */
    private void initialize(String apiKeyName, String privateKey, String proxyUrl, Result result) {
        if (keyClient != null) {
            result.success(null);
            return;
        }
        try {
            keyClient = new com.coinbase.waassdk.MPCKeyService(apiKeyName, privateKey, proxyUrl, this.executor);
            result.success(null);
        } catch (Exception e) {
            result.error("Error", "initialize MPC key service failed: " + e.getMessage(), null);
        }
    }

    /**
     * Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
     */
    private void registerDevice(Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        try {
            Device device = keyClient.registerDevice().get();
            result.success(Collections.singletonMap("Name", device.getName()));
        } catch (Exception e) {
            result.error("Error", e.getMessage(), null);
        }
    }

    /**
     * Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
     * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     * stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
     * Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
     */
    private void pollForPendingDeviceGroup(String deviceGroup, int pollInterval, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        try {
            // You may need to adjust this to match the expected output and WaasPromise structure in your SDK
            Object response = keyClient.pollForPendingDeviceGroup(deviceGroup, pollInterval);
            result.success(response);
        } catch (Exception e) {
            result.error("Error", e.getMessage(), null);
        }
    }

    private boolean failIfUninitialized(Result result) {
        if (keyClient == null) {
            result.error("Error", "MPCKeyService must be initialized", null);
            return true;
        }
        return false;
    }

    /**
     * Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
     * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
     * Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
     * resolves with the empty string otherwise.
     */
    public void stopPollingPendingDeviceGroup(Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.stopPollingPendingDeviceGroup(), result, null, this.executor);
    }

    /**
     * Initiates an operation to create a Signature resource from the given transaction.
     * Resolves with the string "success" on successful initiation; rejects with an error otherwise.
     */
    public void createSignatureFromTx(String parent, Map<String, Object> transaction, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        try {
            JSONObject serializedTx = Utils.convertMapToJson(transaction);
            WaasPromise.resolveMap(keyClient.createSignatureFromTx(parent, serializedTx), result, null, this.executor);
        } catch (Exception e) {
            result.error("CREATE_SIGNATURE_ERROR", "createSignatureFromTx failed", e.getMessage());
        }
    }

    /**
     * Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
     * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     * stopPollingForPendingSignatures or processPendingSignature before another call is made to this function.
     * Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
     */
    public void pollForPendingSignatures(String deviceGroup, int pollInterval, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.pollForPendingSignatures(deviceGroup, pollInterval), result, Utils::convertJsonToArray, this.executor);
    }

    /**
     * Stops polling for pending Signatures This function should be called, e.g., before your app exits,
     * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
     * Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
     * resolves with the empty string otherwise.
     */
    public void stopPollingForPendingSignatures(Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.stopPollingForPendingSignatures(), result, null, this.executor);
    }

    /**
     * Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
     * rejects with an error otherwise.
     */
    public void waitPendingSignature(String operation, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.waitPendingSignature(operation), result, (Signature signature) -> {
            Map<String, Object> resultMap = new HashMap<>();
            resultMap.put("Name", signature.getName());
            resultMap.put("Payload", signature.getPayload());
            resultMap.put("SignedPayload", signature.getSignedPayload());
            return resultMap;
        }, this.executor);
    }

    /**
     * Gets the signed transaction using the given inputs.
     * Resolves with the SignedTransaction on success; rejects with an error otherwise.
     */
    public void getSignedTransaction(Map<String, Object> transaction, Map<String, Object> signature, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        try {
            Signature goSignature = new Signature();
            goSignature.setName((String) signature.get("Name"));
            goSignature.setPayload((String) signature.get("Payload"));
            goSignature.setSignedPayload((String) signature.get("SignedPayload"));

            JSONObject serializedTx = Utils.convertMapToJson(transaction);

            WaasPromise.resolveMap(keyClient.getSignedTransaction(serializedTx, goSignature), result, (SignedTransaction tx) -> {
                Map<String, Object> resultMap = new HashMap<>();
                resultMap.put("Transaction", transaction);
                resultMap.put("Signature", signature);
                resultMap.put("RawTransaction", tx.getRawTransaction());
                resultMap.put("TransactionHash", tx.getTransactionHash());
                return resultMap;
            }, this.executor);
        } catch (Exception e) {
            result.error("ERROR_CODE", "getSignedTransaction failed : " + e.getMessage(), null);
        }
    }


    /**
     * Gets a DeviceGroup with the given name. Resolves with the DeviceGroup object on success; rejects with an error otherwise.
     */
    public void getDeviceGroup(String name, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }

        WaasPromise.resolveMap(keyClient.getDeviceGroup(name), result, (deviceGroup) -> {
            byte[] devicesData = deviceGroup.getDevices();
            String devicesDataBytesToStrings = new String(devicesData, StandardCharsets.UTF_8);

            Map<String, Object> map = new HashMap<>();
            map.put("Name", deviceGroup.getName());
            map.put("MPCKeyExportMetadata", deviceGroup.getMPCKeyExportMetadata());
            map.put("Devices", devicesDataBytesToStrings);
            return map;
        }, this.executor);
    }

    /**
     * Initiates an operation to prepare device archive for MPCKey export. Resolves with the operation name on successful initiation; rejects with
     * an error otherwise.
     */
    public void prepareDeviceArchive(String deviceGroup, String device, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.prepareDeviceArchive(deviceGroup, device), result, null, this.executor);
    }

    /**
     * Polls for pending DeviceArchives (i.e. DeviceArchiveOperations), and returns the first set that materializes.
     * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     * stopPollingForDeviceArchives or computePrepareDeviceArchiveMPCOperation) before another call is made to this function.
     * Resolves with a list of the pending DeviceArchives on success; rejects with an error otherwise.
     */
    public void pollForPendingDeviceArchives(String deviceGroup, int pollInterval, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.pollForPendingDeviceArchives(deviceGroup, pollInterval), result, Utils::convertJsonToArray, this.executor);
    }

    /**
     * Stops polling for pending DeviceArchive operations. This function should be called, e.g., before your app exits,
     * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchiveOperation.
     * Resolves with string "stopped polling for pending Device Archives" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    public void stopPollingForPendingDeviceArchives(Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.stopPollingForPendingDeviceArchives(), result, null, this.executor);
    }


    /**
     * Polls for pending DeviceBackups (i.e. DeviceBackupOperations), and returns the first set that materializes.
     * Only one DeviceBackup can be polled at a time; thus, this function must return (by calling either
     * stopPollingForDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made to this function.
     * Resolves with a list of the pending DeviceBackups on success; rejects with an error otherwise.
     */
    public void pollForPendingDeviceBackups(String deviceGroup, int pollInterval, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.pollForPendingDeviceBackups(deviceGroup, pollInterval), result, Utils::convertJsonToArray, this.executor);
    }

    /**
     * Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
     * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackup.
     * Resolves with string "stopped polling for pending Device Backups" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    public void stopPollingForPendingDeviceBackups(Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.stopPollingForPendingDeviceBackups(), result, null, this.executor);
    }


    /**
     * Initiates an operation to prepare device backup to add new Devices to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
     * an error otherwise.
     */
    public void prepareDeviceBackup(String deviceGroup, String device, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.prepareDeviceBackup(deviceGroup, device), result, null, this.executor);
    }

    /**
     * Initiates an operation to add a Device to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
     * an error otherwise.
     */
    public void addDevice(String deviceGroup, String device, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.addDevice(deviceGroup, device), result, null, this.executor);
    }


    /**
     * Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
     * Only one Device can be polled at a time; thus, this function must return (by calling either
     * stopPollingForDevices or computeAddDeviceMPCOperation) before another call is made to this function.
     * Resolves with a list of the pending Devices on success; rejects with an error otherwise.
     */
    public void pollForPendingDevices(String deviceGroup, int pollInterval, Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.pollForPendingDevices(deviceGroup, pollInterval), result, Utils::convertJsonToArray, this.executor);
    }

    /**
     * Stops polling for pending AddDevice operations. This function should be called, e.g., before your app exits,
     * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Device.
     * Resolves with string "stopped polling for pending Devices" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    public void stopPollingForPendingDevices(Result result) {
        if (failIfUninitialized(result)) {
            return;
        }
        WaasPromise.resolveMap(keyClient.stopPollingForPendingDevices(), result, null, this.executor);
    }
}

