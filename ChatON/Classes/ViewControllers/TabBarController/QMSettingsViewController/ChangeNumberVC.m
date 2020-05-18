//
//  ChangeNumberVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ChangeNumberVC.h"
#import "QBApi.h"
#import "SettingsManager.h"
//#import "libPhoneNumberiOS.h"

@interface ChangeNumberVC ()
@property (weak, nonatomic) IBOutlet UITextField *oldnumber;
@property (weak, nonatomic) IBOutlet UITextField *newnumber;
@property (weak, nonatomic) IBOutlet UIButton *changenumberbtn;
- (IBAction)changenumberaction:(id)sender;


@end

@implementation ChangeNumberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _oldnumber.text = self.currentUser.login;
    _changenumberbtn.layer.cornerRadius = 4.0;
    
    
    // Do any additional setup after loading the view.
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    
}
- (BOOL)validatePhone:(NSString *)phoneNumber
{
//    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
//    
//    
//        NSError *error = nil;
//        NBPhoneNumber *phoneNumberUS = [phoneUtil parse:phoneNumber defaultRegion:@"US" error:&error];
//        if (error) {
//            NSLog(@"err [%@]", [error localizedDescription]);
//        }
//    BOOL valid_num = [phoneUtil isValidNumber:phoneNumberUS];
//    BOOL possible_num = [phoneUtil isPossibleNumber:phoneNumberUS error:&error];
//    NSString *getregioncode = [phoneUtil getRegionCodeForNumber:phoneNumberUS];
//    
//    if(valid_num == 1 && possible_num == 1  && getregioncode!=NULL){
//        
//        NSLog(@"- isValidNumber [%@]", [phoneUtil isValidNumber:phoneNumberUS] ? @"YES" : @"NO");
//        NSLog(@"- isPossibleNumber [%@]", [phoneUtil isPossibleNumber:phoneNumberUS error:&error] ? @"YES" : @"NO");
//        NSLog(@"- getRegionCodeForNumber [%@]", [phoneUtil getRegionCodeForNumber:phoneNumberUS]);
//        return YES;
//        
//    }
//    else{
//       
//        
//        UIAlertController *alertController = [UIAlertController
//                                              alertControllerWithTitle:@"Wrong Number Format"
//                                              message: @"Please enter your number in correct format +(countrycode)(numberdigits)"
//                                              preferredStyle:UIAlertControllerStyleAlert];
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
//                                                            style:UIAlertActionStyleCancel
//                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
//                                                              
//                                                          }]];
//
//        
//        [self presentViewController:alertController animated:YES completion:nil];
//
//        
        return NO;
  //  }

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)changenumberaction:(id)sender {
    
//    BOOL isnumbervalid;
//   isnumbervalid =  [self validatePhone:_newnumber.text];
//    if(isnumbervalid ){
//        
//        NSString *stringWithoutplus = [_newnumber.text
//                                         stringByReplacingOccurrencesOfString:@"+" withString:@""];
//        QBUUser *user = self.currentUser;
//        user.login = _newnumber.text;
//        user.fullName = stringWithoutplus;
//        user.phone = stringWithoutplus;
//        
//        QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
//        updateUserParams.fullName = user.fullName;
//        updateUserParams.login = user.login;
//        
//        
//        [[QMApi instance] updateCurrentUser:updateUserParams image:nil progress:nil completion:^(BOOL success) {
//        
//            if(success){
//                NSLog(@"Number Change");
//                UIAlertController *alertController = [UIAlertController
//                                                      alertControllerWithTitle:@"Success"
//                                                      message: @"Number Change Successfully"
//                                                      preferredStyle:UIAlertControllerStyleAlert];
//                
//                [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
//                                                                    style:UIAlertActionStyleCancel
//                                                                  handler:^(UIAlertAction * _Nonnull __unused action) {
//                                                                      
//                                                                  }]];
//                
//                
//                [self presentViewController:alertController animated:YES completion:nil];
//                
//            }
//        }];
//        
//        
//        ;
//    }
   // NSLog(@"valid number : %d",checknumber);
}
@end
