#import "OnesignalPlugin.h"
#import "OneSignalCategories.h"

@implementation OnesignalPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [OneSignal initWithLaunchOptions:nil appId:nil];
    
  OnesignalPlugin* instance = [[OnesignalPlugin alloc] init];
  instance.channel = [FlutterMethodChannel
                                     methodChannelWithName:@"onesignal"
                                     binaryMessenger:[registrar messenger]];
    
  [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"OneSignal#init" isEqualToString:call.method]) {
      [OneSignal initWithLaunchOptions:nil appId:call.arguments[@"appId"] handleNotificationReceived:^(OSNotification *notification) {
          [self handleReceivedNotification:notification];
      } handleNotificationAction:^(OSNotificationOpenedResult *result) {
          [self handleNotificationOpened:result];
      } settings:call.arguments[@"settings"]];

      [OneSignal addSubscriptionObserver:self];
  } else if ([@"OneSignal#setLogLevel" isEqualToString:call.method]) {
      [OneSignal setLogLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"console"] intValue] visualLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"visual"] intValue]];
  } else if ([@"OneSignal#requiresUserPrivacyConsent" isEqualToString:call.method]) {
      result(@(OneSignal.requiresUserPrivacyConsent));
  } else if ([@"OneSignal#consentGranted" isEqualToString:call.method]) {
      NSNumber *granted = call.arguments[@"granted"];
      
      if (!granted)
          return;
      
      [OneSignal consentGranted:[granted boolValue]];
  } else if ([@"OneSignal#setRequiresUserPrivacyConsent" isEqualToString:call.method]) {
      [OneSignal setRequiresUserPrivacyConsent:[call.arguments[@"required"] boolValue]];
  } else if ([@"OneSignal#promptPermission" isEqualToString:call.method]) {
      [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {
          [self.channel invokeMethod:@"OneSignal#userAnsweredPrompt" arguments:@(accepted)];
      }];
  } else if ([@"OneSignal#log" isEqualToString:call.method]) {
      [OneSignal onesignal_Log:(ONE_S_LOG_LEVEL)[call.arguments[@"logLevel"] integerValue] message:(NSString *)call.arguments[@"message"]];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleReceivedNotification:(OSNotification *)notification {
    [self.channel invokeMethod:@"OneSignal#handleReceivedNotification" arguments:@[notification.toJson]];
}

- (void)handleNotificationOpened:(OSNotificationOpenedResult *)result {
    [self.channel invokeMethod:@"OneSignal#handleOpenedNotification" arguments:@[result.toJson]];
}

- (void)onOSSubscriptionChanged:(OSSubscriptionStateChanges*)stateChanges {
   [self.channel invokeMethod:@"OneSignal#subscriptionChanged" arguments: @[stateChanges.toDictionary]];
}

@end
