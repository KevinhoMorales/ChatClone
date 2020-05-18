//
// Created by QuickBlox team on 14/12/2013.
// Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBRequest.h"

@class QBResponse;
@class QBASession;
@class QBSessionParameters;
@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

@interface QBRequest (QBAuth)

//MARK: - App authorization

/**
 Session Destroy
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)destroySessionWithSuccessBlock:(nullable void (^)(QBResponse *response))successBlock
                                   errorBlock:(nullable QBRequestErrorBlock)errorBlock;

//MARK: - LogIn

/**
 User LogIn with login
 
 @param login Login of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithUserLogin:(NSString *)login
                         password:(NSString *)password
                     successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                       errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 User LogIn with email
 
 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithUserEmail:(NSString *)email
                         password:(NSString *)password
                     successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                       errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 User LogIn with social provider's token
 
 @param provider Social provider. Posible values: facebook, twitter.
 @param accessToken Social provider access token.
 @param accessTokenSecret Social provider access token secret.
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithSocialProvider:(NSString *)provider
                           accessToken:(nullable NSString *)accessToken
                     accessTokenSecret:(nullable NSString *)accessTokenSecret
                          successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                            errorBlock:(nullable QBRequestErrorBlock)errorBlock;

/**
 User login using Firebase (only phone number. See https://firebase.google.com/docs/auth/ios/phone-auth).
 
 @param projectID Firebase project ID
 @param accessToken Access token
 @param successBlock Block with response and user instances if request succeded.
 @param errorBlock Block with response instance if request failed.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithFirebaseProjectID:(NSString *)projectID
                              accessToken:(NSString *)accessToken
                             successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                               errorBlock:(nullable QBRequestErrorBlock)errorBlock;


//MARK: - LogOut

/**
 LogOut current user
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logOutWithSuccessBlock:(nullable void (^)(QBResponse *response))successBlock
                           errorBlock:(nullable QBRequestErrorBlock)errorBlock;

//MARK: - Create User

/**
 User sign up
 
 @param user User to signup
 @param successBlock Block with response and user instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)signUp:(QBUUser *)user
         successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
           errorBlock:(nullable QBRequestErrorBlock)errorBlock;

// MARK: - DEPRECATED

/**
 *  User login using Twitter Digits.
 *
 *  @param headers      Taken from '-[DGTOAuthSigning OAuthEchoHeadersToVerifyCredentials]'.
 *  @param successBlock Block with response and user instances if request succeded.
 *  @param errorBlock   Block with response instance if request failed.
 *  @warning Deprecated in 2.9.3 Use 'logInWithFirebaseProjectID:accessToken:successBlock:errorBlock:'.
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)logInWithTwitterDigitsAuthHeaders:(NSDictionary *)headers
                                    successBlock:(nullable void (^)(QBResponse *response, QBUUser * _Nullable user))successBlock
                                      errorBlock:(nullable QBRequestErrorBlock)errorBlock
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.9.3 Use 'logInWithFirebaseProjectID:accessToken:successBlock:errorBlock:'.");

@end

NS_ASSUME_NONNULL_END