#import "OnesignalPlugin.h"
#import <OneSignal/OneSignal.h>

@implementation OnesignalPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"onesignal"
            binaryMessenger:[registrar messenger]];
  OnesignalPlugin* instance = [[OnesignalPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"OneSignal#init" isEqualToString:call.method]) {
     [OneSignal initWithLaunchOptions:nil appId:call.arguments[@"appId"]];
  } else if ([@"OneSignal#setLogLevel" isEqualToString:call.method]) {
      [OneSignal setLogLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"console"] intValue] visualLevel:(ONE_S_LOG_LEVEL)[call.arguments[@"visual"] intValue]];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
