//
//  ABPerson.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ABPerson : NSObject

@property (strong, nonatomic, readonly) NSString *firstName;
@property (strong, nonatomic, readonly) NSString *lastName;
@property (strong, nonatomic, readonly) NSString *middleName;
@property (strong, nonatomic, readonly) NSString *nickName;
@property (strong, nonatomic, readonly) UIImage *image;
@property (strong, nonatomic, readonly) NSArray *emails;
@property (strong, nonatomic, readonly) NSArray *phonenumbers;
@property (strong, nonatomic, readonly) NSString *PhoneNumber;
@property (strong, nonatomic, readonly) NSString *organizationProperty;
@property (strong, nonatomic, readonly) NSString *fullName;

- (instancetype)initWithRecordID:(ABRecordID)recordID addressBookRef:(ABAddressBookRef)addressBookRef;

@end
