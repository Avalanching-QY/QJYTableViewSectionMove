//
//  CustomSwitch.m
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/30.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import "CustomSwitch.h"

@interface CustomSwitch ()
@property (nonatomic, strong) UIView *sign;
@end

@implementation CustomSwitch

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commoInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = rect.size.height/2;
    self.backgroundColor = [UIColor blueColor];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    

}

- (void)commoInit {
    
}


@end
