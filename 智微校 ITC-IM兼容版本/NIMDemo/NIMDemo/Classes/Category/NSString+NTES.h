//
//  NSString+NTES.h
//  NIMDemo
//
//  Created by chris on 15/2/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (NTES)

- (CGSize)stringSizeWithFont:(UIFont *)font;

- (NSString *)MD5String;

- (NSUInteger)getBytesLength;

- (NSString *)stringByDeletingPictureResolution;

- (NSString *)tokenByPassword;

+(NSString*) removeLastOneChar:(NSString*)origin;

+ (BOOL) isBlankString:(NSString *)string;

+ (BOOL)isMobileNumber:(NSString *)mobileNum;

+ (BOOL)isValidEmail:(NSString *)checkString;

+(NSString *)escape:(NSString *)str;
@end
