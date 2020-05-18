 //
//  QMApi.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBApi.h"

#import "SettingsManager.h"
#import "CallManager.h"
#import "ContentService.h"
#import <Reachability.h>
#import <SVProgressHUD.h>
#import "REAlertView+QMSuccess.h"
#import "ViewControllersFactory.h"
#import "MainTabBarController.h"

#import "MessageBarStyleSheetFactory.h"
#import "QMSoundManager.h"

#import <_CDMessage.h>
#import <_CDDialog.h>

const NSTimeInterval kQMPresenceTime = 30;

static NSString *const kQMErrorKey         = @"errors";
static NSString *const kQMErrorEmailKey    = @"email";
static NSString *const kQMErrorFullNameKey = @"full_name";
static NSString *const kQMErrorPasswordKey = @"password";

@interface QMApi()

@property (strong, nonatomic) SettingsManager *settingsManager;
@property (strong, nonatomic) QMContactListService* contactListService;
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;

@property (strong, nonatomic) CallManager *avCallManager;
@property (strong, nonatomic) ContentService *contentService;
@property (strong, nonatomic) Reachability *internetConnection;
@property (strong, nonatomic) NSTimer *presenceTimer;
@property (strong, nonatomic) NSMutableDictionary *useroutgoingcalls;
@property (strong, nonatomic) NSMutableDictionary *userincomingcalls;
@property (strong,nonatomic) NSMutableArray *callslist;

@end

@implementation QMApi

@dynamic currentUser;


+ (instancetype)instance {
    
    static QMApi *servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
        //[QBChat instance].useMutualSubscriptionForContactList = YES;
        
        QBSettings.autoReconnectEnabled = YES;

        servicesFacade.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:kQMPresenceTime
                                                                        target:servicesFacade
                                                                      selector:@selector(sendPresence)
                                                                      userInfo:nil
                                                                       repeats:YES];
    });
    
    return servicesFacade;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
#if QM_AUDIO_VIDEO_ENABLED == 1
        _avCallManager = [[CallManager alloc] initWithServiceManager:self];
#endif
        self.useroutgoingcalls = [NSMutableDictionary dictionary];
        self.userincomingcalls = [NSMutableDictionary dictionary];

         [self.usersService loadFromCache];
        [self.usersService serviceWillStart];
       // authService = [[QMAuthService alloc] initWithServiceManager:self];
        [QMChatCache setupDBWithStoreNamed:kChatCacheNameKey];
        [QMChatCache instance].messagesLimitPerDialog = 10;
       // _chatService = [[QMChatService alloc] initWithServiceManager:self cacheDataSource:self];
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        [_contactListService addDelegate:self];
        _settingsManager = [[SettingsManager alloc] init];
        _contentService = [[ContentService alloc] init];
        _internetConnection = [Reachability reachabilityForInternetConnection];
       // [_chatService addDelegate:self];
        
        __weak __typeof(self)weakSelf = self;
        void (^internetConnectionReachable)(Reachability *reachability) = ^(Reachability *reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.isAuthorized) {
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                    [weakSelf applicationDidBecomeActive:nil];
                }
            });
        };
        void (^internetConnectionNotReachable)(Reachability *reachability) = ^(Reachability *reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil) maskType:SVProgressHUDMaskTypeNone];
            });
        };
        
        self.internetConnection.reachableBlock = internetConnectionReachable;
        self.internetConnection.unreachableBlock = internetConnectionNotReachable;
    }
    
    [self.internetConnection startNotifier];
    return self;
}

- (QBUUser *)currentUser {
    return [QBSession currentSession].currentUser;
}
-(void)addoutgoingaudiocall:(QBUUser *)oponentuser type:(NSString*)calltype date:(NSString*)calldate user:(QBUUser*)currentuser calltype:(NSString*)callform {
    
    NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:oponentuser];
    self.useroutgoingcalls[@"user"] = personEncodedObject;
    self.useroutgoingcalls[@"calltype"] = calltype;
    self.useroutgoingcalls[@"calldate"] = calldate;
    self.useroutgoingcalls[@"callform"] = callform;
    
    // [_callslist addObject:self.usercalls];
    
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    list = [[[NSUserDefaults standardUserDefaults] objectForKey:currentuser.fullName]mutableCopy];
    if(list.count == 0){
        
        list = [[NSMutableArray alloc] init];
        [list addObject:self.useroutgoingcalls];
    }
    else{
        [list addObject:self.useroutgoingcalls];
    }
    
    NSLog(@"usercalls %@",list);
    
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:currentuser.fullName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}
-(void)addoutgoingvideocall:(NSArray *)oponentuser type:(NSString*)calltype date:(NSString*)calldate user:(QBUUser*)currentuser calltype:(NSString*)callform{
    
    NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:oponentuser];
    self.useroutgoingcalls[@"user"] = personEncodedObject;
    self.useroutgoingcalls[@"calltype"] = calltype;
    self.useroutgoingcalls[@"calldate"] = calldate;
    self.useroutgoingcalls[@"callform"] = callform;
    
    // [_callslist addObject:self.usercalls];
    
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    list = [[[NSUserDefaults standardUserDefaults] objectForKey:currentuser.fullName]mutableCopy];
    if(list.count == 0){
        
        list = [[NSMutableArray alloc] init];
        [list addObject:self.useroutgoingcalls];
    }
    else{
        [list addObject:self.useroutgoingcalls];
    }
    
    NSLog(@"usercalls %@",list);
    
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:currentuser.fullName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)addincomingcall:(QBUUser *)oponentuser type:(NSString*)calltype date:(NSString*)calldate user:(QBUUser*)currentuser calltype:(NSString*)callform {
    
    NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:currentuser];
    self.userincomingcalls[@"user"] = personEncodedObject;
    self.userincomingcalls[@"calltype"] = calltype;
    self.userincomingcalls[@"calldate"] = calldate;
    self.userincomingcalls[@"callform"] = callform;
    
    // [_callslist addObject:self.usercalls];
    
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    list = [[[NSUserDefaults standardUserDefaults] objectForKey:oponentuser.fullName]mutableCopy];
    if(list.count == 0){
        
        list = [[NSMutableArray alloc] init];
        [list addObject:self.userincomingcalls];
    }
    else{
        [list addObject:self.userincomingcalls];
    }
    
    NSLog(@"usercalls %@",list);
    
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:oponentuser.fullName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}
-(NSMutableArray*)usercalllist:(QBUUser*)user {
    
    if(user.fullName!=nil){
    NSMutableArray *list = [[[NSUserDefaults standardUserDefaults] objectForKey:user.fullName] mutableCopy];
    
    return list;
    }
    else {
        return nil;
    }
}


- (void)retriveUsersForNotificationIfNeeded:(QBChatMessage *)notification
{
    NSArray *idsToFetch = nil;
    if (notification.messageType == QMMessageTypeContactRequest) {
        idsToFetch = @[@(notification.senderID)];
    } else {
        idsToFetch = notification.dialog.occupantIDs;
    }
    //change
    
    [self.usersService getUsersWithIDs:idsToFetch];
    
}

- (BOOL)isInternetConnected {
    
    return self.internetConnection.isReachable;
}

#pragma mark - STATUS

- (void)sendPresence {
    
    if ([[QBChat instance] isConnected]) {
        [[QBChat instance] sendPresenceWithStatus:@"YES"];
    }
}

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion {
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService fetchDialogsUpdatedFromDate:self.settingsManager.lastActivityDate andPageLimit:kQMDialogsPageLimit iterationBlock:nil completionBlock:^(QBResponse *response) {
        //
        weakSelf.settingsManager.lastActivityDate = [NSDate date];
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self loginChat:^(BOOL success) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        if ([QBChat instance].isConnected) {
            [self joinGroupDialogs];
            if (completion) completion(YES);
        }
        else {
            if (completion) completion(NO);
        }
    });
}

- (void)applicationWillResignActive {
    [self logoutFromChat];
}

- (NSString *)errorStringFromArray:(NSArray *)errorArray {
    NSString *errorString = [[NSString alloc] init];
    
    for (NSUInteger i = 0; i < errorArray.count; ++i) {
        if (i > 0) {
            errorString = [errorString stringByAppendingString:@" and "];
        }
        errorString = [errorString stringByAppendingString:errorArray[i]];
    }
    
    return errorString;
}

- (NSString *)appendErrorString:(NSString *)errorString toMessageString:(NSString *)messageString {
    if (messageString.length > 0) {
        messageString = [messageString stringByAppendingString:@"\n"];
    }
    
    messageString = [messageString stringByAppendingString:errorString];
    
    return messageString;
}
- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

#pragma mark - QMContactListServiceDelegate


- (NSString *)errorStringFromResponseStatus:(QBResponseStatusCode)statusCode {
    NSString *errorString = [[NSString alloc] init];
    
    switch (statusCode) {
        case QBResponseStatusCodeServerError:
            errorString = NSLocalizedString(@"QM_STR_BAD_GATEWAY_ERROR", nil);
            break;
        case QBResponseStatusCodeUnknown:
            errorString = NSLocalizedString(@"QM_STR_CONNECTION_NETWORK_ERROR", nil);
            break;
        case QBResponseStatusCodeUnAuthorized:
            errorString = NSLocalizedString(@"QM_STR_INCORRECT_USER_DATA_ERROR", nil);
            break;
        case QBResponseStatusCodeValidationFailed:
            errorString = NSLocalizedString(@"QM_STR_INCORRECT_USER_DATA_ERROR", nil);
            break;
        default:
            errorString = NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil);
            break;
    }
    
    return errorString;
}

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedUsers:(QMCacheCollection)block {
    
    //change
    [QMUsersCache.instance usersSortedBy:@"id" ascending:YES];
   
}



#pragma mark QMServicesManagerProtocol

- (BOOL)isAuthorized {
    return self.authService.isAuthorized;
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    NSAssert(!response.success, @"Error handling is available only if response success value is False");
    
    if (!self.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    NSString *errorMessage = [[NSString alloc] init];
    
    if (self.isAuthorized) {
        errorMessage = [self errorStringFromResponseStatus:response.status];
    }
    else {
        
        id errorReasons = response.error.reasons[kQMErrorKey];
        
        if ([errorReasons isKindOfClass:[NSDictionary class]]) {
            //
            if (errorReasons[kQMErrorEmailKey]) {
                
                NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_EMAIL_ERROR", nil), [self errorStringFromArray:errorReasons[kQMErrorEmailKey]]];
                errorMessage = [self appendErrorString:errorString toMessageString:errorMessage];
                
            }
            if (errorReasons[kQMErrorFullNameKey]) {
                
                NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FULL_NAME_ERROR", nil), [self errorStringFromArray:errorReasons[kQMErrorFullNameKey]]];
                errorMessage = [self appendErrorString:errorString toMessageString:errorMessage];
                
            }
            if (errorReasons[kQMErrorPasswordKey]) {
                
                NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_PASSWORD_ERROR", nil), [self errorStringFromArray:errorReasons[kQMErrorPasswordKey]]];
                errorMessage = [self appendErrorString:errorString toMessageString:errorMessage];
                
            }
        }
        else {
            errorMessage = [self errorStringFromResponseStatus:response.status];
        }
        
    }
    
    [AlertView showAlertWithMessage:errorMessage actionSuccess:NO];
}

#pragma mark QMChatServiceCache delegate

- (void)chatService:(QMChatService *)chatService didLoadChatDialogsFromCache:(NSArray *)dialogs withUsers:(NSSet *)dialogsUsersIDs {
    
    //change
    
    [self.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];
    
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    [QMChatCache.instance insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    [QMChatCache.instance insertOrUpdateDialogs:chatDialogs completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    [QMChatCache.instance insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    [QMChatCache.instance insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [QMChatCache.instance deleteDialogWithID:chatDialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    NSAssert([message.dialogID isEqualToString:dialog.ID], @"must be equal");
    
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialog.ID completion:nil];
    [QMChatCache.instance insertOrUpdateDialog:dialog completion:nil];
}

#pragma mark QMChatServiceCacheDataSource

- (void)cachedDialogs:(QMCacheCollection)block {
    [QMChatCache.instance dialogsSortedBy:CDDialogAttributes.lastMessageDate ascending:YES completion:^(NSArray *dialogs) {
        block(dialogs);
    }];
}

- (void)cachedDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion {
    [QMChatCache.instance dialogByID:dialogID completion:^(QBChatDialog *cachedDialog) {
        completion(cachedDialog);
    }];
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
    [QMChatCache.instance messagesWithDialogId:dialogID sortedBy:CDMessageAttributes.messageID ascending:YES completion:^(NSArray *array) {
        block(array);
    }];
}
- (QBNetworkStatus)networkStatus {
    
    if (_reachabilityRef != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
            
            return [self networkStatusForFlags:flags];
        }
    }
    
    return NO;
}

- (QBNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    
    //    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return QBNetworkStatusNotReachable;
    }
    
    QBNetworkStatus returnValue = QBNetworkStatusNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = QBNetworkStatusReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = QBNetworkStatusReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = QBNetworkStatusReachableViaWWAN;
    }
    
    return returnValue;
}
@end

@implementation NSObject(CurrentUser)

@dynamic currentUser;

- (QBUUser *)currentUser {
    return [[QMApi instance] currentUser];
}

@end
