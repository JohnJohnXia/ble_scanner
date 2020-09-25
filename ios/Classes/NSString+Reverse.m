//
//  NSString+Reverse.m
//  PateoBluetoochDemo
//
//  Created by john xia on 14-8-5.
//  Copyright (c) 2014年 Beyondsoft. All rights reserved.
//

#import "NSString+Reverse.h"

@implementation NSString (Reverse)

- (NSString *)reverseString
{
    NSUInteger length = [self length];
    
    NSMutableString *reversedString = [[NSMutableString alloc] initWithCapacity:length];
    
    while (length > 0) {
        [reversedString appendString:[NSString stringWithFormat:@"%c",[self characterAtIndex:--length]]];
    }
    
    return reversedString;
}

- (NSString *)hexStringTransformToBinaryString
{
    
    NSDictionary *hexDic = @{@"0": @"0000",
                             @"1": @"0001",
                             @"2": @"0010",
                             @"3": @"0011",
                             @"4": @"0100",
                             @"5": @"0101",
                             @"6": @"0110",
                             @"7": @"0111",
                             @"8": @"1000",
                             @"9": @"1001",
                             @"A": @"1010",
                             @"B": @"1011",
                             @"C": @"1100",
                             @"D": @"1101",
                             @"E": @"1110",
                             @"F": @"1111"};
    
    NSUInteger length = [self length];
    
    NSMutableString *binaryString = [[NSMutableString alloc] initWithCapacity:length*4];
    
    for (int i = 0; i < length; i ++) {
        NSString *key = [self substringWithRange:NSMakeRange(i, 1)];
        [binaryString appendString:[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
    }
    return binaryString;
}

- (NSString *)binaryStringTransformToHexString
{
    NSString *hexString = [NSString stringWithFormat:@"%lx",strtoul([self UTF8String], 0, 2)];
    return [hexString uppercaseString];
}

- (NSString *)hexStringTransformToDecString
{
    NSString *newHex = @"";
    if ([self hasPrefix:@"0x"]) {
        newHex = [self substringFromIndex:2];
    }else{
        newHex = self;
    }
    
    //第一种
    NSString *decStr = [NSString stringWithFormat:@"%lu",strtoul([newHex UTF8String], 0, 16)];
    
    //第二种
    //    NSScanner *scan = [NSScanner scannerWithString:newHex];
    //    unsigned int n = 0;
    //    [scan scanHexInt:&n];
    //    NSString *decStr = [NSString stringWithFormat:@"%d",n];
    
    return decStr;
}

- (NSString *)decStringTransformToHexString
{
    NSString *hexString = [NSString stringWithFormat:@"%lx",strtoul([self UTF8String], 0, 10)];
    NSString *resultStr = @"";
    if (hexString.length%2 == 1) {
        resultStr = [NSString stringWithFormat:@"0x0%@",hexString];
    }else{
        resultStr = [NSString stringWithFormat:@"0x%@",hexString];
    }
    return resultStr;
}

- (NSString *)decStringTransformToHexStringWithNoOX
{
    NSString *hexString = [NSString stringWithFormat:@"%lx",strtoul([self UTF8String], 0, 10)];
    NSString *resultStr = @"";
    if (hexString.length == 1) {
        resultStr = [NSString stringWithFormat:@"0%@",hexString];
    }else{
        resultStr = [NSString stringWithFormat:@"%@",hexString];
    }
    return resultStr;
}

- (NSArray *)asciiTransformToHexStringArray
{
    NSUInteger length = [self length];
    
    NSMutableArray *hexStringArray = [NSMutableArray arrayWithCapacity:0];
    //NSString *resultString = @"";
    
    for (int i = 0; i < length; i++) {
        
        int key = [self characterAtIndex:i];
        
        NSString *decString = [NSString stringWithFormat:@"%d",key];
        
        NSString *hexString = [decString decStringTransformToHexStringWithNoOX];
        
        [hexStringArray addObject:hexString];
        
//        if (isupper(key)) {
//            NSLog(@"大写字母");
//        }else if (islower(key)) {
//            NSLog(@"小写字母");
//        }else if (isdigit(key)) {
//            NSLog(@"数字");
//        }
    }
    
    //resultString = [hexStringArray componentsJoinedByString:@","];
    
    return hexStringArray;
}

- (NSData *)asciiTransformToData
{
    NSUInteger length = [self length];
    
    Byte dataBytes[length];
    //NSMutableData *resultData = [NSMutableData data];
    
    for (int i = 0; i < length; i++) {
        
        int key = [self characterAtIndex:i];
        
        dataBytes[i] = key;
        
        //[resultData appendBytes:dataBytes[i] length:1];
    }
    
    NSData *resultData = [[NSData alloc] initWithBytes:dataBytes length:length];
    
    return resultData;
}

- (NSData *)hexStringTransformToData
{
    NSString *hexString = self;
    
    if ([self hasPrefix:@"0x"]) {
        hexString = [self substringFromIndex:2];
    }
    
    NSUInteger dataLength = [hexString length]/2;
    
    Byte dataBytes[dataLength];
    
    for (int i = 0; i < dataLength; i++) {
        NSString *hex = [hexString substringWithRange:NSMakeRange(i*2, 2)];
        
        NSString *dec = [hex hexStringTransformToDecString];
        
        dataBytes[i] = [dec intValue];
    }
    
    NSData *resultData = [[NSData alloc] initWithBytes:dataBytes length:dataLength];
    
    return resultData;
}

- (NSString *)plusAnotherHexString:(NSString *)anotherHexString
{
    NSString *decStr1 = [self hexStringTransformToDecString];
    NSString *decStr2 = [anotherHexString hexStringTransformToDecString];
    
    int resultDecInt = [decStr1 intValue] + [decStr2 intValue];
    
    NSString *resultDecStr = [NSString stringWithFormat:@"%d",resultDecInt];
    
    return [resultDecStr decStringTransformToHexString];
}

- (NSString *)minusAnotherHexString:(NSString *)anotherHexString
{
    NSString *decStr1 = [self hexStringTransformToDecString];
    NSString *decStr2 = [anotherHexString hexStringTransformToDecString];
    
    int resultDecInt = [decStr1 intValue] - [decStr2 intValue];
    if (resultDecInt > 0) {
        NSString *resultDecStr = [NSString stringWithFormat:@"%d",resultDecInt];
        return [resultDecStr decStringTransformToHexString];
    }else{
        return @"";
    }
}

@end
