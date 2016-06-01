//
//  DataContainer.m
//  MyLink
//
//  Created by chen on 16/1/1.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "DataContainer.h"

#define TITLE_HEIGHT    30

@implementation DataContainer

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 5*2, 20)];
        //titleLabel.backgroundColor = [UIColor orangeColor];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
    }
    
    return self;
}

- (float)headerHeight
{
    return TITLE_HEIGHT;
}

- (void)setHeight:(float)height
{
    CGRect theRect = self.frame;
    theRect.size.height = height;
    self.frame = theRect;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect theRect = CGRectMake(1, 0, rect.size.width-2, rect.size.height-1);
    UIBezierPath *theRectPath = [UIBezierPath bezierPathWithRect:rect];
    theRectPath.lineWidth = 1.0;
    [[UIColor colorWithRed:52/255.0 green:72/255.0 blue:90/255.0 alpha:1.0] set];
    [theRectPath stroke];
    
    theRect = CGRectMake(0, 0, rect.size.width, TITLE_HEIGHT);
    UIBezierPath *theTitlePath = [UIBezierPath bezierPathWithRect:theRect];
    theTitlePath.lineWidth = 1.0;
    [[UIColor colorWithRed:52/255.0 green:72/255.0 blue:90/255.0 alpha:1.0] set];
    //[theTitlePath stroke];
    [theTitlePath fill];

}

@end
