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
        [self setLanguage:call];
    else if ([@"OneSignal#addAliasWithLabel" isEqualToString:call.method])
        [self addAliasWithLabel:call];
    else if ([@"OneSignal#addAliases" isEqualToString:call.method])
        [self addAliases:call];
    else if ([@"OneSignal#removeAlias" isEqualToString:call.method])
        [self removeAlias:call];
    else if ([@"OneSignal#removeAliases" isEqualToString:call.method])
        [self removeAliases:call];
    else if ([@"OneSignal#addTagWithKey" isEqualToString:call.method])
        [self addTagWithKey:call];
    else if ([@"OneSignal#addTags" isEqualToString:call.method])
        [self addTags:call];
    else if ([@"OneSignal#removeTag" isEqualToString:call.method])
        [self removeTag:call];
    else if ([@"OneSignal#removeTags" isEqualToString:call.method])
        [self removeTags:call];
    else if ([@"OneSignal#addEmail" isEqualToString:call.method])
        [self addEmail:call];
    else if ([@"OneSignal#removeEmail" isEqualToString:call.method])
        [self removeEmail:call withResult:result];
    else if ([@"OneSignal#addSmsNumber" isEqualToString:call.method])
        [self addSmsNumber:call];
    else if ([@"OneSignal#removeSmsNumber" isEqualToString:call.method])
        [self removeSmsNumber:call withResult:result];
    
    else
        result(FlutterMethodNotImplemented);
}

- (void)setLanguage:(FlutterMethodCall *)call {
    id language = call.arguments[@"language"];
    if (language == [NSNull null]) {
        language = nil;
    }

    [OneSignal.User setLanguage:language];
}

// TODO: may not need this
- (void)addAliasWithLabel:(FlutterMethodCall *)call {
    NSString *aliasId = call.arguments[@"aliasId"];
    NSNumber *aliasLabel = call.arguments[@"aliasLabel"];
    [OneSignal.User addAliasWithLabel:aliasLabel id:aliasId];
}

- (void)addAliases:(FlutterMethodCall *)call {
    NSDictionary *aliases = call.arguments;
    [OneSignal.User addAliases:aliases];
}

// TODO: may not need this
- (void)removeAlias:(FlutterMethodCall *)call {
    NSNumber *aliasLabel = call.arguments[@"alias"];
    [OneSignal.User removeAlias:aliasLabel];
}

- (void)removeAliases:(FlutterMethodCall *)call {
    NSDictionary *aliases = call.arguments;
    [OneSignal.User removeAliases:aliases];
}

// TODO: may not need this
- (void)addTagWithKey:(FlutterMethodCall *)call {
    NSString *key = call.arguments[@"key"];
    NSNumber *value = call.arguments[@"value"];
    [OneSignal.User addTagWithKey:key value:value];
}

- (void)addTags:(FlutterMethodCall *)call {
    NSDictionary *tags = call.arguments;
    [OneSignal.User addTags:tags];
}

// TODO: may not need this
- (void)removeTag:(FlutterMethodCall *)call {
    NSNumber *key = call.arguments[@"key"];
    [OneSignal.User removeTag:key];
}

- (void)removeTags:(FlutterMethodCall *)call {
    NSDictionary *tags = call.arguments;
    [OneSignal.User removeTags:tags];
}

- (void)addEmail:(FlutterMethodCall *)call {
    NSString *email = call.arguments;
    [OneSignal.User addEmail:email];
}

- (void)removeEmail:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *email = call.arguments[@"email"];
    result(@([OneSignal.User removeEmail:email]));
}

- (void)addSmsNumber:(FlutterMethodCall *)call {
    NSString *smsNumber = call.arguments;
    [OneSignal.User addSmsNumber:smsNumber];
}

- (void)removeSmsNumber:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSString *smsNumber = call.arguments[@"smsNumber"];
    result(@([OneSignal.User removeSmsNumber:smsNumber]));
}



@end
