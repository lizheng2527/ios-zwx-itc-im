//
//  PInMainController.m
//  NIM
//
//  Created by 中电和讯 on 2017/11/23.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "PInMainController.h"

#import "TYHHomeLabel.h"
#import "TitleModel.h"
#import <MJExtension.h>
#import "PInDetailController.h"
#import "SDAutoLayout.h"

#import "PAddVisitRecordController.h"
#import "PAddServerApplicationController.h"
#import "PAddServerRecordController.h"
#import "ProjectMainModel.h"
#import "ProjectNetHelper.h"
#import "PCheckSearchController.h"

@interface PInMainController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView * lineView;
@property (nonatomic, strong) TYHHomeLabel * label;
@property (nonatomic, assign) BOOL showHI;
@property (nonatomic, assign) NSInteger indexAll;
@property (nonatomic, assign) NSInteger defaultIndex;
// 接收偏移量的位置
@property (nonatomic, assign) NSInteger indexItem;

@end

@implementation PInMainController

- (NSMutableArray *)dataArray {
    
    if (_dataArray == nil) {
        
        self.dataArray = [[NSMutableArray alloc] init];
        NSArray * array = [NSArray arrayWithObjects:@{@"title":@"拜访记录",@"status":@"0"},@{@"title":@"服务申请",@"status":@"0"},@{@"title":@"服务记录",@"status":@"0"}, nil];
        self.dataArray = [TitleModel mj_objectArrayWithKeyValuesArray:array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _indexAll = 2;
    _defaultIndex = 0;
    [self initView];
    [self createBarItem];
    // 不知道怎么 topscroolview 的 子类里有 UIImageView 怎么搞的
    // 添加子控制器
    [self setupChildVc];
    [self setupTitle];
    _showHI = YES;
    [self scrollViewDidEndScrollingAnimation:self.contentScrollView];
    [self createApplyButton];
}
#pragma mark - initView
-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.topScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 50)];
    self.topScrollView.bounces = NO;
    self.topScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.topScrollView];
    self.contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, AdjustHeight+50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50 - AdjustHeight)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.bounces = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.contentScrollView];
    
}


-(void)createBarItem
{
    UIBarButtonItem *
    barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    //设置字体为加粗的12号系统字，自己也可以随便设置。
    [barItemInNavigationBarAppearanceProxy
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[UIFont
                                                           boldSystemFontOfSize:14], NSFontAttributeName,nil] forState:UIControlStateNormal];
    UIBarButtonItem * rightItem = nil;
    rightItem = [[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStyleDone target:self
                                               action:@selector(checkAction:)];
    self.navigationItem.rightBarButtonItem =rightItem;
}

-(void)createApplyButton
{
    UIButton *applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    applyButton.frame = CGRectMake(self.view.width / 2 - 45, self.view.height - 110, 90, 30);
    if (kDevice_Is_iPhoneX) {
        applyButton.frame = CGRectMake(self.view.width / 2 - 45, self.view.height - 110 - 34, 90, 30);
    }
    applyButton.layer.masksToBounds = YES;
    applyButton.layer.cornerRadius = 4.f;
    [applyButton setTitle:@"添加项目" forState: UIControlStateNormal];
    [applyButton setBackgroundColor:[UIColor blueColor]];
    [applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [applyButton addTarget:self action:@selector(addItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:applyButton];
}

// 添加子控制器
- (void)setupChildVc {
    for (int i = 0; i <= _indexAll; i ++) {
        PInDetailController * ContentView = [[PInDetailController alloc] init];
        ContentView.viewTag = 1001 + i;
        TitleModel * model = self.dataArray[i];
        ContentView.projectID = _projectID;
        ContentView.title = model.title;
        [self addChildViewController:ContentView];
    }
}

static CGFloat labelW;
// 添加标题
- (void)setupTitle {
    
    // 定义临时变量
    CGFloat labelY = 0;
    CGFloat labelH = self.topScrollView.frame.size.height;
    
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width;
    //    if (labelWidth > 320) {
    labelW = labelWidth / 3;
    //    } else {
    //        labelW = 80;
    //    }
    
    NSInteger  index = self.childViewControllers.count;
    // 添加label
    for (NSInteger i = 0; i<=_indexAll; i++) {
        CGFloat labelX = i * labelW;
        TYHHomeLabel *label = [[TYHHomeLabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH) WithType:2];
        label.text = [self.childViewControllers[i] title];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        if (i != index -1) {
            
            UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(labelW - 1, labelY + 15, 1, labelH - 30)];
            lab.backgroundColor = [UIColor TabBarColorAssetColor];
            [label addSubview:lab];
        }
        
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick:)]];
        label.tag = i;
        self.label = label;
        [self.topScrollView addSubview:label];
        
        if (i == 0) { // 最前面的label
            label.scale = 1.0;
        }
    }
    
    // 设置contentSize
    self.topScrollView.contentSize = CGSizeMake((_indexAll + 1) * labelW, 0);
    self.contentScrollView.contentSize = CGSizeMake((_indexAll + 1) * [UIScreen mainScreen].bounds.size.width, 0);
    
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 48, SCREEN_WIDTH, 2)];
    lineView3.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    [self.view addSubview:lineView3];
}
-(UIImageView *)lineView
{
    if (_lineView == nil) {
        _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 45, labelW, 3)];
        _lineView.backgroundColor = [UIColor TabBarColorAssetColor];
        
    }
    return _lineView;
}
/**
 * 监听顶部label点击
 */
- (void)labelClick:(UITapGestureRecognizer *)tap
{
    // 取出被点击label的索引
    NSInteger index = tap.view.tag;
    
    if (self.topScrollView.subviews[index]){
        
        self.label = self.topScrollView.subviews[index];
        [self.label addSubview:self.lineView];
        
    } else {
        
        [self.lineView removeFromSuperview];
    }
    // 让底部的内容scrollView滚动到对应位置
    [self setButtomContentView:index];
}
- (void)setButtomContentView:(NSInteger)index {
    
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = index * self.contentScrollView.frame.size.width;
    [self.contentScrollView setContentOffset:offset animated:YES];
}

#pragma mark - <UIScrollViewDelegate>
/**
 * scrollView结束了滚动动画以后就会调用这个方法（比如- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;方法执行的动画完毕后）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 一些临时变量
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 当前位置需要显示的控制器的索引
    NSInteger index = offsetX / width;
    
    if (_showHI) {
        // 偏移量
        index = 0;
        
        offsetX = index * [UIScreen mainScreen].bounds.size.width;
        [scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        _showHI = NO;
    }
    // 让对应的顶部标题居中显示
    TYHHomeLabel *label = self.topScrollView.subviews[index];
    self.label = label;
    CGPoint titleOffset = self.topScrollView.contentOffset;
    titleOffset.x = label.center.x - width * 0.5;
    
    if (label){
        [label addSubview:self.lineView];
    } else {
        [self.lineView removeFromSuperview];
    }
    // 左边超出处理
    if (titleOffset.x < 0) titleOffset.x = 0;
    // 右边超出处理
    CGFloat maxTitleOffsetX = self.topScrollView.contentSize.width - width;
    if (titleOffset.x > maxTitleOffsetX) titleOffset.x = maxTitleOffsetX;
    [self.topScrollView setContentOffset:titleOffset animated:YES];
    
    // 让其他label回到最初的状态
    for (TYHHomeLabel *otherLabel in self.topScrollView.subviews) {
        if (otherLabel != label && [otherLabel isKindOfClass:[UILabel class]])
            otherLabel.scale = 0.0;
    }
    
    // 取出需要显示的控制器
    UIViewController *willShowVc = self.childViewControllers[index];
    willShowVc.view.backgroundColor = [UIColor clearColor];
    [willShowVc viewWillAppear:YES];
    
    // 如果当前位置的位置已经显示过了，就直接返回
    //    if ([willShowVc isViewLoaded]) return;
    
    // 添加控制器的view到contentScrollView中;  // 第一次 宽高 600 550
    willShowVc.view.frame = CGRectMake(offsetX, 0, width, height);
    [scrollView addSubview:willShowVc.view];
}

/**
 * 手指松开scrollView后，scrollView停止减速完毕就会调用这个
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/**
 * 只要scrollView在滚动，就会调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat scale = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (scale < 0 || scale > self.topScrollView.subviews.count - 1) return;
    
    // 获得需要操作的左边label
    NSInteger leftIndex = scale;
    TYHHomeLabel *leftLabel = self.topScrollView.subviews[leftIndex];
    
    //获得需要操作的右边label
    NSInteger rightIndex = leftIndex + 1;
    
    TYHHomeLabel *rightLabel = (rightIndex == self.topScrollView.subviews.count) ? nil : self.topScrollView.subviews[rightIndex];
    
    // 右边比例
    CGFloat rightScale = scale - leftIndex;
    // 左边比例
    CGFloat leftScale = 1 - rightScale;
    
    // 设置label的比例
    [(TYHHomeLabel *)leftLabel setScale:(CGFloat)leftScale];
    //  在 topScrollViewView 上的 UIImageView 不知道是怎么出来的
    for (id view in scrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            return;
        }
    }
//    [(TYHHomeLabel *)rightLabel setScale:(CGFloat)rightScale];
}


#pragma mark - Actions
-(void)returnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)checkAction:(id)sender
{
    PCheckSearchController *searchView = [PCheckSearchController new];
    searchView.projectID = _projectID;
    [self.navigationController pushViewController:searchView animated:YES];
}


-(void)addItemAction:(id)sender
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择要填写的表单" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                   
                                                         handler:^(UIAlertAction * action) {}];
    UIAlertAction* addVisitRecord = [UIAlertAction actionWithTitle:@"拜访记录" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
        
        PAddVisitRecordController *pView = [PAddVisitRecordController new];
        pView.projectName = self.title;
        pView.projectID = _projectID;
        pView.applyer = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_USERNAME];
        
        [self.navigationController pushViewController:pView animated:YES];
        
    }];
    UIAlertAction* addServerApplication = [UIAlertAction actionWithTitle:@"服务申请" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
        
        PAddServerApplicationController *pView = [PAddServerApplicationController new];
        pView.projectName = self.title;
        pView.projectID = _projectID;
        pView.applyer = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_USERNAME];
        [self.navigationController pushViewController:pView animated:YES];
        
    }];
    UIAlertAction* addServerRecord = [UIAlertAction actionWithTitle:@"服务记录" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
        
        PAddServerRecordController *pView = [PAddServerRecordController new];
        pView.projectName = self.title;
        pView.projectID = _projectID;
        pView.applyer = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_USERNAME];
        [self.navigationController pushViewController:pView animated:YES];
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:addVisitRecord];
    [alertController addAction:addServerApplication];
    [alertController addAction:addServerRecord];
    [self presentViewController:alertController animated:YES completion:nil];
}



#pragma mark Other

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
