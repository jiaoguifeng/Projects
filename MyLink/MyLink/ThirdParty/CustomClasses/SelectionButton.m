//
//  SelectionButton.m
//  MyLink
//
//  Created by chen on 16/1/14.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "SelectionButton.h"
#import "Utility.h"

@interface SelectionButton()
{
    UILabel *titleLabel;
}
@end

@implementation SelectionButton

@synthesize titleLabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        //self.layer.cornerRadius = 4;
        //self.layer.masksToBounds = YES;

        CGRect titleRect = CGRectMake(10, (frame.size.height-20)/2, frame.size.width - 10*2, 20);
        titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        //titleLabel.backgroundColor = [UIColor orangeColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:titleLabel];
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    if(enabled)
        titleLabel.textColor = [UIColor blackColor];
    else
        titleLabel.textColor = [UIColor darkGrayColor];
}

- (void)setButtonTitle:(NSString *)title
{
    titleLabel.text = title;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:0.3] set];
    //UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path fill];
    
    [[UIColor darkGrayColor] set];
    path = [UIBezierPath bezierPathWithRect:rect];
    path.lineWidth = 1.0;
    [path stroke];
}


@end
