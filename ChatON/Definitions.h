//
//  Definitions.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#ifndef Q_municate_Definitions_h
#define Q_municate_Definitions_h

#define QM_TEST 0

#define QM_AUDIO_VIDEO_ENABLED 1

#define DELETING_DIALOGS_ENABLED 0

#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define $(...)  [NSSet setWithObjects:__VA_ARGS__, nil]

#define CHECK_OVERRIDE()\
@throw\
[NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]\
userInfo:nil]

/*ContentService*/
typedef void(^QMContentProgressBlock)(float progress);
typedef void(^QMCFileUploadResponseBlock)(QBResponse *response, QBCBlob *blob);
typedef void(^QMCFileDownloadResponseBlock)(QBResponse *response, NSData *fileData);
typedef void(^QBUUserPagedResponseBlock)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users);

/*ChatDialogs constants*/
static const NSUInteger kQMDialogsPageLimit = 10;

//******************** CoreData ********************

static NSString *const kChatCacheNameKey                    = @"HeyYapp";
static NSString *const kContactListCacheNameKey             = @"HeyYapp-contacts";

//******************** Segue Identifiers ********************
static NSString *const kTabBarSegueIdnetifier               = @"TabBarSegue";
static NSString *const kSplashSegueIdentifier               = @"SplashSegue";
static NSString *const kWelcomeScreenSegueIdentifier        = @"WelcomeScreenSegue";
static NSString *const kSignUpSegueIdentifier               = @"SignUpSegue";
static NSString *const kLogInSegueSegueIdentifier           = @"LogInSegue";
static NSString *const kDetailsSegueIdentifier              = @"DetailsSegue";
static NSString *const kVideoCallSegueIdentifier            = @"VideoCallSegue";
static NSString *const kAudioCallSegueIdentifier            = @"AudioCallSegue";
static NSString *const kGoToDuringAudioCallSegueIdentifier  = @"goToDuringAudioCallSegueIdentifier";
static NSString *const kGoToDuringVideoCallSegueIdentifier  = @"goToDuringVideoCallSegueIdentifier";
static NSString *const kChatViewSegueIdentifier             = @"ChatViewSegue";
static NSString *const kIncomingCallIdentifier              = @"IncomingCallIdentifier";
static NSString *const kProfileSegueIdentifier              = @"ProfileSegue";
static NSString *const kCreateNewChatSegueIdentifier        = @"CreateNewChatSegue";
static NSString *const kGroupDetailsSegueIdentifier         = @"GroupDetailsSegue";
static NSString *const kQMAddMembersToGroupControllerSegue  = @"QMAddMembersToGroupControllerSegue";
static NSString *const kSettingsCellBundleVersion           = @"CFBundleVersion";

//******************** USER DEFAULTS KEYS ********************
static NSString *const kMailSubjectString                   = @"Chat ON";
static NSString *const kMailBodyString                      = @"<a https://itunes.apple.com/us/app/lets-chat-2017/id1245540517?ls=1&mt=8'>Check Chat ON! and Join Me</a>";

//******************** PUSH NOTIFICATIONS ********************
static NSString *const kPushNotificationDialogIDKey         = @"dialog_id";

#endif
