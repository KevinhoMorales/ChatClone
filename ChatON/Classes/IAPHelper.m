//
//  IAPHelper.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import <Quickblox/Quickblox.h>
#import "QBApi.h"
#import "CallsHistoryVC.h"
#import "MainTabBarController.h"
#import "SettingsViewController.h"


NSString *const kSubscriptionExpirationDateKey = @"ExpirationDate";
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@implementation IAPHelper
{
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
    
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
//    VerificationController * verifier = [VerificationController sharedInstance];
//    [verifier verifyPurchase:transaction completionHandler:^(BOOL success) {
//        if (success) {
//            NSLog(@"Successfully verified receipt!");
            [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
//        } else {
//            NSLog(@"Failed to validate receipt.");
//            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
//        }
//    }];
}
-(NSString *)getExpiryDateString {
    if ([self daysRemainingOnSubscription] > 0) {
        NSDate *today = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSString *str = [NSString stringWithFormat:@"Subscribed! \nExpires: %@ (%i Days)",[dateFormat stringFromDate:today],[self daysRemainingOnSubscription]];
        NSLog(@"date format %@",str);
        return [NSString stringWithFormat:@"Subscribed! Expires: %@ (%i Days)",[dateFormat stringFromDate:today],[self daysRemainingOnSubscription]];
    } else {
        return @"Not Subscribed";
    }
}
- (int)daysRemainingOnSubscription {
    //1
    NSDate *expirationDate = [[NSUserDefaults standardUserDefaults]
                              objectForKey:kSubscriptionExpirationDateKey];
    
    //2
    NSTimeInterval timeInt = [expirationDate timeIntervalSinceDate:[NSDate date]];
    
    //3
    int days = timeInt / 60 / 60 / 24;
    
    //4
    if (days > 0) {
        return days;
    } else {
        return 0;
    }
}
- (NSDate *)getExpirationDateForMonths:(int)months {
    
    NSDate *originDate = nil;
    
    //1
    if ([self daysRemainingOnSubscription] > 0) {
        originDate = [[NSUserDefaults standardUserDefaults]
                      objectForKey:kSubscriptionExpirationDateKey];
    } else {
        originDate = [NSDate date];
    }
    
    //2
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setMonth:months];
    [dateComp setDay:1]; //add an extra day to subscription because we love our users
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                         toDate:originDate
                                                        options:0];
}
- (NSString *)getExpirationDateString {
    if ([self daysRemainingOnSubscription] > 0) {
        NSDate *today = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionExpirationDateKey];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        return [NSString stringWithFormat:@"Subscribed! \nExpires: %@ (%i Days)",[dateFormat stringFromDate:today],[self daysRemainingOnSubscription]];
    } else {
        return @"Not Subscribed";
    }
}
- (void)purchaseSubscriptionWithMonths:(int)months {
    //1
    
    QBUUser *user = self.currentUser;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/YYYY"];
    NSString *date_str = user.website;
    date_str = [date_str stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSDate *date = [dateFormat dateFromString:date_str];
    
    NSDate * serverDate = date;
    NSDate * localDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionExpirationDateKey];
    
    
    if ([serverDate compare:localDate] == NSOrderedDescending) {
        [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:kSubscriptionExpirationDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSDate * expirationDate = [self getExpirationDateForMonths:months];
    NSDateFormatter *dateFormat_ = [[NSDateFormatter alloc] init];
    [dateFormat_ setDateFormat:@"dd/MM/YYYY"];
    NSString *expdate = [dateFormat_ stringFromDate:expirationDate];
    
    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
    
    updateUserParams.website = expdate;
    
    [[QMApi instance] updateCurrentUser:updateUserParams image:nil progress:nil completion:^(BOOL success) {}];
    ;
    
    [[NSUserDefaults standardUserDefaults] setObject:expirationDate forKey:kSubscriptionExpirationDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Subscription Complete!");
    
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    if(skProducts.count > 0){
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    }
    
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"removeadskey"];
  
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    if ([productIdentifier isEqualToString:@"com.northysoftware.inapprage.randomragefaces"]) {
        
        int currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"com.northysoftware.inapprage.randomragefaces"];
        currentValue += 5;
        [[NSUserDefaults standardUserDefaults] setInteger:currentValue forKey:@"com.northysoftware.inapprage.randomragefaces"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([productIdentifier hasSuffix:@"monthlyrageface"]) {
        if ([productIdentifier isEqualToString:@"com.heelo.inapprage.12monthlyrageface"]) {
            [self purchaseSubscriptionWithMonths:12];
        }
    } else {
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}
- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
@end
