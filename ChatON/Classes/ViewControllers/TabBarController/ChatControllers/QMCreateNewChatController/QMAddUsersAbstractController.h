//
//  QMAddUsersAbstractController.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QMAddUsersAbstractController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSArray *contacts;

/** Actions */
- (IBAction)performAction:(UIButton *)sender;

@end
