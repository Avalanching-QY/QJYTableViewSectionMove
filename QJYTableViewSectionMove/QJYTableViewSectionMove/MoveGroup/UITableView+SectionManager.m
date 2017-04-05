//
//  UITableView+SectionManager.m
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/30.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import "UITableView+SectionManager.h"

@implementation UITableView (SectionManager)

- (nullable NSIndexPath *)indexPathForSectionAtPoint:(CGPoint)point numberOfSecton:(NSInteger)count {
    static NSIndexPath *indexPath = nil;
    indexPath = nil;
    /** 使用indexPath可以为空 点击在外面 */
    for (NSInteger i = 0; i < count ; i++) {
        UIView *targetView = [self headerViewForSection:i];
        CGRect rect = targetView.frame;
        if (point.y <= rect.origin.y + 44) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            break;
        }
    }
    return indexPath;
}
@end
