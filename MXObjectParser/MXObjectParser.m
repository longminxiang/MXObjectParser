//
//  MXObjectParser.m
//  MXObjectParserDemo
//
//  Created by eric on 15/7/14.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import "MXObjectParser.h"
#import <objc/runtime.h>

typedef enum {
    MXObjectPropertyTypeUnknown = 0,
    MXObjectPropertyTypeId,
    MXObjectPropertyTypeInt,
    MXObjectPropertyTypeLong,
    MXObjectPropertyTypeFloat,
    MXObjectPropertyTypeDouble,
    MXObjectPropertyTypeBOOL,
} MXObjectPropertyType;

#pragma mark
#pragma mark === MXObjectProperty ===

@interface MXObjectProperty : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) MXObjectPropertyType type;
@property (nonatomic, assign) Class ptyClass;

+ (NSDictionary *)propertiesWithClass:(Class)cls;

@end

@implementation MXObjectProperty

+ (NSMutableDictionary *)propertyCaches
{
    static id caches;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        caches = [NSMutableDictionary new];
    });
    return caches;
}

#define MXTE(__s) [flag isEqualToString:__s]

+ (NSDictionary *)propertiesWithClass:(Class)cls
{
    NSString *cacheKey = NSStringFromClass(cls);
    NSDictionary *cache = [[self propertyCaches] valueForKey:cacheKey];
    if (cache) return cache;
    
    NSMutableDictionary *properties = [NSMutableDictionary new];
    
    if ([cls superclass] != [NSObject class]) {
        NSDictionary *sproperties = [self propertiesWithClass:[cls superclass]];
        [properties addEntriesFromDictionary:sproperties];
    }
    
    u_int count;
    objc_property_t *objc_ps = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t objc_p = objc_ps[i];
        MXObjectProperty *property = [MXObjectProperty new];
        NSString *pname = [NSString stringWithUTF8String:property_getName(objc_p)];
        property.name = pname;
        
        NSString *tstr = [NSString stringWithUTF8String:property_getAttributes(objc_p)];
        NSArray *coms = [tstr componentsSeparatedByString:@","];
        tstr = coms[0];
        NSString *flag = [tstr substringWithRange:NSMakeRange(1, 1)];
        
        if ([flag isEqualToString:@"@"]) {
            NSString *clsName = [tstr substringFromIndex:3];
            clsName = [clsName substringToIndex:clsName.length-1];
            property.ptyClass = NSClassFromString(clsName);
            property.type = MXObjectPropertyTypeId;
        }
        else if (MXTE(@"i") || MXTE(@"I")) {
            property.type = MXObjectPropertyTypeInt;
        }
        else if (MXTE(@"l") || MXTE(@"L") || MXTE(@"q") || MXTE(@"Q")) {
            property.type = MXObjectPropertyTypeLong;
        }
        else if (MXTE(@"f")) {
            property.type = MXObjectPropertyTypeFloat;
        }
        else if (MXTE(@"d")) {
            property.type = MXObjectPropertyTypeDouble;
        }
        else if (MXTE(@"B") || MXTE(@"c")) {
            property.type = MXObjectPropertyTypeBOOL;
        }
        else {
            property.type = MXObjectPropertyTypeUnknown;
        }
        
        [properties setValue:property forKey:property.name];
    }
    free(objc_ps);
    if (!properties.count) return nil;
    [[self propertyCaches] setValue:properties forKey:cacheKey];
    return properties;
}

@end

#pragma mark
#pragma mark === MXObjectParser ===

@implementation NSObject (MXObjectParser)

+ (NSDictionary *)mxp_properties
{
    NSDictionary *types = [MXObjectProperty propertiesWithClass:self];
    return types;
}

+ (MXObjectProperty *)mxp_propertyWithName:(NSString *)pname
{
    NSDictionary *ptys = [self mxp_properties];
    return [ptys valueForKey:pname];
}

+ (NSDictionary *)mxp_objClassInArray
{
    return nil;
}

+ (NSDictionary *)subMappersWithName:(NSString *)name mappers:(NSDictionary *)mappers
{
    NSMutableDictionary *smps = [NSMutableDictionary new];
    [mappers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *cmps = [key componentsSeparatedByString:@"."];
        NSString *tname = cmps[0];
        if ([tname isEqualToString:name] && [key length] > tname.length+1) {
            NSString *nkey = [key substringFromIndex:tname.length+1];
            [smps setValue:obj forKey:nkey];
        }
    }];
    return smps.count ? smps : nil;
}

+ (instancetype)mxp_instanceWithDictionary:(NSDictionary *)dic
{
    return [self mxp_instanceWithDictionary:dic mappers:nil];
}

+ (instancetype)mxp_instanceWithDictionary:(NSDictionary *)dic mappers:(NSDictionary *)mappers
{
    if (![dic isKindOfClass:[NSDictionary class]]) return nil;
    id instance = [self new];
    
    for (NSString *akey in dic.allKeys) {
        id value = dic[akey];
        NSString *key = mappers[akey] ? mappers[akey] : akey;
        MXObjectProperty *pty = [self mxp_propertyWithName:key];
        
        if (!value || [value isKindOfClass:[NSNull class]] || !pty) {
            continue;
        }
        
        switch (pty.type) {
            case MXObjectPropertyTypeInt:value = @([value intValue]);break;
            case MXObjectPropertyTypeLong:value = @([value longValue]);break;
            case MXObjectPropertyTypeFloat:value = @([value floatValue]);break;
            case MXObjectPropertyTypeDouble:value = @([value doubleValue]);break;
            case MXObjectPropertyTypeBOOL:value = @([value boolValue]);break;
            case MXObjectPropertyTypeId: {
                if ([value isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *mps = [self subMappersWithName:pty.name mappers:mappers];
                    id nobj = [pty.ptyClass mxp_instanceWithDictionary:value mappers:mps];
                    value = nobj;
                }
                else if ([value isKindOfClass:[NSArray class]]) {
                    NSString *cstr = [self mxp_objClassInArray][key];
                    if (cstr) {
                        NSMutableArray *nobjs = [NSMutableArray new];
                        Class cls = NSClassFromString(cstr);
                        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSDictionary *mps = [self subMappersWithName:pty.name mappers:mappers];
                            id nsobj = [cls mxp_instanceWithDictionary:obj mappers:mps];
                            [nobjs addObject:nsobj];
                        }];
                        value = nobjs;
                    }
                }
                else if (pty.ptyClass == [NSDate class]) {
                    value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
                }
                else if (pty.ptyClass == [NSString class]) {
                    if (![value isKindOfClass:[NSString class]]) {
                        value = [NSString stringWithFormat:@"%@", value];
                    }
                }
                else if (![value isKindOfClass:pty.ptyClass]) {
                    continue;
                }
                break;
            }
            default: continue;
        }
        
        [instance setValue:value forKey:key];
    }
    [instance setMxp_dictionary:dic];
    return instance;
}

- (NSDictionary *)mxp_dictionary
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMxp_dictionary:(NSDictionary *)mxp_dictionary
{
    objc_setAssociatedObject(self, @selector(mxp_dictionary), mxp_dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
