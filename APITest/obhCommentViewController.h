//
//  obhCommentViewController.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface obhCommentViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSString* mediaID;

@end
