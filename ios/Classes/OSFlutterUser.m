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

#import "OSFlutterUser.h"
#import <OneSignalFramework/OneSignalFramework.h>
#import <OneSignalUser/OneSignalUser.h>
#import "OSFlutterCategories.h"
#import "OSFlutterPushSubscription.h"


@implementation OSFlutterUser
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    OSFlutterUser *instance = [OSFlutterUser new];

    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"OneSignal#user"
                        binaryMessenger:[registrar messenger]];

    [registrar addMethodCallDelegate:instance channel:instance.channel];
    [OSFlutterPushSubscription registerWithRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"OneSignal#setLanguage" isEqualToString:call.method])
        [self setLanguage:call withResult:result];
    else if ([@"OneSignal#getOnesignalId" isEqualToString:call.method])
        [self getOnesignalId:call withResult:result];
    else if ([@"OneSignal#getExternalId" isEqualToString:call.method])
        [self getExternalId:call withResult:result];
    else if ([@"OneSignal#addAliases" isEqualToString:call.method])
        [self addAliases:call withResult:result];
    else if ([@"OneSignal#removeAliases" isEqualToString:call.method])
        [self removeAliases:call withResult:result];
    else if ([@"OneSignal#addTags" isEqualToString:call.method])
        [self addTags:call withResult:result];
    else if ([@"OneSignal#removeTags" isEqualToString:call.method])
        [self removeTags:call withResult:result];
    else if ([@"OneSignal#getTags" isEqualToString:call.method])
        [self getTags:call withResult:result];
    else if ([@"OneSignal#addEmail" isEqualToString:call.method])
        [self addEmail:call withResult:result];
    else if ([@"OneSignal#removeEmail" isEqualToString:call.method])
        [self removeEmail:call withResult:result];
    else if ([@"OneSignal#addSms" isEqualToString:call.method])
        [self addSms:call withResult:result];
    else if ([@"OneSignal#removeSms" isEqualToString:call.method])
        [self removeSms:call withResult:result];
    else if ([@"OneSignal#lifecycleInit" isEqualToString:call.method])
        [self lifecycleInit:call withResult:result];
    else
        result(FlutterMethodNotImplemented);
}

- (void)setLanguage:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    id language = call.arguments[@"language"];
    if (language == [NSNull null]) {
        language = nil;
    }

    [OneSignal.User setLanguage:language];
    result(nil);
}

- (void)addAliases:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *aliases = call.arguments;
    [OneSignal.User addAliases:aliases];
    result(nil);
}

- (void)removeAliases:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *aliases = call.arguments;
    [OneSignal.User removeAliases:aliases];
    result(nil);
}

- (void)addTags:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *tags = call.arguments;
    [OneSignal.User addTags:tags];
    result(nil);
}

- (void)removeTags:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSDictionary *tags = call.arguments;
    [OneSignal.User removeTags:tags];
    result(nil);
}

- (void)getTags:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result([OneSignal.User getTags]);
}

- (void)addEmail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *email = call.arguments;
    [OneSignal.User addEmail:email];
    result(nil);
}

- (void)removeEmail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *email = call.arguments;
    [OneSignal.User removeEmail:email];
    result(nil);
}

- (void)addSms:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *smsNumber = call.arguments;
    [OneSignal.User addSms:smsNumber];
    result(nil);
}

- (void)removeSms:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *smsNumber = call.arguments;
    [OneSignal.User removeSms:smsNumber];
    result(nil);
}

- (void)lifecycleInit:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    [OneSignal.User addObserver:self];
    result(nil);
}

- (void)onUserStateDidChangeWithState:(OSUserChangedState *)state {
    NSString *onesignalId = [self getStringOrNSNull:state.current.onesignalId];
    NSString *externalId = [self getStringOrNSNull:state.current.externalId];

    NSMutableDictionary *result = [NSMutableDictionary new];
    
    NSMutableDictionary *currentObject = [NSMutableDictionary new];
    
    currentObject[@"onesignalId"] = onesignalId;
    currentObject[@"externalId"] = externalId;
    result[@"current"] = currentObject;

    [self.channel invokeMethod:@"OneSignal#onUserStateChange" arguments:result];
}

- (void)getOnesignalId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result(OneSignal.User.onesignalId);
}

- (void)getExternalId:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    result(OneSignal.User.externalId);
}

/** Helper method to return NSNull if string is empty or nil **/
- (NSString *)getStringOrNSNull:(NSString *)string {
    // length method can be used on nil and strings
    if (string.length > 0) {
        return string;
    } else {
        return [NSNull null];
    }
}
@end
