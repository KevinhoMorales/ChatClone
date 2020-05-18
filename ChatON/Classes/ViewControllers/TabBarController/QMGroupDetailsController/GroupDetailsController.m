//
//  GroupDetailsController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "GroupDetailsController.h"
#import "QMAddMembersToGroupController.h"
#import "GroupDetailsDataSource.h"
#import "SVProgressHUD.h"
#import "QMImageView.h"
#import "ImagePicker.h"
#import "QBApi.h"
#import "ContentService.h"
#import "UIImage+Cropper.h"
#import "ActionSheet.h"
#import "REAlertView+QMSuccess.h"
#import "UsersUtils.h"

@interface GroupDetailsController ()

<UITableViewDelegate, UIActionSheetDelegate, QMContactListServiceDelegate, QMChatServiceDelegate, QMChatConnectionDelegate,QMImagePickerResultHandler>

@property (weak, nonatomic) IBOutlet QMImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)changegroupname:(id)sender;

@property (strong, nonatomic) GroupDetailsDataSource *dataSource;

@property (nonatomic, assign) BOOL shouldNotUnsubFromServices;
@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation GroupDetailsController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.groupAvatarView.imageViewType = QMImageViewTypeCircle;
    
    NSURL *url = [UsersUtils userAvatarURL:self.currentUser];
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    
    [self.groupAvatarView setImageWithURL:url
                        placeholder:placeholder
                            options:SDWebImageHighPriority
                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                               ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                           } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               
                               
                           }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeGroupAvatar:)];
    [self.groupAvatarView addGestureRecognizer:tap];
   // self.groupAvatarView.layer.cornerRadius = self.groupAvatarView.frame.size.width / 2;
   // self.groupAvatarView.layer.masksToBounds = YES;
    
    self.dataSource = [[GroupDetailsDataSource alloc] initWithTableView:self.tableView];
    [self updateGUIWithChatDialog:self.chatDialog];
}

- (void)requestOnlineUsers {
    __weak __typeof(self)weakSelf = self;
   
    //change
    
    [self.chatDialog requestOnlineUsersWithCompletionBlock:^(NSMutableArray<NSNumber *> * _Nullable onlineUsers, NSError * _Nullable error) {
       
        [weakSelf updateOnlineStatus:onlineUsers.count];
    }];
}

- (void)updateOnlineStatus:(NSUInteger)online {
    
    NSString *onlineUsersCountText = [NSString stringWithFormat:@"%zd/%zd online", online, self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = onlineUsersCountText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.shouldNotUnsubFromServices = NO;

    [[QMApi instance].contactListService addDelegate:self];
    [[QMApi instance].chatService addDelegate:self];
}
  
- (void)viewWillDisappear:(BOOL)animated {
    
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
    
    if (!self.shouldNotUnsubFromServices) {
        [[QMApi instance].contactListService removeDelegate:self];
        [[QMApi instance].chatService removeDelegate:self];
    }
}

- (IBAction)changeDialogName:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if(response.success){
            self.groupNameField.text = self.chatDialog.name;
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)changeGroupAvatar:(id)sender {
    [self.view endEditing:YES];

    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [ImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGEE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [ImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    

   
}
- (void)imagePicker:(ImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    
        __weak typeof(self)weakSelf = self;
          __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QMApi instance] changeAvatar:photo forChatDialog:strongSelf.chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
            //
            if (response.success) {
                weakSelf.groupAvatarView.image = [photo imageByCircularScaleAndCrop:weakSelf.groupAvatarView.frame.size];
            }
            [SVProgressHUD dismiss];
        }];
    
    
}
- (IBAction)addFriendsToChat:(id)sender
{
    // check for friends:
    NSArray *friends = [[QMApi instance] contactsOnly];
    NSArray *usersIDs = [[QMApi instance] idsWithUsers:friends];
    NSArray *friendsIDsToAdd = [self filteredIDs:usersIDs forChatDialog:self.chatDialog];
    
    if ([friendsIDsToAdd count] == 0) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"QM_STR_CANT_ADD_NEW_FRIEND", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    
    [self performSegueWithIdentifier:kQMAddMembersToGroupControllerSegue sender:nil];
}

- (void)updateGUI {
    [self.dataSource reloadUserData];
    [self requestOnlineUsers];
}

- (void)updateGUIWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(self.chatDialog && chatDialog.type == QBChatDialogTypeGroup , @"chatDialog can't be nil and must be group type");
    self.groupNameField.text = chatDialog.name;
    if (chatDialog.photo) {
        [self.groupAvatarView setImageWithURL:[NSURL URLWithString:chatDialog.photo] placeholder:[UIImage imageNamed:@"upic_placeholder_details_group"] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {} completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    }
    [self.dataSource reloadDataWithChatDialog:chatDialog];
    self.chatDialog = chatDialog;
    self.occupantsCountLabel.text = [NSString stringWithFormat:@"%zd participants", self.chatDialog.occupantIDs.count];
    [self requestOnlineUsers];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    
}
- (void)leaveGroupChat
{
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [[QMApi instance] leaveChatDialog:self.chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        [SVProgressHUD dismiss];
        if (response.success) {
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        __weak typeof(self)weakSelf = self;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [ActionSheet presentActionSheetInView:tableView configuration:^(ActionSheet *actionSheet) {
            actionSheet.title = @"Are you sure?";
            [actionSheet addCancelButtonWihtTitle:@"Cancel" andActionBlock:^{}];
            [actionSheet addDestructiveButtonWithTitle:@"Leave chat" andActionBlock:^{
                // leave logic:
                [weakSelf leaveGroupChat];
            }];
        }];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMAddMembersToGroupControllerSegue]) {
        self.shouldNotUnsubFromServices = YES;
        
        QMAddMembersToGroupController *addMembersVC = segue.destinationViewController;
        addMembersVC.chatDialog = self.chatDialog;
    }
}

#pragma mark Contact List Serice Delegate

- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    if ([self.chatDialog.occupantIDs containsObject:@(userID)]) {
        [self updateGUI];
    }
}

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    [self updateGUI];
}

#pragma mark Chat Service Delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    if ([chatDialog.ID isEqualToString:self.chatDialog.ID]) {
        [self updateGUIWithChatDialog:chatDialog];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    if ([chatDialog.ID isEqualToString:self.chatDialog.ID]) {
        [self updateGUIWithChatDialog:chatDialog];
    }
}

- (IBAction)changegroupname:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if(response.success){
            self.groupNameField.text = self.chatDialog.name;
        }
        [SVProgressHUD dismiss];
    }];
}
@end
