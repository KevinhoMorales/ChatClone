//
//  QBApi+Permissions.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBApi.h"
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>

@implementation QMApi (Permissions)

- (void)requestPermissionToMicrophoneWithCompletion:(void(^)(BOOL granted))completion {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if( completion ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(granted);
            });
        }
    }];
}

- (void)requestPermissionToCameraWithCompletion:(void(^)(BOOL authorized))completion {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        if( completion ){
            completion(YES);
        }
    } else if(authStatus == AVAuthorizationStatusDenied){
        if( completion ){
            completion(NO);
        }
    } else if(authStatus == AVAuthorizationStatusRestricted){
        if( completion ){
            completion(NO);
        }
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if( completion ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(granted);
                });
            }
        }];
    } else {
        if( completion ){
            completion(NO);
        }
    }
}

@end
