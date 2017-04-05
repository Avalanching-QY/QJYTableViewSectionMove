//
//  CustomHeadView.m
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/24.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import "CustomHeadView.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
@interface CustomHeadView ()

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *dragSign;
@property (nonatomic, strong) UILabel *numbers;
@property (nonatomic, strong) UIView *moveView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) void(^editSectionBlock)(CustomHeadView *targetView);
@property (nonatomic, strong) void(^deleteSectionBlock)(CustomHeadView *targetView);
@property (nonatomic, strong) void(^longpressSectionBlock)(UILongPressGestureRecognizer *longPress, CustomHeadView *targetView);
@property (nonatomic, strong) void(^spreadSectionBlock)(CustomHeadView *targetView);

@end

@implementation CustomHeadView

#pragma mark - Life Cycle

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self commoInit];
    }
    return self;
}

#pragma mark - Accessors

- (void)commoInit {
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    /** 编辑按钮 */
    _editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_editButton setTitle:@"修改" forState:UIControlStateNormal];
    [_editButton setBackgroundColor:[UIColor clearColor]];
    [_editButton setFrame:CGRectMake(SCREENWIDTH - 100, 0, 50, 50)];
    [_editButton addTarget:self action:@selector(editSectionAntion:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_editButton];
    
    /** 删除按钮 */
    _deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteButton setBackgroundColor:[UIColor clearColor]];
    [_deleteButton setFrame:CGRectMake(SCREENWIDTH - 50, 0, 50, 50)];
    [_deleteButton addTarget:self action:@selector(deleteSectionAntion:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];
    
    /** 可移动涂层 */
    self.moveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    self.moveView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.moveView];
    
    /** 长按手势相应区域 */
    _dragSign = [UIButton buttonWithType:UIButtonTypeCustom];
    _dragSign.frame = CGRectMake(SCREENWIDTH - 81, 12.5, 70, 25);
    _dragSign.layer.cornerRadius = 3.f;
    [_dragSign setBackgroundColor:[UIColor grayColor]];
    [_dragSign setTitle:@"touch" forState:UIControlStateNormal];
    [self.moveView addSubview:_dragSign];
    
    _numbers = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 130, 8	, 30, 30)];
    _numbers.textColor = [UIColor whiteColor];
    _numbers.backgroundColor = [UIColor blueColor];
    _numbers.layer.masksToBounds = YES;
    _numbers.layer.cornerRadius = 15.0f;
    _numbers.textAlignment = NSTextAlignmentCenter;
    [self.moveView addSubview:_numbers];
    
    /** 左右滑动手势 */
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)];
    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)];
    [_swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [_swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:_swipeLeft];
    [self addGestureRecognizer:_swipeRight];
    
    /** 点击手势，用于开关section */
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSection:)];
    _tap.numberOfTapsRequired = 1;
    _tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:_tap];
    
    /** 长按手势，用于拖拽section */
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSectionAntion:)];
    [_dragSign addGestureRecognizer:_longPress];
}

#pragma mark - Actions

- (void)deleteSectionAntion:(UIButton *)button {
    if (_deleteSectionBlock) {
        self.deleteSectionBlock(self);
    }
}

- (void)editSectionAntion:(UIButton *)button {
    if (_editSectionBlock) {
        self.editSectionBlock(self);
    }
}

- (void)longPressSectionAntion:(UILongPressGestureRecognizer *)longPress {
    if (_longpressSectionBlock) {
        self.longpressSectionBlock(longPress, self);
    }
}

- (void)swipeToLeft:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.moveView.frame.origin.x != 0) {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect rect = self.contentView.frame;
                rect.origin.x = 0;
                self.moveView.frame = rect;
            }];
        }
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.moveView.frame.origin.x == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect rect = self.contentView.frame;
                rect.origin.x = -120;
                self.moveView.frame = rect;
            }];
        }
    }
}

- (void)openSection:(UITapGestureRecognizer *)tap {
    if (_spreadSectionBlock) {
        self.spreadSectionBlock(self);
    }
}

#pragma mark - Public

- (void)setModelToSectionWithModel:(SectionModel *)model
                  editSectionBlock:(void(^)(CustomHeadView *targetView))editSectionBlock
                deleteSectionBlock:(void(^)(CustomHeadView *targetView))deleteSectionBlock
                spreadSectionBlock:(void(^)(CustomHeadView *targetView))spreadSectionBlock
             longpressSectionBlock:(void(^)(UILongPressGestureRecognizer *longPress, CustomHeadView *targetView))longpressSectionBlock {
    self.textLabel.text = model.title;
    self.numbers.text = [NSString stringWithFormat:@"%ld", (long)model.dataSource.count];
    self.strongModel = model;
    self.deleteSectionBlock = deleteSectionBlock;
    self.editSectionBlock = editSectionBlock;
    self.spreadSectionBlock = spreadSectionBlock;
    self.longpressSectionBlock = longpressSectionBlock;
}

#pragma mark - Private

@end
