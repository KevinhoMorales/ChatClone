//
//  SettingsViewController.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SettingsViewController : StaticDataTableViewController<GADBannerViewDelegate,UIPopoverPresentationControllerDelegate,UIPopoverControllerDelegate>

@property (nonatomic, strong) UIPopoverPresentationController *colorPickerPopover;

//@property(strong,nonatomic) GADBannerView *bannerview;

@end
