/**
 * Modified MIT License
 *
 * Copyright 2017 OneSignal
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

#import "OSFlutterTagsController.h"
#import <OneSignal/OneSignal.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterTagsController
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterTagsController *instance = [OSFlutterTagsController new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#tags"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"OneSignal#sendTags" isEqualToString:call.method]) {
        [self sendTags:call withResult:result];
    } else if ([@"OneSignal#getTags" isEqualToString:call.method]) {
        [self getTags:call withResult:result];
    } else if ([@"OneSignal#deleteTags" isEqualToString:call.method]) {
        [self deleteTags:call withResult:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)sendTags:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *tags = call.arguments;
    [OneSignal sendTags:tags onSuccess:^(NSDictionary *tags) {
        result(tags);
    } onFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)getTags:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal getTags:^(NSDictionary *tags) {
        result(tags);
    } onFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

- (void)deleteTags:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSArray *tags = call.arguments;
    [OneSignal deleteTags:tags onSuccess:^(NSDictionary *response) {
        result(response);
    } onFailure:^(NSError *error) {
        result(error.flutterError);
    }];
}

@end
