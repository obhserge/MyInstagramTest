//
//  obhUser.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhUser.h"

@implementation obhUser

- (id)initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        self.username = [responseObject objectForKey:@"username"];
        self.fullName = [responseObject objectForKey:@"full_name"];
        self.bio = [responseObject objectForKey:@"bio"];
        self.userID = [responseObject objectForKey:@"id"];
        
        NSString* urlString = [responseObject objectForKey:@"profile_picture"];
        
        if (urlString) {
            self.profilePictureURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}

@end
