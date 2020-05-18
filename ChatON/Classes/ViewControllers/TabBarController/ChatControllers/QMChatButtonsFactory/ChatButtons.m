//
//  ChatButtons.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ChatButtons.h"

@implementation ChatButtons

+ (UIButton *)groupInfo {
    
    UIButton *groupInfoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [groupInfoButton setFrame:CGRectMake(0, 0, 30, 40)];
    [groupInfoButton setImage:[UIImage imageNamed:@"ic_info_top"] forState:UIControlStateNormal];
    
    return groupInfoButton;
}

+ (UIButton *)audioCall {
    
    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioButton setFrame:CGRectMake(0, 0, 30, 40)];
    [audioButton setImage:[UIImage imageNamed:@"ic_phone_top"] forState:UIControlStateNormal];
    return audioButton;
}
+ (UIButton *)emailchat {
    
    UIButton *clearchatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearchatButton setFrame:CGRectMake(0, 0, 30, 40)];
    [clearchatButton setImage:[UIImage imageNamed:@"emailchat"] forState:UIControlStateNormal];
    return clearchatButton;
}
+ (UIButton *)clearchat {
    
    UIButton *clearchatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearchatButton setFrame:CGRectMake(0, 0, 30, 40)];
    [clearchatButton setImage:[UIImage imageNamed:@"emailchat"] forState:UIControlStateNormal];
    return clearchatButton;
}

+ (UIButton *)videoCall {
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoButton setFrame:CGRectMake(0, 0, 30, 40)];
    [videoButton setImage:[UIImage imageNamed:@"ic_camera_top"] forState:UIControlStateNormal];
    return videoButton;
}

+ (UIButton *)emojiButton {
    
    UIImage *buttonImage = [UIImage imageNamed:@"ic_smile"];
    
    UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [emojiButton setImage:buttonImage forState:UIControlStateNormal];
    emojiButton.contentMode = UIViewContentModeScaleAspectFit;
    emojiButton.backgroundColor = [UIColor clearColor];
    emojiButton.tintColor = [UIColor lightGrayColor];
    
    return emojiButton;
}

@end
