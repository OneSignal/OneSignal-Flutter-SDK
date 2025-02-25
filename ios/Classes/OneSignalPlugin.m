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
#import "OSFlutterNotifications.h"
#import "OSFlutterSession.h"
#import "OSFlutterLocation.h"
#import "OSFlutterInAppMessages.h"
#import "OSFlutterLiveActivities.h"


@interface OneSignalPlugin ()

@property (strong, nonatomic) FlutterMethodChannel *channel;

@end

@implementation OneSignalPlugin

+ (instancetype)sharedInstance {
    static OneSignalPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OneSignalPlugin new];
    });
    return sharedInstance;
}

#pragma mark FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

    OneSignalWrapper.sdkType = @"flutter";
    OneSignalWrapper.sdkVersion = @"050300";
    [OneSignal initialize:nil withLaunchOptions:nil];

    OneSignalPlugin.sharedInstance.channel = [FlutterMethodChannel
                                     methodChannelWithName:@"OneSignal"
                                     binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:OneSignalPlugin.sharedInstance channel:OneSignalPlugin.sharedInstance.channel];
    [OSFlutterDebug registerWithRegistrar:registrar];
    [OSFlutterUser registerWithRegistrar:registrar];
    [OSFlutterNotifications registerWithRegistrar:registrar];
    [OSFlutterSession registerWithRegistrar:registrar];
    [OSFlutterLocation registerWithRegistrar:registrar];
    [OSFlutterInAppMessages registerWithRegistrar:registrar];
    [OSFlutterLiveActivities registerWithRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#initialize" isEqualToString:call.method])
        [self initialize:call withResult:result];
    else if ([@"OneSignal#login" isEqualToString:call.method])
        [self login:call withResult:result];
    else if ([@"OneSignal#logout" isEqualToString:call.method])
        [self logout:call withResult:result];
    else if ([@"OneSignal#consentRequired" isEqualToString:call.method])
        [self setConsentRequired:call withResult:result];
    else if ([@"OneSignal#consentGiven" isEqualToString:call.method])
        [self setConsentGiven:call withResult:result];
    else
        result(FlutterMethodNotImplemented);
}

#pragma mark Init

- (void)initialize:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    [OneSignal initialize:call.arguments[@"appId"] withLaunchOptions:nil];
    result(nil);
}

#pragma mark Login Logout

- (void)login:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    [OneSignal login:call.arguments[@"externalId"]];
    result(nil);
}

- (void)logout:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    [OneSignal logout];
    result(nil);
}

#pragma mark Privacy Consent

- (void)setConsentGiven:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    BOOL granted = [call.arguments[@"granted"] boolValue];
    [OneSignal setConsentGiven:granted];
    result(nil);
}

- (void)setConsentRequired:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    BOOL required = [call.arguments[@"required"] boolValue];
    [OneSignal setConsentRequired:required];  
    result(nil);
}

@end
