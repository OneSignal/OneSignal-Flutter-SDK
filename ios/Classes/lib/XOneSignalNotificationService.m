//
//  NotificationService.m
//  OneSignalNotificationServiceExtension
//
//  Created by Brad Hesse on 7/13/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import <OneSignal/OneSignal.h>
#import "OneSignalPlugin.h"

#import "XOneSignalNotificationService.h"

static XOneSignalNotificationService *obj;

@interface XOneSignalNotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNNotificationRequest *receivedRequest;
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation XOneSignalNotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.receivedRequest = request;
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    NSLog(@"didReceiveNotificationRequest");
    [OneSignalPlugin.sharedInstance.callbackChannel invokeMethod: @"OneSignal#onBackgroundNotification" arguments: self.bestAttemptContent];

    // [OneSignal didReceiveNotificationExtensionRequest:self.receivedRequest withMutableNotificationContent:self.bestAttemptContent withContentHandler:self.contentHandler];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    
    [OneSignal serviceExtensionTimeWillExpireRequest:self.receivedRequest withMutableNotificationContent:self.bestAttemptContent];
    
    self.contentHandler(self.bestAttemptContent);
}

@end
