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

#import "OneSignalCategories.h"

@implementation OSNotification (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[@"payload"] = [self.payload toJson];
    json[@"displayType"] = @((int)self.displayType);
    json[@"shown"] = @(self.shown);
    json[@"appInFocus"] = @(self.isAppInFocus);
    json[@"silent"] = @(self.silentNotification);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"Converted notification to JSON: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSLog(@"TITLE: %@", self.payload.title);
    return json;
}
@end

@implementation OSNotificationPayload (Flutter)
-(NSDictionary *)toJson {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[@"contentAvailable"] = @(self.contentAvailable);
    json[@"mutableContent"] = @(self.mutableContent);
    
    if (self.notificationID) json[@"notificationId"] = self.notificationID;
    if (self.rawPayload) json[@"rawPayload"] = self.rawPayload;
    if (self.templateName) json[@"templateName"] = self.templateName;
    if (self.templateID) json[@"templateId"] = self.templateID;
    if (self.badge) json[@"badge"] = @(self.badge);
    if (self.badgeIncrement) json[@"badgeIncrement"] = @(self.badgeIncrement);
    if (self.sound) json[@"sound"] = self.sound;
    if (self.title) json[@"title"] = self.title;
    if (self.subtitle) json[@"subtitle"] = self.subtitle;
    if (self.body) json[@"body"] = self.body;
    if (self.launchURL) json[@"launchUrl"] = self.launchURL;
    if (self.additionalData) json[@"additionalData"] = self.additionalData;
    if (self.attachments) json[@"attachments"] = self.attachments;
    if (self.actionButtons) json[@"buttons"] = self.actionButtons;
    if (self.category) json[@"category"] = self.category;
    
    return json;
}
@end

@implementation OSNotificationOpenedResult (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[@"notification"] = self.notification.toJson;
    json[@"action"] = @{@"type" : @((int)self.action.type), @"id" : self.action.actionID};
    
    return json;
}
@end

@implementation NSError (Flutter)
- (FlutterError *)flutterError {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"%i", (int)self.code] message:self.localizedDescription details:nil];
}
@end
