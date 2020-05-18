//
//  QMNotificationSettingsVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMNotificationSettingsVC.h"
#import "QBApi.h"
#import "SettingsManager.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"

@interface QMNotificationSettingsVC ()
@property (weak, nonatomic) IBOutlet UISwitch *MessageSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *messageSoundcell;
@property (weak, nonatomic) IBOutlet UILabel *messageSoundname;
@property (weak, nonatomic) IBOutlet UISwitch *groupMessageSwitch;

@property (weak, nonatomic) IBOutlet UITableViewCell *groupMessagecell;
@property (weak, nonatomic) IBOutlet UILabel *groupMessageSound;
@property (weak, nonatomic) IBOutlet UISwitch *PreviewSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *ResetSettings;

@end

@implementation QMNotificationSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.MessageSwitch.on = [QMApi instance].settingsManager.pushNotificationsEnabled;
    self.groupMessageSwitch.on = [QMApi instance].settingsManager.pushNotificationsEnabled;

}
- (IBAction)ResetSettings:(id)sender {
    
    if(!_groupMessageSwitch.isOn){
        [_groupMessageSwitch setOn:YES];
    }
    if(!_MessageSwitch.isOn){
        [_MessageSwitch setOn:YES];
    }
    if(!_PreviewSwitch.isOn){
        [_PreviewSwitch setOn:YES];
    }
    self.messageSoundname.text = @"Note";
     self.groupMessageSound.text = @"Note";
}

-(void)viewWillAppear:(BOOL)animated{
    
   // [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"soundname"];
    NSString *sound_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundname"];
    NSString *group_soundname = [[NSUserDefaults standardUserDefaults] objectForKey:@"groupsoundname"];
    
    if(sound_name == nil){
        
        self.messageSoundname.text = @"Note";
    }
    else{
         self.messageSoundname.text = sound_name;
    }
    if(group_soundname == nil){
        
        self.groupMessageSound.text = @"Note";
    }
    else{
        self.groupMessageSound.text = group_soundname;
    }
    
}
- (IBAction)MessageNotSwitch:(id)sender {
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        self.MessageSwitch.on = !self.MessageSwitch.on;
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if ([sender isOn]) {
        [[QMApi instance] subscribeToPushNotificationsForceSettings:YES complete:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
    else {
        [[QMApi instance] unSubscribeToPushNotifications:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
}
- (IBAction)GroupNotiSwitch:(id)sender {
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        self.groupMessageSwitch.on = !self.groupMessageSwitch.on;
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if ([sender isOn]) {
        [[QMApi instance] subscribeToPushNotificationsForceSettings:YES complete:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
    else {
        [[QMApi instance] unSubscribeToPushNotifications:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
 
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor grayColor]];
    if(section == 2){
        
        [header.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
    }
    else {
        [header.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    }
   
    
    
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
