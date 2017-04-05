//
//  CustomHeadView.h
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/24.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionModel.h"

@interface CustomHeadView : UITableViewHeaderFooterView

@property (nonatomic, strong) SectionModel *strongModel;

- (void)setModelToSectionWithModel:(SectionModel *)model
                  editSectionBlock:(void(^)(CustomHeadView *targetView))editSectionBlock
                deleteSectionBlock:(void(^)(CustomHeadView *targetView))deleteSectionBlock
                spreadSectionBlock:(void(^)(CustomHeadView *targetView))spreadSectionBlock
             longpressSectionBlock:(void(^)(UILongPressGestureRecognizer *longPress, CustomHeadView *targetView))longpressSectionBlock;
@end
