//
//  BLEManager.h
//  ScanBLEDemo
//
//  Created by John Xia on 2020/6/22.
//  Copyright © 2020 John Xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    BLEConnectStatusPowerError = 0,
    BLEConnectStatusDiscovering,
    BLEConnectStatusDiscovered,
    BLEConnectStatusDiscoverNotFound,
    BLEConnectStatusConnectFail,
    BLEConnectStatusConnectSuccess,
    BLEConnectStatusDisconnect,
} BLEConnectStatus;

typedef void(^ScanCodeBlock)(NSString *code);

typedef void(^BLEConnectStatusBlock)(BLEConnectStatus status,NSString *bleTipString);

@interface BLEManager : NSObject

@property (strong, nonatomic) UIViewController *rootVC;

@property (strong, nonatomic) ScanCodeBlock codeBlock;

@property (strong, nonatomic) BLEConnectStatusBlock bleStatusBlock;

+ (BLEManager *)sharedInstance;

- (void)startScan;

- (void)sendData:(NSString *)string;

- (void)sendParcelId:(NSString *)parcelId extraString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
