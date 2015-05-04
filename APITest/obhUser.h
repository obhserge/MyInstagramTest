//
//  obhUser.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhServerObject.h"

@interface obhUser : obhServerObject

@property (strong, nonatomic) NSString* bio;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) NSURL* profilePictureURL;

@end
