//
//  CallsHistoryVC.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUsersMemoryStorage.h"
#import "QBApi.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface CallsHistoryVC : UIViewController<QMUsersMemoryStorageDelegate,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate>

@property(strong,nonatomic)GADBannerView *bannerview;
-(void)loadbanner;
@end