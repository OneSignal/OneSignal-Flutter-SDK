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

#import "OSFlutterLocation.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterLocation
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterLocation *instance = [OSFlutterLocation new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#location"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#requestPermission" isEqualToString:call.method])
        [self requestPermission:call withResult:result];
    else if ([@"OneSignal#setShared" isEqualToString:call.method])
        [self setLocationShared:call withResult:result];
    else if ([@"OneSignal#isShared" isEqualToString:call.method])
        result(@([OneSignal.Location isShared]));
    else
        result(FlutterMethodNotImplemented);
}

- (void)setLocationShared:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL locationShared = [call.arguments boolValue];
    [OneSignal.Location setShared:locationShared];
    result(nil);
}

- (void)requestPermission:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.Location requestPermission];
    result(nil);
}



@end
