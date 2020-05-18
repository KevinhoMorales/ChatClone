//
//  ImagePicker.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QMImagePickerResult)(UIImage *image);

@protocol QMImagePickerResultHandler;

@interface ImagePicker : UIImagePickerController

+ (void)presentIn:(UIViewController *)vc
        configure:(void (^)(UIImagePickerController *picker))configure
           result:(QMImagePickerResult)result;

+ (void)chooseSourceTypeInVC:(id)vc allowsEditing:(BOOL)allowsEditing result:(QMImagePickerResult)result;

+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;
+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing;

+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;
+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing;

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler;
+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler
                           allowsEditing:(BOOL)allowsEditing;

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;
+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing;

@end

@protocol QMImagePickerResultHandler <NSObject>

@optional

- (void)imagePicker:(ImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo;
- (void)imagePicker:(ImagePicker *)imagePicker didFinishPickingVideo:(NSURL *)videoUrl;

@end
