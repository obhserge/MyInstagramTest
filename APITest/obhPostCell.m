//
//  obhPostCell.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhPostCell.h"

@implementation obhPostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (CGFloat)heightForText:(NSString*) text withFont:(UIFont*) font{
    
    CGFloat offset = 5.0f;
    
    //UIFont* font = [UIFont systemFontOfSize:17.f];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentCenter];
    
    
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          font, NSFontAttributeName,
                          paragraph, NSParagraphStyleAttributeName,
                          shadow, NSShadowAttributeName, nil];
        
    CGRect rect = [text boundingRectWithSize:CGSizeMake(320 - 2*offset, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attr
                                     context:nil];
    
    
    
    return CGRectGetHeight(rect) + 2*offset;
    
}
@end
