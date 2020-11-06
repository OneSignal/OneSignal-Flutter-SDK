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

#import "OSFlutterCategories.h"

/*
    The OneSignal iOS SDK implements similar methods (`toDictionary`)
    However we decided to implement custom `toJson` methods for several
    of these objects to add more properties.

    TODO: Update the native iOS SDK to add these details
    (ie. `templateId` is missing from OSNotificationPayload's `toDictionary`
    method in the native SDK) and remove them from here.
*/

@implementation OSNotification (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *json = [NSMutableDictionary new];

    json[@"contentAvailable"] = @(self.contentAvailable);
    json[@"mutableContent"] = @(self.mutableContent);

    if (self.rawPayload) {
        NSError *jsonError;
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.rawPayload options:NSJSONWritingPrettyPrinted error:&jsonError];

        if (!jsonError) {
            NSString *rawPayloadString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            json[@"rawPayload"] = rawPayloadString;
        }
    }

    if (self.notificationId) json[@"notificationId"] = self.notificationId;
    if (self.templateName) json[@"templateName"] = self.templateName;
    if (self.templateId) json[@"templateId"] = self.templateId;
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

    if (self.notification) json[@"notification"] = self.notification.toJson;
    if (self.action.actionId) json[@"action"] = @{@"type" : @((int)self.action.type), @"id" : self.action.actionId};

    return json;
}
@end

@implementation OSInAppMessageAction (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *json = [NSMutableDictionary new];

    json[@"click_name"] = self.clickName;
    json[@"click_url"] = self.clickUrl.absoluteString;
    json[@"first_click"] = @(self.firstClick);
    json[@"closes_message"] = @(self.closesMessage);

    return json;
}
@end

@implementation NSError (Flutter)
- (FlutterError *)flutterError {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"%i", (int)self.code] message:self.localizedDescription details:nil];
}
@end
