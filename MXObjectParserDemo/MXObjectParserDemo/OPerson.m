//
//  OPerson.m
//  MXObjectParserDemo
//
//  Created by eric on 15/7/14.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import "OPerson.h"

@implementation OMan

@end

@implementation OHouse

+ (NSDictionary *)mxp_objClassInArray
{
    return @{@"nnns": @"OMan"};
}

@end

@implementation OPerson

+ (NSDictionary *)mxp_objClassInArray
{
    return @{@"nnns": @"OHouse"};
}

@end
