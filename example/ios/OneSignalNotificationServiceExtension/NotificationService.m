//
//  NotificationService.m
//  OneSignalNotificationServiceExtension
//
//  Created by Brad Hesse on 7/13/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "NotificationService.h"
#import <OneSignal/OneSignal.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) UNNotificationRequest *request;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    self.request = request;
    
    [OneSignal didReceiveNotificationExtensionRequest:request withMutableNotificationContent:self.bestAttemptContent];
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    
    [OneSignal serviceExtensionTimeWillExpireRequest:self.request withMutableNotificationContent:self.bestAttemptContent];
    
    self.contentHandler(self.bestAttemptContent);
}

@end
