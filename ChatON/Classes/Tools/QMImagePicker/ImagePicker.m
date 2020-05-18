//
//  ImagePicker.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ImagePicker.h"
#import "ActionSheet.h"

@interface ImagePicker()

<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (copy, nonatomic) QMImagePickerResult result;
@property (weak, nonatomic) id<QMImagePickerResultHandler> resultHandler;



@end

@implementation ImagePicker

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

+ (void)presentIn:(UIViewController *)vc
        configure:(void (^)(UIImagePickerController *picker))configure
           result:(QMImagePickerResult)result {
    
    ImagePicker *picker = [[ImagePicker alloc] init];
    picker.result = result;
    configure(picker);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [vc presentViewController:picker animated:YES completion:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            
            NSURL *resultMediaUrl = info[UIImagePickerControllerMediaURL];
            [self.resultHandler imagePicker:self didFinishPickingVideo:resultMediaUrl];
        }
        else {
            
            NSString *key = picker.allowsEditing ? UIImagePickerControllerEditedImage: UIImagePickerControllerOriginalImage;
            UIImage *resultImage = info[key];
            
            [self.resultHandler imagePicker:self didFinishPickingPhoto:resultImage];
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
}
+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] takePhotoInViewController:vc resultHandler:resultHandler allowsEditing:YES];
}

+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing {
    
    ImagePicker *imagePicker = [[[self class] alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = allowsEditing;
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:YES completion:nil];
}

+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] choosePhotoInViewController:vc resultHandler:resultHandler allowsEditing:YES];
}
+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing {
    
    ImagePicker *imagePicker = [[[self class] alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = allowsEditing;
    
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:YES completion:nil];
}

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] takePhotoOrVideoInViewController:vc
                                       maxDuration:maxDuration
                                           quality:quality
                                     resultHandler:resultHandler
                                     allowsEditing:YES];
}

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler
                           allowsEditing:(BOOL)allowsEditing {
    
    ImagePicker *imagePicker = [[[self class] alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.videoMaximumDuration = maxDuration;
    imagePicker.videoQuality = quality;
    imagePicker.allowsEditing = allowsEditing;
    
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:NO completion:nil];
}

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] chooseFromGaleryInViewController:vc resultHandler:resultHandler allowsEditing:YES];
}

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing {
    
    ImagePicker *imagePicker = [[[self class] alloc] init];
    imagePicker.allowsEditing = allowsEditing;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
    imagePicker.resultHandler = resultHandler;
    [vc presentViewController:imagePicker animated:YES completion:nil];
}


+ (void)chooseSourceTypeInVC:(id)vc allowsEditing:(BOOL)allowsEditing result:(QMImagePickerResult)result {
    
    UIViewController *viewController = vc;
    
    void (^showImagePicker)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType type) {
        
        [ImagePicker presentIn:viewController configure:^(UIImagePickerController *picker) {
            
            picker.sourceType = type;
            picker.allowsEditing = allowsEditing;
            
        } result:result];
    };
    
    
    [ActionSheet presentActionSheetInView:viewController.view configuration:^(ActionSheet *actionSheet) {
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_TAKE_NEW_PHOTO", nil)
                         andActionBlock:^{
                             showImagePicker(UIImagePickerControllerSourceTypeCamera);
                         }];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil)
                         andActionBlock:^{
                             showImagePicker(UIImagePickerControllerSourceTypePhotoLibrary);
                         }];
        
        [actionSheet addCancelButtonWihtTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                               andActionBlock:^{}];
    }];
}

@end
