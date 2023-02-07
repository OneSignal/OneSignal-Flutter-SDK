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

#import "OneSignalPlugin.h"
#import "OSFlutterCategories.h"
#import "OSFlutterDebug.h"
#import "OSFlutterUser.h"


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

@end

@implementation OneSignalPlugin

+ (instancetype)sharedInstance {
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

    [OneSignal setMSDKType:@"flutter"];

    OneSignalPlugin.sharedInstance.channel = [FlutterMethodChannel
                                     methodChannelWithName:@"OneSignal"
                                     binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:OneSignalPlugin.sharedInstance channel:OneSignalPlugin.sharedInstance.channel];
    [OSFlutterDebug registerWithRegistrar:registrar];
    [OSFlutterUser registerWithRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#initialize" isEqualToString:call.method])
        [self initialize:call];
    else if ([@"OneSignal#login" isEqualToString:call.method])
        [self login:call];
    else if ([@"OneSignal#getPrivacyConsent" isEqualToString:call.method])
        result(@(OneSignal.getPrivacyConsent));
    else if ([@"OneSignal#setPrivacyConsent" isEqualToString:call.method])
        [self setPrivacyConsent:call];
    else if ([@"OneSignal#requiresPrivacyConsent" isEqualToString:call.method])
        result(@(OneSignal.requiresPrivacyConsent));
    else if ([@"OneSignal#setRequiresPrivacyConsent" isEqualToString:call.method])
        [self setRequiresPrivacyConsent:call];
    else if ([@"OneSignal#setLaunchURLsInApp" isEqualToString:call.method])
        [self setLaunchURLsInApp:call];
     else if ([@"OneSignal#enterLiveActivity" isEqualToString:call.method])
        [self enterLiveActivity:call withResult:result];
    else if ([@"OneSignal#exitLiveActivity" isEqualToString:call.method])
        [self exitLiveActivity:call withResult:result];
    else
        result(FlutterMethodNotImplemented);
}

#pragma mark Init

- (void)initialize:(FlutterMethodCall *)call {

    [OneSignal initialize:call.arguments[@"appId"] withLaunchOptions:nil];
    // If the user has required privacy consent, the SDK will not
    // add these observers. So we should delay adding the observers
    // until consent has been provided.
    // if (OneSignal.requiresUserPrivacyConsent) {
    //     self.waitingForUserConsent = true;
    // } else {
    //     [self addObservers];
    // }
   // result(nil);
}

#pragma mark Login Logout

- (void)login:(FlutterMethodCall *)call {
    [OneSignal login:call.arguments[@"externalId"]];
}

- (void)logout:(FlutterMethodCall *)call {
    [OneSignal logout];
}

#pragma mark Privacy Consent

- (void)setPrivacyConsent:(FlutterMethodCall *)call {
    BOOL granted = [call.arguments[@"granted"] boolValue];
    [OneSignal setPrivacyConsent:granted];
}

- (void)setRequiresPrivacyConsent:(FlutterMethodCall *)call {
    BOOL required = [call.arguments[@"required"] boolValue];
    [OneSignal setRequiresPrivacyConsent:required];  
}

#pragma mark Launch Urls In App

- (void)setLaunchURLsInApp:(FlutterMethodCall *)call {
    BOOL launchUrlsInApp = [call.arguments[@"launchUrlsInApp"] boolValue];
    [OneSignal setLaunchURLsInApp:launchUrlsInApp];
}

#pragma mark Live Activity

- (void)enterLiveActivity:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *activityId = call.arguments[@"activityId"];
    NSString *token = call.arguments[@"token"];

    [OneSignal enterLiveActivity:activityId withToken:token withSuccess:^(NSDictionary *results) {
        result(results);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)exitLiveActivity:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *activityId = call.arguments[@"activityId"];

    [OneSignal exitLiveActivity:activityId withSuccess:^(NSDictionary *results) {
        result(results);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

@end
