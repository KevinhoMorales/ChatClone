//
//  LicenseAgreementVC.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LicenceCompletionBlock)(BOOL accepted);

@interface LicenseAgreementVC : UIViewController

@property (copy, nonatomic) LicenceCompletionBlock licenceCompletionBlock;

@end
