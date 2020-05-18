//
//  DialogsDataSource.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "DialogsDataSource.h"
#import "DialogCell.h"
#import "SVProgressHUD.h"
#import "QBApi.h"

@interface DialogsDataSource()
<
UITableViewDataSource,
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMContactListServiceDelegate,
QMUsersServiceDelegate
>


@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic, readonly) NSMutableArray *dialogs;
@property (assign, nonatomic) NSUInteger unreadDialogsCount;

@end

@implementation DialogsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        [[QMApi instance].chatService addDelegate:self];
        self.chatDataSource.delegate = self;
        [[QMApi instance].usersService addDelegate:self];
        [[QMApi instance].contactListService addDelegate:self];
        self.tableView = tableView;
        self.tableView.dataSource = self;
    }
    
    
    return self;
}

- (void)retrieveUserIfNeededWithMessage:(QBChatMessage *)message
{
    __weak typeof(self)weakSelf = self;
    
    //change
    
    if (message.messageType == QMMessageTypeContactRequest) {
        [[QMApi instance].usersService getUserWithID:message.senderID];
       
            
         [weakSelf updateGUI];
        
    }
    else if (message.addedOccupantsIDs.count > 0) {
        
        [[QMApi instance].usersService getUsersWithIDs:message.addedOccupantsIDs];
    }

}

- (void)updateGUI {
    
    [self.tableView reloadData];
    [self fetchUnreadDialogsCount];
}
-(void)deletechatDialogsWithMessages:(NSArray*)messages{
    
 
    [self.chatDataSource deleteMessages:messages];
  //  QBChatMessage *message = [[QMApi instance].chatService.messagesMemoryStorage lastMessageFromDialogID:dialog.ID];
   // [self.chatDataSource updateMessage:message];
    

}
-(void)updateLastMessage:(QBChatMessage*)lastmessage{
    
    [self.chatDataSource updateMessage:lastmessage];
}
- (void)setUnreadDialogsCount:(NSUInteger)unreadDialogsCount {
    
    if (_unreadDialogsCount != unreadDialogsCount) {
        _unreadDialogsCount = unreadDialogsCount;
        
        [self.delegate didChangeUnreadDialogCount:_unreadDialogsCount];
    }
}

- (void)fetchUnreadDialogsCount {
    
    NSArray * dialogs = [[QMApi instance] dialogHistory];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unreadMessagesCount > 0"];
    NSArray *result = [dialogs filteredArrayUsingPredicate:predicate];
    self.unreadDialogsCount = result.count;
}

- (void)insertRowAtIndex:(NSUInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
  
    NSUInteger count = self.dialogs.count;
    return count>0?count:1;
}

- (QBChatDialog *)dialogAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *dialogs = self.dialogs;
    if (dialogs.count == 0) {
        return nil;
    }
    
    QBChatDialog *dialog = dialogs[indexPath.row];
    return dialog;
}

- (NSMutableArray *)dialogs {
    
    NSMutableArray *dialogs = [[QMApi instance].chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO].mutableCopy;
    
    return dialogs;
}

NSString *const kQMDialogCellID = @"DialogCell";
NSString *const kQMDontHaveAnyChatsCellID = @"QMDontHaveAnyChatsCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *dialogs = self.dialogs;
    
    if (dialogs.count == 0) {
        DialogCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyChatsCellID];
        return cell;
    }
    
    DialogCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDialogCellID];
    QBChatDialog *dialog = dialogs[indexPath.row];
    cell.dialog = dialog;
    
    return cell;
}

#pragma mark - UITableViewDataSource Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

    return YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        __weak typeof(self)weakSelf = self;
        
        NSLog(@"indexpath %ld",(long)indexPath.row);
        NSLog(@"dialog count before %lu",(unsigned long)self.dialogs.count);
        [SVProgressHUD show];
        QBChatDialog *dialog = [self dialogAtIndexPath:indexPath];
        
        [[QMApi instance].chatService.dialogsMemoryStorage deleteChatDialogWithID:dialog.ID];
        [[QMApi instance].chatService.messagesMemoryStorage deleteMessagesWithDialogID:dialog.ID];
        
        [[QMChatCache instance] deleteDialogWithID:dialog.ID completion:^{
            
           // [self.dialogs removeObjectAtIndex:indexPath.row];
            NSLog(@"dialog count after %lu",(unsigned long)self.dialogs.count);
            [SVProgressHUD dismiss];
            if(weakSelf.dialogs.count == 0){
             
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                [tableView setEditing:NO animated:NO];
            }
            else{
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

            }
            
            
        }];
//        [[QMApi instance] deleteChatDialog:dialog completion:^(BOOL success) {
//            
//            if(success){
//                [[QMApi instance].chatService.dialogsMemoryStorage deleteChatDialogWithID:dialog.ID];
//              
//            [[QMChatCache instance] deleteDialogWithID:dialog.ID completion:^{
//                
//                  [self.dialogs removeObjectAtIndex:indexPath.row];
//                NSLog(@"dialog count after %lu",(unsigned long)self.dialogs.count);
//                [SVProgressHUD dismiss];
//                (weakSelf.dialogs.count == 0) ?
//                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade] :
//                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            }];
//
//            }
//              
//               
//        }];
    }
}

#pragma mark -
#pragma mark Chat Service Delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    
    [self updateGUI];
    [self retrieveUserIfNeededWithMessage:message];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    [self updateGUI];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [self updateGUI];
}

#pragma mark Contact List Serice Delegate

- (void)contactListService:(QMContactListService *)contactListService didAddUsers:(NSArray *)users {
    [self.tableView reloadData];
}

@end
