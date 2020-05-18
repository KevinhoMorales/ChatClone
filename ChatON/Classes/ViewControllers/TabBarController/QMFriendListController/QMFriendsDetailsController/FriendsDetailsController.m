
//
//  FriendsDetailsController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "FriendsDetailsController.h"
#import "VideoCallController.h"
#import "ChatVC.h"
#import "UsersUtils.h"
#import "QMImageView.h"
#import "AlertsFactory.h"
#import "AlertView.h"
#import "SVProgressHUD.h"
#import "QBApi.h"
#import "REAlertView+QMSuccess.h"

typedef NS_ENUM(NSUInteger, QMCallType) {
    QMCallTypePhone,
    QMCallTypeVideo,
    QMCallTypeAudio,
    QMCallTypeChat
};

@interface FriendsDetailsController ()
<
UIActionSheetDelegate,
QMContactListServiceDelegate
>

@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *videoChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *audioChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *chatCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteContactButton;
@property (weak, nonatomic) IBOutlet QMImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *userDetails;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@end

@implementation FriendsDetailsController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
     [[QMApi instance].contactListService addDelegate:self];
    
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.selectedUser.phone.length == 0) {
        [self.phoneLabel setText:NSLocalizedString(@"QM_STR_NONE", nil)];
    } else {
        self.phoneLabel.text = self.selectedUser.phone;
    }
    self.fullName.text = self.selectedUser.fullName;
    self.userDetails.text = self.selectedUser.status;
    self.userAvatar.imageViewType = QMImageViewTypeCircle;
    
    NSURL *url = [UsersUtils userAvatarURL:self.selectedUser];
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    [self.userAvatar setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {
         
     }
     
                      completedBlock:
     ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         
     }];
    [[[QMApi instance].usersService getUserWithID:self.selectedUser.ID forceLoad:YES] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
        
        
        
        
        self.fullName.text = task.result.fullName;
        self.userDetails.text = task.result.status;
        self.userAvatar.imageViewType = QMImageViewTypeCircle;
        
        NSURL *url = [UsersUtils userAvatarURL:task.result];
        UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
        [self.userAvatar setImageWithURL:url
                             placeholder:placeholder
                                 options:SDWebImageHighPriority
                                progress:
         ^(NSInteger receivedSize, NSInteger expectedSize) {
             
         }
         
                          completedBlock:
         ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
             
         }];
        return nil;
    }];
   
   
    
    [self updateUserStatus];
    
    [self disableDeleteContactButtonIfNeeded];
    
#if !QM_AUDIO_VIDEO_ENABLED
    
    UITableViewCell *videoChatCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewCell *audioChatCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [self cells:@[videoChatCell, audioChatCell] setHidden:YES];
    
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[QMApi instance].contactListService removeDelegate:self];
}

- (void)updateUserStatus {
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:self.selectedUser.ID];
    
    if (item) { //friend if YES
        self.status.text = NSLocalizedString(item.online ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
        self.onlineCircle.hidden = !item.online;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        ChatVC *chatController = segue.destinationViewController;
        chatController.dialog = sender;
        
        NSAssert([sender isKindOfClass:QBChatDialog.class], @"Need update this case");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case QMCallTypePhone: break;
            
#if QM_AUDIO_VIDEO_ENABLED
        case QMCallTypeVideo:{
            
//            if( ![[QMApi instance] isFriend:self.selectedUser] || [[QMApi instance] userIDIsInPendingList:self.selectedUser.ID] ) {
//                [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
//            }
//            else{
//                [[QMApi instance] callToUser:@(self.selectedUser.ID) conferenceType:QBRTCConferenceTypeVideo];
//            }
        }
            break;
        case QMCallTypeAudio: {
            if( ![[QMApi instance] isFriend:self.selectedUser] || [[QMApi instance] userIDIsInPendingList:self.selectedUser.ID] ) {
                [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
            }
            else{
                [[QMApi instance] callToUser:@(self.selectedUser.ID) conferenceType:QBRTCConferenceTypeAudio];
            }
        }
            break;
        case QMCallTypeChat: {
#else
        case QMCallTypeVideo: {
#endif
            __weak __typeof(self)weakSelf = self;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [[QMApi instance] createPrivateChatDialogIfNeededWithOpponent:self.selectedUser completion:^(QBChatDialog *chatDialog) {
                
                if (chatDialog) {
                    [weakSelf performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatDialog];
                }
                [SVProgressHUD dismiss];
            }];
            
        } break;
            
        default:break;
    }
}

#pragma mark - Actions

- (IBAction)removeFromFriends:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [AlertView presentAlertViewWithConfiguration:^(AlertView *alertView) {
        
        alertView.message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_CONTACT", @"{User Full Name}"), self.selectedUser.fullName];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{}];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil) andActionBlock:^{
            
            [[QMApi instance] removeUserFromContactList:weakSelf.selectedUser completion:^(BOOL success, QBChatMessage *notification) {}];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
    

- (void)disableDeleteContactButtonIfNeeded
{
    BOOL isContact = [[QMApi instance] isFriend:self.selectedUser];
    self.deleteContactButton.enabled = isContact;
}
    
#pragma mark Contact List Serice Delegate
    
- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    [self updateUserStatus];
}
    
- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    [self updateUserStatus];
}
    
- (void)contactListService:(QMContactListService *)contactListService didUpdateUser:(QBUUser *)user {
    [self updateUserStatus];
}

@end
