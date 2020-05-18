//
//  QMCustomWallPaperCollectionViewController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCustomWallPaperCollectionViewController.h"
#import "CollectionViewCell.h"

@interface QMCustomWallPaperCollectionViewController ()
{
    NSMutableArray *wallpapers;
}
@property (weak, nonatomic) UIViewController *currentlyPresentedViewController;

@end

@implementation QMCustomWallPaperCollectionViewController

static NSString * const reuseIdentifier = @"newwallpapercell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.cancel.hidden = YES;
    self.setbtn.hidden = YES;
    wallpapers = [NSMutableArray array];
    for(int i =0; i< 38; i++){
    
        [wallpapers addObject:[NSString stringWithFormat:@"wallpapers%d.jpg",i+1]];
      

    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
   
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return wallpapers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    UIImage *image = [UIImage imageNamed:wallpapers[indexPath.row]];
    
    cell.newcellimage.image = image;
    
    //UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    //recipeImageView.image = [UIImage imageNamed:[wallpapers objectAtIndex:indexPath.row]];
    
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.cancel.hidden = NO;
    self.setbtn.hidden = NO;
    
    
    NSLog(@"selected wallpaper %@",wallpapers[indexPath.row]);
    [[NSUserDefaults standardUserDefaults] setObject:wallpapers[indexPath.row] forKey:@"chatbackground"];
    
    
}


- (IBAction)setAction:(id)sender {
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatbackground"];
    if(str!=nil){
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Success"
                                              message: @"Wallpaper Changed"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              
                                                          }]];
        
        
        [self presentViewController:alertController animated:YES completion:nil];

        
    }
}

- (IBAction)CancelAction:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
  // [_currentlyPresentedViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
