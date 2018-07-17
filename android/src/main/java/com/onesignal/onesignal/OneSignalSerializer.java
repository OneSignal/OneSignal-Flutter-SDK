package com.onesignal.onesignal;

import com.onesignal.OSPermissionState;
import com.onesignal.OSPermissionSubscriptionState;
import com.onesignal.OSSubscriptionState;
import com.onesignal.OSEmailSubscriptionState;
import java.util.HashMap;
/**
 * Created by bradhesse on 7/17/18.
 */

public class OneSignalSerializer {
    static public HashMap<Object, Object> subscriptionStateToMap(OSSubscriptionState state) {
        HashMap<Object, Object> subscription = new HashMap<Object, Object>();

        subscription.put("subscribed", state.getSubscribed());
        subscription.put("userSubscriptionSetting", state.getUserSubscriptionSetting());
        subscription.put("pushToken", state.getPushToken());
        subscription.put("userId", state.getUserId());

        return subscription;
    }

    static public HashMap<Object, Object> permissionStateToMap(OSPermissionState state) {
        HashMap<Object, Object> permission = new HashMap<Object, Object>();

        permission.put("enabled", state.getEnabled());

        return permission;
    }

    static public HashMap<Object, Object> emailSubscriptionStateToMap(OSEmailSubscriptionState state) {
        HashMap<Object, Object> emailState = new HashMap<Object, Object>();

        emailState.put("emailUserId", state.getEmailUserId());
        emailState.put("emailAddress", state.getEmailAddress());
        emailState.put("subscribed", state.getSubscribed());

        return emailState;
    }

    static public HashMap<Object, Object> permissionSubscriptionStateToMap(OSPermissionSubscriptionState state) {
        HashMap<Object, Object> permissionSubscriptionState = new HashMap<Object, Object>();

        permissionSubscriptionState.put("subscriptionStatus", OneSignalSerializer.subscriptionStateToMap(state.getSubscriptionStatus()));
        permissionSubscriptionState.put("permissionStatus", OneSignalSerializer.permissionStateToMap(state.getPermissionStatus()));
        permissionSubscriptionState.put("emailSubscriptionStatus", OneSignalSerializer.emailSubscriptionStateToMap(state.getEmailSubscriptionStatus()));

        return permissionSubscriptionState;
    }
}
