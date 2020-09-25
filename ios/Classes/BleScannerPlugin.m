#import "BleScannerPlugin.h"
#import "BLEManager.h"

NSString *const BLE_METHOD_CHANNEL_NAME = @"plugins.flutter.io/ble/methods";

@interface BleScannerPlugin ()

@property (strong, nonatomic) FlutterMethodChannel *methodChannel;

@end

@implementation BleScannerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:BLE_METHOD_CHANNEL_NAME
                                                              binaryMessenger:[registrar messenger]];
        
  BleScannerPlugin *instance = [[BleScannerPlugin alloc] initWithMethodChannel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel
{
    self = [super init];
    if (self) {
        
        _methodChannel = channel;
        
        [BLEManager sharedInstance].codeBlock = ^(NSString * _Nonnull code) {
            [self.methodChannel invokeMethod:@"scanResult" arguments:@{@"codeValue":code}];
        };
        
        [BLEManager sharedInstance].bleStatusBlock = ^(BLEConnectStatus status, NSString * _Nonnull bleTipString) {
            
            NSString *eventType = @"bluetoothPowerError";
            
            switch (status) {
                case BLEConnectStatusPowerError:
                    eventType = @"bluetoothPowerError";
                    break;
                case BLEConnectStatusDiscovered:
                    eventType = @"bluetoothDiscovered";
                    break;
                case BLEConnectStatusDiscoverNotFound:
                    eventType = @"bluetoothDiscoverNotFound";
                    break;
                case BLEConnectStatusDisconnect:
                    eventType = @"bluetoothDisconnect";
                    break;
                case BLEConnectStatusConnectSuccess:
                    eventType = @"bluetoothConnectSuccess";
                    break;
                case BLEConnectStatusConnectFail:
                    eventType = @"bluetoothConnectFail";
                    break;
                default:
                    break;
            }
            
            [self.methodChannel invokeMethod:@"bleStatus" arguments:@{@"status":@(status)}];
        };
        
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"startScan"]) {
      [[BLEManager sharedInstance] startScan];
  }else if ([call.method isEqualToString:@"sendExtraData"]) {
      [[BLEManager sharedInstance] sendParcelId:call.arguments[@"parcelId"]
                                    extraString:call.arguments[@"extraData"]];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

@end
