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

#import "OSFlutterInAppMessages.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import "OSFlutterCategories.h"

@implementation OSFlutterInAppMessages

+ (instancetype)sharedInstance {
    static OSFlutterInAppMessages *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [OSFlutterInAppMessages new];
    });
    return sharedInstance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
   
    OSFlutterInAppMessages.sharedInstance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#inappmessages"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:OSFlutterInAppMessages.sharedInstance channel:OSFlutterInAppMessages.sharedInstance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"OneSignal#addTrigger" isEqualToString:call.method]) 
        [self addTriggers:call withResult:result];
    else if ([@"OneSignal#addTriggers" isEqualToString:call.method]) 
        [self addTriggers:call withResult:result];
    else if ([@"OneSignal#removeTrigger" isEqualToString:call.method]) 
        [self removeTrigger:call withResult:result];
    else if ([@"OneSignal#removeTriggers" isEqualToString:call.method]) 
        [self removeTriggers:call withResult:result];
    else if ([@"OneSignal#clearTriggers" isEqualToString:call.method]) 
          [self clearTriggers:call withResult:result];
    else if ([@"OneSignal#paused" isEqualToString:call.method]) 
        [self paused:call withResult:result];
    else if ([@"OneSignal#arePaused" isEqualToString:call.method]) 
        result(@([OneSignal.InAppMessages paused]));
    else if ([@"OneSignal#lifecycleInit" isEqualToString:call.method])
        [self lifecycleInit:call withResult:result];
    else 
        result(FlutterMethodNotImplemented);
    
}

- (void)addTriggers:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *triggers = call.arguments;
    [OneSignal.InAppMessages addTriggers:triggers];
    result(nil);
}

- (void)removeTrigger:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *key = call.arguments;
    [OneSignal.InAppMessages removeTrigger:key];
    result(nil);
}

- (void)removeTriggers:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSArray *keys = call.arguments;
    [OneSignal.InAppMessages removeTriggers:keys];
    result(nil);
}

- (void)clearTriggers:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.InAppMessages clearTriggers];
    result(nil);
}

- (void)paused:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    BOOL pause = [call.arguments boolValue];
    [OneSignal.InAppMessages paused:pause];
    result(nil);
}

- (void)lifecycleInit:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.InAppMessages addClickListener:OSFlutterInAppMessages.sharedInstance];
    [OneSignal.InAppMessages addLifecycleListener:OSFlutterInAppMessages.sharedInstance];
}



#pragma mark In App Message Click

- (void)onClickInAppMessage:(OSInAppMessageClickEvent * _Nonnull)event {
    [self.channel invokeMethod:@"OneSignal#onClickInAppMessage" arguments:event.toJson];
}

#pragma mark OSInAppMessageLifecycleListener
- (void)onWillDisplayInAppMessage:(OSInAppMessageWillDisplayEvent *) event {
    [self.channel invokeMethod:@"OneSignal#onWillDisplayInAppMessage" arguments:event.toJson];
}

- (void)onDidDisplayInAppMessage:(OSInAppMessageDidDisplayEvent *) event {
    [self.channel invokeMethod:@"OneSignal#onDidDisplayInAppMessage" arguments:event.toJson];
}

- (void)onWillDismissInAppMessage:(OSInAppMessageWillDismissEvent *) event {
    [self.channel invokeMethod:@"OneSignal#onWillDismissInAppMessage" arguments:event.toJson];
}

- (void)onDidDismissInAppMessage:(OSInAppMessageDidDismissEvent *) event {
    [self.channel invokeMethod:@"OneSignal#onDidDismissInAppMessage" arguments:event.toJson];
}

@end
