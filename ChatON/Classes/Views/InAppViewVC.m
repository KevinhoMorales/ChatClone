//
//  InAppViewVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "InAppViewVC.h"
#import "IAPHelper.h"
#import "RageIAPHelper.h"
#import <UIKit/UIKit.h>
#import "QBApi.h"

@interface InAppViewVC ()<UIPopoverPresentationControllerDelegate>
{
    NSArray *_products;

}
- (IBAction)RestorePurchase:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *buybtn;
@end

@implementation InAppViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.preferredContentSize = CGSizeMake(320, 400);
    self.buybtn.layer.cornerRadius = 4.0;
    // [self reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    
    [self reload];
    [self refresh];
    [self changebuttontitle];
}
- (void)reload {
    _products = nil;
    
    
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            if(products.count ==0){
                
            }
            else{
            _products = products;
            [self changebuttontitle];
            }
            
        }
       // [self.refreshControl endRefreshing];
    }];
}
-(void)changebuttontitle {
    
    IAPHelper * helper = [[IAPHelper alloc] init];
    
    SKProduct * product = (SKProduct *) _products[0];
    
    
    if ((![product.productIdentifier isEqualToString:@"com.northysoftware.inapprage.randomragefaces"] &&
         [[RageIAPHelper sharedInstance] productPurchased:product.productIdentifier] &&
         ![product.productIdentifier hasSuffix:@"monthlyrageface"]) || ([helper daysRemainingOnSubscription] > 0 && ![product.productIdentifier hasSuffix:@"monthlyrageface"])) {
        
    } else {
        
        if ([product.productIdentifier hasSuffix:@"monthlyrageface"]) {
            
            if ([helper daysRemainingOnSubscription] > 0) {
                
                [_buybtn setTitle:@"$1.99/For 1 Year(Renew)" forState:UIControlStateNormal];
                
                [_buybtn addTarget:self action:@selector(InAppAction:) forControlEvents:UIControlEventTouchUpInside];
                
                
            } else {
                
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"removeadskey"];
                [_buybtn setTitle:@"$1.99/For 1 Year " forState:UIControlStateNormal];
                
                [_buybtn addTarget:self action:@selector(InAppAction:) forControlEvents:UIControlEventTouchUpInside];
                
                
            }
            
        } else {
            
            [_buybtn setTitle:@"Buy" forState:UIControlStateNormal];
            
            [_buybtn addTarget:self action:@selector(InAppAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    
}
- (void)refresh {
    
    IAPHelper * helper = [[IAPHelper alloc] init];
    if ([helper daysRemainingOnSubscription] > 0) {
        self.label.text = [helper getExpiryDateString];
    } else {
        
        self.label.text = @"";
    }
}
- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            if ([product.productIdentifier hasSuffix:@"monthlyrageface"]) {
                [self reload];
              //  [self.refreshControl beginRefreshing];
            } else {
                // [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            *stop = YES;
        }
    }];
}
- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}
- (IBAction)InAppAction:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    
    if(_products!=nil)
    {
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    [[RageIAPHelper sharedInstance] buyProduct:product];
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

- (IBAction)RestorePurchase:(id)sender {
    
    
    NSDate *todaydate = [NSDate date];
    NSDateFormatter *df_ = [[NSDateFormatter alloc] init];
    [df_ setDateFormat:@"dd/MM/YYYY"];
    NSString *currentDate = [df_ stringFromDate:todaydate];
    NSLog(@"date str %@",self.currentUser.website);
    NSString *expiry_Date = self.currentUser.website;
   
    
    expiry_Date = [expiry_Date stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSDate *exp_date = [df_ dateFromString:expiry_Date];
     if ( [currentDate compare:expiry_Date] == NSOrderedAscending  || [currentDate compare:expiry_Date ] == NSOrderedSame ){
         
         [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
         UIAlertView *restorealert = [[UIAlertView alloc]
                                      initWithTitle:@"Restore"
                                      message:@"You Successfully restore your subscription"
                                      delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
         
         [restorealert show];
         
         [[NSUserDefaults standardUserDefaults] setObject:exp_date forKey:kSubscriptionExpirationDateKey];
         [[NSUserDefaults standardUserDefaults] synchronize];
         [self changebuttontitle];
         [self refresh];

         [[NSUserDefaults standardUserDefaults] setBool:
          YES forKey:@"removeadskey"];

     }
     else if ( [currentDate compare:expiry_Date] == NSOrderedDescending ) {
         
         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"removeadskey"];
         UIAlertView *restorealert = [[UIAlertView alloc]
                                      initWithTitle:@"Oops"
                                      message:@"Your Subscription expires"
                                      delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
         
         [restorealert show];
         
         
         
     }
     else {
         
         UIAlertView *restorealert = [[UIAlertView alloc]
                                      initWithTitle:@"Restore"
                                      message:@"There is no products purchased by you"
                                      delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
         
         [restorealert show];
     }
   
    
}
@end
