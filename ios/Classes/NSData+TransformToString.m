//
//  NSData+TransformToString.m
//  PateoBluetoochDemo
//
//  Created by john xia on 14-8-6.
//  Copyright (c) 2014年 Beyondsoft. All rights reserved.
//

#import "NSData+TransformToString.h"
#import "NSString+Reverse.h"

@implementation NSData (TransformToString)

- (NSString *)dataTransformToHexString
{
    NSString *resultHexStr = @"";
    Byte *byte = (Byte *)[self bytes];
    
    for (int i = 0; i<[self length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",byte[i]&0xff]; //16进制数
        if ([newHexStr length] == 1) {//若只有一位则在前面加0
            resultHexStr = [NSString stringWithFormat:@"%@0%@",resultHexStr,newHexStr];
        }else{
            resultHexStr = [NSString stringWithFormat:@"%@%@",resultHexStr,newHexStr];
        }
    }
    return resultHexStr;
}

- (NSString *)dataTransformToDecString
{
    NSString *resultHexStr = @"";
    Byte *byte = (Byte *)[self bytes];
    
    for (int i = 0; i<[self length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%hhu",byte[i]]; //10进制数
        if ([newHexStr length] == 1) {//若只有一位则在前面加0
            resultHexStr = [NSString stringWithFormat:@"%@0%@",resultHexStr,newHexStr];
        }else{
            resultHexStr = [NSString stringWithFormat:@"%@%@",resultHexStr,newHexStr];
        }
    }
    return resultHexStr;
}

- (NSString *)dataTransformateToASCIIString
{
    int letterA = 65;  //A
    int letterZ = 90;  //Z
    int lettera = 97;  //a
    int letterz = 122; //z
    int number0 = 48;  //0
    int number9 = 57;  //9
    
    NSMutableString *asciiString = [NSMutableString string];
    Byte *byte = (Byte *)[self bytes];
    
    for (int i = 0; i < [self length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%hhu",byte[i]]; //10进制数
        int value = [newHexStr intValue];
        if (value >= letterA && value <= letterZ) {
            [asciiString appendFormat:@"%c",'A' + value - letterA];
        }else if (value >= lettera && value <= letterz){
            [asciiString appendFormat:@"%c",'a' + value - lettera];
        }else if (value >= number0 && value <= number9){
            [asciiString appendFormat:@"%d",value - number0];
        }else if (value == 0){
            //[asciiString appendFormat:@"Nul"];
            [asciiString appendFormat:@""];
        }else if (value == 46){
            [asciiString appendFormat:@"."];
        }else{
            [asciiString appendFormat:@"%c",value];
        }
    }
    return asciiString;
}

- (NSString *)lowFrontDataTransformToHighFrontHexString
{
    NSString *resultHexStr = @"";
    Byte *byte = (Byte *)[self bytes];
    
    for (int i = 0; i<[self length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",byte[i]&0xff]; //16进制数
        if ([newHexStr length] == 1) {//若只有一位则在前面加0
            resultHexStr = [NSString stringWithFormat:@"0%@%@",newHexStr,resultHexStr];
        }else{
            resultHexStr = [NSString stringWithFormat:@"%@%@",newHexStr,resultHexStr];
        }
    }
    return resultHexStr;
}

- (NSData *)lowDataForEachByteInDataToPlus
{
    int resultValue = 0;
    Byte dataBytes[1] = {0};
    
    Byte *byte = (Byte *)[self bytes];
    for (int i = 0; i < [self length]; i ++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%hhu",byte[i]]; //10进制数
        int value = [newHexStr intValue];
        
        resultValue += value;
    }
    
    NSString *decStr = [NSString stringWithFormat:@"%d",resultValue];
    NSString *hexStr = [decStr decStringTransformToHexStringWithNoOX];
    
    if ([hexStr length] <= 2) {
        dataBytes[0] = resultValue;
        
    }else if ([hexStr length] > 2) {
        NSString *resultHexStr = [hexStr substringWithRange:NSMakeRange(hexStr.length-2, 2)];
        
        NSString *resultDecStr = [resultHexStr hexStringTransformToDecString];
        
        dataBytes[0] = [resultDecStr intValue];
    }
    
    NSData *resultData = [[NSData alloc] initWithBytes:dataBytes length:1];
    
    return resultData;
}

@end
