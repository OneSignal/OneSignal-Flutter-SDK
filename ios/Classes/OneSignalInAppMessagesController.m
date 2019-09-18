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

#import "OneSignalInAppMessagesController.h"
#import <OneSignal/OneSignal.h>
#import "OneSignalCategories.h"

@implementation OneSignalInAppMessagesController
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OneSignalInAppMessagesController *instance = [OneSignalInAppMessagesController new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#inAppMessages"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

-(void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"OneSignal#addTrigger" isEqualToString:call.method]) {
        [OneSignal addTriggers:call.arguments];
    } else if ([@"OneSignal#addTriggers" isEqualToString:call.method]) {
        [OneSignal addTriggers:call.arguments];
    } else if ([@"OneSignal#removeTriggerForKey" isEqualToString:call.method]) {
        [OneSignal removeTriggerForKey:call.arguments];
    } else if ([@"OneSignal#removeTriggersForKeys" isEqualToString:call.method]) {
        [OneSignal removeTriggersForKeys:call.arguments];
    } else if ([@"OneSignal#getTriggerValueForKey" isEqualToString:call.method]) {
        result([OneSignal getTriggerValueForKey:call.arguments]);
    } else if ([@"OneSignal#pauseInAppMessages" isEqualToString:call.method]) {
        [OneSignal pauseInAppMessages:[call.arguments boolValue]];
    }
}
@end
