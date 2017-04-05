//
//  UITableView+SectionManager.h
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/30.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SectionManager)
/**
 *根据点获取IndexPath
 */
- (nullable NSIndexPath *)indexPathForSectionAtPoint:(CGPoint)point numberOfSecton:(NSInteger)count;
@end
