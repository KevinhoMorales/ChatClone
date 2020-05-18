//
//  ABPerson.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ABPerson.h"

@interface ABPerson()

@property (assign, nonatomic) ABRecordID recordID;
@property (assign, nonatomic) ABAddressBookRef abRef;
@property (assign, nonatomic) ABRecordRef recordRef;

@end

@implementation ABPerson

- (instancetype)initWithRecordID:(ABRecordID)recordID addressBookRef:(ABAddressBookRef)addressBookRef {
    
    self = [super init];
    if (self) {
        _recordID = recordID;
        _abRef = CFRetain(addressBookRef);
    }
    return self;
}

- (ABRecordRef )recordRef {
    
    if (!_recordRef) {
        _recordRef = CFRetain(ABAddressBookGetPersonWithRecordID(_abRef, _recordID));
    }
    return _recordRef;
}

- (void)dealloc {
    
    if (_recordRef) CFRelease(_recordRef);
    if (_abRef) CFRelease(_abRef);
}

- (NSString *)stringFromProperty:(ABPropertyID)propertyID {
    
    CFStringRef ref = ABRecordCopyValue(self.recordRef, propertyID);
    
    if (!ref) return @"";
    
    NSString *string = (__bridge NSString *)ref;
    CFRelease(ref);
    
    return string;
}

- (NSString *)firstName {

    NSString *firstName = [self stringFromProperty:kABPersonFirstNameProperty];
    return firstName;
}

- (NSString *)lastName {

    NSString *lastName =  [self stringFromProperty:kABPersonFirstNameProperty];
    return lastName;
}

- (NSString *)middleName {
    
    NSString *middleName =  [self stringFromProperty:kABPersonFirstNameProperty];
    return middleName;
}

- (NSString *)nickName {

    NSString *nickName = [self stringFromProperty:kABPersonNicknameProperty];
    return nickName;
}
-(NSString *)PhoneNumber {
    
    ABMultiValueRef phoneMultiValue = ABRecordCopyValue(self.recordRef, kABPersonPhoneProperty);
    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phoneMultiValue, 0);
    NSString *phone = (__bridge NSString *)phoneNumberRef;
    
    if(phoneMultiValue){
        CFRelease(phoneMultiValue);
    }
    return phone;
}
-(NSArray *)phonenumbers {
    
    ABMultiValueRef phoneMultiValue = ABRecordCopyValue(self.recordRef, kABPersonPhoneProperty);
    CFArrayRef arrayRef = ABMultiValueCopyArrayOfAllValues(phoneMultiValue);
    NSArray *phonenumbers = (__bridge NSArray*)arrayRef;
    
    if(phoneMultiValue)
        CFRelease(phoneMultiValue);
    
    if (arrayRef) {
        CFRelease(arrayRef);
    }
    
    return phonenumbers;
}
- (NSString *)organizationProperty {

    NSString *organizationProperty = [self stringFromProperty:kABPersonOrganizationProperty];
    return organizationProperty;
}

- (NSString *)fullName {
    
    CFStringRef ref = ABRecordCopyCompositeName(self.recordRef);
    
    if (!ref) {
        return self.emails.firstObject;
    }
    
    NSString *fullTitle = (__bridge NSString *)ref;
    CFRelease(ref);
    
    return fullTitle;
}

- (UIImage *)image {
    
    if (!ABPersonHasImageData(self.recordRef)) return nil;
    CFDataRef imageData = ABPersonCopyImageData(self.recordRef);
    
    if (!imageData) return nil;
    
    NSData *data = (__bridge NSData *)imageData;
    UIImage *image = [UIImage imageWithData:data];
    CFRelease(imageData);
    
    return image;
}

- (NSArray *)emails {
    
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(self.recordRef, kABPersonEmailProperty);
    CFArrayRef arrayRef = ABMultiValueCopyArrayOfAllValues(emailMultiValue);
    NSArray *emailAddresses = (__bridge NSArray*)arrayRef;

    if(emailMultiValue)
        CFRelease(emailMultiValue);
    
    if (arrayRef) {
        CFRelease(arrayRef);
    }
    
    return emailAddresses;
}

- (BOOL)isEqual:(ABPerson *)other {
    BOOL equal = (other == self || self.recordID == other.recordID || [self.emails isEqualToArray:other.emails]) ? YES : NO;
    return equal;
//    return (other == self || self.recordID == other.recordID || [self.emails isEqualToArray:other.emails]) ? YES : NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self emails]];
}

@end
