//
//  MXObjectParser.h
//  MXObjectParserDemo
//
//  Created by eric on 15/7/14.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MXObjectParser)

+ (instancetype)mxp_instanceWithDictionary:(NSDictionary *)dic;

+ (instancetype)mxp_instanceWithDictionary:(NSDictionary *)dic mappers:(NSDictionary *)mappers;

+ (NSDictionary *)mxp_objClassInArray;

@end
