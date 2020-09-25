//
//  BLEManager.m
//  ScanBLEDemo
//
//  Created by John Xia on 2020/6/22.
//  Copyright © 2020 John Xia. All rights reserved.
//

#import "BLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSData+TransformToString.h"
#import "NSString+Reverse.h"

@interface BLEManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSInteger   _totalServiceCount;
    
    NSInteger   _currentServiceCount;
    
    NSInteger   _totalCharacteristicCount;
    
    NSInteger   _currentCharacteristicCount;
    
    NSString    *_bleTipText;
    
    BOOL        _isBluetoothPowerOn;
    
    BOOL        _isPeripheralConnected;
}

@property (atomic, strong) dispatch_queue_t         bluetoothQueue;

@property (strong, nonatomic) CBCentralManager      *centralManager;

@property (strong, nonatomic) CBPeripheral          *connectedPeripheral;

@property (strong, nonatomic) CBCharacteristic      *writeNotifyCharacteristic;

@end

@implementation BLEManager

+ (BLEManager *)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey : @"UBoxCenterManagerIdentifier"}];
        
        self.bluetoothQueue = dispatch_queue_create("com.ubtech.corebluetooth.queue", DISPATCH_QUEUE_SERIAL);
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.bluetoothQueue options:nil];
        
        //self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    
    return self;
}

#pragma mark - Custom Method

- (void)updateLogFormat:(NSString *)format,... NS_FORMAT_FUNCTION(1,2)
{
//    if (self.rootVC) {
//        [self.rootVC updateLogFormat:format];
//    }
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    
    NSLog(@"BLE: %@",str);
}

- (void)startScan
{
    dispatch_async(self.bluetoothQueue, ^{
        [self.centralManager stopScan];
    });
    
    if (_isBluetoothPowerOn) {
        if (_isPeripheralConnected) {
            if (_bleStatusBlock) {
                _bleStatusBlock(BLEConnectStatusConnectSuccess,@"Connected");
            }
        }else {
            if (_bleStatusBlock) {
                _bleStatusBlock(BLEConnectStatusDiscovering,@"Discovering");
            }
        }
    }else {
        if (_bleStatusBlock) {
            _bleStatusBlock(BLEConnectStatusPowerError,_bleTipText);
        }
    }
    
    dispatch_async(self.bluetoothQueue, ^{
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFF0"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
        
        [self updateLogFormat:@"开始扫描"];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_isBluetoothPowerOn && !_isPeripheralConnected) {
            if (_bleStatusBlock) {
                _bleStatusBlock(BLEConnectStatusDiscoverNotFound,@"Not found");
            }
        }
    });
    
}

- (void)sendData:(NSString *)string
{
    if (!string || string.length == 0) {
        return;
    }
    
    NSData *data = [string asciiTransformToData];
    
    NSMutableData *commandData = [NSMutableData data];
    
    Byte startByte[] = {0x02,0x00};
    [commandData appendData:[NSData dataWithBytes:startByte length:2]];
    
    NSData *lengthData = [[[NSString stringWithFormat:@"%ld",data.length] decStringTransformToHexString] hexStringTransformToData];
    [commandData appendData:lengthData];
    
    [commandData appendData:data];
    
    Byte endByte[] = {0x0d,0x0d};
    [commandData appendData:[NSData dataWithBytes:endByte length:2]];
    
    [self updateLogFormat:@"发送命令 %@",commandData];
    
    [self.connectedPeripheral writeValue:commandData forCharacteristic:self.writeNotifyCharacteristic type:CBCharacteristicWriteWithResponse];
    
}

- (void)sendParcelIdData:(NSData *)parcelData batchNo:(NSString *)string
{
    if (!string || string.length == 0) {
        return;
    }
    
    NSData *data = [string asciiTransformToData];
    
    NSMutableData *commandData = [NSMutableData data];
    
    Byte startByte[] = {0x02,0x00};
    [commandData appendData:[NSData dataWithBytes:startByte length:2]];
    
    NSData *lengthData = [[[NSString stringWithFormat:@"%ld",parcelData.length+data.length] decStringTransformToHexString] hexStringTransformToData];
    [commandData appendData:lengthData];
    
    [commandData appendData:parcelData];
    
    [commandData appendData:data];
    
    Byte endByte[] = {0x0d,0x0d};
    [commandData appendData:[NSData dataWithBytes:endByte length:2]];
    
    [self updateLogFormat:@"发送命令 %@",commandData];
    
    [self.connectedPeripheral writeValue:commandData forCharacteristic:self.writeNotifyCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)sendParcelId:(NSString *)parcelId extraString:(NSString *)extraString
{
    if (!extraString || extraString.length == 0) {
        return;
    }
    
    NSData *parcelIdData = [parcelId asciiTransformToData];
    
    NSData *extraData = [extraString asciiTransformToData];
    
    NSMutableData *commandData = [NSMutableData data];
    
    Byte startByte[] = {0x02,0x00};
    [commandData appendData:[NSData dataWithBytes:startByte length:2]];
    
    NSData *lengthData = [[[NSString stringWithFormat:@"%ld",parcelIdData.length+1+extraData.length+2] decStringTransformToHexString] hexStringTransformToData];
    [commandData appendData:lengthData];
    
    [commandData appendData:parcelIdData];
    
    Byte lineByte[] = {0x0d};
    [commandData appendData:[NSData dataWithBytes:lineByte length:1]];
    
    [commandData appendData:extraData];
    
    Byte cutByte[] = {0x0d,0x0d};
    [commandData appendData:[NSData dataWithBytes:cutByte length:2]];
    
    Byte endByte[] = {0x0d,0x0d};
    [commandData appendData:[NSData dataWithBytes:endByte length:2]];
    
    [self updateLogFormat:@"发送命令 %@",commandData];
    
    [self.connectedPeripheral writeValue:commandData forCharacteristic:self.writeNotifyCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSString *messtoshow;
        
    _isBluetoothPowerOn = NO;
    _isPeripheralConnected = NO;
    
    switch (central.state) {
        case CBManagerStateUnknown:
        {
            messtoshow = [NSString stringWithFormat:@"State unknown, update imminent."];
            break;
        }
        case CBManagerStateResetting:
        {
            messtoshow = [NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            break;
        }
        case CBManagerStateUnsupported:
        {
            messtoshow = [NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            break;
        }
        case CBManagerStateUnauthorized:
        {
            messtoshow = [NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            break;
        }
        case CBManagerStatePoweredOff:
        {
            messtoshow = @"Please turn on Bluetooth";
            break;
        }
        case CBManagerStatePoweredOn:
        {
            _isBluetoothPowerOn = YES;
            messtoshow = @"蓝牙正常";
            [self startScan];
            break;
        }
    }
    
    _bleTipText = messtoshow;
    
    if (central.state != CBManagerStatePoweredOn && _bleStatusBlock) {
        _bleStatusBlock(BLEConnectStatusPowerError,messtoshow);
    }
    
    [self updateLogFormat:@"CentralManagerState %@",messtoshow];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self updateLogFormat:@"\n Discovered %@ at %ld\n uuid us %@ service is %@", peripheral.name, (long)RSSI.integerValue,peripheral.identifier.UUIDString,peripheral.services];
    
    if (_bleStatusBlock) {
        _bleStatusBlock(BLEConnectStatusDiscovered,@"Discovered");
    }
    
    self.connectedPeripheral = peripheral;
    [central connectPeripheral:peripheral options:nil];
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [central stopScan];
    
    [self updateLogFormat:@"Connect %@ Success",peripheral.name];
    
    _isPeripheralConnected = YES;
    
    if (_bleStatusBlock) {
        _bleStatusBlock(BLEConnectStatusConnectSuccess,@"Conected");
    }
    
    self.connectedPeripheral = peripheral;
    
    [self.connectedPeripheral setDelegate:self];
    [self.connectedPeripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    
    _isPeripheralConnected = NO;
    
    [self updateLogFormat:@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]];
    
    if (_bleStatusBlock) {
        _bleStatusBlock(BLEConnectStatusConnectFail,[error localizedDescription]);
    }
    
    [central stopScan];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self updateLogFormat:@"%@ Disconnected",peripheral.name];
    
    _isPeripheralConnected = NO;
    if (_bleStatusBlock) {
        _bleStatusBlock(BLEConnectStatusDisconnect,!error ? error.localizedDescription : @"Disconected");
    }
    
    _currentServiceCount = 0;
    _totalServiceCount = 0;
    
    [self.centralManager cancelPeripheralConnection:peripheral];
    [self updateLogFormat:@"Ready to reconnect %@",peripheral.name];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        
        NSLog(@"serviceUUID is %@",service.UUID);
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    NSLog(@"发现服务:%@ (%@)",service.UUID.data ,service.UUID);
    _currentServiceCount++;
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"特征 UUID: %@ (%@) property:%lu",characteristic.UUID.data,characteristic.UUID,(unsigned long)characteristic.properties);
        
        if (characteristic.properties == CBCharacteristicPropertyNotify) {
            //NSLog(@"notify UUID: %@")
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }else if (characteristic.properties == CBCharacteristicPropertyWrite) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]) {
            
            [self updateLogFormat:@"发现写特征服务 %@",characteristic.UUID];
            
            self.writeNotifyCharacteristic = characteristic;
            
            [peripheral setNotifyValue:YES forCharacteristic:self.writeNotifyCharacteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        //NSLog(@"=======%@",error.userInfo);
        [self updateLogFormat:@"发送命令失败 error:%@",error.userInfo];
    }else{
        //NSLog(@"发送数据成功");
        [self updateLogFormat:@"发送命令成功",nil];
    }
}

//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//{
//    NSLog(@"发现描述的特征:%@ (%@)",characteristic.UUID.data ,characteristic.UUID);
//
//    NSLog(@"setNotifyValue:YES forCharacteristic: %@", characteristic.UUID);
//    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//
//    for (CBDescriptor *des in characteristic.descriptors) {
//
//        NSLog(@"描述 UUID: %@ (%@)",des.UUID.data,des.UUID);
//
//    }
//}

/**
 *  获取外设发来的数据，-[readValueForCharacteristic:]方式。
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"char uuid is %@",characteristic.UUID);
    //NSLog(@"value data is %@",characteristic.value);
    
    [self updateLogFormat:@"蓝牙外设发送来的数据 %@",characteristic.value];
    
    NSString *str = [[NSString alloc] initWithBytes:characteristic.value.bytes length:characteristic.value.length encoding:NSUTF8StringEncoding];

    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    [self updateLogFormat:@"解析后数据 %@",str];
    
    if (_codeBlock) {
        _codeBlock(str);
    }
    
//    NSData *parcelData = [[str stringByAppendingString:@"\r\n\t"] dataUsingEncoding:NSUTF8StringEncoding];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self sendParcelIdData:parcelData batchNo:@"1-2-3423"];
//
//        //[self sendData:@"1-2-3423"];
//    });
}

@end
