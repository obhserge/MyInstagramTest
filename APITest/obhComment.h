//
//  obhComment.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhServerObject.h"

@interface obhComment : obhServerObject

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* userProfilePictureURL;
@property (strong, nonatomic) NSString* createdTime;
@property (strong, nonatomic) NSString* commentText;

@end
