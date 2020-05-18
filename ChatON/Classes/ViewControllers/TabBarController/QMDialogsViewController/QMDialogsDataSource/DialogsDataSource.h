//
//  DialogsDataSource.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.


#import <Foundation/Foundation.h>
#import <QMChatViewController.h>

@protocol QMDialogsDataSourceDelegate <NSObject>

- (void)didChangeUnreadDialogCount:(NSUInteger)unreadDialogsCount;

@end

@interface DialogsDataSource : QMChatViewController<QMChatDataSourceDelegate>

@property(weak, nonatomic) id <QMDialogsDataSourceDelegate> delegate;

-(void)deletechatDialogsWithMessages:(NSArray*)messages;
-(void)updateLastMessage:(QBChatMessage*)lastmessage;
- (instancetype)initWithTableView:(UITableView *)tableView;
- (QBChatDialog *)dialogAtIndexPath:(NSIndexPath *)indexPath;
-(NSMutableArray *)dialogs;
- (void)fetchUnreadDialogsCount;

@end
