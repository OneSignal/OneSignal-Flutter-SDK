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
        sharedInstance.hasSetNotificationWillShowInForegroundHandler = false;
        sharedInstance.receivedNotificationCache = [NSMutableDictionary new];
        sharedInstance.notificationCompletionCache = [NSMutableDictionary new];
    });
    return sharedInstance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterNotifications *instance = [OSFlutterNotifications new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#notifications"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
    
    [OneSignal.Notifications setNotificationWillShowInForegroundHandler:^(OSNotification *notification, OSNotificationDisplayResponse completion) {
        [OSFlutterNotifications.sharedInstance handleNotificationWillShowInForeground:notification completion:completion];
    }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result { 
    if ([@"OneSignal#permission" isEqualToString:call.method])
        result(@([OneSignal.Notifications permission]));
    else if ([@"OneSignal#canRequest" isEqualToString:call.method])
        result(@([OneSignal.Notifications canRequestPermission]));
    else if ([@"OneSignal#clearAll" isEqualToString:call.method])
        [self clearAll:call withResult:result];
    else if ([@"OneSignal#requestPermission" isEqualToString:call.method])
        [self requestPermission:call withResult:result];
    else  if ([@"OneSignal#registerForProvisionalAuthorization" isEqualToString:call.method])
        [self registerForProvisionalAuthorization:call withResult:result];
     else if ([@"OneSignal#addPermissionObserver" isEqualToString:call.method])
        [self addPermissionObserver:call withResult:result];
    else if ([@"OneSignal#removePermissionObserver" isEqualToString:call.method])
        [self removePermissionObserver:call withResult:result];
    else if ([@"OneSignal#initNotificationWillShowInForegroundHandlerParams" isEqualToString:call.method])
        [self initNotificationWillShowInForegroundHandlerParams];
    else if ([@"OneSignal#initNotificationOpenedHandlerParams" isEqualToString:call.method])
        [self initNotificationOpenedHandlerParams];
    else
        result(FlutterMethodNotImplemented);
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



- (void)onOSPermissionChanged:(OSPermissionState*)state {
    [self.channel invokeMethod:@"OneSignal#OSPermissionChanged" arguments:state.jsonRepresentation];
}

- (void)addPermissionObserver:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.Notifications addPermissionObserver:self];
    result(nil);
}

// TODO: possibly don't need
- (void)removePermissionObserver:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.Notifications removePermissionObserver:self];
    result(nil);
}

#pragma mark Received in Foreground Notification 

- (void)initNotificationWillShowInForegroundHandlerParams {
    self.hasSetNotificationWillShowInForegroundHandler = YES;
}

- (void)handleNotificationWillShowInForeground:(OSNotification *)notification completion:(OSNotificationDisplayResponse)completion {
    if (!self.hasSetNotificationWillShowInForegroundHandler) {
        completion(notification);
        return;
    }

    self.receivedNotificationCache[notification.notificationId] = notification;
    self.notificationCompletionCache[notification.notificationId] = completion;
    [self.channel invokeMethod:@"OneSignal#handleNotificationWillShowInForeground" arguments:notification.toJson];
}

#pragma mark Opened Notification

- (void)initNotificationOpenedHandlerParams {
    [OneSignal.Notifications setNotificationOpenedHandler:^(OSNotificationOpenedResult * _Nonnull result) {
        [OSFlutterNotifications.sharedInstance handleNotificationOpened:result];
    }];
}

- (void)handleNotificationOpened:(OSNotificationOpenedResult *)result {
    [self.channel invokeMethod:@"OneSignal#handleOpenedNotification" arguments:result.toJson];
}


@end
