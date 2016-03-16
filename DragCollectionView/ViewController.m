//
//  ViewController.m
//  DragCollectionView
//
//  Created by zhoupengfei on 16/3/14.
//  Copyright © 2016年 zpf. All rights reserved.
//

#import "ViewController.h"
#import "DragCollectionView.h"
#define KCellIdentifier @"CellIdentifier"
#define kMaxCol 5
#define KMargin 8
@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DragCollectionViewDataSource>

@property(nonatomic,weak)UICollectionView * collectionView;
@property(nonatomic,strong)NSMutableArray * contentData;
@end

@implementation ViewController

-(NSMutableArray*)contentData{
    if (_contentData == nil) {
        _contentData = [NSMutableArray array];
    }
    
    return _contentData;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    DragCollectionView * collectionView = [[DragCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    collectionView.dragCollectionDelegate = self;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8);
    flowLayout.minimumLineSpacing = 8;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:KCellIdentifier];
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    for (NSInteger index = 0; index < 10; index++) {
        [self.contentData addObject:[NSString stringWithFormat:@"%ld",(long)index]];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.bounds.size.width - 58)/ kMaxCol , (self.view.bounds.size.width  - 58)/ kMaxCol );
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contentData.count;
}

-(NSArray*)dataSourceOfDragCollectionViewData:(DragCollectionView*)collectionView{
    return self.contentData;
}

-(void)dataSourceOfDragCollectionView:(DragCollectionView*)collectionView newDataAfterMove:(NSArray*)newData{
    self.contentData = newData.copy;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:KCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    UILabel * label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 50, 20)];
    label.text = self.contentData[indexPath.item];
    [cell.contentView addSubview:label];
    return cell;
}


@end
