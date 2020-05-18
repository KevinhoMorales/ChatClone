//
//  SignUpVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "SignUpVC.h"
#import "WelcomeScreenVC.h"
#import "LicenseAgreement.h"
#import "UIImage+Cropper.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QBApi.h"
#import "ImagePicker.h"
#import "ActionSheet.h"
#import "QMImageView.h"
#import "UsersUtils.h"

@interface SignUpVC ()<QMImagePickerResultHandler>

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet QMImageView *userImage;


@property (strong, nonatomic) UIImage *cachedPicture;

- (IBAction)chooseUserPicture:(id)sender;
- (IBAction)signUp:(id)sender;

@end

@implementation SignUpVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImage.imageViewType = QMImageViewTypeCircle;

    NSURL *url = [UsersUtils userAvatarURL:self.currentUser];

    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];

    [self.userImage setImageWithURL:url
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)chooseUserPicture:(id)sender {
    
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
- (void)imagePicker:(ImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    __weak __typeof(self)weakSelf = self;
    
    
    weakSelf.cachedPicture = photo;
    weakSelf.userImage.image = [photo imageByCircularScaleAndCrop:weakSelf.userImage.frame.size];
    
    
    
}

- (IBAction)pressentUserAgreement:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    [LicenseAgreement checkAcceptedUserAgreementInViewController:self completion:nil];
}

- (IBAction)signUp:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    [self fireSignUp];
}

- (void)fireSignUp
{
    NSString *fullName = self.fullNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (fullName.length == 0 || password.length == 0 || email.length == 0) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [LicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL userAgreementSuccess) {
        
        if (userAgreementSuccess) {
            
            QBUUser *newUser = [QBUUser user];
            
            newUser.fullName = fullName;
            newUser.email = email;
            newUser.password = password;
            newUser.tags = [[NSMutableArray alloc] initWithObjects:@"ios", nil];
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            void (^presentTabBar)(void) = ^(void) {
                
                [SVProgressHUD dismiss];
                [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
            };
            
            [[QMApi instance] signUpAndLoginWithUser:newUser rememberMe:YES completion:^(BOOL success) {
                
                if (success) {
                    
                    if (weakSelf.cachedPicture) {
                        
                        [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeClear];
                        [[QMApi instance] updateCurrentUser:nil image:weakSelf.cachedPicture progress:^(float progress) {
                            //
                            [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
                        } completion:^(BOOL success) {
                            //
                            presentTabBar();
                        }];
                    }
                    else {
                        presentTabBar();
                    }
                }
                else {
                    [SVProgressHUD dismiss];
                }
            }];
        }
    }];
}

@end
