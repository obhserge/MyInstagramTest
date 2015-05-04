//
//  UIView+UITableViewCell.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "UIView+UITableViewCell.h"

@implementation UIView (UITableViewCell)

- (UITableViewCell*) superCell {
    
    if (!self.superview) {
        return Nil;
    }
    
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell*)self.superview;
    }
    
    return [self.superview superCell];
    
} 

@end
