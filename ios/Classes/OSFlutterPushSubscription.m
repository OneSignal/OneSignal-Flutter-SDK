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

#import "OSFlutterPushSubscription.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import <OneSignalUser/OneSignalUser.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterPushSubscription

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterPushSubscription *instance = [OSFlutterPushSubscription new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#pushsubscription"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#pushSubscriptionId" isEqualToString:call.method])
        result(OneSignal.User.pushSubscription.id);
    else if ([@"OneSignal#pushSubscriptionToken" isEqualToString:call.method])
        result(OneSignal.User.pushSubscription.token);
    else if ([@"OneSignal#pushSubscriptionOptedIn" isEqualToString:call.method])
        result(@(OneSignal.User.pushSubscription.optedIn));
    else if ([@"OneSignal#optIn" isEqualToString:call.method])
        [self optIn:call withResult:result];
    else if ([@"OneSignal#optOut" isEqualToString:call.method])
        [self optOut:call withResult:result];
    else if ([@"OneSignal#lifecycleInit" isEqualToString:call.method])
        [self lifecycleInit:call withResult:result];
    else
        result(FlutterMethodNotImplemented);
}

- (void)optIn:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.User.pushSubscription optIn];
    result(nil);
}

- (void)optOut:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.User.pushSubscription optOut];
    result(nil);
}

- (void)lifecycleInit:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.User.pushSubscription addObserver:self];
    result(nil);
}

- (void)onPushSubscriptionDidChangeWithState:(OSPushSubscriptionChangedState *)state {
    [self.channel invokeMethod:@"OneSignal#onPushSubscriptionChange" arguments:state.jsonRepresentation];
}

@end

