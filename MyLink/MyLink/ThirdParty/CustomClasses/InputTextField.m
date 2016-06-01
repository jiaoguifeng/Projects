//
//  InputTextField.m
//  MyLink
//
//  Created by chen on 16/1/14.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "InputTextField.h"

@implementation InputTextField


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

- (CGRect)textRectForBounds:(CGRect)bounds
{
    float delta = 10.0;
    CGRect inset = CGRectMake(bounds.origin.x + delta, bounds.origin.y, bounds.size.width - delta, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    float delta = 10.0;
    CGRect inset = CGRectMake(bounds.origin.x + delta, bounds.origin.y, bounds.size.width - delta, bounds.size.height);
    return inset;
}

- (void)setEnabled:(BOOL)enabled
{
    if(enabled)
        self.textColor = [UIColor blackColor];
    else
        self.textColor = [UIColor darkGrayColor];
}

@end
