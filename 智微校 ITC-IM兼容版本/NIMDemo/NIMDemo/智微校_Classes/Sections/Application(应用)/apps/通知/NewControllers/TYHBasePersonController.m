//
//  TYHBasePersonController.m
//  TYHxiaoxin
//
//  Created by hzth-mac3 on 16/1/6.
//  Copyright © 2016年 Lanxum. All rights reserved.
//

#import "TYHBasePersonController.h"
#import "ContactModelListHelper.h"
#import "ContactModel.h"
#import "SessionViewCell.h"
#import <UIImageView+WebCache.h>
#import "TYHContactCell.h"
#import "InviteJoinListViewCell.h"
#import <UIView+Toast.h>
#import "TYHContactDetailCell.h"
#import "TYHNewSendViewController.h"
#import "NTESNoticeSelPerTableViewCell.h"


#define HeadBtnWidth 55
#define HeadBtnHeight 70
#define WIDTH ([UIScreen mainScreen].bounds.size.width / 320 )
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface TYHBasePersonController ()<UISearchBarDelegate,UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UILabel * lable2;

@property (nonatomic, strong) UIBarButtonItem * btnItem;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) NSArray * resultsData;

@property (nonatomic, strong) NSMutableArray * resultsArray;

@property (nonatomic, strong) NSMutableArray * resultsModelArray;
@property (nonatomic, strong) NSMutableArray * tempArr;

@property (nonatomic, strong) UISearchBar *mySearchBar;
//@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation TYHBasePersonController
{
    BOOL isAlreadyInserted;
}

- (NSMutableArray *)tempArray {
    
    if (_tempArray == nil) {
        self.tempArray = [NSMutableArray  arrayWithArray:_modelArray];
    }
    return _tempArray;
}

- (NSMutableArray *)tempSelectGroupArray {
    
    if (_tempSelectGroupArray == nil) {
        self.tempSelectGroupArray = [[NSMutableArray  alloc] init];
    }
    return _tempSelectGroupArray;
}

- (NSMutableArray *)tempSelectGroupModelArray {
    
    if (_tempSelectGroupModelArray == nil) {
        self.tempSelectGroupModelArray = [[NSMutableArray  alloc] init];
    }
    return _tempSelectGroupModelArray;
}

- (NSArray *)resultsData {
    
    if (_resultsData == nil) {
        self.resultsData = [[NSArray alloc] init];
    }
    return _resultsData;
}

- (NSMutableArray *)selectArray {
    
    if (_selectArray) {
        self.selectArray = [[NSMutableArray alloc] init];
    }
    return _selectArray;
}
- (NSMutableArray *)showTableView {
    
    if (_showTableView == nil) {
        _showTableView = [[NSMutableArray alloc] init];
    }
    return _showTableView;
}
-(void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelFont = [UIFont systemFontOfSize:12];
    HUD.labelText = @"获取数据中";
    self.HUD = HUD;
    
//    _groupTableView.contentInset = UIEdgeInsetsZero;
//    _groupTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    
//    self.navigationController.navigationBar.translucent = NO;
}



//-(void)viewWillDisappear:(BOOL)animated
//{
//    self.navigationController.navigationBar.translucent = YES;
//}


- (void)creatLeftItem {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
        
        self.navigationItem.leftBarButtonItem = leftItem;
    } else {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
        
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedArray = [NSMutableArray arrayWithArray:_chooseArray];
//    NSLog(@"111 chooseArray = %@",_chooseArray);
//    NSLog(@"111 selectedArray = %@",_selectedArray);
    
    self.setArray = [NSSet setWithArray:_selectedArray];
//    [self creatLeftItem];
    
    [self creatTableView];
    
    isAlreadyInserted = NO;
    NSString *dataSourceName = [[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DEFAULT_DataSourceName"];
    
    dataSourceName = dataSourceName.length?dataSourceName:@"";
    
    ContactModelListHelper *myHelper = [[ContactModelListHelper alloc]init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString * strUrl = [NSString stringWithFormat:@"%@%@?sys_auto_authenticate=true&sys_username=%@&sys_password=%@&userId=%@&imToken=%@&dataSourceName=%@",BaseURL,_urlStr,_userName,_password,_userId,self.token,dataSourceName];
        
        [myHelper getContactCompletionNoticeContact:strUrl block:^(BOOL Successful, NSMutableArray *myArray) {
            
            if (Successful) {
                
                _groupArray = [NSMutableArray arrayWithArray:myArray];
                
//                NSLog(@"_groupArray = %@",_groupArray);
                
                // 模型name数组
                _resultsData = [NSMutableArray arrayWithArray:myHelper.nameSource];
                
                _resultsModelArray = [NSMutableArray arrayWithArray:myHelper.dataSource];
                
                _resultsArray = [NSMutableArray array];
                
//                NSLog(@"_resultsData %@",_resultsData);
                [self.groupTableView reloadData];
                
                [self.HUD removeFromSuperview];
            }
            
        }];
        
    });
    
    
    [_showTableView addObject:[[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_ID]];
    
    
    [self setRightItem];
    
    [self initMysearchBarAndMysearchDisPlay];
}
- (void)setRightItem {
    
    UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(self.view.frame.size.width - 44, 0, 50, 40);
    button.backgroundColor = [UIColor TabBarColorGreen];
    UILabel * lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    lable1.font = [UIFont systemFontOfSize:12];
    lable1.textColor = [UIColor whiteColor];
    lable1.text = @"确定";
    lable1.textAlignment = NSTextAlignmentCenter;
    [button addSubview:lable1];
    UILabel * lable2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 50, 20)];
    lable2.font = [UIFont systemFontOfSize:12];
    lable2.textColor = [UIColor whiteColor];
    if (_setArray == nil) {
        
        lable2.text = @"0";
    } else {
        
        lable2.text = [NSString stringWithFormat:@"%d",(int)_setArray.count];
    }
    lable2.textAlignment = NSTextAlignmentCenter;
    [button addSubview:lable2];
    
    self.lable2 = lable2;
    
    [button addTarget:self action:@selector(backChoosePerson) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * butItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.btnItem = butItem;
    
    self.navigationItem.rightBarButtonItem = self.btnItem;
}


- (void)returnClicked {
    
    self.returnTextArrayBlock(self.selectedArray);
    
    self.returnUserModelBlock(self.modelArray);
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)backChoosePerson {
    
    TYHNewSendViewController * sendVc = [[TYHNewSendViewController alloc] init];
    
    sendVc.modelArray =  self.modelArray;
    
//    NSLog(@" sendVc.modelArray  == %@",sendVc.modelArray);
    sendVc.tempSelectGroupModelArray = self.tempSelectGroupModelArray;
    sendVc.tempSelectGroupArray = self.tempSelectGroupArray;
    [self.navigationController pushViewController:sendVc animated:YES];
    
}
//  初始化tableview
- (void)creatTableView {
    
    _groupTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, WIDTH * 320,HEIGHT - 64)];
    
    _groupTableView.dataSource = self;
    _groupTableView.delegate = self;
    _groupTableView.bounces = NO;
    
    [self.view addSubview:_groupTableView];
    
    [_groupTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

// 初始化 搜索框
-(void)initMysearchBarAndMysearchDisPlay
{
//    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,WIDTH * 320 ,40)];
//    _mySearchBar.delegate = self;
//    _mySearchBar.placeholder = @"姓名";
//    [_mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//    self.groupTableView.tableHeaderView = _mySearchBar;
//
//    _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
//    _mySearchDisplayController.delegate = self;
//    _mySearchDisplayController.searchResultsDataSource = self;
//    _mySearchDisplayController.searchResultsDelegate = self;
//    _mySearchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
//    _mySearchDisplayController.searchResultsTableView.tableHeaderView= [[UIView alloc]initWithFrame:CGRectZero];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
     
    _searchController.searchResultsUpdater = self;
     
    _searchController.dimsBackgroundDuringPresentation = NO;
     
    _searchController.hidesNavigationBarDuringPresentation = NO;
     
    _searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
     
    self.groupTableView.tableHeaderView = self.searchController.searchBar;
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
     
    NSString *searchString = [self.searchController.searchBar text];
     
    [_resultsArray removeAllObjects];
    
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    NSMutableArray *tempResults = [NSMutableArray array];
    for (int i = 0; i < _resultsData.count; i++) {
        NSString *storeString = _resultsData[i];
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchString options:searchOptions range:storeRange];
        if (foundRange.length) {
            [tempResults addObject:storeString];
        }
    }
    NSMutableArray *arry = [NSMutableArray array];
    [arry addObjectsFromArray:tempResults];
    
    _resultsArray =  [NSMutableArray arrayWithArray:[[NSSet setWithArray:arry] allObjects]];
    
    //刷新表格
 
    [self.groupTableView reloadData];
}
//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
//
//    [_resultsArray removeAllObjects];
//
//    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
//
//    NSMutableArray *tempResults = [NSMutableArray array];
//    for (int i = 0; i < _resultsData.count; i++) {
//        NSString *storeString = _resultsData[i];
//        NSRange storeRange = NSMakeRange(0, storeString.length);
//        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
//        if (foundRange.length) {
//            [tempResults addObject:storeString];
//        }
//    }
//    NSMutableArray *arry = [NSMutableArray array];
//    [arry addObjectsFromArray:tempResults];
//
//    _resultsArray =  [NSMutableArray arrayWithArray:[[NSSet setWithArray:arry] allObjects]];
//
//}

//#pragma mark - UISearchDisplayController delegate methods
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchString:(NSString *)searchString {
//
//    [self filterContentForSearchText:searchString  scope:[[self.searchDisplayController.searchBar scopeButtonTitles]  objectAtIndex:[self.searchDisplayController.searchBar                                                      selectedScopeButtonIndex]]];
//
//    return YES;
//
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchScope:(NSInteger)searchOption {
//
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
//
//    return YES;
//
//}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _mySearchBar.showsCancelButton = YES;
    NSArray *subViews;
    
    if (is_IOS_7) {
        subViews = [(_mySearchBar.subviews[0]) subviews];
    }
    else {
        subViews = _mySearchBar.subviews;
    }
    
    for (id view in subViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.searchController.active){
        return _resultsArray.count;
    }else {
        
        if (_groupArray.count >0 && _groupArray) {
            return _groupArray.count;
        }
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchController.active) {
        return  50;
    }
    else if ([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[ContactModel class]])
    {
        return 50;
    }
    else if([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[UserModel class]])
    {
        return 50;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchController.active) {
        
        //        if ([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[UserModel class]]){
        
        static NSString *myCell = @"InviteJoinListViewCellidentifier";
        
        InviteJoinListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
        
        if (cell == nil) {
            
            cell = [[InviteJoinListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSelectBtnClickeGroups:)];
            cell.contentView.userInteractionEnabled = YES;
            [cell.contentView addGestureRecognizer:tap];
        }
        
        for (UserModel * model in _resultsModelArray) {
            
            if ([model.name isEqualToString:_resultsArray[indexPath.row]]) {
                
                cell.selecImage.frame = CGRectMake(self.view.frame.size.width - 50, 15.0f, 22.25f, 22.25f);
                
                cell.portraitImg.image = [self dealImageWIthVoipAccount:model.voipAccount];
                
                cell.portraitImg.layer.masksToBounds = YES;
                cell.portraitImg.layer.cornerRadius = cell.portraitImg.frame.size.width / 2;
                cell.nameLabel.text = model.name;
                cell.selecImage.tag = indexPath.row+1000000;
                
                if ([_selectedArray containsObject:model.strId]  || [_showTableView containsObject:model.strId]) {
                    cell.selecImage.image = [UIImage imageNamed:@"select_account_list_checked"];
                }
                else{
                    cell.selecImage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
                }
            }
        }
        
        return cell;
        //        }
        
    }else {
        
        NSInteger indentationLevel = 0;
        if ([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[ContactModel class]]) {
            static NSString *iden = @"NTESNoticeSelPerTableViewCell";
            NTESNoticeSelPerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
            if (!cell) {
                cell = [[NSBundle mainBundle]loadNibNamed:@"NTESNoticeSelPerTableViewCell" owner:self options:nil].firstObject;
                indentationLevel = cell.indentationLevel;
            }
            cell.selectImage.frame = CGRectMake(self.view.frame.size.width - 50, 15.0f, 22.25f, 22.25f);
            [cell.selectImage setUserInteractionEnabled:YES];
            [cell.selectImage setTag:indexPath.row+10000];
            
            
            UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
            [cell.selectImage addGestureRecognizer:singleTap];
            
            
            ContactModel *model = [self.groupArray objectAtIndex:indexPath.row];
            if ([self.tempSelectGroupArray containsObject:model.contactId]) {
                cell.selectImage.image = [UIImage imageNamed:@"select_account_list_checked"];
            }
            else{
                cell.selectImage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
            }
            if (isAlreadyInserted) {
                cell.icon.image = [UIImage imageNamed:@"展开"];
            } else{
                cell.icon.image = [UIImage imageNamed:@"未展开"];
            }
            cell.titleLabel.text = model.name;
            return cell;
        }
        else if ([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[UserModel class]]){
            
            static NSString *contactlistcellid = @"InviteJoinListViewCellidentifier";
            InviteJoinListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactlistcellid];
            if (cell == nil) {
                cell = [[InviteJoinListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactlistcellid];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSelectBtnClickeGroup:)];
                cell.contentView.userInteractionEnabled = YES;
                [cell.contentView addGestureRecognizer:tap];
            }
            UserModel *model = [self.groupArray objectAtIndex:indexPath.row];
            
            cell.selecImage.frame = CGRectMake(self.view.frame.size.width - 50, 15.0f, 22.25f, 22.25f);
            cell.portraitImg.image = [self dealImageWIthVoipAccount:model.voipAccount];
            
            cell.portraitImg.layer.masksToBounds = YES;
            cell.portraitImg.layer.cornerRadius = cell.portraitImg.frame.size.width / 2;
            cell.nameLabel.text =model.name;
            cell.selecImage.tag =indexPath.row+1000;
            if ([_selectedArray containsObject:model.strId]  || [_showTableView containsObject:model.strId]) {
                cell.selecImage.image = [UIImage imageNamed:@"select_account_list_checked"];
            }
            else{
                cell.selecImage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
            }
            return cell;
        }
    }
    return nil;
}

-(void)onClickImage : (UITapGestureRecognizer *)tap{
    
    UIImageView * img = (UIImageView *)tap.view;
    NSInteger i = img.tag;
    ContactModel *model = [self.groupArray objectAtIndex:i-10000];
    if (self.tempSelectGroupArray && ![self.tempSelectGroupArray containsObject:model.contactId]) {
        [self getModelChild:model];
        if (model.parentId && ![@"0" isEqualToString:model.parentId]) {
             [self addParentAll:model.parentId strId:model.contactId];
        }
    }else{
        [self removeModelChild:model];
        [self removeParentId:model.parentId];
    }
    self.setArray = [NSSet setWithArray:self.selectedArray];
    self.modelArray = self.tempArray;
    [self.groupTableView reloadData];
    [self setRightItem];
    NSLog(@"当前x选择了%lu",(unsigned long)[_selectedArray count]);
}

- (void)cellSelectBtnClickeGroups:(UITapGestureRecognizer *)tap {
    
    CGPoint point = [tap locationInView:_groupTableView];
    
    NSIndexPath * indexPath = [_groupTableView indexPathForRowAtPoint:point];
    
    NSLog(@"indexPath.row = %ld",indexPath.row);
    
    UIImageView * selectimage = nil;
    for (UIView * view in tap.view.subviews) {
        if (view.tag >=indexPath.row+1000000) {
            selectimage = (UIImageView *)view;
            break;
        }
    }
    
    for (UserModel * model in _resultsModelArray) {
        
        if ([model.name isEqualToString:_resultsArray[indexPath.row]]) {
            
            NSString * voipSrting = model.strId;
            if ( [_showTableView containsObject:model.strId]) {
                selectimage.image = [UIImage imageNamed:@"select_account_list_checked"];
            } else{
                if ([_selectedArray containsObject:voipSrting]) {
                    
                    selectimage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
                    [_selectedArray removeObject:voipSrting];
                    
                    if (self.tempArray.count != 0) {
                        
                        
                        [self.tempArray enumerateObjectsUsingBlock:^(UserModel *models, NSUInteger idx, BOOL *stop) {
                            
                            if ([models.strId isEqualToString:voipSrting]) {
                                *stop = YES;
                                [self.tempArray removeObject:models];
                            }
                        }];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setValue:voipSrting forKey:USER_DEFAULT_ID];
                    
                    self.setArray = [NSSet setWithArray:self.selectedArray];
                } else {
                    selectimage.image = [UIImage imageNamed:@"select_account_list_checked"];
                    [_selectedArray addObject:voipSrting];
                    
                    [self.tempArray addObject:model];
                    
                    self.setArray = [NSSet setWithArray:self.selectedArray];
                    
                    [[NSUserDefaults standardUserDefaults] setValue:voipSrting forKey:USER_DEFAULT_ID];
                }
                self.modelArray = self.tempArray;
            }
            NSLog(@"_selectedArray 111 == %@",_selectedArray);
            [_groupTableView reloadData];
            break;
        }
        
    }
    
    [self.groupTableView reloadData];
    
    [self setRightItem];
    
}

- (void)cellSelectBtnClickeGroup:(UITapGestureRecognizer *)tap {
    
    CGPoint point = [tap locationInView:_groupTableView];
    NSIndexPath * indexPath = [_groupTableView indexPathForRowAtPoint:point];
    UIImageView * selectimage = nil;
    for (UIView * view in tap.view.subviews) {
        if (view.tag >=indexPath.row+1000) {
            selectimage = (UIImageView *)view;
            break;
        }
    }
    
    if([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[UserModel class]]){
        
        UserModel *model = [self.groupArray objectAtIndex:indexPath.row];
        NSString *voipSrting = model.strId;
        
       
        if ( [_showTableView containsObject:model.strId]) {
            selectimage.image = [UIImage imageNamed:@"select_account_list_checked"];
            [self.view makeToast:@"" duration:0.8 position:nil];
        }
        else{
            
            if ([_selectedArray containsObject:voipSrting] ) {
                 NSLog(@"model.voipAccount == %@ 需要取消全选",model.strId);
                selectimage.image = [UIImage imageNamed:@"select_account_list_unchecked"];
                [_selectedArray removeObject:voipSrting];
                if (model.parentId ) {
                    if (![@"0" isEqualToString:model.parentId]) {
                         [self removeParentId:model.parentId];
                    }
                }
                if (self.tempArray.count != 0) {
                    
                    
                    [self.tempArray enumerateObjectsUsingBlock:^(UserModel *models, NSUInteger idx, BOOL *stop) {
                        
                        if ([models.strId isEqualToString:voipSrting]) {
                            *stop = YES;
                            [self.tempArray removeObject:models];
                        }
                    }];
                }
                
                [[NSUserDefaults standardUserDefaults] setValue:voipSrting forKey:USER_DEFAULT_ID];
                
                self.setArray = [NSSet setWithArray:self.selectedArray];
            }
            else{
                NSLog(@"model.voipAccount == %@ 需要增加判断全选",model.strId);
                selectimage.image = [UIImage imageNamed:@"select_account_list_checked"];
                [_selectedArray addObject:voipSrting];
                [self.tempArray addObject:model];
                if (model.parentId && ![@"0" isEqualToString:model.parentId]) {
                    [self addParentAll:model.parentId strId:model.strId];
                }
                self.setArray = [NSSet setWithArray:self.selectedArray];
                
                [[NSUserDefaults standardUserDefaults] setValue:voipSrting forKey:USER_DEFAULT_ID];
            }
            
            self.modelArray = self.tempArray;
            
        }
        
        [_groupTableView reloadData];
        
        [self setRightItem];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *voipAccount = [[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_ID];
    if (self.searchController.active)
    {
        //        NSArray *array = [[NSSet setWithArray:_modelArray]allObjects];
        //        for (UserModel *model in array) {
        //            if ([model.name isEqualToString:_resultsData[indexPath.row]]) {
        //
        //
        //            }
        //        }
    } else {
        
        UserModel *usermodel = [self.groupArray objectAtIndex:indexPath.row];
        if ([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[UserModel class]]) {
            TYHContactDetailCell *cell = (TYHContactDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
            if ([voipAccount isEqualToString:usermodel.strId]) {
                return;
            }
            if (self.isSelect) {
                for (NSString *user in self.selectedArray) {
                    if ([user isEqualToString:usermodel.strId]) {
                        [self.selectedArray removeObject:usermodel.strId];
                        cell.userIcon.image = [UIImage imageNamed:@"未选中"];
                        return;
                    }
                }
                [self.selectedArray addObject:usermodel.voipAccount];
                cell.userIcon.image = [UIImage imageNamed:@"选中"];
                return;
            }
        }
        
        NTESNoticeSelPerTableViewCell *cell = (NTESNoticeSelPerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        ContactModel *model = [self.groupArray objectAtIndex:indexPath.row];
        if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[InviteJoinListViewCell class]]) {
            return;
        }else {
            
            if (model.childs && model.childs.count > 0) {// 下个层级仍然存在父级
                NSLog(@"下个层级仍然存在父级");
                for (ContactModel *contactModel in model.childs) {
                    NSInteger index = [self.groupArray indexOfObjectIdenticalTo:contactModel];
                    isAlreadyInserted=(index>0 && index!=NSIntegerMax);
                    if(isAlreadyInserted) break;
                }
                
                if (isAlreadyInserted) {
                    cell.icon.image = [UIImage imageNamed:@"未展开"];
                    [self miniMizeThisRowsGroup:model.childs];
                }else{
                    cell.icon.image = [UIImage imageNamed:@"展开"];
                    NSUInteger count=indexPath.row+1;
                    NSMutableArray *arCells=[NSMutableArray array];
                    for(ContactModel *dInner in model.childs ) {
                        [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                        [self.groupArray insertObject:dInner atIndex:count++];
                    }
                    [tableView insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            if (model.userList && model.userList.count) {//下个层级无父级
//                BOOL isAlreadyInserted = NO;
                NSLog(@"下个层级无父级");
                for (UserModel *userModel in model.userList) {
                    NSInteger index = [self.groupArray indexOfObjectIdenticalTo:userModel];
                    isAlreadyInserted=(index>0 && index!=NSIntegerMax);
                    if(isAlreadyInserted) break;
                }
                if (isAlreadyInserted) {
                    
                    cell.icon.image = [UIImage imageNamed:@"未展开"];
                    [self miniMizeThisRowsWithUserModelGroup:model.userList];
                }else{
                    cell.icon.image = [UIImage imageNamed:@"展开"];
                    NSUInteger count=indexPath.row+1;
                    NSMutableArray *arCells=[NSMutableArray array];
                    for(UserModel *dInner in model.userList ) {
                        [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                        [self.groupArray insertObject:dInner atIndex:count++];
                    }
                    [tableView insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
// 1
-(void)miniMizeThisRowsGroup:(NSArray*)ar{
    
    for (ContactModel *model in ar) {
        
        NSUInteger indexToRemove = [self.groupArray indexOfObjectIdenticalTo:model];
        if (model.userList && model.userList.count > 0) {
            [self miniMizeThisRowsWithUserModelGroup:model.userList];
        }
        
        if (model.childs && model.childs.count > 0) {
            [self miniMizeThisRowsGroup:model.childs];
        }
        if([self.groupArray indexOfObjectIdenticalTo:model]!=NSNotFound) {
            [self.groupArray removeObjectIdenticalTo:model];
//            [self.groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:
//                                                         [NSIndexPath indexPathForRow:indexToRemove inSection:0]
//                                                         ]
//                                       withRowAnimation:UITableViewRowAnimationNone];
            [self.groupTableView reloadData];
        }

     
    }
}

// 2
-(void)miniMizeThisRowsWithUserModelGroup:(NSArray*)ar{
    
    for (UserModel *model in ar) {
    
        NSUInteger indexToRemove = [self.groupArray indexOfObjectIdenticalTo:model];
        
        if([self.groupArray indexOfObjectIdenticalTo:model]!=NSNotFound) {
            [self.groupArray removeObjectIdenticalTo:model];
//            [self.groupTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:
//                                                         [NSIndexPath indexPathForRow:indexToRemove inSection:0]
//                                                         ]
//                                       withRowAnimation:UITableViewRowAnimationNone];
            [self.groupTableView reloadData];
        }

    }
}

#pragma mark - 全选使用的函数

- (void) getModelChild:(ContactModel *) model{//递归添加子层级
    
    if (self.tempSelectGroupArray && ![self.tempSelectGroupArray containsObject:model.contactId]) {
        [self.tempSelectGroupArray addObject:model.contactId];
        [self.tempSelectGroupModelArray addObject:model];
    }
    if (model.userList && [model.userList count] > 0) {
        for (int i=0; i<[model.userList count]; i++){
            UserModel *userModel = model.userList[i] ;
            if (userModel && userModel.strId) {
                if (![_selectedArray containsObject:userModel.strId]) {
                    [_selectedArray addObject:userModel.strId];
                    [self.tempArray addObject:userModel];
                }
            }
        }
    }
    for (int i=0; i<[model.childs count]; i++){
        if (model.childs[i] != nil && [model.childs count] > 0) {
            [self getModelChild:model.childs[i]];
        }
    }
}

- (void) removeModelChild:(ContactModel *) model{//递归删除
    
    if (self.tempSelectGroupArray && [self.tempSelectGroupArray containsObject:model.contactId]) {
        [self.tempSelectGroupArray removeObject:model.contactId];
        [self.tempSelectGroupModelArray removeObject:model];
    }
    if (model.userList && [model.userList count] > 0) {
        for (int i=0; i<[model.userList count]; i++){
            UserModel *userModel = model.userList[i] ;
            if (userModel && userModel.strId) {
                if ([_selectedArray containsObject:userModel.strId]) {
                    [_selectedArray removeObject:userModel.strId];
                    [self.tempArray removeObject:userModel];
                }
            }
        }
    }
    for (int i=0; i<[model.childs count]; i++){
        if (model.childs[i] != nil && [model.childs count] > 0) {
            [self removeModelChild:model.childs[i]];
        }
    }
}

//通过子节点删除父级节点
-(void) removeParentId:(NSString *) parentId{
    if ([self.tempSelectGroupArray containsObject:parentId]) {
        [self.tempSelectGroupArray removeObject:parentId];
        int index = -1;
        for (int i=0; i<[self.tempSelectGroupModelArray count]; i++)
        {
            ContactModel *model =self.tempSelectGroupModelArray[i];
            if ([model.contactId isEqualToString:parentId]) {
                index = i;
            }
        }
        if (index != -1) {
            ContactModel *m =self.tempSelectGroupModelArray[index];
            [self.tempSelectGroupModelArray removeObjectAtIndex:index];
            if (m.parentId && ![@"0" isEqualToString:m.parentId]) {
                [self removeParentId:m.parentId];
            }
        }
    }
}
//通过选择子节点l动态添加父节点
-(void) addParentAll:(NSString *) parentId strId: (NSString *) strId{
    int index = -1;
    BOOL isAll = YES;
    for (int i = 0; i < [self.groupArray count]; i++) {
        if([self.groupArray[i] isKindOfClass:[ContactModel class]]){
            ContactModel *model = self.groupArray[i];
            if ( model.contactId && [model.contactId isEqualToString:parentId]) {
                if (model.childs && [model.childs count] > 0) {
                    for (int j = 0; j < [model.childs count]; j ++ ) {
                        if (model.childs && [model.childs[j] isKindOfClass:[ContactModel class]]) {
                            ContactModel *m = model.childs[j] ;
                            if(m.userList && [m.userList count] > 0){
                                for (int z = 0; z < [m.userList count]; z ++) {
                                    UserModel  *u = m.userList[z];
                                    if (![self.selectedArray containsObject:u.strId]) {
                                        isAll = NO;
                                        return;
                                    }
                                }
                            }
                            if(m.childs && [m.childs count] > 0){
                                for (int z = 0; z < [m.childs count]; z ++) {
                                    ContactModel  *u = m.childs[z];
                                    if (![self.tempSelectGroupArray containsObject:u.contactId]) {
                                        isAll = NO;
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }
                if (model.userList &&[model.userList count] > 0) {
                    for (int i = 0; i < [model.userList count]; i ++ ) {
                        UserModel *u = model.userList[i];
                        if (![self.selectedArray containsObject:u.strId]) {
                            isAll = NO;
                            return;
                        }
                    }
                }
                index = i;
                break;
            }
        }
    }
    
    
    if (index != -1 && isAll) {
        [self.tempSelectGroupArray addObject:parentId];
        [self.tempSelectGroupModelArray addObject:self.groupArray[index]];
        ContactModel *m = self.groupArray[index];
        if (m.parentId && ![@"0" isEqualToString:m.parentId]) {
            [self addParentAll:m.parentId strId:m.contactId];
        }
    }
}
#pragma mark - 返回行缩进 有三个方法一起配合使用才生效
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.searchController.active) {

               if ([[self.groupArray objectAtIndex:indexPath.row] isKindOfClass:[ContactModel class]]) {
                   ContactModel *model = [self.groupArray objectAtIndex:indexPath.row];
                   return model.IndentationLevel*1;
               }
               else
               {
                   ContactModel *model = [self.groupArray objectAtIndex:indexPath.row];
                   return model.IndentationLevel*1 - 1;
                   
               }
           }
    
    return 0;
    
}
-(UIImage *)dealImageWIthVoipAccount:(NSString *)voipAccount
{
    UIImage *image = [[UIImage alloc]init];
    image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:voipAccount];
    if (image && ![self isBlankString:voipAccount]) {
        return image;
    }
    else
        return [UIImage imageNamed:@"mk-photo"];
    
}
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
- (void)viewDidDisappear:(BOOL)animated{
    self.searchController.active = FALSE;
}
@end
