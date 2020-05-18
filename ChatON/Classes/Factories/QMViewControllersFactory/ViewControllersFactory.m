//
//  QBViewControllersFactory.m
// //  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ViewControllersFactory.h"
#import "ChatVC.h"
#import "QBApi.h"

@implementation QBViewControllersFactory


+ (UIViewController *)chatControllerWithDialogID:(NSString *)dialogID
{
    QBChatDialog *dialog = [[QMApi instance] chatDialogWithID:dialogID];
    
    ChatVC *chatVC = (ChatVC *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatVC"];
    chatVC.dialog = dialog;
    return chatVC;
}


+ (UIViewController *)chatControllerWithDialog:(QBChatDialog *)dialog
{
    ChatVC *chatVC = (ChatVC *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatVC"];
    chatVC.dialog = dialog;
    return chatVC;
}

@end
