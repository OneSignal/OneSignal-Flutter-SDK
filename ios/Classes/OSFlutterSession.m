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

#import "OSFlutterSession.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterSession
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterSession *instance = [OSFlutterSession new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#session"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"OneSignal#addOutcome" isEqualToString:call.method]) {
        [self addOutcome:call withResult:result];
    } else if ([@"OneSignal#addUniqueOutcome" isEqualToString:call.method]) {
        [self addUniqueOutcome:call withResult:result];
    } else if ([@"OneSignal#addOutcomeWithValue" isEqualToString:call.method]) {
        [self addOutcomeWithValue:call withResult:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)addOutcome:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *name = call.arguments;
    [OneSignal.Session addOutcome:name];
    result(nil);
}

- (void)addUniqueOutcome:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *name = call.arguments;
    [OneSignal.Session addUniqueOutcome:name];
    result(nil);
}

- (void)addOutcomeWithValue:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *name = call.arguments[@"outcome_name"];
    NSNumber *value = call.arguments[@"outcome_value"];
    [OneSignal.Session addOutcomeWithValue:name value:value];
    result(nil);
}


@end
