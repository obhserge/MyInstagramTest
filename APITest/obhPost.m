//
//  obhPost.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhPost.h"

@implementation obhPost

- (id)initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        //user
        NSDictionary* user = [responseObject objectForKey:@"user"];
        self.username = [user objectForKey:@"username"];
        self.userProfilePictureURL = [user objectForKey:@"profile_picture"];
        
        //post id
        self.postID = [responseObject objectForKey:@"id"];
        
        //caption
        
        NSDictionary* caption = [responseObject objectForKey:@"caption"];
        if (![caption isEqual:[NSNull null]]) {
            NSString* text = [caption objectForKey:@"text"];
            if (![text isEqualToString:@""]) {
                self.postText = text;
            } else {
                self.postText = @"none text";
            }
            
        } else {
            self.postText = @"none text";
        }
        
        
        //likes
        NSDictionary* likes = [responseObject objectForKey:@"likes"];
        if (![likes isEqual:[NSNull null]]) {
            
            int likesCount = [[likes objectForKey:@"count"] intValue];
            NSString *strLikesCount = [@(likesCount) stringValue];
            self.likesCount = strLikesCount;
        } else {
            self.likesCount = @"0";
        }
        
        //comments
        NSDictionary* comments = [responseObject objectForKey:@"comments"];
        self.comments = comments;
        
        //created time
        [self convertUnixTime:[responseObject objectForKey:@"created_time"]];
        
        //images
        NSDictionary* images = [responseObject objectForKey:@"images"];
        NSDictionary* standartResolutionImage = [images objectForKey:@"standard_resolution"];
        self.standardResolutionImageURL = [standartResolutionImage objectForKey:@"url"];
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
