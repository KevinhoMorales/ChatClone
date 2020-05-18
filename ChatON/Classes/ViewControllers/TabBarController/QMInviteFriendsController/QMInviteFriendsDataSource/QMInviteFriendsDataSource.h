//
//  QMInviteFriendsDataSource.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//


@protocol QMCheckBoxStateDelegate <NSObject>
@optional
- (void)checkListDidChangeCount:(NSInteger)checkedCount;
@end



@interface QMInviteFriendsDataSource : NSObject

@property (weak, nonatomic) id <QMCheckBoxStateDelegate> checkBoxDelegate;
@property (weak, nonatomic) NSArray *search;
@property (weak, nonatomic) NSArray *allusers;

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)emailsToInvite;
- (void)clearABFriendsToInvite;
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller;
-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
@end
