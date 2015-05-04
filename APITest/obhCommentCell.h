//
//  obhCommentCell.h
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface obhCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fromTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

+ (CGFloat)heightForText:(NSString*) text withFont:(UIFont*) font;

@end