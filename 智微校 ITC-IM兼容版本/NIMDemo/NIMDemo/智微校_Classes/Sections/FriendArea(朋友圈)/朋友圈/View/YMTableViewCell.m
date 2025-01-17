//
//  YMTableViewCell.m
//  WFCoretext
//
//  Created by 阿虎 on 14/10/28.
//  Copyright (c) 2014年 tigerwf. All rights reserved.
// 2 3 2 2 2 3 1 3 2 1

#import "YMTableViewCell.h"
#import "WFReplyBody.h"
#import "ContantHead.h"
#import "YMTapGestureRecongnizer.h"
#import "WFHudView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import <UIImageView+WebCache.h>
#import "SchoolMatesModel.h"
#define kImageTag 9999

#define WIDTH ([UIScreen mainScreen].bounds.size.width / 320 )
#define HEIGHT ([UIScreen mainScreen].bounds.size.height / 568)


@implementation YMTableViewCell
{
    UIButton *foldBtn;
    NSMutableArray *photos;
    
    YMTextData *tempDate;
    UIImageView *replyImageView;
    NSInteger oneImageHeight;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        oneImageHeight = 0;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        _delButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delButton setBackgroundImage:[UIImage imageNamed:@"btn_del_normal"] forState:UIControlStateNormal];
        _delButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 37.0f, 20, 24, 24);
//        [_delButton setBackgroundImage:[UIImage imageNamed:@"btn_del_pressed"] forState:UIControlStateSelected];
        _userHeaderImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, TableHeader)];
        _userHeaderImage.backgroundColor = [UIColor clearColor];
        _userHeaderImage.userInteractionEnabled = YES;
        
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headTapAction:)];

        [self.userHeaderImage addGestureRecognizer:gesture];
        
        CALayer *layer = [_userHeaderImage layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:_userHeaderImage.frame.size.width / 2];
        [layer setBorderWidth:0.5f];
        [layer setBorderColor:[[UIColor colorWithRed:63/255.0 green:107/255.0 blue:252/255.0 alpha:0.5] CGColor]];
        [self.contentView addSubview:_userHeaderImage];
        
        _userNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0 + TableHeader + 20, 7, screenWidth - 120, TableHeader/2)];
        _userNameLbl.textAlignment = NSTextAlignmentLeft;
        _userNameLbl.font = [UIFont fontWithName:@"STHeiti-Medium" size:15];
        
        _userNameLbl.textColor = [UIColor colorWithRed:87/255.0 green:96/255.0 blue:150/255.0 alpha:1.0];
        
        _userNameLbl.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headTapAction:)];
        [self.contentView addSubview:_userNameLbl];
        [self.userNameLbl addGestureRecognizer:gesture2];
        
        _userIntroLbl = [[UILabel alloc] initWithFrame:CGRectMake(0 + TableHeader + 20, 5 + TableHeader/2 , screenWidth - 120, TableHeader/2)];
        _userIntroLbl.numberOfLines = 1;
        _userIntroLbl.font = [UIFont boldSystemFontOfSize:14.0];
        _userIntroLbl.textColor = [UIColor grayColor];
        [self.contentView addSubview:_userIntroLbl];
        
        _imageArray = [[NSMutableArray alloc] init];
        _ymTextArray = [[NSMutableArray alloc] init];
        _ymShuoshuoArray = [[NSMutableArray alloc] init];
        _ymFavourArray = [[NSMutableArray alloc] init];
        
        foldBtn = [UIButton buttonWithType:0];
        [foldBtn setTitle:@"展开" forState:0];
        foldBtn.backgroundColor = [UIColor clearColor];
        foldBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [foldBtn setTitleColor:[UIColor grayColor] forState:0];
        [foldBtn addTarget:self action:@selector(foldText) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:foldBtn];

        
        replyImageView = [[UIImageView alloc] init];
        
        replyImageView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [self.contentView addSubview:replyImageView];
        
        _replyBtn = [YMButton buttonWithType:0];
        [_replyBtn setImage:[UIImage imageNamed:@"fw_r2_c2.png"] forState:0];
        [self.contentView addSubview:_replyBtn];
        
        _favourImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _favourImage.image = [UIImage imageNamed:@"zan.png"];
        [self.contentView addSubview:_favourImage];
        
    }
    return self;
}

- (void)foldText{
    
    if (tempDate.foldOrNot == YES) {
        tempDate.foldOrNot = NO;
        [foldBtn setTitle:@"收起" forState:0];
    }else{
        tempDate.foldOrNot = YES;
        [foldBtn setTitle:@"展开" forState:0];
    }
    
    [_delegate changeFoldState:tempDate onCellRow:self.stamp];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)setYMViewWith:(YMTextData *)ymData{
  
    
    
    tempDate = ymData;
    
    
    
#pragma mark -  //头像 昵称 简介
//    _userHeaderImage.image = [UIImage imageNamed:tempDate.messageBody.posterImgstr];
    
    [_userHeaderImage sd_setImageWithURL:[NSURL URLWithString:tempDate.messageBody.posterImgstr] placeholderImage:[UIImage imageNamed:@"mk-photo"]];
    
    _userNameLbl.text = tempDate.messageBody.posterName;
    _userIntroLbl.text = tempDate.messageBody.posterIntro;
    
    //移除说说view 避免滚动时内容重叠
    for ( int i = 0; i < _ymShuoshuoArray.count; i ++) {
        WFTextView * imageV = (WFTextView *)[_ymShuoshuoArray objectAtIndex:i];
        if (imageV.superview) {
            [imageV removeFromSuperview];
        }
    }
    
    [_ymShuoshuoArray removeAllObjects];
  
#pragma mark - // /////////添加说说view

    WFTextView *textView = [[WFTextView alloc] initWithFrame:CGRectMake(offSet_X, 15 + TableHeader, screenWidth - 2 * offSet_X - 35, 0)];
    textView.delegate = self;
    textView.attributedData = ymData.attributedDataShuoshuo;
    textView.isFold = ymData.foldOrNot;
//    textView.isFold = YES;
    
    textView.isDraw = YES;
    [textView setOldString:ymData.showShuoShuo andNewString:ymData.completionShuoshuo];
    [self.contentView addSubview:textView];
    
    BOOL foldOrnot = ymData.foldOrNot;
    float hhhh = foldOrnot?ymData.shuoshuoHeight:ymData.unFoldShuoHeight;
    
    textView.frame = CGRectMake(0 + TableHeader + 20, 15 + TableHeader, screenWidth - 2 * offSet_X - 35, hhhh);
    
    [_ymShuoshuoArray addObject:textView];
    
    //按钮
    foldBtn.frame = CGRectMake(0 + TableHeader + 10, 15 + TableHeader + hhhh + 10 , 50, 20 );
    
    if (ymData.islessLimit) {//小于最小限制 隐藏折叠展开按钮
        
        foldBtn.hidden = YES;
    }else{
        foldBtn.hidden = NO;
    }
    
    if (tempDate.foldOrNot == YES) {
        
        [foldBtn setTitle:@"展开" forState:0];
    }else{
        [foldBtn setTitle:@"收起" forState:0];
    }
    
#pragma mark - /////// //图片部分
    for (int i = 0; i < [_imageArray count]; i++) {
        
        UIImageView * imageV = (UIImageView *)[_imageArray objectAtIndex:i];
        if (imageV.superview) {
            [imageV removeFromSuperview];
        }
    }
    [_imageArray removeAllObjects];
    for (int  i = 0; i < [ymData.showImageArray count]; i++) {

        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(((375 -  200)/4)*(i%3 + 1) +  40 * (i%3) + 16, TableHeader + 3 * ((i/3) + 1) + (i/3) *  ShowImage_H + hhhh + kDistance + (ymData.islessLimit?0:30) , 80,ShowImage_H)];
        image.userInteractionEnabled = YES;
        
        YMTapGestureRecongnizer *tap = [[YMTapGestureRecongnizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [image addGestureRecognizer:tap];
        tap.appendArray = ymData.showImageArray;
        
        image.backgroundColor = [UIColor clearColor];
        image.tag = kImageTag + i;
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
//        [image sd_setImageWithURL:[NSURL URLWithString:[ymData.showImageArray objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"hhh"]];
        
        [image sd_setImageWithURL:[NSURL URLWithString:[ymData.showImageArray objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"hhh"] completed:^(UIImage *imageTmp, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (ymData.showImageArray.count == 1) {
                float heightScale = 90/imageTmp.size.height/1.0;
                float widthScale = 90/imageTmp.size.width/1.0;
                float scale = MIN(heightScale, widthScale);
                float h = imageTmp.size.height*scale;
                float w = imageTmp.size.width*scale;

//                image.contentMode = UIViewContentModeScaleAspectFit & UIViewContentModeLeft;
                 image.frame = CGRectMake(0 + TableHeader + 20, TableHeader + 3 * ((1/3) + 1) +  + hhhh + kDistance + (ymData.islessLimit?0:30) , w,h);
                if (h <80) {
                    image.frame = CGRectMake(0 + TableHeader + 20, TableHeader + 3 * ((1/3) + 1) +  + hhhh + kDistance + (ymData.islessLimit?0:30) , (80/h *w<230?(80/h *w):230),80);
                }
//               else  {
//                    image.frame = CGRectMake(0 + TableHeader + 20, TableHeader + 3 * ((1/3) + 1) +  + hhhh + kDistance + (ymData.islessLimit?0:30) - 5 , 50,(50/w *h<60?(50/w *h):95));
//                }
                
            }
        }];
        
        
//        if (ymData.showImageArray.count == 1) {
//           
//            
//            float heightScale = imageview.frame.height/self.currentImage.size.height;
//            float widthScale = imageview.frame.width/self.currentImage.size.width;
//            float scale = MIN(heightScale, widthScale);
//            
//            if (heightScale > widthScale) {
//                //横图
//                float heigth = self.currentImage.size.height*scale;
//                float gap = (imageview.frame.height-heigth)/2;
//                self.closeIcon.frame = CGRectMake(imageview.frame.width-4-19, gap+4, 19, 19);
//            }
//            else {
//                //长图
//                float width = self.currentImage.size.width*scale;
//                float gap = (imageview.frame.width-width)/2;
//                self.closeIcon.frame = CGRectMake(imageview.frame.width-4-gap-19, 4, 19, 19);
//            }
//            
//            image.contentMode = UIViewContentModeScaleAspectFit & UIViewContentModeLeft;
//            
//             image.frame = CGRectMake(0 + TableHeader + 20, TableHeader + 3 * ((1/3) + 1) +  + hhhh + kDistance + (ymData.islessLimit?0:30) , 80,ShowImage_H);
//        }
        

        [self.contentView addSubview:image];
        [_imageArray addObject:image];
    }
    
#pragma mark - /////点赞部分
    //移除点赞view 避免滚动时内容重叠
    for ( int i = 0; i < _ymFavourArray.count; i ++) {
       
        WFTextView * imageV = (WFTextView *)[_ymFavourArray objectAtIndex:i];
        if (imageV.superview) {
            [imageV removeFromSuperview];
        }
    }
    
    [_ymFavourArray removeAllObjects];


    float origin_Y = 10;
    NSUInteger scale_Y = ymData.showImageArray.count - 1;
    float balanceHeight = 0; //纯粹为了解决没图片高度的问题
    if (ymData.showImageArray.count == 0) {
        scale_Y = 0;
        balanceHeight = - ShowImage_H - kDistance ;
    }
    
    float backView_Y = 0;
    float backView_H = 0;
    
    WFTextView *favourView = [[WFTextView alloc] initWithFrame:CGRectMake(offSet_X + 30, TableHeader + 10 + ShowImage_H + (ShowImage_H + 10)*(scale_Y/3) + origin_Y + hhhh + kDistance + (ymData.islessLimit?0:30) + balanceHeight + kReplyBtnDistance + oneImageHeight, screenWidth - 2 * offSet_X - 35, 0)];
    favourView.delegate = self;
    favourView.attributedData = ymData.attributedDataFavour;
    favourView.isDraw = YES;
    favourView.isFold = YES;
    
    favourView.canClickAll = NO;
    
//    favourView.backgroundColor = [UIColor lightGrayColor];
    favourView.textColor = [UIColor colorWithRed:87/255.0 green:96/255.0 blue:138/255.0 alpha:1.0];
    [favourView setOldString:ymData.showFavour andNewString:ymData.completionFavour];
        favourView.frame = CGRectMake(0 + TableHeader + 20 + 20 + 5,TableHeader + 10 + ShowImage_H + (ShowImage_H + 10)*(scale_Y/3) + origin_Y + hhhh + kDistance + (ymData.islessLimit?0:30) + balanceHeight + kReplyBtnDistance + oneImageHeight, screenWidth - offSet_X * 2 - 55 , ymData.favourHeight);
    [self.contentView addSubview:favourView];
    backView_H += ((ymData.favourHeight == 0)?(-kReply_FavourDistance):ymData.favourHeight);
    [_ymFavourArray addObject:favourView];

//点赞图片的位置
    
    _favourImage.frame = CGRectMake(0 + TableHeader + 20 + 5, favourView.frame.origin.y + oneImageHeight, (ymData.favourHeight == 0)?0:20,(ymData.favourHeight == 0)?0:20);
    
    
#pragma mark - ///// //最下方回复部分
    for (int i = 0; i < [_ymTextArray count]; i++) {
        
        WFTextView * ymTextView = (WFTextView *)[_ymTextArray objectAtIndex:i];
        if (ymTextView.superview) {
            [ymTextView removeFromSuperview];
            //  NSLog(@"here");
        }
    }
    
    [_ymTextArray removeAllObjects];
  
    
    for (int i = 0; i < ymData.replyDataSource.count; i ++ ) {
        
        WFTextView *_ilcoreText = [[WFTextView alloc] initWithFrame:CGRectMake(0 + TableHeader + 20,TableHeader + 10 + ShowImage_H + (ShowImage_H + 10)*(scale_Y/3) + origin_Y + hhhh + kDistance + (ymData.islessLimit?0:30) + balanceHeight + kReplyBtnDistance + ymData.favourHeight + (ymData.favourHeight == 0?0:kReply_FavourDistance) + oneImageHeight, screenWidth - offSet_X * 2, 0)];
        
        if (i == 0) {
            backView_Y = TableHeader + 10 + ShowImage_H + (ShowImage_H + 10)*(scale_Y/3) + origin_Y + hhhh + kDistance + (ymData.islessLimit?0:30) + oneImageHeight;
        }
        
        _ilcoreText.delegate = self;
        _ilcoreText.replyIndex = i;
        _ilcoreText.isFold = NO;
//        _ilcoreText.isDraw = NO;
        _ilcoreText.attributedData = [ymData.attributedDataReply objectAtIndex:i];

        WFReplyBody *body = (WFReplyBody *)[ymData.replyDataSource objectAtIndex:i];
        
        NSString *matchString;
        
        if ([body.repliedUser isEqualToString:@""]) {
            matchString = [NSString stringWithFormat:@"%@:%@",body.replyUser,body.replyInfo];
            
        }else{
            matchString = [NSString stringWithFormat:@"%@回复%@:%@",body.replyUser,body.repliedUser,body.replyInfo];
        }
        
        [_ilcoreText setOldString:matchString andNewString:[ymData.completionReplySource objectAtIndex:i]];
        
        _ilcoreText.frame = CGRectMake(0 + TableHeader + 20 + 5,TableHeader + 10 + ShowImage_H + (ShowImage_H + 10)*(scale_Y/3) + origin_Y + hhhh + kDistance + (ymData.islessLimit?0:30) + balanceHeight + kReplyBtnDistance + ymData.favourHeight + (ymData.favourHeight == 0?0:kReply_FavourDistance) + oneImageHeight, screenWidth - offSet_X * 2 - 35, [_ilcoreText getTextHeight]);
        [self.contentView addSubview:_ilcoreText];
        origin_Y += [_ilcoreText getTextHeight] + 5 ;
        
        backView_H += _ilcoreText.frame.size.height;
        
        [_ymTextArray addObject:_ilcoreText];
        
    }
    backView_H += (ymData.replyDataSource.count - 1)*5;
    if (ymData.replyDataSource.count == 0 ) {//没回复的时候
        
        replyImageView.frame = CGRectMake(0 + TableHeader + 20, backView_Y - 10 + balanceHeight + 5 + kReplyBtnDistance, 0 , 0);
        _replyBtn.frame = CGRectMake(screenWidth - offSet_X - 40 + 6 + 10,TableHeader + 10 + ShowImage_H + (ShowImage_H + 10)*(scale_Y/3) + origin_Y + hhhh + kDistance + (ymData.islessLimit?0:30) + balanceHeight + kReplyBtnDistance - 30 + oneImageHeight, 40, 18);
        if (ymData.attributedDataFavour.count > 0) {
            replyImageView.frame = CGRectMake(0 + TableHeader + 20, favourView.frame.origin.y - 2, screenWidth - offSet_X * 2 - 30, ymData.favourHeight );
        }
    }
    else{
            replyImageView.frame = CGRectMake(0 + TableHeader + 20, backView_Y - 10 + balanceHeight + 5 + kReplyBtnDistance + oneImageHeight , screenWidth - offSet_X * 2 - 30, backView_H + 20 - 8 );//微调
            _replyBtn.frame = CGRectMake(screenWidth - offSet_X - 40 + 6 + 10, replyImageView.frame.origin.y - 30, 40, 18);
    }
    
#pragma mark - ///// //删除自己发的状态
    WFMessageBody *m = ymData.messageBody;
    if ([m.posterID isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:USER_DEFAULT_USERID] ]) {
        
        [self.contentView addSubview:_delButton];
    } else {
        [_delButton removeFromSuperview];
    }
    
//    [self reloadInputViews];
}

#pragma mark - ilcoreTextDelegate
- (void)clickMyself:(NSString *)clickString{
    
    //延迟调用下  可去掉 下同
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:clickString message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];

    });
}




- (void)longClickWFCoretext:(NSString *)clickString replyIndex:(NSInteger)index{
  
    if (index == -1) {
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = clickString;
    }else{
        [_delegate longClickRichText:_stamp replyIndex:index];
    }
}


- (void)clickWFCoretext:(NSString *)clickString replyIndex:(NSInteger)index{
    
    if ([clickString isEqualToString:@""] && index != -1) {
       //reply
        //NSLog(@"reply");
        [_delegate clickRichText:_stamp replyIndex:index];
    }else{
        if ([clickString isEqualToString:@""]) {
            //
        }else{
            [WFHudView showMsg:clickString inView:nil];
        }
    }
}


#pragma mark - 点击action
- (void)tapImageView:(YMTapGestureRecongnizer *)tapGes{
    
    [_delegate showImageViewWithImageViews:tapGes.appendArray byClickWhich:tapGes.view.tag];
}

-(void)headTapAction:(id)sender
{
    [self.delegate headIconClick:self];
}


@end
