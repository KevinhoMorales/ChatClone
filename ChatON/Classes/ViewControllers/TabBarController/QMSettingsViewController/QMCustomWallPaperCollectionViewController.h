//
//  QMCustomWallPaperCollectionViewController.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.


#import <UIKit/UIKit.h>

@interface QMCustomWallPaperCollectionViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
- (IBAction)setAction:(id)sender;
- (IBAction)CancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancel;

@property (weak, nonatomic) IBOutlet UIButton *setbtn;
@end
