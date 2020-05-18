//
//  ContentOperation.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentOperation : NSOperation

@property (copy, nonatomic) QMContentProgressBlock progressHandler;
@property (copy, nonatomic) id completionHandler;

@property (strong, nonatomic) QBRequest *cancelableRequest;

@end
