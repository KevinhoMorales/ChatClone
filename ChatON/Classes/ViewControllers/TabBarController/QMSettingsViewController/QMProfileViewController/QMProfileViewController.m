//
//  QMProfileViewController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfileViewController.h"
#import "QMPlaceholderTextView.h"
#import "QBApi.h"
#import "REAlertView+QMSuccess.h"
#import "QMImageView.h"
#import "SVProgressHUD.h"
#import "ContentService.h"
#import "UIImage+Cropper.h"
#import "ActionSheet.h"
#import "ImagePicker.h"
#import "UsersUtils.h"
#import "FriendListCell.h"

@interface QMProfileViewController ()

<UITextFieldDelegate, UITextViewDelegate,QMImagePickerResultHandler>

@property (weak, nonatomic) IBOutlet QMImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet QMPlaceHolderTextView *statusField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateProfileButton;

@property (strong, nonatomic) NSString *fullNameFieldCache;
@property (copy, nonatomic) NSString *phoneFieldCache;
@property (copy, nonatomic) NSString *statusTextCache;


@property (nonatomic, strong) UIImage *avatarImage;

@end


@implementation QMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarView.imageViewType = QMImageViewTypeCircle;
    self.statusField.placeHolder = @"Add status...";
    
    [self updateProfileView];
    [self setUpdateButtonActivity];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateProfileView {
    
    
    self.fullNameFieldCache = self.currentUser.fullName;
    self.phoneFieldCache = self.currentUser.phone ?: @"";
    self.statusTextCache = self.currentUser.status ?: @"";
    
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    NSURL *url = [UsersUtils userAvatarURL:self.currentUser];
    
    [self.avatarView setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                            } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                
                                
                            }];
    
    self.fullNameField.text = self.currentUser.fullName;
    self.emailField.text = self.currentUser.email;
    self.phoneNumberField.text = self.currentUser.phone;
    self.statusField.text = self.currentUser.status;
}

- (IBAction)changeAvatar:(id)sender {
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
   
        
        weakSelf.avatarImage = photo;
        weakSelf.avatarView.image = [photo imageByCircularScaleAndCrop:weakSelf.avatarView.frame.size];
        [weakSelf setUpdateButtonActivity];
   
}

- (void)setUpdateButtonActivity {
    
    BOOL activity = [self fieldsWereChanged];
    self.updateProfileButton.enabled = activity;
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)saveChanges:(id)sender {
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    [self.view endEditing:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    QBUUser *user = self.currentUser;
    user.status = self.statusTextCache;

    QBUpdateUserParameters *params = [QBUpdateUserParameters new];
    params.customData = self.currentUser.customData;
    params.fullName = self.fullNameFieldCache;
    params.phone = self.phoneFieldCache;
  //  params.status = self.statusTextCache;
    
    [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] updateCurrentUser:params image:self.avatarImage progress:^(float progress) {
        //
        [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
    } completion:^(BOOL success) {
        //
        if (success) {
            
       
            
            weakSelf.avatarImage = nil;
            [weakSelf updateProfileView];
            [weakSelf setUpdateButtonActivity];
        }
        [SVProgressHUD dismiss];
    }];
}

- (BOOL)fieldsWereChanged {
    
    if (self.avatarImage) return YES;
    if (![self.fullNameFieldCache isEqualToString:self.currentUser.fullName]) return YES;
    if (![self.phoneFieldCache isEqualToString:self.currentUser.phone ?: @""]) return YES;
    if (![self.statusTextCache isEqualToString:self.currentUser.status ?: @""]) return YES;
    
    return NO;
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.fullNameField) {
        self.fullNameFieldCache = str;
    } else if (textField == self.phoneNumberField) {
        self.phoneFieldCache = str;
    }
    
    [self setUpdateButtonActivity];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.statusTextCache = textView.text;
    [self setUpdateButtonActivity];
}

@end
