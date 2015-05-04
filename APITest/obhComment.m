//
//  obhComment.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhComment.h"

@implementation obhComment

- (id)initWithDictionary:(NSDictionary*) comments
{
    self = [super initWithDictionary:comments];
    if (self) {
        
        //from
        NSDictionary* from = [comments objectForKey:@"from"];
        self.username = [from objectForKey:@"username"];
        self.userProfilePictureURL = [from objectForKey:@"profile_picture"];
        
        //post id
        self.commentText = [comments objectForKey:@"text"];
        
        //created time
        [self convertUnixTime:[comments objectForKey:@"created_time"]];
        
    }
    return self;
}

- (void)convertUnixTime:(NSString*) time {
    
    NSDate *commentPostedDate = [[NSDate alloc] initWithTimeIntervalSince1970:[time intValue]];
    
    int interval = (int) [[NSDate date] timeIntervalSinceDate:commentPostedDate];
    
    if (interval / 3600 <= 0) {
        interval = (int) [[NSDate date] timeIntervalSinceDate:commentPostedDate] / 60;
        NSString *timePosted = [NSString stringWithFormat:@"%dm ago", interval];
        self.createdTime = timePosted;
    } else {
        interval = (int) [[NSDate date] timeIntervalSinceDate:commentPostedDate] / 3600;
        NSString *timePosted = [NSString stringWithFormat:@"%dh ago", interval];
        self.createdTime = timePosted;
    }
    
}


@end
