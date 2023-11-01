package com.coinable.waas_sdk_flutter;

import com.coinbase.waassdk.WaasException;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

@FunctionalInterface
interface CheckedFunction<T, R> {
    R apply(T t) throws Exception;
}

/**
 * A bridge between Flutter's "Result", and Java's "Future".
 */
public class WaasPromise {
    /**
     * Ties the result of the future<>result together, and applies `mapper` to the result before resolving.
     *
     * @param <T> The return type of the future.
     * @param future The java future, representing an operation from the native SDK.
     * @param result The Flutter result to resolve.
     * @param mapper An optional function to apply to the result of `future`
     * @param executor The executor to resolve the future on.
     */
    static <T> void resolveMap(Future<T> future, Result result, CheckedFunction<T, Object> mapper, ExecutorService executor) {
        executor.submit(() -> {
            try {
                T res = future.get();
                Object output = res;
                if (mapper != null) {
                    output = mapper.apply(res);
                }
                result.success(output);
            } catch (ExecutionException e) {
                Throwable cause = e.getCause();
                if (cause instanceof WaasException) {
                    result.error(((WaasException) cause).getErrorType(), cause.getMessage(), null);
                } else {
                    result.error("EXECUTION_ERROR", cause.getMessage(), null);
                }
            } catch (Exception exc) {
                result.error("GENERAL_ERROR", exc.getMessage(), null);
            }
        });
    }

    /**
     * Ties the result of the Future<T> to the associated Result.
     *
     * @param executor The executor that Waas will wait for the future to resolve on.
     * @param future   A Future from the WaasSdk.
     * @param result   A Flutter result to fulfill.
     */
    static <T> void resolve(Future<T> future, Result result, ExecutorService executor) {
        resolveMap(future, result, null, executor);
    }
}

