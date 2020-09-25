//
//  NSData+TransformToString.h
//  PateoBluetoochDemo
//
//  Created by john xia on 14-8-6.
//  Copyright (c) 2014年 Beyondsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (TransformToString)

/**
 *  转换 NSData 为16进制字符串
 *
 *  @return 转换返回的16进制NSString结果
 */
- (NSString *)dataTransformToHexString;

/**
 *  转换 NSData 为10进制字符串
 *
 *  @return 转换返回的10进制NSString结果
 */
- (NSString *)dataTransformToDecString;

/**
 *  转换16进制的NSData为ASCII字符
 *
 *  @return 转换后的ASCIIString
 */
- (NSString *)dataTransformateToASCIIString;

/**
 *  将低位在前的NSData转换为高位在前，并转成16进制NSString返回
 *
 *  @return 16进制NSString
 */
- (NSString *)lowFrontDataTransformToHighFrontHexString;

/**
 *  将一个NSData中的字节相加取低八位
 *
 *  @return NSData
 */
- (NSData *)lowDataForEachByteInDataToPlus;

@end
