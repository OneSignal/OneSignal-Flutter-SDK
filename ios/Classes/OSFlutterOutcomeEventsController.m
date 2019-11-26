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

#import "OSFlutterOutcomeEventsController.h"
#import <OneSignal/OneSignal.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterOutcomeEventsController
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterOutcomeEventsController *instance = [OSFlutterOutcomeEventsController new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#outcomes"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"OneSignal#sendOutcome" isEqualToString:call.method]) {
        [self sendOutcome:call withResult:result];
    } else if ([@"OneSignal#sendUniqueOutcome" isEqualToString:call.method]) {
        [self sendUniqueOutcome:call withResult:result];
    } else if ([@"OneSignal#sendOutcomeWithValue" isEqualToString:call.method]) {
        [self sendOutcomeWithValue:call withResult:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)sendOutcome:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *name = call.arguments;
    [OneSignal sendOutcome:name onSuccess:^(OSOutcomeEvent *outcome) {
        result(outcome.jsonRepresentation);
    }];
}

- (void)sendUniqueOutcome:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *name = call.arguments;
    [OneSignal sendUniqueOutcome:name onSuccess:^(OSOutcomeEvent *outcome) {
        result(outcome.jsonRepresentation);
    }];
}

- (void)sendOutcomeWithValue:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *name = call.arguments[@"outcome_name"];
    NSNumber *value = call.arguments[@"outcome_value"];
    [OneSignal sendOutcomeWithValue:name value:value onSuccess:^(OSOutcomeEvent *outcome) {
        result(outcome.jsonRepresentation);
    }];
}

@end
