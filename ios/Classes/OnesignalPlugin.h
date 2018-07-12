#import <Flutter/Flutter.h>
#import <OneSignal/OneSignal.h>

@interface OnesignalPlugin : NSObject<FlutterPlugin, OSSubscriptionObserver>
@property (strong, nonatomic) FlutterMethodChannel *channel;
@end