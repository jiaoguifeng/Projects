//
//  BadgeButton.m
//  MyLink
//
//  Created by chen on 15/12/31.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "BadgeButton.h"

@interface BadgeButton()
{
    UIImageView *badgeImage;
    UILabel *badgeNumberLabel;
}

@end

@implementation BadgeButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        badgeImage = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 18, 0, 18, 18)];
        badgeImage.contentMode = UIViewContentModeScaleAspectFit;
        badgeImage.backgroundColor = [UIColor colorWithRed:193/255.0 green:38/255.0 blue:52/255.0 alpha:1.0];
        //badgeImage.backgroundColor = [UIColor redColor];
        badgeImage.layer.masksToBounds = YES;
        badgeImage.layer.cornerRadius = badgeImage.frame.size.width*0.5;
        badgeImage.layer.borderWidth = 1.0;
        badgeImage.layer.borderColor = [UIColor clearColor].CGColor;
        [self addSubview:badgeImage];
        
        badgeNumberLabel = [[UILabel alloc] initWithFrame:badgeImage.bounds];
        badgeNumberLabel.textAlignment = NSTextAlignmentCenter;
        badgeNumberLabel.textColor = [UIColor whiteColor];
        badgeNumberLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [badgeImage addSubview:badgeNumberLabel];
        
        [self setBadgeNumber:0];
    }
    
    return self;
}

- (void)setBadgeNumber:(NSInteger)number
{
    if(number == 0)
        badgeImage.hidden = YES;
    else
    {
        badgeImage.hidden = NO;
        if(number >= 10)
            badgeNumberLabel.font = [UIFont boldSystemFontOfSize:10.0];
        else
            badgeNumberLabel.font = [UIFont boldSystemFontOfSize:13.0];
        
        badgeNumberLabel.text = [[NSNumber numberWithInteger:number] stringValue];
    }
}

@end
