//
//  obhServerObject.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface obhServerObject : NSObject

- (id)initWithServerResponse:(NSDictionary*) responseObject;

- (id)initWithDictionary:(NSDictionary*) comments;

@end
