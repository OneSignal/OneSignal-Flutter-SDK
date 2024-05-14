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

#import "OSFlutterLiveActivities.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import "OneSignalLiveActivities/OneSignalLiveActivities-Swift.h"
#import "OSFlutterCategories.h"

@implementation OSFlutterLiveActivities
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterLiveActivities *instance = [OSFlutterLiveActivities new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#liveactivities"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#enterLiveActivity" isEqualToString:call.method])
        [self enterLiveActivity:call withResult:result];
    else if ([@"OneSignal#exitLiveActivity" isEqualToString:call.method])
        [self exitLiveActivity:call withResult:result];
    else if ([@"OneSignal#setPushToStartToken" isEqualToString:call.method])
        [self setPushToStartToken:call withResult:result];
    else if ([@"OneSignal#removePushToStartToken" isEqualToString:call.method])
        [self removePushToStartToken:call withResult:result];
    else if ([@"OneSignal#setupDefault" isEqualToString:call.method])
        [self setupDefault:call withResult:result];
    else if ([@"OneSignal#startDefault" isEqualToString:call.method])
        [self startDefault:call withResult:result];
    else 
        result(FlutterMethodNotImplemented);
}

- (void)enterLiveActivity:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *activityId = call.arguments[@"activityId"];
    NSString *token = call.arguments[@"token"];

    [OneSignal.LiveActivities enter:activityId withToken:token withSuccess:^(NSDictionary *results) {
        result(results);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)exitLiveActivity:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *activityId = call.arguments[@"activityId"];

    [OneSignal.LiveActivities exit:activityId withSuccess:^(NSDictionary *results) {
        result(results);
    } withFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)setPushToStartToken:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *activityType = call.arguments[@"activityType"];
    NSString *token = call.arguments[@"token"];
    NSError* err=nil;

    if (@available(iOS 17.2, *)) {
        [OneSignalLiveActivitiesManagerImpl setPushToStartToken:activityType withToken:token error:&err];
        if (err) {
            [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"activityType must be the name of your ActivityAttributes struct"]];
        }
    } else {
        [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"cannot setPushToStartToken on iOS < 17.2"]];
    }

    result(nil);
}

- (void)removePushToStartToken:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *activityType = call.arguments[@"activityType"];
    NSError* err=nil;

    if (@available(iOS 17.2, *)) {
        [OneSignalLiveActivitiesManagerImpl removePushToStartToken:activityType error:&err];
        if (err) {
            [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"activityType must be the name of your ActivityAttributes struct"]];
        }
    } else {
        [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"cannot removePushToStartToken on iOS < 17.2"]];
    }

    result(nil);
}

- (void)setupDefault:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *options = call.arguments[@"options"];

    LiveActivitySetupOptions *laOptions = nil;

    if (options != [NSNull null]) {
        laOptions = [LiveActivitySetupOptions alloc];
        [laOptions setEnablePushToStart:[options[@"enablePushToStart"] boolValue]];
        [laOptions setEnablePushToUpdate:[options[@"enablePushToUpdate"] boolValue]];
    }

    if (@available(iOS 16.1, *)) {
        [OneSignalLiveActivitiesManagerImpl setupDefaultWithOptions:laOptions];
    } else {
        [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"cannot setupDefault on iOS < 16.1"]];
    }

    result(nil);
}

- (void)startDefault:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *activityId = call.arguments[@"activityId"];
    NSDictionary *attributes = call.arguments[@"attributes"];
    NSDictionary *content = call.arguments[@"content"];

    if (@available(iOS 16.1, *)) {
        [OneSignalLiveActivitiesManagerImpl startDefault:activityId attributes:attributes content:content];
    } else {
        [OneSignalLog onesignalLog:ONE_S_LL_ERROR message:[NSString stringWithFormat:@"cannot startDefault on iOS < 16.1"]];
    }

    result(nil);
}

@end
