//
//  CallsHistoryVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "CallsHistoryVC.h"
#import "QMUsersMemoryStorage.h"
#import "QBApi.h"
#import "CallListCell.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"
#import "QBApi.h"
#import "SettingsManager.h"
#import "QMImageView.h"
#import "UsersUtils.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Macro.h"

@interface CallsHistoryVC ()

@property (strong, nonatomic) QMUsersMemoryStorage *usersMemoryStorage;
@property (strong,nonatomic) NSMutableArray* calllist;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)clearcallLog:(id)sender;
@property (strong, nonatomic)  UILabel *nocalls;

@end

@implementation CallsHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
      self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
 
    

    
   
    // Do any additional setup after loading the view.
}
-(void)loadbanner {
   // [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"removeadskey"];
    
    
    BOOL removeads = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeadskey"];
    if(removeads == YES){
        
        
        [self.bannerview removeFromSuperview];
        [_bannerview setHidden:YES];
        _bannerview.frame = CGRectMake(0, 0, 0, 0);
        _bannerview = nil;
        _bannerview.delegate = nil;
        _bannerview.rootViewController = nil;
        [self.view setNeedsDisplay];
        
    }
    else{
        
        _bannerview = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _bannerview.adUnitID = @"ca-app-pub-4057351632708751/7502560433";
        [_bannerview loadRequest:[GADRequest request]];
        _bannerview.delegate = self;
        _bannerview.rootViewController = self;
        if(IS_IPHONE_5){
            
            _bannerview.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2+190, 420, 50);
        }
        else if(IS_IPHONE_6){
            _bannerview.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2+235, 420, 50);
        }
        else if(IS_IPHONE_6P){
            _bannerview.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2+270, 420, 50);
        }
        
        [self.view addSubview:_bannerview];
        
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    
    [self loadbanner];
   
    QBUUser *user = self.currentUser;
    
    _calllist = [[QMApi instance] usercalllist:user];
    if(_calllist.count == 0){
        
        _nocalls = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-70, self.view.frame.size.height/2-80, 200, 200)];
        _nocalls.text = @"No Recent Calls";
        _nocalls.textColor = [UIColor darkGrayColor];
        [self.view addSubview:_nocalls];
       
    }
    else{
         _nocalls.text = @"";
        _nocalls.hidden = YES;
        [self.view addSubview:_nocalls];
        [self.tableview reloadData];
    }
   
    NSLog(@"callslist %@",_calllist);
}
-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    
       NSLog(@"Banner loading error: %@", error.description);
}
-(void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    
    NSLog(@"banner ad recieved");
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  _calllist.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CallListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Listcell" forIndexPath:indexPath];
    
    NSDictionary *dic = [_calllist objectAtIndex:indexPath.row];

    NSString *callform = dic[@"callform"];
    NSString *calltypeimage = dic[@"calltype"];
    NSString *calldate = dic[@"calldate"];
    
    if([callform isEqualToString:@"Audio"] ){
        
       
        NSData *userdata = dic[@"user"];
        QBUUser * oponentuser = [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
        cell.profilepic.imageViewType = QMImageViewTypeCircle;
        UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
        NSURL *url = [UsersUtils userAvatarURL:oponentuser];
        
        [cell.profilepic setImageWithURL:url
                             placeholder:placeholder
                                 options:SDWebImageHighPriority
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                                } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    
                                    
                                }];
        cell.callername.text = oponentuser.fullName;
    }
    if([callform isEqualToString:@"Video"] && [calltypeimage isEqualToString:@"INCOMING CALL"] ){
        
        
        NSData *userdata = dic[@"user"];
        QBUUser * oponentuser = [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
        cell.profilepic.imageViewType = QMImageViewTypeCircle;
        UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
        NSURL *url = [UsersUtils userAvatarURL:oponentuser];
        
        [cell.profilepic setImageWithURL:url
                             placeholder:placeholder
                                 options:SDWebImageHighPriority
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                                } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    
                                    
                                }];
        cell.callername.text = oponentuser.fullName;
    }
    
    if([callform isEqualToString:@"Video"] && [calltypeimage isEqualToString:@"OUTGOING CALL"]){
        
        NSData *userdata = dic[@"user"];
        NSMutableArray * oponentuser = [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
         NSString *chatName = [self chatNameFromUserNames:oponentuser];
        
        NSURL *url = [NSURL URLWithString:@""];
        
        UIImage *placeholder = [UIImage imageNamed:@"group_placeholder"];
        
        [cell.profilepic setImageWithURL:url
                                  placeholder:placeholder
                                      options:SDWebImageHighPriority
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                         ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                                     } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                         
                                     }];
        [cell.profilepic setImageViewType:QMImageViewTypeCircle];
        cell.callername.text = chatName;
    }
    
   
    
   
    if([calltypeimage  isEqual: @"OUTGOING CALL"]){
        
        cell.calltypeimage.image = [UIImage imageNamed:@"outgoingcall"];
    }
    else if([calltypeimage isEqualToString:@"INCOMING CALL"]){
        
        cell.calltypeimage.image = [UIImage imageNamed:@"incomingcall"];
    }
    cell.calltime.text = calldate;
    if([callform isEqualToString:@"Audio"]){
        
        [cell.calltype setImage:[UIImage imageNamed:@"audiocall"] forState:UIControlStateNormal];
        
    }
    else if([callform isEqualToString:@"Video"]){
        
       [cell.calltype setImage:[UIImage imageNamed:@"videocall"] forState:UIControlStateNormal];
    }
    
    return cell;
    
}
- (NSString *)chatNameFromUserNames:(NSMutableArray *)users {
    
    if(users == nil){
        return nil;
    }
    else{
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [names addObject:user.fullName];
    }
    
    [names addObject:[QMApi instance].currentUser.fullName];
    return [names componentsJoinedByString:@", "];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView  didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSDictionary *dic = [_calllist objectAtIndex:indexPath.row];
     NSString *callform = dic[@"callform"];
    if([callform isEqualToString:@"Audio"]){
        
        NSData *userdata = dic[@"user"];
        QBUUser * oponentuser = [NSKeyedUnarchiver unarchiveObjectWithData:userdata];
         [[QMApi instance] callToUser:@(oponentuser.ID) conferenceType:QBRTCConferenceTypeAudio];
        
    }
    if([callform isEqualToString:@"Video"]){
        
        [self performSegueWithIdentifier:@"selectusers" sender:nil];
    }
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    

    if([segue.identifier isEqualToString:@"selectusers"]){
        
        VideoCallUsersSelection *cs = segue.destinationViewController;
        // [cs callWithConferenceType:QBRTCConferenceTypeVideo];
    }
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clearcallLog:(id)sender {
    
    [_calllist removeAllObjects];
     [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.currentUser.fullName];
    [self.tableview reloadData];
    _nocalls = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-70, self.view.frame.size.height/2-80, 200, 200)];
    _nocalls.text = @"No Recent Calls";
    _nocalls.textColor = [UIColor darkGrayColor];
    [self.view addSubview:_nocalls];
    
    
}
@end
