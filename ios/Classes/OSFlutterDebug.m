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

#import "OSFlutterDebug.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterDebug
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterDebug *instance = [OSFlutterDebug new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#debug"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#setLogLevel" isEqualToString:call.method])
        [self setLogLevel:call withResult:result];
    else if ([@"OneSignal#setAlertLevel" isEqualToString:call.method])
        [self setAlertLevel:call withResult:result];
    else 
        result(FlutterMethodNotImplemented);
}

- (void)setLogLevel:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    ONE_S_LOG_LEVEL logLevel = (ONE_S_LOG_LEVEL)[call.arguments[@"logLevel"] intValue];
    [OneSignal.Debug setLogLevel:logLevel];
    result(nil);
}

- (void)setAlertLevel:(FlutterMethodCall *)call withResult:(FlutterResult)result{
    ONE_S_LOG_LEVEL visualLogLevel = (ONE_S_LOG_LEVEL)[call.arguments[@"visualLevel"] intValue];
    [OneSignal.Debug setAlertLevel:visualLogLevel];
    result(nil);
}

@end
