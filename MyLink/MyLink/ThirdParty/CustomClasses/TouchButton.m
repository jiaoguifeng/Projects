//
//  TouchButton.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "TouchButton.h"

#define BUTTON_IMAGE_SIZE   50
#define BUTTON_TITLE_HEIGHT 10

@interface TouchButton()
{
    BOOL needFillColor;
    
    UIImageView *btnImage;
    UILabel *btnTitle;
}
@end

@implementation TouchButton

@synthesize buttonID,buttonTag,bgColor,buttonImage,buttonTitle,delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        needFillColor = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        buttonID = TOUCH_BUTTON_NONE;
        
        buttonID = -1;
        
        /*btnImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - BUTTON_IMAGE_SIZE)/2,
                                                                 (self.frame.size.height - BUTTON_IMAGE_SIZE)/2 - 10,
                                                                 BUTTON_IMAGE_SIZE, BUTTON_IMAGE_SIZE)];*/
        float theButtonWidth = self.frame.size.width/2;
        if(self.frame.size.width > self.frame.size.height)
            theButtonWidth = self.frame.size.height/2;
        btnImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - theButtonWidth)/2,
                                                                 (self.frame.size.height - theButtonWidth)/2 - 10,
                                                                 theButtonWidth, theButtonWidth)];
        [self addSubview:btnImage];
        
        btnTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, btnImage.frame.origin.y + btnImage.frame.size.height,
                                                             self.frame.size.width, BUTTON_TITLE_HEIGHT)];
        btnTitle.textAlignment = NSTextAlignmentCenter;
        //btnTitle.backgroundColor = [UIColor lightGrayColor];
        btnTitle.textColor = [UIColor whiteColor];
        btnTitle.font = [UIFont systemFontOfSize:10.0];
        [self addSubview:btnTitle];

        //
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressed:)];
        [self addGestureRecognizer:longGesture];

    }
    
    return self;
}

- (void)setBgColor:(UIColor *)_bgColor
{
    [self setBackgroundColor:_bgColor];
}

- (void)setButtonImage:(NSString *)_buttonImage
{
    btnImage.image = [UIImage imageNamed:_buttonImage];
}

- (void)setButtonTitle:(NSString *)_buttonTitle
{
    btnTitle.text = _buttonTitle;
}

#pragma mark - single tap

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesBegan...");
    needFillColor = YES;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesMoved...");
    needFillColor = YES;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesEnded...");
    needFillColor = NO;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //NSLog(@"touchesCancelled...");
    needFillColor = NO;
    [self setNeedsDisplay];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    //NSLog(@"Clicked...");
    [delegate buttonSinglePressed:buttonID buttonTag:buttonTag];
}

#pragma mark - long press

- (void)handleLongPressed:(UILongPressGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"long press began...");
        [delegate buttonLongPressed:buttonID buttonTag:buttonTag];
    }
    else if(sender.state == UIGestureRecognizerStateChanged)
    {
        //NSLog(@"long press changed...");
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        //NSLog(@"long press ended...");
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(needFillColor)
    {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3].CGColor);
        CGContextAddRect(context,rect);
        CGContextFillPath(context);
    }
    
}


@end
