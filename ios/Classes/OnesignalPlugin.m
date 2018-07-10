#import "OnesignalPlugin.h"
#import <OneSignal/OneSignal.h>
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
          NSLog(@"Notification received in ObjC: %@", notification.stringify);
          [self handleReceivedNotification:notification];
      } handleNotificationAction:^(OSNotificationOpenedResult *result) {
          [self handleNotificationOpened:result];
      } settings:call.arguments[@"settings"]];
  } else if ([@"OneSignal#setLogLevel" isEqualToString:call.method]) {
      [OneSignal setLogLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"console"] intValue] visualLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"visual"] intValue]];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleReceivedNotification:(OSNotification *)notification {
    [self.channel invokeMethod:@"onesignal#handleReceivedNotification" arguments:notification.toJson];
}

- (void)handleNotificationOpened:(OSNotificationOpenedResult *)result {
    [self.channel invokeMethod:@"onesignal#handleOpenedNotification" arguments:result.toJson];
}

@end
