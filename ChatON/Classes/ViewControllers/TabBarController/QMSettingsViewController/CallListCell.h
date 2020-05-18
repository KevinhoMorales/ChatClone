//
//  CallListCell.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"
#import "QBApi.h"
#import "SettingsManager.h"
#import "QMImageView.h"
#import "UsersUtils.h"

@interface CallListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet QMImageView *profilepic;
@property (weak, nonatomic) IBOutlet UILabel *callername;
@property (weak, nonatomic) IBOutlet UIImageView *calltypeimage;
@property (weak, nonatomic) IBOutlet UIButton *calltype;
@property (weak, nonatomic) IBOutlet UILabel *calltime;

@end
