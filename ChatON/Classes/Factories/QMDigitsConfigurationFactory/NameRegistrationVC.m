//
//  NameRegistrationVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NameRegistrationVC.h"
#import "QMImageView.h"
#import "UsersUtils.h"
#import "QBApi.h"
#import "AlertView.h"
#import "ImagePicker.h"
#import "SignUpVC.h"
#import "UIImage+Cropper.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "ActionSheet.h"


@interface NameRegistrationVC ()<QMImagePickerResultHandler>
@property (weak, nonatomic) IBOutlet UITextField *namefield;
@property (weak, nonatomic) IBOutlet UIButton *chooseprofilepic;
@property (weak, nonatomic) IBOutlet QMImageView *profilepic;
@property (weak, nonatomic) IBOutlet UIButton *signup;
- (IBAction)signup:(id)sender;
- (IBAction)profiepicaction:(id)sender;
@property (strong, nonatomic) UIImage *cachedPicture;

@end

@implementation NameRegistrationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.profilepic.imageViewType = QMImageViewTypeCircle;
    
    NSURL *url = [UsersUtils userAvatarURL:[QMApi instance].currentUser];
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    
    [self.profilepic setImageWithURL:url
                        placeholder:placeholder
                            options:SDWebImageHighPriority
                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                               ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                           } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               
                               
                           }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    //self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
    //self.userImage.layer.masksToBounds = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signup:(id)sender {
    
    [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
    
    QBUUser *user = self.currentUser;
    user.fullName = _namefield.text;

    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
    updateUserParams.customData = user.customData;
    updateUserParams.fullName = user.fullName;
    
    
    [[QMApi instance] updateCurrentUser:updateUserParams image:_cachedPicture progress:nil completion:^(BOOL success) {
        
        if(success){
            _cachedPicture = nil;
        }
    
    }];
    
    
    ;

    
}
- (void)imagePicker:(ImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    __weak __typeof(self)weakSelf = self;
    
    
    weakSelf.cachedPicture = photo;
    weakSelf.profilepic.image = [photo imageByCircularScaleAndCrop:weakSelf.profilepic.frame.size];
    
    
    
}


- (IBAction)profiepicaction:(id)sender {
    
    
    [self.view endEditing:YES];
    
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [ImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGEE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [ImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
