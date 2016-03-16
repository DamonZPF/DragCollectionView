//
//  DragCollectionView.m
//  DragCollectionView
//
//  Created by zhoupengfei on 16/3/14.
//  Copyright © 2016年 zpf. All rights reserved.
//

#import "DragCollectionView.h"

@interface DragCollectionView()
@property(nonatomic,strong)UIView * snapMoveCell; //截图cell 用于移动
@property(nonatomic,strong)NSIndexPath * originalIndexPath; //手指所在的cell indexPath
@property(nonatomic,strong)NSIndexPath * moveIndexPath ; //可替换的cell indexPath
@property(nonatomic,assign)CGPoint lastPoint ; //手指所在cell 的Point
@end

@implementation DragCollectionView

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
   self =  [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        ////添加长按手势
        [self addLongPressGesture];
    }
    return self;
}

#pragma mark ////添加长按手势
-(void)addLongPressGesture{
    UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressGesture.minimumPressDuration = 0.25;
    [self addGestureRecognizer:longPressGesture];
}
#pragma mark //触发手势
-(void)longPress:(UILongPressGestureRecognizer*)longPressGesture{

    if (longPressGesture.state == UIGestureRecognizerStateBegan) { //开始
        [self setupGestureBegan:longPressGesture];
    }else if(longPressGesture.state == UIGestureRecognizerStateChanged){//移动
        [self setupGestureChanged:longPressGesture];
    }else if (longPressGesture.state == UIGestureRecognizerStateCancelled || longPressGesture.state == UIGestureRecognizerStateEnded){//取消或者结束
        [self setupGestureEndOrCancel:longPressGesture];
    }

}

#pragma mark 手势开始
-(void)setupGestureBegan:(UILongPressGestureRecognizer*)longPressGesture{

    //获取手指所在的cell
    self.lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    self.originalIndexPath = [self indexPathForItemAtPoint:self.lastPoint];
   
    UICollectionViewCell * cell = [self cellForItemAtIndexPath:self.originalIndexPath];
    UIView * snapMoveCell = [cell snapshotViewAfterScreenUpdates:NO]; //截图
    [self addSubview:snapMoveCell];
    
    //隐藏旧的的Cell
    cell.hidden = YES;
    snapMoveCell.frame = cell.frame;
    self.snapMoveCell = snapMoveCell;

    
}

#pragma mark 手势改变
-(void)setupGestureChanged:(UILongPressGestureRecognizer*)longPressGesture{

    CGFloat transX = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].x - self.lastPoint.x;
    CGFloat transY = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].y - self.lastPoint.y;
    
    self.snapMoveCell.center = CGPointApplyAffineTransform(self.snapMoveCell.center, CGAffineTransformMakeTranslation(transX, transY));//移动截图
    self.lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];//记录移动的位置
   
    [self setupMoveCell];//交换cell
}

#pragma mark 手势取消或者结束
-(void)setupGestureEndOrCancel:(UILongPressGestureRecognizer*)longPressGesture{
    UICollectionViewCell * cell = [self cellForItemAtIndexPath:self.originalIndexPath];
    [UIView animateWithDuration:0.25 animations:^{
        self.snapMoveCell.center = cell.center;//通过动画过度到移动的Cell位置
    } completion:^(BOOL finished) {
        [self.snapMoveCell removeFromSuperview];//移除截图Cell
        cell.hidden = NO;//显示隐藏的Cell
    }];
}


#pragma mark 交换cell
-(void)setupMoveCell{

    //遍历所有可见的Cell
    for (UICollectionViewCell  * cell in [self visibleCells]) {
        if ([self indexPathForCell:cell]  == self.originalIndexPath) {//非当前的选中的cell
            continue;
        }
        //计算当前截图cell 与可见cell 的中心距离
        CGFloat spacingX = fabs(self.snapMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(self.snapMoveCell.center.y - cell.center.y);
        //如果相交
        if (spacingX <= self.snapMoveCell.bounds.size.width / 2.0 && spacingY <= self.snapMoveCell.bounds.size.height / 2.0) {
            
            self.moveIndexPath = [self indexPathForCell:cell];
            [self updateDataSource];
            [self moveItemAtIndexPath:self.originalIndexPath toIndexPath:self.moveIndexPath];
            self.originalIndexPath = self.moveIndexPath;
            break;
        }
    }
    
}


#pragma mark 更新数据源
-(void)updateDataSource{
    NSMutableArray * orignalSection = [[self.dragCollectionDelegate dataSourceOfDragCollectionViewData:self] mutableCopy];
    if (orignalSection.count) {
        if (self.moveIndexPath.item > self.originalIndexPath.item) {
            
            for (NSInteger index = self.originalIndexPath.item; index < self.moveIndexPath.item; index++) {
                [orignalSection exchangeObjectAtIndex:index withObjectAtIndex:index+1];
            }
        }else{
            for (NSInteger index = self.originalIndexPath.item; index > self.moveIndexPath.item; index--) {
                [orignalSection exchangeObjectAtIndex:index withObjectAtIndex:index-1];
            }
        }
    }
    
    [self.dragCollectionDelegate dataSourceOfDragCollectionView:self newDataAfterMove:orignalSection.copy];
}
@end
