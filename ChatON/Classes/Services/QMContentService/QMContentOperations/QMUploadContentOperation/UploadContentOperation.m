//
//  UploadContentOperation.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "UploadContentOperation.h"

@interface UploadContentOperation()

@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *contentType;
@property (assign, nonatomic) BOOL public;

@end

@implementation UploadContentOperation

- (instancetype)initWithUploadFile:(NSData *)data
                          fileName:(NSString *)fileName
                       contentType:(NSString *)contentType
                          isPublic:(BOOL)isPublic {
    
    self = [super init];
    if (self) {
        
        self.data = data;
        self.fileName = fileName;
        self.contentType = contentType;
        self.public = isPublic;
    }
    
    return self;
}

- (void)main {
    
    self.cancelableRequest = [QBRequest TUploadFile:self.data
                                           fileName:self.fileName
                                        contentType:self.contentType
                                           isPublic:self.public
                                       successBlock:^(QBResponse *response, QBCBlob *blob) {
                                           //
                                           if (self.completionHandler) {
                                               QMCFileUploadResponseBlock block = (QMCFileUploadResponseBlock)self.completionHandler;
                                               block(response,blob);
                                           }
                                       } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                           //
                                           if (self.progressHandler) self.progressHandler(status.percentOfCompletion);
                                       } errorBlock:^(QBResponse *response) {
                                           //
                                           if (self.completionHandler) {
                                               QMCFileUploadResponseBlock block = (QMCFileUploadResponseBlock)self.completionHandler;
                                               block(response,nil);
                                           }
                                       }];
}

@end
