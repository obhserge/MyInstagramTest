//
//  obhLoginViewController.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class obhAccessToken;

typedef void(^obhLoginCpmpletionBlock)(obhAccessToken* token);

@interface obhLoginViewController : UIViewController

- (id)initWithCompletionBlock:(obhLoginCpmpletionBlock) completionBlock;

@end
