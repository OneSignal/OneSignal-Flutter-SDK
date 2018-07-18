/**
 * Modified MIT License
 *
 * Copyright 2017 OneSignal
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

#import "OneSignalPlugin.h"
#import "OneSignalCategories.h"
#import "OneSignalTagsController.h"

@interface OneSignalPlugin ()
@end

@implementation OneSignalPlugin

+ (instancetype)sharedInstance
{
    static OneSignalPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OneSignalPlugin new];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [OneSignal initWithLaunchOptions:nil appId:nil];
    
    OneSignalPlugin.sharedInstance.channel = [FlutterMethodChannel
                                     methodChannelWithName:@"OneSignal"
                                     binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:OneSignalPlugin.sharedInstance channel:OneSignalPlugin.sharedInstance.channel];
    
    [OneSignalTagsController registerWithRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#init" isEqualToString:call.method]) {
        NSLog(@"Initializing with iOS settings: %@", call.arguments[@"settings"]);

        [OneSignal initWithLaunchOptions:nil appId:call.arguments[@"appId"] handleNotificationReceived:^(OSNotification *notification) {
            [self handleReceivedNotification:notification];
        } handleNotificationAction:^(OSNotificationOpenedResult *result) {
            [self handleNotificationOpened:result];
        } settings:call.arguments[@"settings"]];

        [OneSignal addSubscriptionObserver:self];
        [OneSignal addPermissionObserver:self];
        [OneSignal addEmailSubscriptionObserver:self];

        result(@[]);

        return;
    } else if ([@"OneSignal#setLogLevel" isEqualToString:call.method]) {
        [OneSignal setLogLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"console"] intValue] visualLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"visual"] intValue]];
        result([NSNull null]);
    } else if ([@"OneSignal#requiresUserPrivacyConsent" isEqualToString:call.method]) {
        result(@(OneSignal.requiresUserPrivacyConsent));
    } else if ([@"OneSignal#consentGranted" isEqualToString:call.method]) {
        NSNumber *granted = call.arguments[@"granted"];

        if (!granted)
            return;

        [OneSignal consentGranted:[granted boolValue]];
        result(@[]);
    } else if ([@"OneSignal#setRequiresUserPrivacyConsent" isEqualToString:call.method]) {
        [OneSignal setRequiresUserPrivacyConsent:[call.arguments[@"required"] boolValue]];
        result(@[]);
    } else if ([@"OneSignal#promptPermission" isEqualToString:call.method]) {
        [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
            [self.channel invokeMethod:@"OneSignal#userAnsweredPrompt" arguments:@(accepted)];
        }];
    } else if ([@"OneSignal#log" isEqualToString:call.method]) {
        [OneSignal onesignal_Log:(ONE_S_LOG_LEVEL)[call.arguments[@"logLevel"] integerValue] message:(NSString *)call.arguments[@"message"]];
    } else if ([@"OneSignal#inFocusDisplayType" isEqualToString:call.method]) {
        result(@(OneSignal.inFocusDisplayType));
    } else if ([@"OneSignal#getPermissionSubscriptionState" isEqualToString:call.method]) {
        result(OneSignal.getPermissionSubscriptionState.toDictionary);
    } else if ([@"OneSignal#setInFocusDisplayType" isEqualToString:call.method]) {
        [OneSignal setInFocusDisplayType:(OSNotificationDisplayType)[call.arguments[@"displayType"] intValue]];
    } else if ([@"OneSignal#setSubscription" isEqualToString:call.method]) {
        [OneSignal setSubscription:[call.arguments boolValue]];
    } else if ([@"OneSignal#postNotification" isEqualToString:call.method]) {
        [OneSignal postNotification:(NSDictionary *)call.arguments onSuccess:^(NSDictionary *response) {
            result(response);
        } onFailure:^(NSError *error) {
            result(error.flutterError);
        }];
    } else if ([@"OneSignal#promptLocation" isEqualToString:call.method]) {
        [OneSignal promptLocation];
        result(@[]);
    } else if ([@"OneSignal#setLocationShared" isEqualToString:call.method]) {
        [OneSignal setLocationShared:[call.arguments boolValue]];
    } else if ([@"OneSignal#setEmail" isEqualToString:call.method]) {
        [OneSignal setEmail:call.arguments[@"email"] withEmailAuthHashToken:call.arguments[@"emailAuthHashToken"] withSuccess:^{
            result(@[]);
        } withFailure:^(NSError *error) {
            result(error.flutterError);
        }];
    } else if ([@"OneSignal#logoutEmail" isEqualToString:call.method]) {
        [OneSignal logoutEmailWithSuccess:^{
            result(@[]);
        } withFailure:^(NSError *error) {
            result(error.flutterError);
        }];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleReceivedNotification:(OSNotification *)notification {
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:notification.toJson options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    NSLog(@"Received notification with json: %@", json);
    [self.channel invokeMethod:@"OneSignal#handleReceivedNotification" arguments:notification.toJson ? notification.toJson : @[]];
}

- (void)handleNotificationOpened:(OSNotificationOpenedResult *)result {
    NSLog(@"Handling notification opened? %@", result);
    [self.channel invokeMethod:@"OneSignal#handleOpenedNotification" arguments:result.toJson];
}

- (void)onOSSubscriptionChanged:(OSSubscriptionStateChanges*)stateChanges {
   [self.channel invokeMethod:@"OneSignal#subscriptionChanged" arguments: stateChanges.toDictionary];
}

-(void)onOSPermissionChanged:(OSPermissionStateChanges *)stateChanges {
    [self.channel invokeMethod:@"OneSignal#permissionChanged" arguments:stateChanges.toDictionary];
}

-(void)onOSEmailSubscriptionChanged:(OSEmailSubscriptionStateChanges *)stateChanges {
    [self.channel invokeMethod:@"OneSignal#emailSubscriptionChanged" arguments:stateChanges.toDictionary];
}

@end
