//
//  IAButton.h
//  QBRTCChatSemple
//
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAButton : UIButton

@property (assign, nonatomic) BOOL isPushed;
@property (strong, nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *selectedColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *highlightedColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *hightlightedTextColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *textColor  UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *mainLabelFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *subLabelFont UI_APPEARANCE_SELECTOR;

@end
