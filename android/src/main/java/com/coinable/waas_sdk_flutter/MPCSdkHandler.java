package com.coinable.waas_sdk_flutter;

import android.content.Context;

import androidx.annotation.NonNull;

import com.coinbase.waassdk.WaasException;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MPCSdkHandler implements MethodCallHandler {
    private Context applicationContext;

    public MPCSdkHandler(Context context) {
        this.applicationContext = context;
    }

    private com.coinbase.waassdk.MPCSdk sdk;
    private ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());

    // The error code for MPC-SDK related errors.
    private final String mpcSdkErr = "E_MPC_SDK";
    // The error message for calls made without initializing SDK.
    private final String uninitializedErr = "MPCSdk must be initialized";

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (sdk == null && !call.method.equals("initialize")) {
            result.error("UNINITIALIZED", "MPCSdk must be initialized", null);
            return;
        }

        switch (call.method) {
            case "initialize":
                Boolean isSimulator = call.argument("isSimulator");
                initialize(isSimulator, result);
                break;
            case "bootstrapDevice":
                String passcode = call.argument("passcode");
                bootstrapDevice(passcode, result);
                break;
            case "getRegistrationData":
                getRegistrationData(result);
                break;
            case "computeMPCOperation":
                String mpcData = call.argument("mpcData");
                computeMPCOperation(mpcData, result);
                break;
            case "exportPrivateKeys":
                String mpcKeyExportMetadata = call.argument("mpcKeyExportMetadata");
                String pass = call.argument("passcode");
                exportPrivateKeys(mpcKeyExportMetadata, pass, result);
                break;
            case "computePrepareDeviceArchiveMPCOperation":
                String data = call.argument("mpcData");
                String passcodeForArchive = call.argument("passcode");
                computePrepareDeviceArchiveMPCOperation(data, passcodeForArchive, result);
                break;
            case "computePrepareDeviceBackupMPCOperation":
                String dataBackup = call.argument("mpcData");
                String passcodeForBackup = call.argument("passcode");
                computePrepareDeviceBackupMPCOperation(dataBackup, passcodeForBackup, result);
                break;
            case "exportDeviceBackup":
                exportDeviceBackup(result);
                break;
            case "computeAddDeviceMPCOperation":
                String mpcDataAdd = call.argument("mpcData");
                String passcodeAdd = call.argument("passcode");
                String deviceBackup = call.argument("deviceBackup");
                computeAddDeviceMPCOperation(mpcDataAdd, passcodeAdd, deviceBackup, result);
                break;
            case "resetPasscode":
                String newPasscode = call.argument("newPasscode");
                resetPasscode(newPasscode, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean failIfUnitialized(Result result) {
        if (sdk == null) {
            result.error(mpcSdkErr, uninitializedErr, null);
            return true;
        }

        return false;
    }

    /**
     * Initializes the MPCSdk  with the given parameters.
     * Resolves with the string "success" on success; rejects with an error otherwise.
     */
    private void initialize(Boolean isSimulator, Result result) {
        if (sdk != null) {
            result.success(true);
            return;
        }
        try {
            sdk = new com.coinbase.waassdk.MPCSdk(this.applicationContext, isSimulator, this.executor);
            result.success(true);
        } catch (Exception e) {
            result.error("INIT_ERROR", "initialize MPCSdk service failed", e.getMessage());
        }
    }

    /**
     * BootstrapDevice initializes the Device with the given passcode. The passcode is used to generate a private/public
     * key pair that encodes the back-up material for WaaS keys created on this Device. This function should be called
     * exactly once per Device per application, and should be called before the Device is registered with
     * GetRegistrationData. It is the responsibility of the application to track whether BootstrapDevice
     * has been called for the Device. It resolves with the string "bootstrap complete" on successful initialization;
     * or a rejection otherwise.
     */
    private void bootstrapDevice(String passcode, Result result) {
        if (sdk == null) {
            result.error("UNINITIALIZED", "MPCSdk must be initialized", null);
            return;
        }
        try {
            sdk.bootstrapDevice(passcode);
            result.success(null);
        } catch (Exception e) {
            result.error("BOOTSTRAP_ERROR", e.getMessage(), null);
        }
    }

    /**
     * GetRegistrationData returns the data required to call RegisterDeviceAPI on MPCKeyService.
     * Resolves with the RegistrationData on success; rejects with an error otherwise.
     */
    private void getRegistrationData(Result result) {
        try {
            result.success(sdk.getRegistrationData());
        } catch (WaasException e) {
            result.error("REGISTRATION_ERROR", e.getMessage(), null);
        }
    }

    /**
     * ComputeMPCOperation computes an MPC operation, given mpcData from the response of ListMPCOperations API on
     * MPCKeyService. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    public void computeMPCOperation(String mpcData, Result result) {
        if (failIfUnitialized(result)) {
            return;
        }

        WaasPromise.resolve(sdk.computeMPCOperation(mpcData), result, executor);
    }


    /**
     * Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
     * exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
     * rejects with an error otherwise.
     */
    public void exportPrivateKeys(String mpcKeyExportMetadata, String passcode, Result result) {
        if (failIfUnitialized(result)) {
            return;
        }

        WaasPromise.resolveMap(sdk.exportPrivateKeys(mpcKeyExportMetadata, passcode), result, Utils::convertJsonToArray, executor);
    }


    /**
     * Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
     * MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    public void computePrepareDeviceArchiveMPCOperation(String mpcData, String passcode, Result result) {
        if (failIfUnitialized(result)) {
            return;
        }

        WaasPromise.resolve(sdk.computePrepareDeviceArchiveMPCOperation(mpcData, passcode), result, executor);
    }

    /**
     * Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
     * MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    public void computePrepareDeviceBackupMPCOperation(String mpcData, String passcode, Result result) {
        if (failIfUnitialized(result)) {
            return;
        }

        WaasPromise.resolve(sdk.computePrepareDeviceBackupMPCOperation(mpcData, passcode), result, executor);
    }

    /**
     * Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
     * Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
     */
    public void exportDeviceBackup(Result result) {
        if (failIfUnitialized(result)) {
            return;
        }

        WaasPromise.resolve(sdk.exportDeviceBackup(), result, executor);
    }


    /**
     * Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
     * MPCKeyService, passcode of the Device and deviceBackup created with PrepareDeviceBackup operation. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    public void computeAddDeviceMPCOperation(String mpcData, String passcode, String deviceBackup, Result result) {
        if (failIfUnitialized(result)) {
            return;
        }

        WaasPromise.resolve(sdk.computeAddDeviceMPCOperation(mpcData, passcode, deviceBackup), result, executor);
    }

    /**
     * Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
     * While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
     * PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
     * This function can be used when/if the end user forgets their old passcode.
     * It resolves with the string "passcode reset" on success; a rejection otherwise.
     */
    public void resetPasscode(String newPasscode, Result result) {
        if (failIfUnitialized(result)) {
            return;
        }
        WaasPromise.resolve(sdk.resetPasscode(newPasscode), result, executor);
    }
}
