package com.coinable.waas_sdk_flutter;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class Utils {

    public static Map<String, Object> convertJsonToMap(JSONObject jsonObject) throws JSONException {
        Map<String, Object> map = new HashMap<>();

        Iterator<String> iterator = jsonObject.keys();
        while (iterator.hasNext()) {
            String key = iterator.next();
            Object value = jsonObject.get(key);
            if (value instanceof JSONObject) {
                map.put(key, convertJsonToMap((JSONObject) value));
            } else if (value instanceof JSONArray) {
                map.put(key, convertJsonToArray((JSONArray) value));
            } else if (value instanceof Boolean) {
                map.put(key, (Boolean) value);
            } else if (value instanceof Integer) {
                map.put(key, (Integer) value);
            } else if (value instanceof Double) {
                map.put(key, (Double) value);
            } else if (value instanceof String) {
                map.put(key, (String) value);
            } else {
                map.put(key, value.toString());
            }
        }
        return map;
    }

    public static List<Object> convertJsonToArray(JSONArray jsonArray) throws JSONException {
        List<Object> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            Object value = jsonArray.get(i);
            if (value instanceof JSONObject) {
                list.add(convertJsonToMap((JSONObject) value));
            } else if (value instanceof JSONArray) {
                list.add(convertJsonToArray((JSONArray) value));
            } else if (value instanceof Boolean) {
                list.add((Boolean) value);
            } else if (value instanceof Integer) {
                list.add((Integer) value);
            } else if (value instanceof Double) {
                list.add((Double) value);
            } else if (value instanceof String) {
                list.add((String) value);
            } else {
                list.add(value.toString());
            }
        }
        return list;
    }
    public static JSONObject convertMapToJson(Map<String, Object> map) throws JSONException {
        JSONObject object = new JSONObject();
        for (String key : map.keySet()) {
            Object value = map.get(key);
            if (value == null) {
                object.put(key, JSONObject.NULL);
            } else if (value instanceof Boolean) {
                object.put(key, (Boolean) value);
            } else if (value instanceof Number) {
                object.put(key, ((Number) value).doubleValue());
            } else if (value instanceof String) {
                object.put(key, value);
            } else if (value instanceof Map) {
                object.put(key, convertMapToJson((Map<String, Object>) value));
            } else if (value instanceof List) {
                object.put(key, convertArrayToJson((List<Object>) value));
            } else {
                throw new JSONException("Unsupported value type: " + value.getClass().getName());
            }
        }
        return object;
    }

    public static JSONArray convertArrayToJson(List<Object> list) throws JSONException {
        JSONArray array = new JSONArray();
        for (Object value : list) {
            if (value == null) {
                array.put(JSONObject.NULL);
            } else if (value instanceof Boolean) {
                array.put((Boolean) value);
            } else if (value instanceof Number) {
                array.put(((Number) value).doubleValue());
            } else if (value instanceof String) {
                array.put(value);
            } else if (value instanceof Map) {
                array.put(convertMapToJson((Map<String, Object>) value));
            } else if (value instanceof List) {
                array.put(convertArrayToJson((List<Object>) value));
            } else {
                throw new JSONException("Unsupported value type: " + value.getClass().getName());
            }
        }
        return array;
    }
}
