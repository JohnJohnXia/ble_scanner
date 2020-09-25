//
//  NSString+Reverse.h
//  PateoBluetoochDemo
//
//  Created by john xia on 14-8-5.
//  Copyright (c) 2014年 Beyondsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <ctype.h>

@interface NSString (Reverse)

/**
 *  反转NSString
 *
 *  @return 反转后的NSString
 */
- (NSString *)reverseString;

/**
 *  转换16进制NSString为2进制NSString
 *
 *  @return 2进制NSString
 */
- (NSString *)hexStringTransformToBinaryString;

/**
 *  转换2进制NSString为16进制NSString
 *
 *  @return 16进制NSString(字母大写)
 */
- (NSString *)binaryStringTransformToHexString;

/**
 *  转换16进制NSString为10进制NSString
 *
 *  @return 10进制NSString
 */
- (NSString *)hexStringTransformToDecString;

/**
 *  转换10进制NSString为16进制NSString
 *
 *  @return 16进制NSString
 */
- (NSString *)decStringTransformToHexString;

/**
 *  转换10进制NSString为16进制NSString,不含0x开头
 *
 *  @return 返回不含0x开头的16进制
 */
- (NSString *)decStringTransformToHexStringWithNoOX;

/**
 *  转换ascii码为16进制数
 *
 *  @return 16进制NSString
 */
- (NSArray *)asciiTransformToHexStringArray;

/**
 *  转换ascii码为NSData
 *
 *  @return NSData
 */
- (NSData *)asciiTransformToData;

/**
 *  转换16进制数为NSData
 *
 *  @return NSData
 */
- (NSData *)hexStringTransformToData;

/**
 *  16进制数相加返回16进制数,本身是被加数
 *
 *  @param anotherHexString  加数
 *
 *  @return 16进制数结果
 */
- (NSString *)plusAnotherHexString:(NSString *)anotherHexString;

/**
 *  16进制数相减返回16进制数,本身是被减数
 *
 *  @param anotherHexString 减数
 *
 *  @return 16进制结果
 */
- (NSString *)minusAnotherHexString:(NSString *)anotherHexString;

@end
