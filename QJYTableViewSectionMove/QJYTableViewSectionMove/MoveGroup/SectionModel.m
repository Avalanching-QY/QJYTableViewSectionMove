//
//  SectionModel.m
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/30.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import "SectionModel.h"

@implementation SectionModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _sectionSwitch = NO;
        _dataSource = [[NSMutableArray alloc] init];
        int count = arc4random() % 10 + 1;
        for (int i = 0; i < count; i++) {
            NSString *title = [NSString stringWithFormat:@"NO.%c", i + 65];
            [_dataSource addObject:title];
        }
    }
    return self;
}

@end
