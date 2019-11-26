/**
 * Modified MIT License
 *
 * Copyright 2019 OneSignal
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

#import "OSFlutterInAppMessagesController.h"
#import <OneSignal/OneSignal.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterInAppMessagesController
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterInAppMessagesController *instance = [OSFlutterInAppMessagesController new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#inAppMessages"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"OneSignal#addTrigger" isEqualToString:call.method]) {
        [self addTriggers:call withResult:result];
    } else if ([@"OneSignal#addTriggers" isEqualToString:call.method]) {
        [self addTriggers:call withResult:result];
    } else if ([@"OneSignal#removeTriggerForKey" isEqualToString:call.method]) {
        [self removeTriggerForKey:call withResult:result];
    } else if ([@"OneSignal#removeTriggersForKeys" isEqualToString:call.method]) {
        [self removeTriggersForKeys:call withResult:result];
    } else if ([@"OneSignal#getTriggerValueForKey" isEqualToString:call.method]) {
        result([OneSignal getTriggerValueForKey:call.arguments]);
    } else if ([@"OneSignal#pauseInAppMessages" isEqualToString:call.method]) {
        [self pauseInAppMessages:call withResult:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)addTriggers:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *triggers = call.arguments;
    [OneSignal addTriggers:triggers];
    result(nil);
}

- (void)removeTriggerForKey:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *key = call.arguments;
    [OneSignal removeTriggerForKey:key];
    result(nil);
}

- (void)removeTriggersForKeys:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSArray *keys = call.arguments;
    [OneSignal removeTriggersForKeys:keys];
    result(nil);
}

- (void)pauseInAppMessages:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL pause = [call.arguments boolValue];
    [OneSignal pauseInAppMessages:pause];
    result(nil);
}

@end
