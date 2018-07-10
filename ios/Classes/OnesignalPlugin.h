#import <Flutter/Flutter.h>

@interface OnesignalPlugin : NSObject<FlutterPlugin>
@property (strong, nonatomic) FlutterMethodChannel *channel;
@end