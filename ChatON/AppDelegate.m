//
//  AppDelegate.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.

#import "AppDelegate.h"

//.. Wazowski Edition
#import <Chartboost/Chartboost.h>
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>


#import "Classes/ViewControllers/TabBarController/MainTabBarController.h"
//..

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "SVProgressHUD.h"
#import "REAlertView+QMSuccess.h"
#import "QBApi.h"
#import "SettingsManager.h"
#import "CallManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ViewControllersFactory.h"
#import <DigitsKit/DigitsKit.h>

#define DEVELOPMENT 1
#define STAGE_SERVER_IS_ACTIVE 0


#if DEVELOPMENT

// Development
/*
const NSUInteger kQMApplicationID = 14542;
NSString *const kQMAuthorizationKey = @"rJqAFphrSnpyZW2";
NSString *const kQMAuthorizationSecret = @"tTEB2wK-dU8X3Ra";
NSString *const kQMAcconuntKey = @"2qCrjKYFkYnfRnUiYxLZ";
*/
const NSUInteger kQMApplicationID = 58755;
NSString *const kQMAuthorizationKey = @"uZyZje8GgUFR5WE";
NSString *const kQMAuthorizationSecret = @"rGpPwVwaJuuAQhx";
NSString *const kQMAcconuntKey = @"6Qyiz3pZfNsex1Enqnp7";


//// Stage server for E-bay:
//
//const NSUInteger kQMApplicationID = 13029;
//NSString *const kQMAuthorizationKey = @"3mBwAnczNvh-sBK";
//NSString *const kQMAuthorizationSecret = @"xWP2jgUsQOpxj-6";
//NSString *const kQMAcconuntKey = @"tLapBNZPeqCHxEA8zApx";
//NSString *const kQMContentBucket = @"blobs-test-oz";

#else

// Production
/*
const NSUInteger kQMApplicationID = 13318;
NSString *const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
NSString *const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
NSString *const kQMAcconuntKey = @"6Qyiz3pZfNsex1Enqnp7";
*/
const NSUInteger kQMApplicationID = 58755;
NSString *const kQMAuthorizationKey = @"uZyZje8GgUFR5WE";
NSString *const kQMAuthorizationSecret = @"rGpPwVwaJuuAQhx";
NSString *const kQMAcconuntKey = @"6Qyiz3pZfNsex1Enqnp7";

#endif


/* ==================================================================== */

@interface AppDelegate () <QMNotificationHandlerDelegate, ChartboostDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"badgecount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
   // self.navigationBar.tintColor = [UIColor colorWithRed:(65.0f/255.0f) green:(105.0f/255.0f) blue:(225.0f/255.0f) alpha:1];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
    // QB Settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAcconuntKey];
    
    [QBSettings setLogLevel:QBLogLevelDebug];
    
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
//#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
//#endif
    
//#ifndef DEBUG
  //  [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
//#endif
    
#if STAGE_SERVER_IS_ACTIVE == 1
    //    [QBSettings setServerApiDomain:@"https://api.stage.quickblox.com"];
    
    [QBConnection setApiDomain:@"https://api.stage.quickblox.com" forServiceZone:QBConnectionZoneTypeProduction];
    [QBConnection setServiceZone:QBConnectionZoneTypeProduction];
    [QBSettings setServerChatDomain:@"chatstage.quickblox.com"];
    [QBSettings setContentBucket: kQMContentBucket];
#endif
    
    [QBRTCClient initializeRTC];
 //   [QBRTCConfig setICEServers:[[QMApi instance].avCallManager quickbloxICE]];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    /*Configure app appearance*/
    NSDictionary *normalAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.000 alpha:0.750]};
    NSDictionary *disabledAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.935 alpha:0.260]};
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateDisabled];
    
    //.. Wazowski Edition
    // Initialize the Chartboost library
    [Chartboost startWithAppId:@"59758acef6cd4506db90f818"
                  appSignature:@"995395ef25e07e716cff91830e415c8a75467f19"
                      delegate:self];
    //..
    
    // Fire services:
    
    [QMApi instance];
    
    /** Crashlytics */
    [Fabric with:@[[Crashlytics class]]];

    
    if (launchOptions != nil) {
        NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [[QMApi instance] setPushNotification:notification];
    }

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([application applicationState] == UIApplicationStateInactive) {
        NSString *dialogID = userInfo[kPushNotificationDialogIDKey];
        if (dialogID != nil) {
            NSString *dialogWithIDWasEntered = [QMApi instance].settingsManager.dialogWithIDisActive;
            if ([dialogWithIDWasEntered isEqualToString:dialogID]) return;
            
            [[QMApi instance] setPushNotification:userInfo];
            
            [[QMApi instance] handlePushNotificationWithDelegate:self];
        }
        ILog(@"Push was received. User info: %@", userInfo);
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"badgecount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    [[QMApi instance] applicationWillResignActive];
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    if (!QMApi.instance.currentUser) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] applicationDidBecomeActive:^(BOOL success) {}];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    BOOL urlWasIntendedForFacebook = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                                    openURL:url
                                                                          sourceApplication:sourceApplication
                                                                                 annotation:annotation
                                      ];
    return urlWasIntendedForFacebook;
}


#pragma mark - PUSH NOTIFICATIONS REGISTRATION

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (deviceToken) {
        [[QMApi instance] setDeviceToken:deviceToken];
    }
}

#pragma mark - QMNotificationHandlerDelegate protocol

- (void)notificationHandlerDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    UITabBarController *rootController = [(UITabBarController *)self.window.rootViewController selectedViewController];
    UINavigationController *navigationController = (UINavigationController *)rootController;
    
    UIViewController *chatVC = [QBViewControllersFactory chatControllerWithDialog:chatDialog];
    
    NSString *dialogWithIDWasEntered = [QMApi instance].settingsManager.dialogWithIDisActive;
    if (dialogWithIDWasEntered != nil) {
        // some chat already opened, return to dialogs view controller first
        [navigationController popViewControllerAnimated:NO];
    }
    
    [navigationController pushViewController:chatVC animated:YES];
}


#pragma mark - Chartboost Delegate Methods
/*
 * didInitialize
 *
 * This is used to signal when Chartboost SDK has completed its initialization.
 *
 * status is YES if the server accepted the appID and appSignature as valid
 * status is NO if the network is unavailable or the appID/appSignature are invalid
 *
 * Is fired on:
 * -after startWithAppId has completed background initialization and is ready to display ads
 */
- (void)didInitialize:(BOOL)status {
    NSLog(@"didInitialize");
    // chartboost is ready
    [Chartboost cacheRewardedVideo:CBLocationMainMenu];
    [Chartboost cacheMoreApps:CBLocationHomeScreen];
    
    // Show an interstitial whenever the app starts up
    
    BOOL removeads = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeadskey"];
    if(removeads == YES){
        NSLog(@"remove ads purchased...");
    }
    else {
         [Chartboost showInterstitial:CBLocationDefault];
    }
   
}


/*
 * shouldDisplayInterstitial
 *
 * This is used to control when an interstitial should or should not be displayed
 * The default is YES, and that will let an interstitial display as normal
 * If it's not okay to display an interstitial, return NO
 *
 * For example: during gameplay, return NO.
 *
 * Is fired on:
 * -Interstitial is loaded & ready to display
 */

- (BOOL)shouldDisplayInterstitial:(NSString *)location {
    NSLog(@"about to display interstitial at location %@", location);
    
    // For example:
    // if the user has left the main menu and is currently playing your game, return NO;
    
    // Otherwise return YES to display the interstitial
    return YES;
}


/*
 * didFailToLoadInterstitial
 *
 * This is called when an interstitial has failed to load. The error enum specifies
 * the reason of the failure
 */

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Interstitial, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Interstitial, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Interstitial, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Interstitial, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Interstitial, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Interstitial, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Interstitial, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Interstitial, session not started !");
        } break;
        case CBLoadErrorNoLocationFound : {
            NSLog(@"Failed to load Interstitial, missing location parameter !");
        } break;
        default: {
            NSLog(@"Failed to load Interstitial, unknown error !");
        }
    }
}

/*
 * didCacheInterstitial
 *
 * Passes in the location name that has successfully been cached.
 *
 * Is fired on:
 * - All assets loaded
 * - Triggered by cacheInterstitial
 *
 * Notes:
 * - Similar to this is: (BOOL)hasCachedInterstitial:(NSString *)location;
 * Which will return true if a cached interstitial exists for that location
 */

- (void)didCacheInterstitial:(NSString *)location {
    NSLog(@"interstitial cached at location %@", location);
}

/*
 * didFailToLoadMoreApps
 *
 * This is called when the more apps page has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No more apps page has been created (add a more apps page in the dashboard)
 * - No publishing campaign matches for that user (add more campaigns to your more apps page)
 *  -Find this inside the App > Edit page in the Chartboost dashboard
 */

- (void)didFailToLoadMoreApps:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load More Apps, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load More Apps, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load More Apps, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load More Apps, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load More Apps, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load More Apps, first session !");
        } break;
        case CBLoadErrorNoAdFound: {
            NSLog(@"Failed to load More Apps, Apps not found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load More Apps, session not started !");
        } break;
        default: {
            NSLog(@"Failed to load More Apps, unknown error !");
        }
    }
}

/*
 * didDismissInterstitial
 *
 * This is called when an interstitial is dismissed
 *
 * Is fired on:
 * - Interstitial click
 * - Interstitial close
 *
 */

- (void)didDismissInterstitial:(NSString *)location {
    NSLog(@"dismissed interstitial at location %@", location);
}

/*
 * didDismissMoreApps
 *
 * This is called when the more apps page is dismissed
 *
 * Is fired on:
 * - More Apps click
 * - More Apps close
 *
 */

- (void)didDismissMoreApps:(NSString *)location {
    NSLog(@"dismissed more apps page at location %@", location);
}

/*
 * didCompleteRewardedVideo
 *
 * This is called when a rewarded video has been viewed
 *
 * Is fired on:
 * - Rewarded video completed view
 *
 */
- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    NSLog(@"completed rewarded video view at location %@ with reward amount %d", location, reward);
}

/*
 * didFailToLoadRewardedVideo
 *
 * This is called when a Rewarded Video has failed to load. The error enum specifies
 * the reason of the failure
 */

- (void)didFailToLoadRewardedVideo:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Rewarded Video, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Rewarded Video, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Rewarded Video, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Rewarded Video, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Rewarded Video, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Rewarded Video, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Rewarded Video, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Rewarded Video, session not started !");
        } break;
        case CBLoadErrorNoLocationFound : {
            NSLog(@"Failed to load Rewarded Video, missing location parameter !");
        } break;
        default: {
            NSLog(@"Failed to load Rewarded Video, unknown error !");
        }
    }
}

/*
 * didDisplayInterstitial
 *
 * Called after an interstitial has been displayed on the screen.
 */

- (void)didDisplayInterstitial:(CBLocation)location {
    NSLog(@"Did display interstitial");
    
    // We might want to pause our in-game audio, lets double check that an ad is visible
    if ([Chartboost isAnyViewVisible]) {
        // Use this function anywhere in your logic where you need to know if an ad is visible or not.
        NSLog(@"Pause audio");
    }
}


/*!
 @abstract
 Called after an InPlay object has been loaded from the Chartboost API
 servers and cached locally.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an InPlay object has been loaded from the Chartboost API
 servers and cached locally for a given CBLocation.
 */
- (void)didCacheInPlay:(CBLocation)location {
    NSLog(@"Successfully cached inPlay");
    /*
    ViewController *vc = (ViewController*)self.window.rootViewController;
    [vc renderInPlay:[Chartboost getInPlay:location]];
     */
}

/*!
 @abstract
 Called after a InPlay has attempted to load from the Chartboost API
 servers but failed.
 
 @param location The location for the Chartboost impression type.
 
 @param error The reason for the error defined via a CBLoadError.
 
 @discussion Implement to be notified of when an InPlay has attempted to load from the Chartboost API
 servers but failed for a given CBLocation.
 */
- (void)didFailToLoadInPlay:(CBLocation)location
                  withError:(CBLoadError)error {
    
    NSString *errorString = @"";
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            errorString = @"Failed to load In Play, no Internet connection !";
        } break;
        case CBLoadErrorInternal: {
            errorString = @"Failed to load In Play, internal error !";
        } break;
        case CBLoadErrorNetworkFailure: {
            errorString = @"Failed to load In Play, network errorString !";
        } break;
        case CBLoadErrorWrongOrientation: {
            errorString = @"Failed to load In Play, wrong orientation !";
        } break;
        case CBLoadErrorTooManyConnections: {
            errorString = @"Failed to load In Play, too many connections !";
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            errorString = @"Failed to load In Play, first session !";
        } break;
        case CBLoadErrorNoAdFound : {
            errorString = @"Failed to load In Play, no ad found !";
        } break;
        case CBLoadErrorSessionNotStarted : {
            errorString = @"Failed to load In Play, session not started !";
        } break;
        case CBLoadErrorNoLocationFound : {
            errorString = @"Failed to load In Play, missing location parameter !";
        } break;
        default: {
            errorString = @"Failed to load In Play, unknown error !";
        }
    }
    
    NSLog(@"Error: %@", errorString);
    
    /*
    ViewController *vc = (ViewController*)self.window.rootViewController;
    [vc renderInPlayError:errorString];
     */
}

@end
