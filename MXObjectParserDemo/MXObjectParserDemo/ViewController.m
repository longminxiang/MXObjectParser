//
//  ViewController.m
//  MXObjectParserDemo
//
//  Created by eric on 15/7/14.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import "ViewController.h"
#import "OPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testInstanceWithDictionary];
}

- (void)testInstanceWithDictionary
{
    NSDictionary *dic = @{
                          @"name111": @"dfjd",
                          @"name": @(9),
                          @"age": @"sun",
                          @"house": @{@"name": @"xxxx"},
                          @"nnnss": @[@{@"name": @"sss"}, @{@"name": @"eee"}],
                          @"man": @{
                                  @"name": @"xidk",
                                  @"housess": @{
                                          @"name": @"housedd",
                                          @"nnnns": @[
                                                        @{
                                                            @"name": @"123",
                                                            @"house11": @{@"name": @"nhouses"}
                                                        },
                                                        @{
                                                            @"name": @"445"
                                                        }
                                                    ]
                                          }
                                  }
                          };
    

    OPerson *per = [OPerson mxp_instanceWithDictionary:dic mappers:@{@"namea": @"name", @"man.housess": @"house", @"man.house.nnnns": @"nnns", @"man.house.nnns.house11": @"house"}];
    NSLog(@"%@", per.name);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
