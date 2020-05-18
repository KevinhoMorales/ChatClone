//
//  ChatVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ChatVC.h"
#import "MainTabBarController.h"
#import "GroupDetailsController.h"
#import "BaseCallsController.h"
#import "MessageBarStyleSheetFactory.h"
#import "QBApi.h"
#import "AlertsFactory.h"
#import "OnlineTitle.h"
#import "IDMPhotoBrowser.h"
#import "QMAudioCallController.h"
#import "VideoCallController.h"
#import "QMPlaceholderTextView.h"
#import "REAlertView+QMSuccess.h"
#import <SVProgressHUD.h>
#import "ChatUtils.h"
#import "UsersUtils.h"
#import "QMImageView.h"
#import "SettingsManager.h"
#import "AGEmojiKeyBoardView.h"
#import "UIImage+fixOrientation.h"
#import "LocationViewController.h"
#import "ImagePicker.h"
#import "QMSoundManager.h"
#import "IQAudioRecorderController.h"
#import "VideoCallUsersSelection.h"




//.. Wazowski Edition
//#import "UIColor+Hex.h"
//..

// chat controller


#import "UIImage+QM.h"
#import "UIColor+QM.h"
#import <TTTAttributedLabel.h>
#import "QMChatAttachmentIncomingCell.h"
#import "QMChatAttachmentOutgoingCell.h"
#import "QMChatAttachmentCell.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"
#import "MessageStatusStringBuilder.h"
#import "ChatButtons.h"
#import <MessageUI/MessageUI.h>
#import <QMChatLocationOutgoingCell.h>
#import <UIImageView+QMLocationSnapshot.h>



static const NSUInteger widthPadding                         = 40.0f;
static const CGFloat kQMEmojiButtonSize                      = 45.0f;
static const NSInteger kQMEmojiButtonTag                     = 100;
static const CGFloat kQMInputToolbarTextContainerInsetRight  = 25.0f;

@interface ChatVC ()
<
AGEmojiKeyboardViewDataSource,
AGEmojiKeyboardViewDelegate,
AVAudioPlayerDelegate
>

@property (strong, nonatomic) OnlineTitle *onlineTitle;

@property (nonatomic, copy) QBUUser* opponentUser;
@property (nonatomic, strong) id<NSObject> observerDidBecomeActive;
@property (nonatomic, strong) MessageStatusStringBuilder* stringBuilder;
@property (nonatomic, strong) NSMapTable* attachmentCells;
@property (nonatomic, readonly) UIImagePickerController* pickerController;
@property (nonatomic, assign) BOOL shouldHoldScrollOnCollectionView;
@property (nonatomic, strong) NSTimer* typingTimer;
@property (nonatomic, strong) id observerDidEnterBackground;

@property (nonatomic, strong) NSArray* unreadMessages;

@property (nonatomic, assign) BOOL isSendingAttachment;
@property (weak, nonatomic) BFTask *contactRequestTask;

@property (nonatomic, assign) BOOL isSendingVideoAttachment;

@property (strong, nonatomic) QMDeferredQueueManager *deferredQueueManager;


@property (nonatomic, strong) UIButton *emojiButton;

@property (nonatomic, assign) BOOL shouldUpdateDialogAfterReturnFromGroupInfo;

@end

@implementation ChatVC

@dynamic deferredQueueManager;
@synthesize pickerController = _pickerController;

- (UIImagePickerController *)pickerController
{
    if (_pickerController == nil) {
        _pickerController = [UIImagePickerController new];
        _pickerController.delegate = self;
    }
    return _pickerController;
}

- (void)refreshCollectionView
{
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:NO];
}

#pragma mark - Override

- (NSUInteger)senderID
{
    return [QMApi instance].currentUser.ID;
}

- (NSString *)senderDisplayName
{
    return [QMApi instance].currentUser.fullName;
}

#pragma mark - View lifecycle

-(void) writeStringToFile:(NSMutableArray *)aString{
    
    NSString *filePath =  [NSHomeDirectory()
                           stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = @"textFile.txt";
    NSString *fileAtPath = [NSString stringWithFormat:@"%@/%@",filePath ,fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    NSError* error = nil;
    [aString  writeToFile:fileAtPath atomically:YES];
    NSData *fileData = [NSData dataWithContentsOfFile:fileAtPath options: 0 error: &error];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSLog(@"Documents directory: %@",
          [fileMgr contentsOfDirectoryAtPath:filePath error:&error]);
    
    if (fileData == nil)
    {
        NSLog(@"Failed to read file, error %@", error);
    }
    else {
        [self readStringFromFile];
    }
    
    NSLog(@"string data %@",aString);
    
    __weak typeof(self)weakSelf = self;
    
    NSString *str = [aString componentsJoinedByString:@"\n \n \n"];
    NSLog(@"str: %@",str);

}
-(void)readStringFromFile
{
    NSError* error = nil;
    NSString *filePath =  [NSHomeDirectory()
                           stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = @"textFile.txt";
    NSString *txtFilePath = [filePath stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:txtFilePath];
    if(fileExists){
        NSLog(@"exist");
    }
    NSData *fileData = [NSData dataWithContentsOfFile:txtFilePath options: 0 error: &error];
    if (fileData == nil)
    {
        NSLog(@"Failed to read file, error %@", error);
    }
    else
    {
        // parse the JSON etc
    }
    
    __weak typeof(self)weakSelf = self;
    
    [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
        
        
        [mailVC setSubject:kMailSubjectString];
        [mailVC setMessageBody:@"Chat History" isHTML:YES];
        [mailVC addAttachmentData:fileData mimeType:@"text/plain" fileName:@"textFile.txt"];
        
        [weakSelf presentViewController:mailVC animated:YES completion:nil];
        
    } finish:^(MFMailComposeResult result, NSError *error) {
        
        if (!error && result == MFMailComposeResultSent) {
            
            // [weakSelf.dataSource clearABFriendsToInvite];
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
        }
        else if (result == MFMailComposeResultFailed && !error) {
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"QM_STR_MAIL_COMPOSER_ERROR_DESCRIPTION_FOR_INVITE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) otherButtonTitles:nil] show];
            
        } else if (result == MFMailComposeResultFailed && error) {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // chat appearance
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //.. Wazowski Edition
    
    [[QMApi instance].chatService addDelegate:self];
    [[QMApi instance].contactListService addDelegate:self];
    [self.deferredQueueManager addDelegate:self];
    
 //   [QMChatCell registerMenuAction:@selector(delete:)];
    _audioplayer.delegate = self;
    
    UIImageView *backgroundimage = [[UIImageView alloc] init];
    backgroundimage.frame = CGRectMake(0, 0, 640, 1136);
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatbackground"];
    NSString *wallpapername = [str stringByReplacingOccurrencesOfString:@"s" withString:@""];
    
    if(str == nil){
        
        backgroundimage.image = [UIImage imageNamed:@"chat_back.jpeg"];
        self.collectionView.backgroundView = backgroundimage;
        
        //  self.collectionView.viewForBaselineLayout.backgroundColor = [UIColor colorWithPatternImage:[ UIImage imageNamed:@"chat_back.jpeg"]];
    }
    else{
        
        backgroundimage.image = [UIImage imageNamed:wallpapername];
        self.collectionView.backgroundView = backgroundimage;
        
        //self.collectionView.viewForBaselineLayout.backgroundColor = [UIColor colorWithPatternImage:[ UIImage imageNamed:str]];
    }
    
    //..
    

    self.inputToolbar.contentView.textView.placeHolder = @"Message";
    
    self.stringBuilder = [MessageStatusStringBuilder new];
    
   // self.showLoadEarlierMessagesHeader = YES;
    
    // emoji button init
    [self configureEmojiButton];
    
    //
    if (self.dialog.type == QBChatDialogTypePrivate) {
        NSUInteger oponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        NSString *oponent_id = [NSString stringWithFormat:@"%d",oponentID];
        [[NSUserDefaults standardUserDefaults] setObject:oponent_id forKey:@"opponentId"];

        self.opponentUser = [[QMApi instance] userWithID:oponentID];
        [self configureNavigationBarForPrivateChat];
        
        [self updateTitleInfoForPrivateDialog];
    } else {
        if (!self.dialog.isJoined) {
            //[self.dialog join];
        }
        
        [self configureNavigationBarForGroupChat];
        self.title = self.dialog.name;
    }
    if (self.items.count > 0 && self.chatDataSource.messagesCount == 0) {
        
        [self.chatDataSource addMessages:self.items];
    }
    
    // Retrieving messages from memory storage.
    // self.items = [[[QMApi instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
    
    
    QMCollectionViewFlowLayoutInvalidationContext* context = [QMCollectionViewFlowLayoutInvalidationContext context];
    context.invalidateFlowLayoutMessagesCache = YES;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
    
  //  [self refreshCollectionView];
    [self refreshMessages];
    
    // Handling 'typing' status.
    if (self.dialog.type == QBChatDialogTypePrivate) {
        __weak typeof(self)weakSelf = self;
        [self.dialog setOnUserIsTyping:^(NSUInteger userID) {
            __typeof(self) strongSelf = weakSelf;
            if ([QBSession currentSession].currentUser.ID == userID) {
                return;
            }
            strongSelf.title = @"typing...";
        }];
        
        // Handling user stopped typing.
        [self.dialog setOnUserStoppedTyping:^(NSUInteger userID) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf updateTitleInfoForPrivateDialog];
        }];
    }
    
}
- (NSArray *)items {
    
    return [[QMApi instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID];
}
- (void)refreshMessages {
    
    
    // Retrieving message from Quickblox REST history and cache.
    [[QMApi instance].chatService messagesWithChatDialogID:self.dialog.ID iterationBlock:^(QBResponse * __unused response, NSArray *messages, BOOL * __unused stop) {
        
        
        if (messages.count > 0) {
            
            [self.chatDataSource addMessages:messages];
        }
    }];
}
- (void)deferredQueueManager:(QMDeferredQueueManager *)__unused queueManager didAddMessageLocally:(QBChatMessage *)addedMessage {
    
    if ([addedMessage.dialogID isEqualToString:self.dialog.ID]) {
        
        [self.chatDataSource addMessage:addedMessage];
    }
}
- (void)deferredQueueManager:(QMDeferredQueueManager *)__unused queueManager didUpdateMessageLocally:(QBChatMessage *)addedMessage {
    
    [self.chatDataSource updateMessage:addedMessage];
}
- (QMDeferredQueueManager *)deferredQueueManager {
    
    return [QMApi instance].chatService.deferredQueueManager;
}
- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {
    
    if (showingProgress ) {
        [SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeClear];
    }
    
    // Retrieving message from Quickblox REST history and cache.
    [[QMApi instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
        if (response.success) {
            
            
            if (showingProgress) {
                [SVProgressHUD dismiss];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Can not refresh messages"];
            NSLog(@"can not refresh messages: %@", response.error.error);
        }
    }];
}

- (void)updateTitleInfoForPrivateDialog {
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:self.opponentUser.ID];
    NSString *status = NSLocalizedString(item.online ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
    
    self.onlineTitle.titleLabel.text = self.opponentUser.fullName;
    self.onlineTitle.statusLabel.text = status;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.shouldUpdateDialogAfterReturnFromGroupInfo) {
        QBChatDialog *updatedDialog = [[QMApi instance].chatService.dialogsMemoryStorage chatDialogWithID:self.dialog.ID];
        if (updatedDialog != nil) {
            self.dialog = updatedDialog;
            self.title = self.dialog.name;
            
            //change
            
            [[QMApi instance].chatService joinToGroupDialog:self.dialog completion:^(NSError * _Nullable error) {
                
                NSLog(@"Failed to join group dialog, because: %@", error.localizedDescription);
            }];
            
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.shouldUpdateDialogAfterReturnFromGroupInfo = NO;
    }
    
    [[QMApi instance].settingsManager setDialogWithIDisActive:self.dialog.ID];
    
    
    [QMApi instance].chatService.chatAttachmentService.delegate = self;
    
    self.actionsHandler = self; // contact request delegate
    
    __weak __typeof(self) weakSelf = self;
    self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
        
        if ([[QBChat instance] isConnected]) {
            [strongSelf refreshMessagesShowingProgress:NO];
        }
    }];
    
    self.observerDidEnterBackground = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf fireStopTypingIfNecessary];
    }];
    
    if ([self.items count] > 0) {
        [self refreshMessagesShowingProgress:NO];
    }
    else {
        [self refreshMessagesShowingProgress:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[QMApi instance].settingsManager setDialogWithIDisActive:nil];
    
    [super viewWillDisappear:animated];
    
    [[QMApi instance].chatService removeDelegate:self];
    [[QMApi instance].contactListService removeDelegate:self];
    self.actionsHandler = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidEnterBackground];
    
    // Deletes typing blocks.
    [self.dialog clearTypingStatusBlocks];
}

- (void)configureNavigationBarForPrivateChat {
    
    self.onlineTitle = [[OnlineTitle alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       150,
                                                                       self.navigationController.navigationBar.frame.size.height)];
    self.navigationItem.titleView = self.onlineTitle;
    
#if QM_AUDIO_VIDEO_ENABLED
    UIButton *audioButton = [ChatButtons audioCall];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [ChatButtons videoCall];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *clearchatButton = [ChatButtons clearchat];
    [clearchatButton addTarget:self action:@selector(emailchatAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    UIBarButtonItem *clearchatBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearchatButton];
    
    
    [self.navigationItem setRightBarButtonItems:@[videoCallBarButtonItem,  audioCallBarButtonItem,clearchatBarButtonItem] animated:YES];
    
#else
    [self.navigationItem setRightBarButtonItem:nil];
#endif
}

- (void)configureNavigationBarForGroupChat {
    
    self.title = self.dialog.name;
    UIButton *groupInfoButton = [ChatButtons groupInfo];
    [groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIButton *clearchatButton = [ChatButtons clearchat];
    [clearchatButton addTarget:self action:@selector(emailchatAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *clearchatBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearchatButton];
    
    UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
    self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem,clearchatBarButtonItem];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)clearcharAction {
    
    
    NSArray* messages = [[QMApi instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID].copy;
    
    if (messages.count) {
        //       [[ServicesManager instance].chatService deleteMessagesLocally:messages forDialogID:self.dialog.ID];
    }
    
    NSMutableSet *messagesIDs = [NSMutableSet set];
    
    for (QBChatMessage *message in messages) {
        
        
        [messagesIDs addObject:message.ID];
    }
    
    
    [QBRequest deleteMessagesWithIDs:messagesIDs forAllUsers:NO successBlock:^(QBResponse *response) {
        
        if (response.error == NULL) {
            
            
            [[QMApi instance].chatService deleteMessagesLocally:messages forDialogID:self.dialog.ID];
            
            
            [self.chatDataSource deleteMessages:messages];
            NSLog(@"woohoooo Goneeee");
            
            
            //            [self refreshMessagesShowingProgress:NO];
            //            [self refreshCollectionView];
            
        }
        
        
    } errorBlock:^(QBResponse *response) {
        
        
        NSLog(@"There is some error :/");
    }];
    

}
-(void)emailchatAction {
    
    NSLog(@"email chat Action");
    
    NSMutableArray *str_arr = [NSMutableArray array];
    QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:20 skip:0];
    
    [QBRequest messagesWithDialogID:self.dialog.ID extendedRequest:nil forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
    
    
        [QBRequest usersWithSuccessBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users) {
            
            NSInteger user_id;
            NSInteger sender_id;
            for(QBChatMessage *message in messages){
                
                sender_id = message.senderID;
                
                for(QBUUser *user in users){
                    
                    user_id = user.ID;
                    if(sender_id == user_id){
                        
                        NSString *str = [NSString stringWithFormat:@"%@ : %@ : %@ ",message.createdAt,user.fullName,message.text];
                        [str_arr addObject:str];
                        
                        
                    }
                }
                
            }
            NSLog(@"email chat %@",str_arr);
            [self writeStringToFile:str_arr];
            
            
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            
        }];
        
    
        
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error: %@", response.error);
    }];

}
- (void)chatService:(QMChatService*)chatService didDeleteMessagesFromMemoryStorage:(NSArray QB_GENERIC(QBChatMessage*)*)messages forDialogID:(NSString*)dialogID {
    
    
    NSLog(@"Messages Deleted");
    
    
    
    [QMChatCache.instance deleteMessageWithDialogID:dialogID completion:^{
        
        
        NSLog(@"Messages deleted from cache");
        
        
        
    }];
    
//    [self.items removeAllObjects];
//    self.items = nil;
//    [self refreshCollectionView];
//    self.showLoadEarlierMessagesHeader = NO;
    
    
    QBChatMessage *latestMessage = [[QMApi instance].chatService.messagesMemoryStorage lastMessageFromDialogID:self.dialog.ID];
    NSLog(@"last message %@",latestMessage);
    if(latestMessage == nil){
        NSLog(@"nil..");
        
//        [[QMApi instance].chatService deleteDialogWithID:dialogID completion:^(QBResponse *response) {
//            
//            if(response!= nil){
//                NSLog(@"dialog deletd..");
//                
//                //  [self performSegueWithIdentifier:kBackSegueIdentifier sender:nil];
//                [self.navigationController popViewControllerAnimated:true];
//            }
//        }];
        //            [[QMApi instance] deleteChatDialog:_dialog completion:^(BOOL success) {
        //
        //                NSLog(@"dialog deleted...");
        //            }];
        
    }
}

#pragma mark - Nav Buttons Actions

- (BOOL)callsAllowed {
#if QM_AUDIO_VIDEO_ENABLED == 0
    [AlertsFactory comingSoonAlert];
    return NO;
#else
    if (![QMApi instance].isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return NO;
    }
    
    if( ![[QMApi instance] isFriend:self.opponentUser] || [[QMApi instance] userIDIsInPendingList:self.opponentUser.ID] ) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
        return NO;
    }
    
    BOOL callsAllowed = [[[self.inputToolbar contentView] textView] isEditable];
    if( !callsAllowed ) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
        return NO;
    }
    
    return YES;
#endif
}

- (void)audioCallAction {
    if (![self callsAllowed]) return;
    
    NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
    [[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeAudio];
}

- (void)videoCallAction {
    if (![self callsAllowed]) return;
    
    [self performSegueWithIdentifier:@"selectusers" sender:nil];
  //  NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
   // [[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeVideo];
}

- (void)groupInfoNavButtonAction {
    
    [self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self.view endEditing:YES];
    if([segue.identifier isEqualToString:@"selectusers"]){
        
        VideoCallUsersSelection *cs = segue.destinationViewController;
        // [cs callWithConferenceType:QBRTCConferenceTypeVideo];
    }
    else if ([segue.identifier isEqualToString:kGroupDetailsSegueIdentifier]) {
        
        self.shouldUpdateDialogAfterReturnFromGroupInfo = YES;
        
        GroupDetailsController *groupDetailVC = segue.destinationViewController;
        groupDetailVC.chatDialog = self.dialog;
    }
    else {
        
        NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        QBUUser *opponent = [[QMApi instance] userWithID:opponentID];
        
        BaseCallsController *callsController = segue.destinationViewController;
        [callsController setOpponent:opponent];
    }
    

}

#pragma mark - Utilities

- (void)sendReadStatusForMessage:(QBChatMessage *)message
{
    if (message.senderID != [QBSession currentSession].currentUser.ID && ![message.readIDs containsObject:@(self.senderID)]) {
        
        if(![[QMApi instance].chatService readMessage:message]){
            NSLog(@"Problems while marking message as read!");
        }
        else {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"badgecount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                [UIApplication sharedApplication].applicationIconBadgeNumber--;
               
            }
        }
    }
}

- (void)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([QBChat instance].isConnected) {
        [[QMApi instance].chatService readMessages:messages forDialogID:dialogID];
        
        
        
    } else {
        self.unreadMessages = messages;
    }
}

- (void)fireStopTypingIfNecessary
{
    [self.typingTimer invalidate];
    self.typingTimer = nil;
    [self.dialog sendUserStoppedTyping];
}

- (BOOL)messageSendingAllowed {
    if (![QMApi instance].isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO];
        return NO;
    }
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        if (![[QMApi instance] isFriend:self.opponentUser]) {
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil) actionSuccess:NO];
            return NO;
        }
        if ([[QMApi instance] userIDIsInPendingList:self.opponentUser.ID]) {
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil) actionSuccess:NO];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark Tool bar Actions

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if (![self.deferredQueueManager shouldSendMessagesInDialogWithID:self.dialog.ID]) {
        return;
    }
    if (self.typingTimer != nil) {
        [self fireStopTypingIfNecessary];
    }
    
    if (![self messageSendingAllowed]) return;
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.markable = YES;
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    message.dateSent = date;
    
    // Sending message.
  
    // change
    
    [[QMApi instance].chatService sendMessage:message toDialog:self.dialog saveToHistory:YES saveToStorage:YES completion:^(NSError * _Nullable error) {
        
        if(error == nil){
            
            [QMSoundManager playMessageSentSound];
        }
    }];
     NSString *soundname_;
   // NSMutableArray *data = self.opponentUser.tags;
    //NSString *soundname = [data objectAtIndex:0];
   
    NSString *message1 = [NSString stringWithFormat:NSLocalizedString(@"QM_text_message_notification", nil) , [QMApi instance].currentUser.fullName, message.text];
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    if(self.dialog.type == QBChatDialogTypePrivate){
        event.usersIDs = [NSString stringWithFormat:@"%zd", self.opponentUser.ID];
        NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"soundname"];
       
        if(soundname == nil){
            soundname_ = @"Note.mp3";
            
        }
        else {
            soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
        }
    }
    else if(self.dialog.type == QBChatDialogTypeGroup){
        
        NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
        for (NSNumber *identifier in self.dialog.occupantIDs) {
            if (![identifier isEqualToNumber:@(QMApi.instance.currentUser.ID)]) {
                [occupantsWithoutCurrentUser addObject:identifier];
            }
        }
        NSString  *occupantIDs = [occupantsWithoutCurrentUser componentsJoinedByString:@","];
        
        NSLog(@" group readers count %@",self.dialog.occupantIDs);
        event.usersIDs = occupantIDs;
        
        NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"groupsoundname"];
        
        if(soundname == nil){
            soundname_ = @"Note.mp3";
            
        }
        else {
            soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
        }
    }
    event.type = QBMEventTypeOneShot;

    
    
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"badgecount"];
    if(count == 0){
     
        count = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"badgecount"];
    }
    else if(count > 0){
        count = count + 1 ;
        [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"badgecount"];
    }
    NSString *countvalue = [NSString stringWithFormat:@"%ld",(long)count];
    // custom params
    NSDictionary  *dictPush = @{@"message" : message1,
                                @"ios_badge": countvalue,
                                @"ios_sound": soundname_
                                };
    //
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    //
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
        NSLog(@"success");
        //
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error %@",response.error);
        //
    }];
    
    [self finishSendingMessageAnimated:YES];
}
- (void)_sendLocationMessage:(CLLocationCoordinate2D)locationCoordinate {
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = @"Location";
    message.senderID = self.senderID;
    message.markable = YES;
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    message.dateSent = [NSDate date];
    
    message.locationCoordinate = locationCoordinate;
    
  
    NSString *soundname_;
 
    NSString *message1 = [NSString stringWithFormat:NSLocalizedString(@"QM_text_message_notification", nil) , [QMApi instance].currentUser.fullName, message.text];
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    if(self.dialog.type == QBChatDialogTypePrivate){
        event.usersIDs = [NSString stringWithFormat:@"%zd", self.opponentUser.ID];
        
        NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"soundname"];
        
        if(soundname == nil){
            soundname_ = @"Note.mp3";
            
        }
        else {
            soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
        }
    }
    else if(self.dialog.type == QBChatDialogTypeGroup){
        
        NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
        for (NSNumber *identifier in self.dialog.occupantIDs) {
            if (![identifier isEqualToNumber:@(QMApi.instance.currentUser.ID)]) {
                [occupantsWithoutCurrentUser addObject:identifier];
            }
        }
        NSString  *occupantIDs = [occupantsWithoutCurrentUser componentsJoinedByString:@","];
        event.usersIDs = occupantIDs;
        
        NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"groupsoundname"];
        
        if(soundname == nil){
            soundname_ = @"Note.mp3";
            
        }
        else {
            soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
        }
    }
    event.type = QBMEventTypeOneShot;
    //
    
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"badgecount"];
    if(count == 0){
        
        count = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"badgecount"];
    }
    else if(count > 0){
        count = count +1 ;
        [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"badgecount"];
    }
    NSString *countvalue = [NSString stringWithFormat:@"%ld",(long)count];
    // custom params
    NSDictionary  *dictPush = @{@"message" : message1,
                                @"ios_badge": countvalue,
                                @"ios_sound": soundname_
                                };
    //
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    //
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
        NSLog(@"success");
        //
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error %@",response.error);
        //
    }];
    [[QMApi instance].chatService sendMessage:message toDialog:self.dialog saveToHistory:YES saveToStorage:YES completion:^(NSError * _Nullable error) {
        
        if(error == nil){
            
            [QMSoundManager playMessageSentSound];
        }
    }];
    
}



- (void)didPressAccessoryButton:(UIButton *)sender {
    if (![self messageSendingAllowed]) return;
    
    //   [super didPressAccessoryButton:sender];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [ImagePicker takePhotoInViewController:self resultHandler:self allowsEditing:NO];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                            [ImagePicker takePhotoOrVideoInViewController:self maxDuration:100 quality:UIImagePickerControllerQualityTypeHigh resultHandler:self];
                                                        //  [ImagePicker choosePhotoInViewController:self resultHandler:self allowsEditing:NO];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_RECORD_AUDIO", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          IQAudioRecorderController *controller = [[IQAudioRecorderController alloc] init];
                                                          controller.delegate = self;
                                                          [self presentViewController:controller animated:YES completion:nil];
                                                          
                                                          
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOCATION", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          LocationViewController *locationVC = [[LocationViewController alloc] initWithState:QMLocationVCStateSend];
                                                          
                                                          [locationVC setSendButtonPressed:^(CLLocationCoordinate2D centerCoordinate) {
                                                              
                                                              [self _sendLocationMessage:centerCoordinate];
                                                          }];
                                                          
                                                          UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:locationVC];
                                                          
                                                          [self presentViewController:navController animated:YES completion:nil];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
- (void)imagePicker:(ImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        
        UIImage *newImage = photo;
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            newImage = [newImage fixOrientation];
        }
        
        [self didPickAttachmentImage:newImage];
    });
  
    
}
-(void)imagePicker:(ImagePicker *)imagePicker didFinishPickingVideo:(NSURL *)videoUrl{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSData *videodata = [NSData dataWithContentsOfURL:videoUrl];
        
        
        [self didPickAttachmentVideo:videodata];
    });
}
#pragma mark - IQAudioRecorderControllerDelegate

- (void)audioRecorderController:(IQAudioRecorderController *)controller didFinishWithAudioAtPath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString:path];
    NSLog(@"audio url %@",url);
    NSData *audiodata = [NSData dataWithContentsOfFile:path];
    NSLog(@"audio data %@",audiodata);
    
    [self didPickAttachmentAudio:audiodata];
    
}

- (void)audioRecorderControllerDidCancel:(IQAudioRecorderController *)controller
{
    
}

#pragma mark - Cell classes

- (Class)viewClassForItem:(QBChatMessage *)item
{
    
    if ([item isLocationMessage]) {
        
        return item.senderID == self.senderID ? [QMChatLocationOutgoingCell class] : [QMChatLocationIncomingCell class];
    }
    if (item.isNotificatonMessage) {
        
        if (item.messageType == QMMessageTypeContactRequest && item.senderID != self.senderID && ![[QMApi instance] isFriend:self.opponentUser]) {
            QBChatMessage *latestMessage = [[QMApi instance].chatService.messagesMemoryStorage lastMessageFromDialogID:self.dialog.ID];
            
            if ([item isEqual:latestMessage]) {
                return [QMChatContactRequestCell class];
            }
            
            return [QMChatNotificationCell class];
        }
        else {
            return [QMChatNotificationCell class];
        }
        
    } else {
        if (item.senderID != self.senderID) {
            if ((item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                return [QMChatAttachmentIncomingCell class];
            } else {
                return [QMChatIncomingCell class];
            }
        } else {
            if ((item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                return [QMChatAttachmentOutgoingCell class];
            } else {
                return [QMChatOutgoingCell class];
            }
        }
    }
    return nil;
}

#pragma mark - Strings builder

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    if (messageItem.isNotificatonMessage) {
        //
        //.. Wazowski Edition
        NSString *dateString = messageItem.dateSent ? [[self timeStampWithDate:messageItem.dateSent] stringByAppendingString:@"\n"] : @"";
        //NSString *dateString = messageItem.dateSent ? [[self timeStampWithDate:messageItem.dateSent] stringByAppendingString:@" "] : @"";
        //..
        NSString *notificationMessageString = [[NSString alloc] init];
        notificationMessageString = messageItem.messageType == QMMessageTypeUpdateGroupDialog ? messageItem.text : [ChatUtils messageTextForNotification:messageItem];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[dateString stringByAppendingString:notificationMessageString]];
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:12.0f]
                        range:NSMakeRange(0, dateString.length-1)];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor blackColor]
                        range:NSMakeRange(0, dateString.length-1)];
        
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont boldSystemFontOfSize:14.0f]
                        range:NSMakeRange(dateString.length, notificationMessageString.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor colorWithRed:113.0f/255.0f green:113.0f/255.0f blue:113.0f/255.0f alpha:1.0f]
                        range:NSMakeRange(dateString.length, notificationMessageString.length)];
        
        return attrStr;
    }
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f] ;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageItem.text ? messageItem.text : @"" attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    if ([messageItem senderID] == self.senderID || self.dialog.type == QBChatDialogTypePrivate) {
        return nil;
    }
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    
    NSString *topLabelText = self.opponentUser.fullName != nil ? self.opponentUser.fullName : self.opponentUser.login;
    
    if (self.dialog.type != QBChatDialogTypePrivate) {
        QBUUser* user = [[QMApi instance] userWithID:messageItem.senderID];
        if (user != nil) {
            topLabelText = user.fullName != nil ? user.fullName : user.login;
        } else {
            topLabelText = [NSString stringWithFormat:@"%lu",(unsigned long)messageItem.senderID];
        }
    }
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122.0f / 255.0f blue:1.0f alpha:1.000], NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1 alpha:0.8f] : [UIColor colorWithWhite:0.000 alpha:0.4f];
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    NSString* text = messageItem.dateSent ? [self timeStampWithDate:messageItem.dateSent] : @"";
    if ([messageItem senderID] == self.senderID) {
        //.. Wazowski Edition
        //..
        //text = [NSString stringWithFormat:@"%@\n%@", text, [self.stringBuilder statusFromMessage:messageItem]];
        text = [NSString stringWithFormat:@"%@ %@", text, [self.stringBuilder statusFromMessage:messageItem]];
        //..
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text
                                                                                attributes:attributes];
    
    return attrStr;
}

#pragma mark - Collection View Datasource

-(void)collectionView:(QMChatCollectionView *)collectionView didLongTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
 }
- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    CGSize size = CGSizeZero;
    
    NSString *messagetype;
    QBChatAttachment *attachment_ = [item.attachments firstObject];
    if(attachment_ != nil){
        messagetype = attachment_.type;
    }
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatLocationIncomingCell class]) {
        if([messagetype isEqualToString:@"video"] || [messagetype isEqualToString:@"location"] || [messagetype isEqualToString:@"image"]){
        size = CGSizeMake(MIN(200, maxWidth), 200);
        }
        else if([messagetype isEqualToString:@"audio"]){
            size = CGSizeMake(MIN(200, maxWidth), 20);
        }
    } else if(viewClass == [QMChatAttachmentOutgoingCell class] || viewClass == [QMChatLocationOutgoingCell class]) {
        
        if([messagetype isEqualToString:@"video"] || [messagetype isEqualToString:@"location"] || [messagetype isEqualToString:@"image"]){
            
        NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
        
        CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                  withConstraints:CGSizeMake(MIN(200, maxWidth), CGFLOAT_MAX)
                                                           limitedToNumberOfLines:0];
        size = CGSizeMake(MIN(200, maxWidth), 200 + ceilf(bottomLabelSize.height));
        }
        else if([messagetype isEqualToString:@"audio"]){
            NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
            
            CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                      withConstraints:CGSizeMake(MIN(200, maxWidth), CGFLOAT_MAX)
                                                               limitedToNumberOfLines:0];
            size = CGSizeMake(MIN(200, maxWidth), 20 + ceilf(bottomLabelSize.height));
        }
    } else {
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    return size;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
    
    NSAttributedString *attributedString = [NSAttributedString new];
    if ([item senderID] == self.senderID) {
        attributedString = [self bottomLabelAttributedStringForItem:item];
    } else {
        if (self.dialog.type != QBChatDialogTypePrivate) {
            CGSize topLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:[self topLabelAttributedStringForItem:item]
                                                                   withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                            limitedToNumberOfLines:0];
            CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                                      withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                               limitedToNumberOfLines:0];
            
            return topLabelSize.width > bottomLabelSize.width ? topLabelSize.width : bottomLabelSize.width;
        }
        else {
            attributedString = [self bottomLabelAttributedStringForItem:item];
        }
    }
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                            limitedToNumberOfLines:0];
    
    return size.width;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)__unused cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.shouldHoldScrollOnCollectionView = YES;
    __weak typeof(self)weakSelf = self;
    // Getting earlier messages for chat dialog identifier.
    [[[QMApi instance].chatService loadEarlierMessagesWithChatDialogID:self.dialog.ID] continueWithBlock:^id(BFTask<NSArray<QBChatMessage *> *> *task) {
       
        if (task.result.count > 0) {
            self.shouldHoldScrollOnCollectionView = NO;
            [self.chatDataSource addMessages:task.result];
        }
        
        return nil;
    }];
    // marking message as read if needed
    QBChatMessage *itemMessage = [self.chatDataSource messageForIndexPath:indexPath];
    [self readMessage:itemMessage];
    
    // getting users if needed
    QBUUser *sender = [[QMApi instance].usersService.usersMemoryStorage userWithID:itemMessage.senderID];
    if (sender == nil) {
        
        
        [[[QMApi instance].usersService getUserWithID:itemMessage.senderID] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
            
            
            [self.chatDataSource updateMessage:itemMessage];
            
            return nil;
        }];
    }
}
- (void)readMessage:(QBChatMessage *)message {
    
    if (message.senderID != self.senderID && ![message.readIDs containsObject:@(self.senderID)]) {
        
        [[[QMApi instance].chatService readMessage:message] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            if (task.isFaulted) {
                
                ILog(@"Problems while marking message as read! Error: %@", task.error);
            }
            else if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"badgecount"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [UIApplication sharedApplication].applicationIconBadgeNumber--;
                
            }
            
            return nil;
        }];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
   // selectedindex = indexPath;\
    
    
    if (action == @selector(delete:)) {
       
        return YES;
    }
    if(action == @selector(copy:)){
        return YES;
    }
    Class viewClass = [self viewClassForItem:[self.chatDataSource messageForIndexPath:indexPath]];
   if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class] || viewClass == [QMChatLocationOutgoingCell class] || viewClass == [QMChatLocationOutgoingCell class]) return NO;
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    QBChatMessage* message = [self.chatDataSource messageForIndexPath:indexPath];
    
    if (action == @selector(delete:)) {
        
        [self.chatDataSource deleteMessage:message];
        [self.deferredQueueManager removeMessage:message];
        [[QMApi instance].chatService.messagesMemoryStorage deleteMessage:message];
        [[QMChatCache instance] deleteMessage:message completion:nil];
        
    }
    if(action == @selector(copy:)) {
        
    Class viewClass = [self viewClassForItem:[self.chatDataSource messageForIndexPath:indexPath]];
    
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class]) return;
    
    [UIPasteboard generalPasteboard].string = message.text;
    }
}

#pragma mark - Utility

- (NSString *)timeStampWithDate:(NSDate *)date {
    
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yy HH:mm";
    });
    
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    return timeStamp;
}

#pragma mark - ChatCollectionViewDelegate

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        layoutModel.topLabelHeight = 0.0;
    }
    
    
    QBChatMessage* item = [self.chatDataSource messageForIndexPath:indexPath];
    Class class = [self viewClassForItem:item];
    
    if (class == [QMChatOutgoingCell class] ||
        class == [QMChatAttachmentOutgoingCell class] || class == [QMChatLocationOutgoingCell class]) {
        NSAttributedString* bottomAttributedString = [self bottomLabelAttributedStringForItem:item];
        CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:bottomAttributedString
                                                       withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                limitedToNumberOfLines:0];
        layoutModel.avatarSize = (CGSize){0.0, 0.0};
        layoutModel.bottomLabelHeight = ceilf(size.height);
    } else if (class == [QMChatAttachmentIncomingCell class] ||
               class == [QMChatIncomingCell class] || class == [QMChatLocationIncomingCell class]) {
        if (self.dialog.type != QBChatDialogTypePrivate) {
            layoutModel.topLabelHeight = 20.0f;
        }
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
        layoutModel.avatarSize = (CGSize){50.0, 50.0};
    } else if (class == [QMChatNotificationCell class]) {
        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
    }
    
    layoutModel.spaceBetweenTextViewAndBottomLabel = 5.0f;
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    QMChatCell *cell_ = (QMChatCell *)cell;
    [cell_ setDelegate:self];
    
    [(QMChatCell *)cell containerView].highlightColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    NSString *messagetype;
    QBChatAttachment *attachment_ = [message.attachments firstObject];
    
    if(attachment_!=nil){
        messagetype = attachment_.type;
    }
    QMMessageStatus status = [self.deferredQueueManager statusForMessage:message];
    switch (status) {
            
        case QMMessageStatusSent:
            cell_.containerView.bgColor = [UIColor colorWithRed:23.0f/255.0f green:208.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
            break;
            
        case QMMessageStatusSending:
            cell_.containerView.bgColor = [UIColor colorWithRed:0.761f green:0.772f blue:0.746f alpha:1.0f];
            break;
            
        case QMMessageStatusNotSent:
            cell_.containerView.bgColor = [UIColor colorWithRed:1.0f green:0.19f blue:0.108f alpha:1.0f];
            break;
    }
    
    //.. Wazowski Edition
    if ([cell isKindOfClass:[QMChatOutgoingCell class]] || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]] || [cell isKindOfClass:[QMChatLocationOutgoingCell class]]) {
       
        [(QMChatOutgoingCell *)cell containerView].bgColor = [UIColor colorWithRed:0 green:33.0/255.0 blue:87.0/255.0 alpha:1.0];
        
    } else if ([cell isKindOfClass:[QMChatIncomingCell class]] || [cell isKindOfClass:[QMChatAttachmentIncomingCell class]] || [cell isKindOfClass:[QMChatLocationIncomingCell class]]) {
        
        [(QMChatIncomingCell *)cell containerView].bgColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
               
        /**
         *  Setting opponent avatar
         */
        
        
        QBChatMessage* message_ = [self.chatDataSource messageForIndexPath:indexPath];
        QBUUser *sender = [[QMApi instance] userWithID:message_.senderID];
        NSURL *userImageUrl = [UsersUtils userAvatarURL:sender];
        UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
        
        [[(QMChatCell *)cell avatarView] setImageWithURL:userImageUrl
                                             placeholder:placeholder
                                                 options:SDWebImageHighPriority
                                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                          completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
        [(QMChatCell *)cell avatarView].imageViewType = QMImageViewTypeCircle;
        
    } else if ([cell isKindOfClass:[QMChatNotificationCell class]] || [cell isKindOfClass:[QMChatContactRequestCell class]]) {
        [(QMChatCell *)cell containerView].bgColor = self.collectionView.backgroundColor;
    }
    if([cell conformsToProtocol:@protocol(QMChatAttachmentCell)] && [messagetype isEqualToString:@"video"]) {
        
        QBChatMessage* message_ = [self.chatDataSource messageForIndexPath:indexPath];
        if (message_.attachments != nil) {
            QBChatAttachment* attachment = message_.attachments.firstObject;
            
            BOOL shouldLoadFile = YES;
            if ([self.attachmentCells objectForKey:attachment.ID] != nil) {
                shouldLoadFile = NO;
            }
            
            NSMutableArray* keysToRemove = [NSMutableArray array];
            
            NSEnumerator* enumerator = [self.attachmentCells keyEnumerator];
            NSString* existingAttachmentID = nil;
            while (existingAttachmentID = [enumerator nextObject]) {
                UICollectionViewCell* cachedCell = [self.attachmentCells objectForKey:existingAttachmentID];
                if ([cachedCell isEqual:cell]) {
                    [keysToRemove addObject:existingAttachmentID];
                }
            }
            
            for (NSString* key in keysToRemove) {
                [self.attachmentCells removeObjectForKey:key];
            }
            
            [self.attachmentCells setObject:cell forKey:attachment.ID];
            [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentID:attachment.ID];
            
            if (!shouldLoadFile) return;
            
            __weak typeof(self)weakSelf = self;
            // Getting image from chat attachment service.
            
            [[QMApi instance].chatService.chatAttachmentService getDataForAttachmentMessage:message_ completion:^(NSError * _Nullable error, NSData * _Nullable data) {
                
                __typeof(self) strongSelf = weakSelf;
                
                NSLog(@"attachment url: %@",attachment.url);
               
                NSURL *url ;
                NSString *docPath = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
                NSString *pdfFilePath = [docPath stringByAppendingPathComponent:@"video.mp4"];
                BOOL success =  [data writeToFile:pdfFilePath atomically:YES];
                if (success) {
                    url = [[NSURL alloc] initFileURLWithPath:pdfFilePath];
                    NSLog(@"url from data : %@",url);
                }
                UIImage * image = [self generateThumbImage:url];
                if ([(UICollectionViewCell<QMChatAttachmentCell> *)cell attachmentID] != attachment.ID) return;
                
                [strongSelf.attachmentCells removeObjectForKey:attachment.ID];
                
                if (error != nil) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                } else {
                    if (image != nil) {
                        [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentImage:image];
                        
                        [cell updateConstraints];
                    }
                }
            }];

            
            
        }
        
    }
  else if([cell conformsToProtocol:@protocol(QMChatAttachmentCell)] && [messagetype isEqualToString:@"audio"]) {
      
      NSLog(@"audio file");
        QBChatMessage* message_ = [self.chatDataSource messageForIndexPath:indexPath];
        if (message_.attachments != nil) {
            QBChatAttachment* attachment = message_.attachments.firstObject;
            
            BOOL shouldLoadFile = YES;
            if ([self.attachmentCells objectForKey:attachment.ID] != nil) {
                shouldLoadFile = NO;
            }
            
            NSMutableArray* keysToRemove = [NSMutableArray array];
            
            NSEnumerator* enumerator = [self.attachmentCells keyEnumerator];
            NSString* existingAttachmentID = nil;
            while (existingAttachmentID = [enumerator nextObject]) {
                UICollectionViewCell* cachedCell = [self.attachmentCells objectForKey:existingAttachmentID];
                if ([cachedCell isEqual:cell]) {
                    [keysToRemove addObject:existingAttachmentID];
                }
            }
            
            for (NSString* key in keysToRemove) {
                [self.attachmentCells removeObjectForKey:key];
            }
            
            [self.attachmentCells setObject:cell forKey:attachment.ID];
            [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentID:attachment.ID];
            
            if (!shouldLoadFile) return;
            
            __weak typeof(self)weakSelf = self;
            // Getting image from chat attachment service.
            
            [[QMApi instance].chatService.chatAttachmentService getDataForAttachmentMessage:message_ completion:^(NSError * _Nullable error, NSData * _Nullable data) {
                
                __typeof(self) strongSelf = weakSelf;
                
                NSURL *url ;
                NSString *docPath = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
                NSString *pdfFilePath = [docPath stringByAppendingPathComponent:@"audio.m4a"];
                BOOL success =  [data writeToFile:pdfFilePath atomically:YES];
                if (success) {
                    url = [[NSURL alloc] initFileURLWithPath:pdfFilePath];
                    NSLog(@"url from audio data : %@",url);
                }
                //UIImage * image = [self generateThumbImage:url];
                UIImage *fgimage = [UIImage imageNamed:@"video_play_icon.png"];
                UIImage *bgimage = [UIImage imageNamed:@"waves.jpg"];
                UIImage *image = [self drawImage:fgimage inImage:bgimage atPoint:CGPointMake(bgimage.size.width/2.5, bgimage.size.height/2.3)];
                if ([(UICollectionViewCell<QMChatAttachmentCell> *)cell attachmentID] != attachment.ID) return;
                
                [strongSelf.attachmentCells removeObjectForKey:attachment.ID];
                
                if (error != nil) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                } else {
                    if (image != nil) {
                        [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentImage:image];
                        
                        [cell updateConstraints];
                    }
                }
            }];
            
            
            
        }
        
    }
    else if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)] && [messagetype isEqualToString:@"image"]) {
        QBChatMessage* message_ = [self.chatDataSource messageForIndexPath:indexPath];
        if (message.attachments != nil) {
            QBChatAttachment* attachment = message_.attachments.firstObject;
            
            BOOL shouldLoadFile = YES;
            if ([self.attachmentCells objectForKey:attachment.ID] != nil) {
                shouldLoadFile = NO;
            }
            
            NSMutableArray* keysToRemove = [NSMutableArray array];
            
            NSEnumerator* enumerator = [self.attachmentCells keyEnumerator];
            NSString* existingAttachmentID = nil;
            while (existingAttachmentID = [enumerator nextObject]) {
                UICollectionViewCell* cachedCell = [self.attachmentCells objectForKey:existingAttachmentID];
                if ([cachedCell isEqual:cell]) {
                    [keysToRemove addObject:existingAttachmentID];
                }
            }
            
            for (NSString* key in keysToRemove) {
                [self.attachmentCells removeObjectForKey:key];
            }
            
            [self.attachmentCells setObject:cell forKey:attachment.ID];
            [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentID:attachment.ID];
            
            if (!shouldLoadFile) return;
            
            __weak typeof(self)weakSelf = self;
            // Getting image from chat attachment service.
            [[QMApi instance].chatService.chatAttachmentService imageForAttachmentMessage:message_ completion:^(NSError * _Nullable error, UIImage * _Nullable image) {
                
                __typeof(self) strongSelf = weakSelf;
                
                if ([(UICollectionViewCell<QMChatAttachmentCell> *)cell attachmentID] != attachment.ID) return;
                
                [strongSelf.attachmentCells removeObjectForKey:attachment.ID];
                
                if (error != nil) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                } else {
                    if (image != nil) {
                        [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentImage:image];
                        [cell updateConstraints];
                    }
                }
            }];
        }
        
    }
    else if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        QBChatMessage *message_ = [self.chatDataSource messageForIndexPath:indexPath];
        [[(id<QMChatLocationCell>)cell imageView]
         setSnapshotWithLocationCoordinate:message_.locationCoordinate];
    }
}
-(UIImage *)generateThumbImage : (NSURL *)url
{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIImage *fgimage = [UIImage imageNamed:@"video_play.png"];
    UIImage *thumbnailwithicon = [self drawImage:fgimage inImage:thumbnail atPoint:CGPointMake(thumbnail.size.width/3.8,thumbnail.size.height/2.6)];
    return thumbnailwithicon;
}
-(UIImage*) drawImage:(UIImage*) fgImage
              inImage:(UIImage*) bgImage
              atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (void)handleNotSentMessage:(QBChatMessage *)notSentMessage {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"QM_STR_MESSAGE_DIDNT_SEND", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TRY_AGAIN", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self.deferredQueueManager perfromDefferedActionForMessage:notSentMessage];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self.chatDataSource deleteMessage:notSentMessage];
                                                          [self.deferredQueueManager removeMessage:notSentMessage];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - QMChatServiceDelegate
- (void)chatService:(QMChatService *)__unused chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID]) {
        
        [self.chatDataSource addMessages:messages];
    }
}
- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    if ([self.dialog.ID isEqualToString:dialogID]) {
        
        if (self.dialog.type == QBChatDialogTypePrivate
            && (message.messageType == QMMessageTypeContactRequest)) {
            // check whether contact request message was sent previously
            // in order to reload it and remove buttons for accept and deny
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            QBChatMessage *lastMessage = [self.chatDataSource messageForIndexPath:indexPath];
            if (lastMessage.messageType == QMMessageTypeContactRequest) {
                
                [self.chatDataSource updateMessage:lastMessage];
            }
        }
        
        // Inserting or updating message received from XMPP or sent by self
        if ([self.chatDataSource messageExists:message]) {
            
            [self.chatDataSource updateMessage:message];
        }
        else {
            
            [self.chatDataSource addMessage:message];
        }
        // Retrieving messages from memory strorage.
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
      //  [self refreshCollectionView];
        
        [self sendReadStatusForMessage:message];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
        [self readMessages:messages forDialogID:dialogID];
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        
        if (self.shouldHoldScrollOnCollectionView) {
            CGFloat bottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y;
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            
            [self.collectionView reloadData];
            [self.collectionView performBatchUpdates:nil completion:nil];
            
            self.collectionView.contentOffset = (CGPoint){0, self.collectionView.contentSize.height - bottomOffset};
            
            [CATransaction commit];
        } else {
            [self refreshCollectionView];
        }
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog{
    if( [self.dialog.ID isEqualToString:chatDialog.ID] ) {
        self.dialog = chatDialog;
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
        
        [self.chatDataSource updateMessage:message];
        
    }
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
}

#pragma mark - QMChatConnectionDelegate

- (void)refreshAndReadMessages;
{
    if (self.dialog.type != QBChatDialogTypePrivate) {
        [self refreshMessagesShowingProgress:NO];
    }
    
    for (QBChatMessage* message in self.unreadMessages) {
        [self sendReadStatusForMessage:message];
    }
    
    self.unreadMessages = nil;
   }

- (void)chatServiceChatDidConnect:(QMChatService *)chatService {
    [self refreshAndReadMessages];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService {
    [self refreshAndReadMessages];
}

#pragma mark - QMChatAttachmentServiceDelegate

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message
{
    if (message.dialogID == self.dialog.ID) {
        // Retrieving messages for dialog from memory storage.
        self.items = [[[QMApi instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
        NSLog(@"message items %@",self.items);
        [self.chatDataSource updateMessage:message];
      //  [self refreshCollectionView];
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QBChatAttachment *)attachment
{
    UICollectionViewCell<QMChatAttachmentCell>* cell = [self.attachmentCells objectForKey:attachment.ID];
    if (cell != nil) {
        [cell updateLoadingProgress:progress];
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.typingTimer) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    } else {
        [self.dialog sendUserIsTyping];
    }
    
    self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(fireStopTypingIfNecessary) userInfo:nil repeats:NO];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [super textViewDidEndEditing:textView];
    
    [self fireStopTypingIfNecessary];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)didPickAttachmentVideo:(NSData *)videodata {
    
   // _isSendingVideoAttachment = YES;
    [SVProgressHUD showWithStatus:@"Uploading attachment" maskType:SVProgressHUDMaskTypeClear];
    
    __weak typeof(self)weakSelf = self;
    
    __typeof(self) strongSelf = weakSelf;

    
    QBChatMessage* message = [QBChatMessage new];
    message.senderID = strongSelf.senderID;
    message.dialogID = strongSelf.dialog.ID;
    message.dateSent = [NSDate date];
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     
        
        // Sending attachment to dialog.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatDataSource addMessage:message];
            
            [[[QMApi instance].chatService sendAttachmentMessage:message
                                                        toDialog:self.dialog
                                             withAttachmentVideo:videodata] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
               
                [SVProgressHUD dismiss];
                
                NSString *soundname_;
              
                NSString *message1 = [NSString stringWithFormat:NSLocalizedString(@"QM_text_message_notification", nil) , [QMApi instance].currentUser.fullName, message.text];
                QBMEvent *event = [QBMEvent event];
                event.notificationType = QBMNotificationTypePush;
                if(self.dialog.type == QBChatDialogTypePrivate){
                    event.usersIDs = [NSString stringWithFormat:@"%zd", self.opponentUser.ID];
                    NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"soundname"];
                    
                    if(soundname == nil){
                        soundname_ = @"Note.mp3";
                        
                    }
                    else {
                        soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
                    }
                }
                else if(self.dialog.type == QBChatDialogTypeGroup){
                    
                    NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
                    for (NSNumber *identifier in self.dialog.occupantIDs) {
                        if (![identifier isEqualToNumber:@(QMApi.instance.currentUser.ID)]) {
                            [occupantsWithoutCurrentUser addObject:identifier];
                        }
                    }
                    NSString  *occupantIDs = [occupantsWithoutCurrentUser componentsJoinedByString:@","];

                    event.usersIDs = occupantIDs;
                    NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"groupsoundname"];
                    
                    if(soundname == nil){
                        soundname_ = @"Note.mp3";
                        
                    }
                    else {
                        soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
                    }
                }
                event.type = QBMEventTypeOneShot;
                //
                NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"badgecount"];
                if(count == 0){
                    
                    count = 1;
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"badgecount"];
                }
                else if(count > 0){
                    count = count +1 ;
                    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"badgecount"];
                }
                NSString *countvalue = [NSString stringWithFormat:@"%ld",(long)count];
                // custom params
                NSDictionary  *dictPush = @{@"message" : message1,
                                            @"ios_badge": countvalue,
                                            @"ios_sound": soundname_
                                            };
                //
                NSError *error = nil;
                NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
                NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
                //
                event.message = jsonString;
                
                [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
                    NSLog(@"success");
                    //
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"error %@",response.error);
                    //
                }];
                [self.attachmentCells removeObjectForKey:message.ID];
                if (task.isFaulted) {
                    
                    // [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:task.error.localizedRecoverySuggestion duration:kQMDefaultNotificationDismissTime];
                    
                    // perform local attachment deleting
                    [[QMApi instance].chatService deleteMessageLocally:message];
                    [self.chatDataSource deleteMessage:message];
                }
                return nil;
            }];
        });
    });
    
}
-(void)didPickAttachmentAudio:(NSData *)audiodata {
    
    
    [SVProgressHUD showWithStatus:@"Uploading attachment" maskType:SVProgressHUDMaskTypeClear];
    
    __weak typeof(self)weakSelf = self;
    
    __typeof(self) strongSelf = weakSelf;
    
    
    QBChatMessage* message = [QBChatMessage new];
    message.senderID = strongSelf.senderID;
    message.dialogID = strongSelf.dialog.ID;
    message.dateSent = [NSDate date];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        // Sending attachment to dialog.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatDataSource addMessage:message];
            
            [[[QMApi instance].chatService sendAttachmentMessage:message
                                                        toDialog:self.dialog
                                             withAttachmentAudio:audiodata] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
                
                [SVProgressHUD dismiss];
                NSString *soundname_;
               
                NSString *message1 = [NSString stringWithFormat:NSLocalizedString(@"QM_text_message_notification", nil) , [QMApi instance].currentUser.fullName, message.text];
                QBMEvent *event = [QBMEvent event];
                event.notificationType = QBMNotificationTypePush;
                if(self.dialog.type == QBChatDialogTypePrivate){
                    event.usersIDs = [NSString stringWithFormat:@"%zd", self.opponentUser.ID];
                    NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"soundname"];
                    
                    if(soundname == nil){
                        soundname_ = @"Note.mp3";
                        
                    }
                    else {
                        soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
                    }
                }
                else if(self.dialog.type == QBChatDialogTypeGroup){
                    
                    NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
                    for (NSNumber *identifier in self.dialog.occupantIDs) {
                        if (![identifier isEqualToNumber:@(QMApi.instance.currentUser.ID)]) {
                            [occupantsWithoutCurrentUser addObject:identifier];
                        }
                    }
                    NSString  *occupantIDs = [occupantsWithoutCurrentUser componentsJoinedByString:@","];
                    NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"groupsoundname"];
                    
                    if(soundname == nil){
                        soundname_ = @"Note.mp3";
                        
                    }
                    else {
                        soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
                    }
                    event.usersIDs = occupantIDs;
                }
                event.type = QBMEventTypeOneShot;
                //
                NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"badgecount"];
                if(count == 0){
                    
                    count = 1;
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"badgecount"];
                }
                else if(count > 0){
                    count = count +1 ;
                    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"badgecount"];
                }
                NSString *countvalue = [NSString stringWithFormat:@"%ld",(long)count];
                // custom params
                NSDictionary  *dictPush = @{@"message" : message1,
                                            @"ios_badge": countvalue,
                                            @"ios_sound": soundname_
                                            };
                //
                NSError *error = nil;
                NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
                NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
                //
                event.message = jsonString;
                
                [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
                    NSLog(@"success");
                    //
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"error %@",response.error);
                    //
                }];
                [self.attachmentCells removeObjectForKey:message.ID];
                if (task.isFaulted) {
                    
                    // [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:task.error.localizedRecoverySuggestion duration:kQMDefaultNotificationDismissTime];
                    
                    // perform local attachment deleting
                    [[QMApi instance].chatService deleteMessageLocally:message];
                    [self.chatDataSource deleteMessage:message];
                }
                return nil;
            }];
        });
    });
}
- (void)didPickAttachmentImage:(UIImage *)image
{
   // self.isSendingAttachment = YES;
    [SVProgressHUD showWithStatus:@"Uploading attachment" maskType:SVProgressHUDMaskTypeClear];
    
    __weak typeof(self)weakSelf = self;

      __typeof(self) strongSelf = weakSelf;
    QBChatMessage* message = [QBChatMessage new];
    message.senderID = strongSelf.senderID;
    message.dialogID = strongSelf.dialog.ID;
    message.dateSent = [NSDate date];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        
        UIImage *resizedImage = [self resizedImageFromImage:image];
        
        // Sending attachment to dialog.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatDataSource addMessage:message];
            
            [[[QMApi instance].chatService sendAttachmentMessage:message
                                                         toDialog:self.dialog
                                              withAttachmentImage:resizedImage] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
               
               
                NSString *soundname_;
              
                NSString *message1 = [NSString stringWithFormat:NSLocalizedString(@"QM_text_message_notification", nil) , [QMApi instance].currentUser.fullName, message.text];
                QBMEvent *event = [QBMEvent event];
                event.notificationType = QBMNotificationTypePush;
                if(self.dialog.type == QBChatDialogTypePrivate){
                    event.usersIDs = [NSString stringWithFormat:@"%zd", self.opponentUser.ID];
                    NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"soundname"];
                    
                    if(soundname == nil){
                        soundname_ = @"Note.mp3";
                        
                    }
                    else {
                        soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
                    }
                }
                else if(self.dialog.type == QBChatDialogTypeGroup){
                    
                    NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
                    for (NSNumber *identifier in self.dialog.occupantIDs) {
                        if (![identifier isEqualToNumber:@(QMApi.instance.currentUser.ID)]) {
                            [occupantsWithoutCurrentUser addObject:identifier];
                        }
                    }
                    NSString  *occupantIDs = [occupantsWithoutCurrentUser componentsJoinedByString:@","];
                    NSString *soundname = [[NSUserDefaults standardUserDefaults]objectForKey:@"groupsoundname"];
                    
                    if(soundname == nil){
                        soundname_ = @"Note.mp3";
                        
                    }
                    else {
                        soundname_ = [NSString stringWithFormat:@"%@.mp3",soundname];
                    }
                    event.usersIDs = occupantIDs;
                }
                event.type = QBMEventTypeOneShot;
                //
                NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"badgecount"];
                if(count == 0){
                    
                    count = 1;
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"badgecount"];
                }
                else if(count > 0){
                    count = count +1 ;
                    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"badgecount"];
                }
                NSString *countvalue = [NSString stringWithFormat:@"%ld",(long)count];
                // custom params
                NSDictionary  *dictPush = @{@"message" : message1,
                                            @"ios_badge": countvalue,
                                            @"ios_sound": soundname_
                                            };
                //
                NSError *error = nil;
                NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
                NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
                //
                event.message = jsonString;
                
                [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
                    NSLog(@"success");
                    //
                } errorBlock:^(QBResponse *response) {
                    NSLog(@"error %@",response.error);
                    //
                }];
                [SVProgressHUD dismiss];
                [self.attachmentCells removeObjectForKey:message.ID];
                if (task.isFaulted) {
                    
                   // [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:task.error.localizedRecoverySuggestion duration:kQMDefaultNotificationDismissTime];
                    
                    // perform local attachment deleting
                    [[QMApi instance].chatService deleteMessageLocally:message];
                    [self.chatDataSource deleteMessage:message];
                }
                return nil;
            }];
        });
    });
}

- (UIImage *)resizedImageFromImage:(UIImage *)image
{
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:(CGRect){0, 0, newSize.width, newSize.height}];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark Contact List Serice Delegate

- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    if (self.dialog.type == QBChatDialogTypePrivate) {
        if (self.opponentUser.ID == userID) {
            self.onlineTitle.statusLabel.text = NSLocalizedString(isOnline ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
        }
    }
}

#pragma mark QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if (accept) {
        [[QMApi instance] confirmAddContactRequest:self.opponentUser completion:^(BOOL success) {
            //
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];

            QBChatMessage *currentMessage = [self.chatDataSource messageForIndexPath:indexPath];
            [self.chatDataSource updateMessage:currentMessage];
           
            [SVProgressHUD dismiss];
            [self refreshMessagesShowingProgress:NO];
            [self refreshCollectionView];
        }];
    }
    else {
        __weak __typeof(self)weakSelf = self;
        [[QMApi instance] rejectAddContactRequest:self.opponentUser completion:^(BOOL success) {
            //
            [[QMApi instance] deleteChatDialog:self.dialog completion:^(BOOL succeed) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [SVProgressHUD dismiss];
            }];
        }];
    }
}

#pragma mark QMChatCellDelegate

- (void)chatCell:(QMChatCell *)cell didTapAtPosition:(CGPoint)position {
}


- (void)chatCell:(QMChatCell *)cell didPerformAction:(SEL)action withSender:(id)sender {
    
//    if(action == @selector(delete:)){
//        NSLog(@"delete");
//        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
//        QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
//        [self.chatDataSource deleteMessage:message];
//        [self.deferredQueueManager removeMessage:message];
//        [[QMApi instance].chatService.messagesMemoryStorage deleteMessage:message];
//        [[QMChatCache instance] deleteMessage:message completion:nil];
//        
//    }
}

- (void)chatCellDidTapContainer:(QMChatCell *)cell {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    QBChatMessage *currentMessage = [self.chatDataSource messageForIndexPath:indexPath];
    
    NSString *messagetype;
    QBChatAttachment *attachment_ = [currentMessage.attachments firstObject];
    if(attachment_ != nil){
        messagetype = attachment_.type;
    }
    QMMessageStatus status = [self.deferredQueueManager statusForMessage:currentMessage];
    if (status == QMMessageStatusNotSent && currentMessage.senderID == self.senderID) {
        
        [self handleNotSentMessage:currentMessage];
        return;
    }
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)] && [messagetype isEqualToString:@"image"]) {
        
        UIImage *attachmentImage = [(QMChatAttachmentIncomingCell *)cell attachmentImageView].image;
        if (attachmentImage != nil) {
            IDMPhoto *photo = [IDMPhoto photoWithImage:attachmentImage];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
            [self presentViewController:browser animated:YES completion:nil];
        }
    }
    if([cell conformsToProtocol:@protocol(QMChatAttachmentCell)] && [messagetype isEqualToString:@"audio"])
    {
        QBChatAttachment *attachement = [currentMessage.attachments firstObject];
        NSString *attachmenturl = attachement.url;
        NSURL *url = [NSURL URLWithString:attachmenturl];
        NSLog(@"current audio attachmnet url %@",attachmenturl);
        if (attachmenturl != nil) {
            
              NSData *_objectData = [NSData dataWithContentsOfURL:url];
            NSURL *url_ ;
            NSString *docPath = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
            NSString *pdfFilePath = [docPath stringByAppendingPathComponent:@"audio.m4a"];
            BOOL success =  [_objectData writeToFile:pdfFilePath atomically:YES];
            if (success) {
                url_ = [[NSURL alloc] initFileURLWithPath:pdfFilePath];
                NSLog(@"url from audio data : %@",url);
            }
          
            NSError *error;
            
          _audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url_  error:&error  ];
            _audioplayer.numberOfLoops = 0;
            _audioplayer.volume = 1.0f;
            [_audioplayer prepareToPlay];
            
            if (_audioplayer == nil)
                NSLog(@"%@", [error description]);
            else
                [_audioplayer play];


        }
    }
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)] && [messagetype isEqualToString:@"video"]) {
        
        QBChatAttachment *attachement = [currentMessage.attachments firstObject];
        NSString *attachmenturl = attachement.url;
        NSURL *url = [NSURL URLWithString:attachmenturl];
        NSLog(@"current attachmnet url %@",attachmenturl);
        if (attachmenturl != nil) {
            
            AVPlayer *player = [AVPlayer playerWithURL:url];
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player = player;
            [playerViewController.player play];//Used to Play On start
            [self presentViewController:playerViewController animated:YES completion:nil];
        }
    }
    else if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        LocationViewController *locationVC = [[LocationViewController alloc] initWithState:QMLocationVCStateView locationCoordinate:[currentMessage locationCoordinate]];
        
        [self.view endEditing:YES]; // hiding keyboard
        [self.navigationController pushViewController:locationVC animated:YES];
    }
}

-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
     NSLog(@"successfully played audio");
}

-(void)audioPlayerDecodeErrorDidOccur:
(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"error playing audio %@",error);
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
}

- (void)chatCellDidTapAvatar:(QMChatCell *)cell {
}

#pragma mark - Emoji

- (void)configureEmojiButton {
    // init
    self.emojiButton = [ChatButtons emojiButton];
    self.emojiButton.tag = kQMEmojiButtonTag;
    [self.emojiButton addTarget:self action:@selector(showEmojiKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    // appearance
    self.emojiButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputToolbar.contentView addSubview:self.emojiButton];
    
    CGFloat emojiButtonSpacing = kQMEmojiButtonSize/3.0f;
    
    [self.inputToolbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emojiButton(==size)]|"
                                                                                          options:0
                                                                                          metrics:@{@"size" : @(kQMEmojiButtonSize)}
                                                                                            views:@{@"emojiButton" : self.emojiButton}]];
    [self.inputToolbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[emojiButton]-spacing-[rightBarButton]"
                                                                                          options:0
                                                                                          metrics:@{@"spacing" : @(emojiButtonSpacing)}
                                                                                            views:@{@"emojiButton"    : self.emojiButton,
                                                                                                    @"rightBarButton" : self.inputToolbar.contentView.rightBarButtonItem}]];
    
    // changing textContainerInset to restrict text entering on emoji button
    self.inputToolbar.contentView.textView.textContainerInset = UIEdgeInsetsMake(self.inputToolbar.contentView.textView.textContainerInset.top,
                                                                                 self.inputToolbar.contentView.textView.textContainerInset.left,
                                                                                 self.inputToolbar.contentView.textView.textContainerInset.bottom,
                                                                                 kQMInputToolbarTextContainerInsetRight);
}

- (void)showEmojiKeyboard {
    
    if ([self.inputToolbar.contentView.textView.inputView isKindOfClass:[AGEmojiKeyboardView class]]) {
        
        UIButton *emojiButton = (UIButton *)[self.inputToolbar.contentView viewWithTag:kQMEmojiButtonTag];
        [emojiButton setImage:[UIImage imageNamed:@"ic_smile"] forState:UIControlStateNormal];
        
        self.inputToolbar.contentView.textView.inputView = nil;
        [self.inputToolbar.contentView.textView reloadInputViews];
        
        [self scrollToBottomAnimated:YES];
        
    } else {
        
        UIButton *emojiButton = (UIButton *)[self.inputToolbar.contentView viewWithTag:kQMEmojiButtonTag];
        [emojiButton setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
        
        AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        emojiKeyboardView.tintColor = [UIColor colorWithRed:0.678 green:0.762 blue:0.752 alpha:1.000];
        
        self.inputToolbar.contentView.textView.inputView = emojiKeyboardView;
        [self.inputToolbar.contentView.textView reloadInputViews];
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    }
}

- (NSArray *)sectionsImages {
    return @[@"😊", @"😊", @"🎍", @"🐶", @"🏠", @"🕘", @"Back"];
}

- (UIImage *)randomImage:(NSInteger)categoryImage {
    
    CGSize size = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[UIFont systemFontOfSize:27] forKey:NSFontAttributeName];
    NSString * sectionImage = self.sectionsImages[categoryImage];
    [sectionImage drawInRect:CGRectMake(0, 0, 30, 30) withAttributes:attributes];
    
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark - Emoji Data source

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_icon"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - Emoji Delegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    
    NSString *textViewString = self.inputToolbar.contentView.textView.text;
    self.inputToolbar.contentView.textView.text = [textViewString stringByAppendingString:emoji];
    [self textViewDidChange:self.inputToolbar.contentView.textView];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
    self.inputToolbar.contentView.textView.inputView = nil;
    [self.inputToolbar.contentView.textView reloadInputViews];
    
    UIButton *emojiButton = (UIButton *)[self.inputToolbar.contentView viewWithTag:kQMEmojiButtonTag];
    [emojiButton setImage:[UIImage imageNamed:@"ic_smile"] forState:UIControlStateNormal];
    
    [self scrollToBottomAnimated:YES];
}

@end
