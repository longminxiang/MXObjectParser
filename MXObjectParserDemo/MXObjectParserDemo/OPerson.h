//
//  OPerson.h
//  MXObjectParserDemo
//
//  Created by eric on 15/7/14.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MXObjectParser/MXObjectParser.h>

@interface OHouse : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *nnns;

@end

@interface OMan : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) OHouse *house;

@end

@interface OPerson : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSNumber *age;
@property (nonatomic, assign) int ageg;
@property (nonatomic, assign) NSInteger agege;
@property (nonatomic, assign) float agesge;
@property (nonatomic, assign) double agessge;
@property (nonatomic, assign) long agessege;
@property (nonatomic, assign) long long agesdsge;
@property (nonatomic, strong) OHouse *house;
@property (nonatomic, strong) OMan *man;

@property (nonatomic, strong) NSArray *nnns;

@end
