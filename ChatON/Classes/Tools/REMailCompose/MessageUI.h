//
//  REMailCompose.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <MessageUI/MessageUI.h>

typedef void(^MFMailComposeResultBlock)(MFMailComposeResult result, NSError *error);
typedef void(^MessageComposeResultBlock)(MessageComposeResult result);

@class REMailComposeViewController;

@interface REMailComposeViewController : MFMailComposeViewController

+ (void)present:(void(^)(REMailComposeViewController *mailVC))mailComposeViewController
         finish:(MFMailComposeResultBlock)finish;

@end

@interface REMessageComposeViewController : MFMessageComposeViewController

+ (void)present:(void(^)(REMessageComposeViewController *massageVC))messageComposeViewController
         finish:(void(^)(MessageComposeResult result))finish;

@end



