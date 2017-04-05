//
//  SectionModel.h
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/30.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionModel : NSObject
/** 展开和关闭分组 */
@property (nonatomic, assign) BOOL sectionSwitch;
/** 分组的标题 */
@property (nonatomic, strong) NSString *title;
/** 分组内部的数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
