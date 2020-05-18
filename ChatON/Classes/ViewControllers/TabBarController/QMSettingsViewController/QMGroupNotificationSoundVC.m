//
//  QMGroupNotificationSoundVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupNotificationSoundVC.h"
#import "SoundManager.h"

@interface QMGroupNotificationSoundVC ()
{
    NSMutableArray *sounds;
    NSInteger selectedindex;
}
@end

@implementation QMGroupNotificationSoundVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sounds = [NSMutableArray arrayWithObjects:@"Note.mp3",@"Advantage.mp3",@"Bird.mp3",@"Birds Chirping.mp3",@"Broken Spring.mp3",@"Confused Bird.mp3",@"Darling's Message.mp3",@"Doorbell.mp3",@"Fast Car.mp3",@"Guitar Strings.mp3",@"Hard Wood.mp3",@"Horn.mp3",@"Incoming Message.mp3",@"Jingle Bells.mp3",@"Lift.mp3",@"Never Mind.mp3",@"Notification.mp3",@"Sneezing.mp3",@"Solemn.mp3",@"Sparkled Magic.mp3",@"Suspicion.mp3",@"The Wrong Spring.mp3",@"Triplet.mp3",@"Uh Oh!.mp3",@"Warning.mp3",@"Weightlifting.mp3",@"Whistle.mp3",@"Who Are You_.mp3",@"You Have a Text Message.mp3", nil];
    
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return sounds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupcellsound" forIndexPath:indexPath];
    
    if(indexPath.row == selectedindex)
    {
        
        [[SoundManager sharedManager] playSound:sounds[indexPath.row] looping:NO];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        [[SoundManager sharedManager] stopSound:sounds[indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *sound_name = [sounds objectAtIndex:indexPath.row];
    NSArray *str = [sound_name componentsSeparatedByString:@"." ];
    cell.textLabel.text = [str objectAtIndex:0];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString *sound_name = [sounds objectAtIndex:indexPath.row];
    NSArray *str = [sound_name componentsSeparatedByString:@"." ];
    [[NSUserDefaults standardUserDefaults] setObject:[str objectAtIndex:0] forKey:@"groupsoundname"];
    
    //    QBUUser *user = [QMApi instance].currentUser;
    //
    //    NSMutableArray *data = user.tags;
    //
    //    [data addObject:sound_name];
    //    user.tags = data;
    //    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
    //    updateUserParams.tags = user.tags;
    //
    //    [[QMApi instance] updateCurrentUser:updateUserParams image:nil progress:nil completion:^(BOOL success) {}];
    ;
    
    selectedindex = indexPath.row;
    [tableView reloadData];
    
}



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
