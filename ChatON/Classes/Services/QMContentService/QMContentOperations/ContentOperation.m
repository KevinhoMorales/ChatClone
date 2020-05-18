//
//  ContentOperation.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ContentOperation.h"

@interface ContentOperation()

@end

@implementation ContentOperation

- (void)cancel {
    
    [self.cancelableRequest cancel];
}

@end
