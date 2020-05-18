//
//  AddressBook.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AddressBookResult)(NSArray *contacts, BOOL success, NSError *error);

@interface AddressBook : NSObject

+ (void)getAllContactsFromAddressBook:(AddressBookResult)block;
+ (void)getContactsWithEmailsWithCompletionBlock:(AddressBookResult)block;

@end
