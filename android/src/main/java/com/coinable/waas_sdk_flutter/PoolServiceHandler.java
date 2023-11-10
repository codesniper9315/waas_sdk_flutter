 package com.coinable.waas_sdk_flutter;

import com.waassdkinternal.v1.Pool;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class PoolServiceHandler implements MethodCallHandler {
    private final String poolsErr = "E_POOL_SERVICE";

    private final String uninitializedErr = "pool service must be initialized";

    private final ExecutorService executor;

    // The handle to the Go PoolService client.
    com.coinbase.waassdk.PoolService poolClient;

    PoolServiceHandler() {
        this.executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "initialize":
                initialize(call.argument("apiKeyName"), call.argument("privateKey"), call.argument("proxyUrl"), result);
                break;
            case "createPool":
                createPool(call.argument("displayName"), call.argument("poolID"), result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * Initializes the PoolService with the given Cloud API Key parameters. Resolves on success;
     * rejects with an error otherwise.
     */
    public void initialize(String apiKeyName, String privateKey, String proxyUrl, Result result) {
        if (poolClient != null) {
            result.success(null);
            return;
        }

        try {
            poolClient = new com.coinbase.waassdk.PoolService(apiKeyName, privateKey, proxyUrl, executor);
            result.success(null);
        } catch (Exception e) {
            result.error(poolsErr,"initialize pool failed : ", e);
        }
    }

    /**
     * Creates a Pool with the given parameters.  Resolves with the created Pool object on success; rejects with an error
     * otherwise.
     */
    public void createPool(String displayName, String poolID, Result result) {
        if (poolClient == null) {
            result.error(poolsErr, uninitializedErr, null);
            return;
        }

        WaasPromise.resolveMap(poolClient.createPool(displayName, poolID), result, (Pool pool) -> {
            Map<String, Object> outMap = new HashMap<>();
            outMap.put("name", pool.getName());
            outMap.put("displayName", pool.getDisplayName());
            return outMap;
        }, executor);
    }
}
