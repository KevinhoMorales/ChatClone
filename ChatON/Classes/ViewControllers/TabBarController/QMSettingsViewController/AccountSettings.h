//
//  AccountSettings.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DigitsKit/DigitsKit.h>

@interface AccountSettings : UITableViewController<DGTSessionUpdateDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *ChangePassandNumCell;
@property (weak, nonatomic) IBOutlet UILabel *ChangeNumberLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *DeleteAccountcell;

@end
