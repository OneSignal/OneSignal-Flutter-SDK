/**
 * Modified MIT License
 *
 * Copyright 2023 OneSignal
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * 1. The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * 2. All copies of substantial portions of the Software may only be used in connection
 * with services provided by OneSignal.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "OSFlutterNotifications.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import <OneSignalNotifications/OneSignalNotifications.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterNotifications

+ (instancetype)sharedInstance {
    static OSFlutterNotifications *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OSFlutterNotifications new];
        sharedInstance.onWillDisplayEventCache = [NSMutableDictionary new];
        sharedInstance.preventedDefaultCache = [NSMutableDictionary new];
    });
    return sharedInstance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

    OSFlutterNotifications.sharedInstance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#notifications"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:OSFlutterNotifications.sharedInstance channel:OSFlutterNotifications.sharedInstance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result { 
    if ([@"OneSignal#permission" isEqualToString:call.method])
        result(@([OneSignal.Notifications permission]));
    else if ([@"OneSignal#permissionNative" isEqualToString:call.method])
        [self permissionNative:call withResult:result];
    else if ([@"OneSignal#canRequest" isEqualToString:call.method])
        result(@([OneSignal.Notifications canRequestPermission]));
    else if ([@"OneSignal#clearAll" isEqualToString:call.method])
        [self clearAll:call withResult:result];
    else if ([@"OneSignal#requestPermission" isEqualToString:call.method])
        [self requestPermission:call withResult:result];
    else  if ([@"OneSignal#registerForProvisionalAuthorization" isEqualToString:call.method])
        [self registerForProvisionalAuthorization:call withResult:result];
    else if ([@"OneSignal#displayNotification" isEqualToString:call.method])
        [self displayNotification:call withResult:result];
    else if ([@"OneSignal#preventDefault" isEqualToString:call.method])
        [self preventDefault:call withResult:result];
     else if ([@"OneSignal#lifecycleInit" isEqualToString:call.method])
        [self lifecycleInit:call withResult:result];
    else if ([@"OneSignal#proceedWithWillDisplay" isEqualToString:call.method])
        [self proceedWithWillDisplay:call withResult:result];
    else if ([@"OneSignal#addNativeClickListener" isEqualToString:call.method])
        [self registerClickListener:call withResult:result];
    else
        result(FlutterMethodNotImplemented);
}

- (void)permissionNative:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    OSNotificationPermission permission = [OneSignal.Notifications permissionNative];
    result(@((int)permission));
}

- (void)clearAll:(FlutterMethodCall *)call  withResult:(FlutterResult)result {
    [OneSignal.Notifications clearAll];
    result(nil);
}

- (void)requestPermission:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL fallbackToSettings = [call.arguments[@"fallbackToSettings"] boolValue];
    
    [OneSignal.Notifications requestPermission:^(BOOL accepted) {
       result(@(accepted));
    } fallbackToSettings:fallbackToSettings];
}

- (void)registerForProvisionalAuthorization:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.Notifications registerForProvisionalAuthorization:^(BOOL accepted) {
       result(@(accepted));
    }];
}

- (void)lifecycleInit:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.Notifications addForegroundLifecycleListener:self];
    [OneSignal.Notifications addPermissionObserver:self];
    result(nil);
}

- (void)registerClickListener:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.Notifications addClickListener:self];
    result(nil);
}

- (void)onNotificationPermissionDidChange:(BOOL)permission {
    [self.channel invokeMethod:@"OneSignal#onNotificationPermissionDidChange" arguments:@{@"permission" : @(permission)}];
}

#pragma mark Received in Notification Lifecycle Event

- (void)onWillDisplayNotification:(OSNotificationWillDisplayEvent *)event {
    self.onWillDisplayEventCache[event.notification.notificationId] = event;
    /// Our bridge layer needs to preventDefault so that the Flutter listener has time to preventDefault before the notification is displayed
    [event preventDefault];
    [self.channel invokeMethod:@"OneSignal#onWillDisplayNotification" arguments:event.toJson];
}

    /// Our bridge layer needs to preventDefault so that the Flutter listener has time to preventDefault before the notification is displayed
    /// This function is called after all of the flutter listeners have responded to the willDisplay event. 
    /// If any of them have called preventDefault we will not call display(). Otherwise we will display.
- (void)proceedWithWillDisplay:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *notificationId = call.arguments[@"notificationId"];
    OSNotificationWillDisplayEvent *event = self.onWillDisplayEventCache[notificationId];
    if (!event) {
        [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"OneSignal (objc): could not find notification will display event for notification with id: %@", notificationId]];
        return;
    }
    if (self.preventedDefaultCache[notificationId]) {
        return;
    }
    [event.notification display];
    result(nil);
}

- (void)preventDefault:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *notificationId = call.arguments[@"notificationId"];
    OSNotificationWillDisplayEvent *event = self.onWillDisplayEventCache[notificationId];
    
    if (!event) {
        [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"OneSignal (objc): could not find notification will display event for notification with id: %@", notificationId]];
        return;
    }
    [event preventDefault];
    self.preventedDefaultCache[event.notification.notificationId] = event;
    result(nil);
}

- (void)displayNotification:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *notificationId = call.arguments[@"notificationId"];
    OSNotificationWillDisplayEvent *event = self.onWillDisplayEventCache[notificationId];
    
    if (!event) {
        [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"OneSignal (objc): could not find notification will display event for notification with id: %@", notificationId]];
        return;
    }
    [event.notification display];
    result(nil);
}

#pragma mark Notification Click

- (void)onClickNotification:(OSNotificationClickEvent * _Nonnull)event {
    [self.channel invokeMethod:@"OneSignal#onClickNotification" arguments:event.toJson];
}


@end
