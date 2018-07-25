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

@property (strong, nonatomic) FlutterMethodChannel *channel;

/*
    Will be true if the SDK is waiting for the
    user's consent before initializing.
    This is important because if the plugin
    doesn't know the SDK is waiting for consent,
    it will add the observers (ie. subscription)
*/
@property (atomic) BOOL waitingForUserConsent;

/*
    holds reference to any notifications received before the
    flutter runtime channel has been opened
    Thus, if a user taps a notification while the app is
    terminated, the SDK will still notify the app once the
    channel is open
*/
@property (strong, nonatomic) OSNotificationOpenedResult *coldStartOpenResult;

@end



@implementation OneSignalPlugin

+ (instancetype)sharedInstance
{
    static OneSignalPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OneSignalPlugin new];
        sharedInstance.waitingForUserConsent = false;
    });
    return sharedInstance;
}

#pragma mark FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    [OneSignal initWithLaunchOptions:nil appId:nil handleNotificationAction:^(OSNotificationOpenedResult *result) {
        @synchronized (OneSignalPlugin.sharedInstance.coldStartOpenResult) {
            OneSignalPlugin.sharedInstance.coldStartOpenResult = result;
        }
    }];
    
    OneSignalPlugin.sharedInstance.channel = [FlutterMethodChannel
                                     methodChannelWithName:@"OneSignal"
                                     binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:OneSignalPlugin.sharedInstance channel:OneSignalPlugin.sharedInstance.channel];
    
    [OneSignalTagsController registerWithRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#init" isEqualToString:call.method]) {
        [self initOneSignal:call withResult:result];
    } else if ([@"OneSignal#setLogLevel" isEqualToString:call.method]) {
        [self setOneSignalLogLevel:call withResult:result];
    } else if ([@"OneSignal#requiresUserPrivacyConsent" isEqualToString:call.method]) {
        result(@(OneSignal.requiresUserPrivacyConsent));
    } else if ([@"OneSignal#consentGranted" isEqualToString:call.method]) {
        [self changeConsentStatus:call withResult:result];
    } else if ([@"OneSignal#setRequiresUserPrivacyConsent" isEqualToString:call.method]) {
        [self setRequiresUserPrivacyConsent:call withResult:result];
    } else if ([@"OneSignal#promptPermission" isEqualToString:call.method]) {
        [self promptPermission:call withResult:result];
    } else if ([@"OneSignal#log" isEqualToString:call.method]) {
        [self oneSignalLog:call withResult:result];
    } else if ([@"OneSignal#inFocusDisplayType" isEqualToString:call.method]) {
        result(@(OneSignal.inFocusDisplayType));
    } else if ([@"OneSignal#getPermissionSubscriptionState" isEqualToString:call.method]) {
        result(OneSignal.getPermissionSubscriptionState.toDictionary);
    } else if ([@"OneSignal#setInFocusDisplayType" isEqualToString:call.method]) {
        [OneSignal setInFocusDisplayType:(OSNotificationDisplayType)[call.arguments[@"displayType"] intValue]];
    } else if ([@"OneSignal#setSubscription" isEqualToString:call.method]) {
        [OneSignal setSubscription:[call.arguments boolValue]];
    } else if ([@"OneSignal#postNotification" isEqualToString:call.method]) {
        [self postNotification:call withResult:result];
    } else if ([@"OneSignal#promptLocation" isEqualToString:call.method]) {
        [self promptLocation:call withResult:result];
    } else if ([@"OneSignal#setLocationShared" isEqualToString:call.method]) {
        [OneSignal setLocationShared:[call.arguments boolValue]];
    } else if ([@"OneSignal#setEmail" isEqualToString:call.method]) {
        [self setEmail:call withResult:result];
    } else if ([@"OneSignal#logoutEmail" isEqualToString:call.method]) {
        [self logoutEmail:call withResult:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initOneSignal:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal initWithLaunchOptions:nil appId:call.arguments[@"appId"] handleNotificationReceived:^(OSNotification *notification) {
        [self handleReceivedNotification:notification];
    } handleNotificationAction:^(OSNotificationOpenedResult *result) {
        [self handleNotificationOpened:result];
    } settings:call.arguments[@"settings"]];
    
    // If the user has required privacy consent, the SDK will not
    // add these observers. So we should delay adding the observers
    // until consent has been provided.
    
    if (OneSignal.requiresUserPrivacyConsent) {
        self.waitingForUserConsent = true;
    } else {
        [self addObservers];
    }
    
    @synchronized(self.coldStartOpenResult) {
        if (self.coldStartOpenResult) {
            [self handleNotificationOpened:self.coldStartOpenResult];
        }
    }
    
    result(@[]);
}

- (void)addObservers {
    [OneSignal addSubscriptionObserver:self];
    [OneSignal addPermissionObserver:self];
    [OneSignal addEmailSubscriptionObserver:self];
}

- (void)setOneSignalLogLevel:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal setLogLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"console"] intValue] visualLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"visual"] intValue]];
    result([NSNull null]);
}

-(void)changeConsentStatus:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL granted = [call.arguments[@"granted"] boolValue];
    
    [OneSignal consentGranted:granted];
    
    if (self.waitingForUserConsent && granted) {
        [self addObservers];
    }
    
    result(@[]);
}

-(void)setRequiresUserPrivacyConsent:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal setRequiresUserPrivacyConsent:[call.arguments[@"required"] boolValue]];
    result(@[]);
}

- (void)promptPermission:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        [self.channel invokeMethod:@"OneSignal#userAnsweredPrompt" arguments:@(accepted)];
    }];
}

- (void)postNotification:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal postNotification:(NSDictionary *)call.arguments onSuccess:^(NSDictionary *response) {
        result(response);
    } onFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)promptLocation:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal promptLocation];
    result(@[]);
}

- (void)setEmail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    
    NSString *email = call.arguments[@"email"];
    NSString *emailAuthHashToken = call.arguments[@"emailAuthHashToken"];
    
    if ([emailAuthHashToken isKindOfClass:[NSNull class]])
        emailAuthHashToken = nil;
    
    [OneSignal setEmail:email withEmailAuthHashToken:emailAuthHashToken withSuccess:^{
        result(@[]);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)logoutEmail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal logoutEmailWithSuccess:^{
        result(@[]);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)oneSignalLog:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal onesignal_Log:(ONE_S_LOG_LEVEL)[call.arguments[@"logLevel"] integerValue] message:(NSString *)call.arguments[@"message"]];
}

#pragma mark Received & Opened Notification Handlers
- (void)handleReceivedNotification:(OSNotification *)notification {
    [self.channel invokeMethod:@"OneSignal#handleReceivedNotification" arguments:notification.toJson ? notification.toJson : @[]];
}

- (void)handleNotificationOpened:(OSNotificationOpenedResult *)result {
    [self.channel invokeMethod:@"OneSignal#handleOpenedNotification" arguments:result.toJson];
}

#pragma mark OSSubscriptionObserver
- (void)onOSSubscriptionChanged:(OSSubscriptionStateChanges*)stateChanges {
   [self.channel invokeMethod:@"OneSignal#subscriptionChanged" arguments: stateChanges.toDictionary];
}

#pragma mark OSPermissionObserver
-(void)onOSPermissionChanged:(OSPermissionStateChanges *)stateChanges {
    [self.channel invokeMethod:@"OneSignal#permissionChanged" arguments:stateChanges.toDictionary];
}

#pragma mark OSEmailSubscriptionObserver
-(void)onOSEmailSubscriptionChanged:(OSEmailSubscriptionStateChanges *)stateChanges {
    [self.channel invokeMethod:@"OneSignal#emailSubscriptionChanged" arguments:stateChanges.toDictionary];
}

@end
