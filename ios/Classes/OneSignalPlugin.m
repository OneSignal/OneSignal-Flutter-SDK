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
#import "OSFlutterCategories.h"
#import "OSFlutterTagsController.h"
#import "OSFlutterInAppMessagesController.h"
#import "OSFlutterOutcomeEventsController.h"

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

@property (atomic) BOOL hasSetInAppMessageClickedHandler;
@property (atomic) BOOL hasSetNotificationWillShowInForegroundHandler;

/*
    Holds reference to any in app messages received before any click action
    occurs on the body, button or image elements of the in app message
*/
@property (strong, nonatomic) OSInAppMessageAction *inAppMessageClickedResult;

@property (strong, nonatomic) NSMutableDictionary* notificationCompletionCache;
@property (strong, nonatomic) NSMutableDictionary* receivedNotificationCache;

@end

@implementation OneSignalPlugin

+ (instancetype)sharedInstance {
    static OneSignalPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OneSignalPlugin new];
        sharedInstance.waitingForUserConsent = false;
        sharedInstance.receivedNotificationCache = [NSMutableDictionary new];;
        sharedInstance.notificationCompletionCache = [NSMutableDictionary new];;
        sharedInstance.hasSetInAppMessageClickedHandler = false;
        sharedInstance.hasSetNotificationWillShowInForegroundHandler = false;
    });
    return sharedInstance;
}

#pragma mark FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

    [OneSignal initWithLaunchOptions:nil];
    [OneSignal setMSDKType:@"flutter"];

    // Wrapper SDK's call init with no app ID early on in the
    // app lifecycle. The developer will call init() later on
    // from the Flutter plugin channel.

    OneSignalPlugin.sharedInstance.channel = [FlutterMethodChannel
                                     methodChannelWithName:@"OneSignal"
                                     binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:OneSignalPlugin.sharedInstance channel:OneSignalPlugin.sharedInstance.channel];

    [OSFlutterTagsController registerWithRegistrar:registrar];
    [OSFlutterInAppMessagesController registerWithRegistrar:registrar];
    [OSFlutterOutcomeEventsController registerWithRegistrar:registrar];
}

- (void)addObservers {
    [OneSignal addSubscriptionObserver:self];
    [OneSignal addPermissionObserver:self];
    [OneSignal addEmailSubscriptionObserver:self];
    [OneSignal addSMSSubscriptionObserver:self];
    [OneSignal setNotificationWillShowInForegroundHandler:^(OSNotification *notification, OSNotificationDisplayResponse completion) {
        [OneSignalPlugin.sharedInstance handleNotificationWillShowInForeground:notification completion:completion];
    }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#setAppId" isEqualToString:call.method])
        [self setAppId:call withResult:result];
    else if ([@"OneSignal#setLogLevel" isEqualToString:call.method])
        [self setOneSignalLogLevel:call withResult:result];
    else if ([@"OneSignal#log" isEqualToString:call.method])
        [self oneSignalLog:call withResult:result];
    else if ([@"OneSignal#requiresUserPrivacyConsent" isEqualToString:call.method])
        result(@(OneSignal.requiresUserPrivacyConsent));
    else if ([@"OneSignal#setRequiresUserPrivacyConsent" isEqualToString:call.method])
        [self setRequiresUserPrivacyConsent:call withResult:result];
    else if ([@"OneSignal#consentGranted" isEqualToString:call.method])
        [self setConsentStatus:call withResult:result];
    else if ([@"OneSignal#promptPermission" isEqualToString:call.method])
        [self promptPermission:call withResult:result];
    else if ([@"OneSignal#getDeviceState" isEqualToString:call.method])
        [self getDeviceState:call withResult:result];
    else if ([@"OneSignal#disablePush" isEqualToString:call.method])
        [self disablePush:call withResult:result];
    else if ([@"OneSignal#postNotification" isEqualToString:call.method])
        [self postNotification:call withResult:result];
    else if ([@"OneSignal#promptLocation" isEqualToString:call.method])
        [self promptLocation:call withResult:result];
    else if ([@"OneSignal#setLocationShared" isEqualToString:call.method])
        [self setLocationShared:call withResult:result];
    else if ([@"OneSignal#setEmail" isEqualToString:call.method])
        [self setEmail:call withResult:result];
    else if ([@"OneSignal#logoutEmail" isEqualToString:call.method])
        [self logoutEmail:call withResult:result];
    else if ([@"OneSignal#setSMSNumber" isEqualToString:call.method])
        [self setSMSNumber:call withResult:result];
    else if ([@"OneSignal#logoutSMSNumber" isEqualToString:call.method])
        [self logoutSMSNumber:call withResult:result];
    else if ([@"OneSignal#setExternalUserId" isEqualToString:call.method])
        [self setExternalUserId:call withResult:result];
    else if ([@"OneSignal#removeExternalUserId" isEqualToString:call.method])
        [self removeExternalUserId:call withResult:result];
    else if ([@"OneSignal#setLanguage" isEqualToString:call.method])
        [self setLanguage:call withResult:result];
    else if ([@"OneSignal#initNotificationOpenedHandlerParams" isEqualToString:call.method])
        [self initNotificationOpenedHandlerParams];
    else if ([@"OneSignal#initInAppMessageClickedHandlerParams" isEqualToString:call.method])
        [self initInAppMessageClickedHandlerParams];
    else if ([@"OneSignal#initNotificationWillShowInForegroundHandlerParams" isEqualToString:call.method])
        [self initNotificationWillShowInForegroundHandlerParams];
    else if ([@"OneSignal#completeNotification" isEqualToString:call.method])
        [self completeNotification:call withResult:result];
    else
        result(FlutterMethodNotImplemented);
}

- (void)setAppId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
     [OneSignal setInAppMessageClickHandler:^(OSInAppMessageAction *action) {
         [self handleInAppMessageClicked:action];
     }];
    
    [OneSignal setAppId:call.arguments[@"appId"]];

    // If the user has required privacy consent, the SDK will not
    // add these observers. So we should delay adding the observers
    // until consent has been provided.
    if (OneSignal.requiresUserPrivacyConsent) {
        self.waitingForUserConsent = true;
    } else {
        [self addObservers];
    }
    result(nil);
}

- (void)setOneSignalLogLevel:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    ONE_S_LOG_LEVEL consoleLogLevel = (ONE_S_LOG_LEVEL)[call.arguments[@"console"] intValue];
    ONE_S_LOG_LEVEL visualLogLevel = (ONE_S_LOG_LEVEL)[call.arguments[@"visual"] intValue];
    [OneSignal setLogLevel:consoleLogLevel visualLevel:visualLogLevel];
    result(nil);
}

- (void)oneSignalLog:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal onesignalLog:(ONE_S_LOG_LEVEL)[call.arguments[@"logLevel"] integerValue] message:(NSString *)call.arguments[@"message"]];
    result(nil);
}

- (void)setRequiresUserPrivacyConsent:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal setRequiresUserPrivacyConsent:[call.arguments[@"required"] boolValue]];
    result(nil);
}

- (void)setConsentStatus:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL granted = [call.arguments[@"granted"] boolValue];
    [OneSignal consentGranted:granted];

    if (self.waitingForUserConsent && granted)
        [self addObservers];
    
    result(nil);
}

- (void)promptPermission:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
        result(@(accepted));
    }];
}

- (void)getDeviceState:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    OSDeviceState *deviceState = OneSignal.getDeviceState;
    
    NSMutableDictionary *json = [NSMutableDictionary new];

    json[@"hasNotificationPermission"] = @(deviceState.hasNotificationPermission);
    json[@"pushDisabled"] = @(deviceState.isPushDisabled);
    json[@"subscribed"] = @(deviceState.isSubscribed);
    json[@"userId"] = deviceState.userId;
    json[@"pushToken"] = deviceState.pushToken;
    json[@"emailUserId"] = deviceState.emailUserId;
    json[@"emailAddress"] = deviceState.emailAddress;
    json[@"emailSubscribed"] = @(deviceState.isEmailSubscribed);
    json[@"smsUserId"] = deviceState.smsUserId;
    json[@"smsNumber"] = deviceState.smsNumber;
    json[@"smsSubscribed"] = @(deviceState.isSMSSubscribed);
    json[@"notificationPermissionStatus"] = @(deviceState.notificationPermissionStatus);

    result(json);
}

- (void)disablePush:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL disable = [call.arguments boolValue];
    [OneSignal disablePush:disable];
    result(nil);
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
    result(nil);
}

- (void)setLocationShared:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL locationShared = [call.arguments boolValue];
    [OneSignal setLocationShared:locationShared];
    result(nil);
}

- (void)setEmail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *email = call.arguments[@"email"];
    NSString *emailAuthHashToken = call.arguments[@"emailAuthHashToken"];

    if ([emailAuthHashToken isKindOfClass:[NSNull class]])
        emailAuthHashToken = nil;

    [OneSignal setEmail:email withEmailAuthHashToken:emailAuthHashToken withSuccess:^{
        result(nil);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)logoutEmail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal logoutEmailWithSuccess:^{
        result(nil);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)setSMSNumber:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *smsNumber = call.arguments[@"smsNumber"];
    NSString *smsAuthHashToken = call.arguments[@"smsAuthHashToken"];

    if ([smsAuthHashToken isKindOfClass:[NSNull class]])
        smsAuthHashToken = nil;

    [OneSignal setSMSNumber:smsNumber withSMSAuthHashToken:smsAuthHashToken withSuccess:^(NSDictionary *results){
        result(results);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)logoutSMSNumber:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal logoutSMSNumberWithSuccess:^(NSDictionary *results){
        result(results);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)setExternalUserId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id externalId = call.arguments[@"externalUserId"];
    id authHashToken = call.arguments[@"authHashToken"];
    if (externalId == [NSNull null])
        externalId = nil;
    if (authHashToken == [NSNull null])
        authHashToken = nil;

    [OneSignal setExternalUserId:externalId withExternalIdAuthHashToken:authHashToken withSuccess:^(NSDictionary *results) {
        result(results);
    } withFailure: ^(NSError* error) {
        [OneSignal onesignalLog:ONE_S_LL_VERBOSE message:[NSString stringWithFormat:@"Set external user id Failure with error: %@", error]];
        result(error.flutterError);
    }];
}

- (void)removeExternalUserId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal removeExternalUserId:^(NSDictionary *results) {
        result(results);
    } withFailure:^(NSError *error) {
        [OneSignal onesignalLog:ONE_S_LL_VERBOSE message:[NSString stringWithFormat:@"Remove external user id Failure with error: %@", error]];
        result(error.flutterError);
    }];
}

- (void)setLanguage:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id language = call.arguments[@"language"];
    if (language == [NSNull null]) {
        language = nil;
    }

    [OneSignal setLanguage:language];
}

- (void)initNotificationOpenedHandlerParams {
    [OneSignal setNotificationOpenedHandler:^(OSNotificationOpenedResult * _Nonnull result) {
        [OneSignalPlugin.sharedInstance handleNotificationOpened:result];
    }];
}

- (void)initInAppMessageClickedHandlerParams {
    _hasSetInAppMessageClickedHandler = true;

    if (self.inAppMessageClickedResult) {
        [self handleInAppMessageClicked:self.inAppMessageClickedResult];
        self.inAppMessageClickedResult = nil;
    }
}

- (void)initNotificationWillShowInForegroundHandlerParams {
    self.hasSetNotificationWillShowInForegroundHandler = YES;
}

#pragma mark Opened Notification Handlers
- (void)handleNotificationOpened:(OSNotificationOpenedResult *)result {
    [self.channel invokeMethod:@"OneSignal#handleOpenedNotification" arguments:result.toJson];
}

#pragma mark Received in Foreground Notification Handlers
- (void)handleNotificationWillShowInForeground:(OSNotification *)notification completion:(OSNotificationDisplayResponse)completion {
    if (!self.hasSetNotificationWillShowInForegroundHandler) {
        completion(notification);
        return;
    }

    self.receivedNotificationCache[notification.notificationId] = notification;
    self.notificationCompletionCache[notification.notificationId] = completion;
    [self.channel invokeMethod:@"OneSignal#handleNotificationWillShowInForeground" arguments:notification.toJson];
}

- (void)completeNotification:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *notificationId = call.arguments[@"notificationId"];
    BOOL shouldDisplay = [call.arguments[@"shouldDisplay"] boolValue];
    OSNotificationDisplayResponse completion = self.notificationCompletionCache[notificationId];
    
    if (!completion) {
        [OneSignal onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"OneSignal (objc): could not find notification completion block with id: %@", notificationId]];
        return;
    }

    if (shouldDisplay) {
        OSNotification *notification = self.receivedNotificationCache[notificationId];
        completion(notification);
    } else {
        completion(nil);
    }

    [self.notificationCompletionCache removeObjectForKey:notificationId];
    [self.receivedNotificationCache removeObjectForKey:notificationId];
}


#pragma mark In App Message Click Handler
- (void)handleInAppMessageClicked:(OSInAppMessageAction *)action {
    if (!self.hasSetInAppMessageClickedHandler) {
        _inAppMessageClickedResult = action;
        return;
    }

    [self.channel invokeMethod:@"OneSignal#handleClickedInAppMessage" arguments:action.toJson];
}

#pragma mark OSSubscriptionObserver
- (void)onOSSubscriptionChanged:(OSSubscriptionStateChanges *)stateChanges {
   [self.channel invokeMethod:@"OneSignal#subscriptionChanged" arguments: stateChanges.toDictionary];
}

#pragma mark OSPermissionObserver
- (void)onOSPermissionChanged:(OSPermissionStateChanges *)stateChanges {
    [self.channel invokeMethod:@"OneSignal#permissionChanged" arguments:stateChanges.toDictionary];
}

#pragma mark OSEmailSubscriptionObserver
- (void)onOSEmailSubscriptionChanged:(OSEmailSubscriptionStateChanges *)stateChanges {
    [self.channel invokeMethod:@"OneSignal#emailSubscriptionChanged" arguments:stateChanges.toDictionary];
}

#pragma mark OSSMSSubscriptionObserver
- (void)onOSSMSSubscriptionChanged:(OSSMSSubscriptionStateChanges *)stateChanges {
    [self.channel invokeMethod:@"OneSignal#smsSubscriptionChanged" arguments:stateChanges.toDictionary];
}

@end
