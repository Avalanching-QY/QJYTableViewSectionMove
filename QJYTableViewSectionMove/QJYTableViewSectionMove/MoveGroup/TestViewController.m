//
//  TestViewController.m
//  QySwitchScreen
//
//  Created by Avalanching on 16/8/26.
//  Copyright © 2016年 Jqy. All rights reserved.
//

#import "TestViewController.h"
#import "CustomHeadView.h"
#import "SectionModel.h"
#import "UITableView+SectionManager.h"

#define ADDAlertViewTag 12345678910
#define SECTION_HEIGHT 44
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface TestViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIAlertView *editAlertView;
@property (nonatomic, strong) UIAlertView *addSectionAlertView;

@property (nonatomic, strong) UITableViewHeaderFooterView *moveSection;
@end

@implementation TestViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self commonInit];
    
    self.navigationController.navigationBar.translucent = NO;
    _locations = [[NSMutableArray alloc] init];
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i = 1; i < 20; i++) {
        SectionModel *model = [[SectionModel alloc] init];
        
        model.title = [NSString stringWithFormat:@"第%d组", i];
        
        [self.dataArray addObject:model];
    }
    [self.tableView reloadData];
}


#pragma mark - Accessors

- (void)commonInit {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加分组" style:UIBarButtonItemStylePlain target:self action:@selector(addNewSection:)];
}


#pragma mark - Actions

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPress {

    UIGestureRecognizerState state = longPress.state;
    CGPoint location = [longPress locationInView:self.tableView];
    
    // 判断长按手势的坐标落在哪一个section上面，如果不想写这个代码，可以将长按手势添加在section上
    NSIndexPath *indexPath = [self.tableView indexPathForSectionAtPoint:location numberOfSecton:self.dataArray.count];
    
    // 这里是快照 我们拖动不是真正的UITableViewHeaderFooterView 而是一张快照
    static UIView       *snapshot = nil;
    
    // 记录section的初始的行号
    static NSIndexPath  *initialLocation = nil;
    
    switch (state) {
            
        case UIGestureRecognizerStateBegan: {
            
            if (indexPath) {
                initialLocation = indexPath;
                self.moveSection = [self.tableView headerViewForSection:indexPath.section];
                
                // 创建section的一个快照
                snapshot = [self customSnapshoFromView:self.moveSection];
                
                // 添加快照至tableView中
                __block CGPoint center = self.moveSection.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                
                // 按下的瞬间执行动画 这里最终目的是为了隐藏选中的Section
                [UIView animateWithDuration:0.25 animations:^{
                    
                    center.y = location.y;
                    snapshot.center = center;
                    
                    // 稍微设置一下快照的样式
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    self.moveSection.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    self.moveSection.hidden = YES;
                }];
            }
            break;
        }
        
        case UIGestureRecognizerStateChanged: {
            
            // 保持位置数组存有前后两个坐标点
            [self.locations addObject:[NSValue valueWithCGPoint:location]];
            if (self.locations.count > 2) {
                [self.locations removeObjectAtIndex:0];
            }
            
            // 移动快照
            CGPoint center = snapshot.center;
            center.y = location.y;
            
            CGPoint firstPoint = [[self.locations firstObject] CGPointValue];
            CGPoint lastPoint = [[self.locations lastObject] CGPointValue];
            
            // 注意这里是中心点，而不是快照的frame.origin.x
            CGFloat moveX = lastPoint.x - firstPoint.x;
            center.x += moveX;
        
            // 如果section的移动在有效范围执行动画
            if (center.y + SECTION_HEIGHT / 2 <= self.tableView.contentSize.height && center.y - SECTION_HEIGHT / 2 >= 0) {
                snapshot.center = center;
                
                // 对比新的indexPath和初始的是否一致，
                // 这里使用NSIndexPath是因为，在某些场景中可能出现垃圾数值，使用对象可以进行nil的判断
                if (indexPath && ![indexPath isEqual:initialLocation]) {
                    
                    // 这里使用try 是为了避免数据源错误造成的崩溃，
                    // 常规情况下OC比较少用 try catch，因为OC是动态语言一下野指针和空指针是在运行时才产生的
                    @try {
                        
                        // 更新数组中的内容
                        [self.dataArray exchangeObjectAtIndex:
                         indexPath.section withObjectAtIndex:initialLocation.section];
                        
                        // 把section移动至指定行 这里是从API中找出来的方法，apple没有像处理cell那样给定了一个编辑模式的样式
                        // 这里参考cell的移动
                        /**
                         *- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;
                         *
                         *- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
                         */
                        [self.tableView moveSection:initialLocation.section toSection:indexPath.section];
                        
                        // 这里判断是否滚动了屏幕的顶部或者底部，这里是指相对坐标。
                        [self scrollTableViewToTargetView:indexPath];
                        
                    } @catch (NSException *exception) {
                        
                        NSLog(@"row is error");
                        
                    } @finally {
                        // 存储改变后indexPath的值，以便下次比较
                        initialLocation = indexPath;
                    }
                } else {
                    // 判断屏幕上的最上方一个和最下方一个，滚动tableView
                    CGRect targetViewFrame = [self.tableView rectForSection:indexPath.section];
                    
                    if (self.moveSection.center.y < snapshot.center.y) {
                        // 向下滚
                        targetViewFrame.origin.y += SECTION_HEIGHT;
                        [self.tableView scrollRectToVisible:targetViewFrame animated:YES];
                        
                    } else if (self.moveSection.center.y > snapshot.center.y) {
                        // 向上滚
                        targetViewFrame.origin.y -= SECTION_HEIGHT;
                        [self.tableView scrollRectToVisible:targetViewFrame animated:YES];
                    }
                    
                }
            }
            break;
        }
            // 长按手势取消状态
        default: {
            // 清空数组
            [self.locations removeAllObjects];
            
            self.moveSection.hidden = NO;
            self.moveSection.alpha = 0.0;
            
            // 将快照恢复到初始状态
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = self.moveSection.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                self.moveSection.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                [snapshot removeFromSuperview];
                
                snapshot = nil;
                
                // 这个地方必须加上这一句，否则在相应长按手势的瞬间取消手势，section将无法显示
                self.moveSection.hidden = NO;
            }];
            break;
        }
    }
    
}

- (void)scrollTableViewToTargetView:(NSIndexPath *)indexPath {
    // 获取目标的frame
    CGRect targetViewFrame = [self.tableView rectForSection:indexPath.section];
    
    // frame相对屏幕的坐标
    CGRect rectInSuperview = [self.tableView convertRect:targetViewFrame toView:self.view];
    
    // 需要tableview如果滚动配合
    if (rectInSuperview.origin.y <= 0 && self.tableView.contentOffset.y != 0) {
        
        targetViewFrame.origin.y -= SECTION_HEIGHT;
    } else {
        targetViewFrame.origin.y += SECTION_HEIGHT;
    }
    
    [self.tableView scrollRectToVisible:targetViewFrame animated:YES];
}

- (void)addNewSection:(UIButton *)button {
    if (!_addSectionAlertView) {
        _addSectionAlertView = [[UIAlertView alloc] initWithTitle:@"添加分组" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"添加", nil];
        _addSectionAlertView.tag = ADDAlertViewTag;
        _addSectionAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    [self.addSectionAlertView show];
}

#pragma mark - Public

#pragma mark - Private
/** 获取快照 */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    // 用UIView的图层生成UIImage，方便一会显示
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 自定义这个快照的样子（下面的一些参数可以自己随意设置）
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

- (BOOL)sectionWillMoveCloseSection {
    BOOL needReload = NO;
    for (int i = 0 ; i < self.dataArray.count; i++) {
        SectionModel *model = self.dataArray[i];
        if (model.sectionSwitch) {
            model.sectionSwitch = NO;
            needReload = YES;
        }
    }
    return needReload;
}

- (void)exchangeIndexPath:(NSIndexPath *)startIndexPath toIndexPath:(NSIndexPath *)endIndexPath {
    static NSIndexPath *tempIndexPath = nil;
    tempIndexPath = startIndexPath;
    startIndexPath = endIndexPath;
    endIndexPath = tempIndexPath;
    tempIndexPath = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray) {
        SectionModel *model = self.dataArray[section];
        if (model.sectionSwitch) {
            return model.dataSource.count;
        }else {
            return 0;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const key = @"UITableViewCell *cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }
    SectionModel *model = self.dataArray[indexPath.section];
    NSArray *temp = model.dataSource;
    cell.imageView.image = [UIImage imageNamed:@"yellowBoy"];
    cell.textLabel.text = temp[indexPath.row];
    
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    SectionModel *model = self.dataArray[section];
    NSString *key = model.title;
    
    CustomHeadView  * sectionView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:key];
    if (!sectionView) {
        sectionView = [[CustomHeadView alloc] initWithReuseIdentifier:key];
    }
    __weak TestViewController *weakSelf = self;
    [sectionView setModelToSectionWithModel:self.dataArray[section] editSectionBlock:^(CustomHeadView *targetView) {
        
        if (!weakSelf.editAlertView) {
            weakSelf.editAlertView  = [[UIAlertView alloc] initWithTitle:@"修改标题" message:@"" delegate:weakSelf cancelButtonTitle:@"cannel" otherButtonTitles:@"confit", nil];
            weakSelf.editAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        }
        weakSelf.editAlertView.tag = [weakSelf.tableView indexPathForSectionAtPoint:targetView.center numberOfSecton:weakSelf.dataArray.count].section;
        [weakSelf.editAlertView show];
        
    } deleteSectionBlock:^(CustomHeadView *targetView) {
        /** section删除按钮的回调 */
        NSIndexPath *indexPath = [self.tableView indexPathForSectionAtPoint:targetView.center numberOfSecton:weakSelf.dataArray.count];
        [weakSelf.dataArray removeObjectAtIndex:indexPath.section];
        [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
        
    } spreadSectionBlock:^(CustomHeadView *targetView) {
        /** section展开效果的回调 */
        NSIndexPath *indexPath = [self.tableView indexPathForSectionAtPoint:targetView.center numberOfSecton:weakSelf.dataArray.count];
        SectionModel *model = targetView.strongModel;
        model.sectionSwitch = !model.sectionSwitch;
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        
    } longpressSectionBlock:^(UILongPressGestureRecognizer *longPress, CustomHeadView *targetView) {
         /** section长按的回调 */
        [weakSelf longPressGestureRecognized:longPress];
    }];
    
    return sectionView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    SectionModel *model = self.dataArray[section];
    if (model.sectionSwitch) {
        return 10;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        return;
    } else {
        
        NSString * title = [alertView textFieldAtIndex:0].text;
        
        if (alertView.tag == ADDAlertViewTag) {
            SectionModel *model = [[SectionModel alloc] init];
            model.title = title;
            [self.dataArray insertObject:model atIndex:0];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            SectionModel *model = self.dataArray[alertView.tag];
            model.title = title;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:alertView.tag] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }

}
@end
