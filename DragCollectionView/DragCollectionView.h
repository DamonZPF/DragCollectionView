//
//  DragCollectionView.h
//  DragCollectionView
//
//  Created by zhoupengfei on 16/3/14.
//  Copyright © 2016年 zpf. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DragCollectionView;
@protocol DragCollectionViewDataSource <UICollectionViewDataSource>
@required
-(NSArray*)dataSourceOfDragCollectionViewData:(DragCollectionView*)collectionView;
-(void)dataSourceOfDragCollectionView:(DragCollectionView*)collectionView newDataAfterMove:(NSArray*)newData;
@end

@interface DragCollectionView : UICollectionView
@property(nonatomic,weak) id <DragCollectionViewDataSource> dragCollectionDelegate;
@end
