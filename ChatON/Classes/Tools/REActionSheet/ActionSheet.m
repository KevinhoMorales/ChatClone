//
//  ActionSheet.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ActionSheet.h"

@interface ActionSheet()

<UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray* buttonActions;

@end

@implementation ActionSheet

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (id)init {
    
    self = [super init];
    if (self) {
        
		self.buttonActions = @[].mutableCopy;
		self.delegate = self;
    }
    
    return self;
}

+ (void)presentActionSheetInView:(UIView *)view configuration:(REActionSheetBlock)configuration {
    
	ActionSheet* actionSheet = [[ActionSheet alloc] init];
	configuration(actionSheet);
	[actionSheet showInView:view];
}

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block {
    
	[self.buttonActions insertObject:[block copy] atIndex:[self addButtonWithTitle:title]];
}

- (void)addDestructiveButtonWithTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block {
    
    NSUInteger index = [self addButtonWithTitle:title];
    [self.buttonActions insertObject:[block copy] atIndex:index];
    self.destructiveButtonIndex = index;
}

- (void)addCancelButtonWihtTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block {
    
    NSUInteger index = [self addButtonWithTitle:title];
    [self.buttonActions insertObject:[block copy] atIndex:index];
    self.cancelButtonIndex = index;
}

#pragma mark - UIAlertViewDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    ActionSheet* tActionSheet = (ActionSheet *)actionSheet;
	REActionSheetButtonAction action = [tActionSheet.buttonActions objectAtIndex:buttonIndex];

	action();
    tActionSheet.buttonActions = nil;
}

@end
