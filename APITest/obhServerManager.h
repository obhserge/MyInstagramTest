//
//  obhServerManager.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class obhUser, obhAccessToken;

@interface obhServerManager : NSObject <NSURLConnectionDelegate>

@property (strong, nonatomic, readonly) obhUser* currentUser;

+ (obhServerManager*)sharedManager;

- (void)authorizeUser:(void(^)(obhUser* user)) completion;

- (void)getUser:(NSString*) userID
      onSuccess:(void(^)(obhUser* user)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure;

- (void)getSelfFeedWithCount:(NSInteger) count
                       maxID:(NSString*) maxID
                       minID:(NSString*) minID
                   onSuccess:(void(^)(NSArray* posts)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure;

- (void)getCommentsWithMediaID:(NSString*) mediaID
                     onSuccess:(void(^)(NSArray* comments)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure;

- (void)postComment:(NSString*) text
            onMedia:(NSString*) mediaID
          onSuccess:(void(^)(id result)) success
          onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure;

- (void)postCode:(NSString*) code
       onSuccess:(void(^)(obhAccessToken *token)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure;

//4802292
@end
