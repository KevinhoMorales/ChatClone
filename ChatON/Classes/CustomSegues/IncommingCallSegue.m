//
//  IncommingCallSegue.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "IncommingCallSegue.h"
#import "IncomingCallController.h"
#import "VideoCallController.h"
#import "BaseCallsController.h"

@implementation IncommingCallSegue

- (void)perform
{
    IncomingCallController *incommingCallController = (IncomingCallController *)self.sourceViewController;
    BaseCallsController *callsController = (VideoCallController *)self.destinationViewController;
    [callsController setOpponent:incommingCallController.opponent];
    callsController.isOpponentCaller = YES;
    
    incommingCallController.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
  // [incommingCallController.navigationController transitionFromViewController:incommingCallController toViewController:callsController duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil completion:nil];
    [incommingCallController.navigationController setViewControllers:@[callsController] animated:YES];
}

@end
