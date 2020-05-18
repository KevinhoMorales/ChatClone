//
//  ChatVC.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMChatViewController.h>
#import <MessageUI/MessageUI.h>
#import "MessageUI.h"
#import "ImagePicker.h"
#import "IQAudioRecorderController.h"

@interface ChatVC : QMChatViewController
<
QMChatServiceDelegate,
QMChatConnectionDelegate,
UITextViewDelegate,
QMChatAttachmentServiceDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
QMContactListServiceDelegate,
QMChatActionsHandler,
QMChatCellDelegate,
QMImagePickerResultHandler,
QMDeferredQueueManagerDelegate,
IQAudioRecorderControllerDelegate,
MFMailComposeViewControllerDelegate

>

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress;

@property (nonatomic, strong) AVAudioPlayer *audioplayer;
@property (nonatomic, strong) QBChatDialog* dialog;

@end
