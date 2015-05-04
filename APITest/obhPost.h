//
//  obhPost.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhServerObject.h"

@interface obhPost : obhServerObject

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* standardResolutionImageURL;
@property (strong, nonatomic) NSString* userProfilePictureURL;
@property (strong, nonatomic) NSString* createdTime;
@property (strong, nonatomic) NSString* likesCount;
@property (strong, nonatomic) NSString* postID;
@property (strong, nonatomic) NSString* postText;
@property (strong, nonatomic) NSDictionary* comments;

@end
