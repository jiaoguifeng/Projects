//
//  PopButtonView.m
//  EasyWIFI
//
//  Created by chen on 5/8/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "PopButtonView.h"

#define POPVIEW_HEIGHT  60
#define POPVIEW_BUTTON_INTERVAL 10

#define POPVIEW_BUTTON_X    10
#define POPVIEW_BUTTON_Y    10
#define POPVIEW_BUTTON_W    30
#define POPVIEW_BUTTON_H    30

#define POPVIEW_LABEL_X     10
#define POPVIEW_LABEL_Y     40
#define POPVIEW_LABEL_W     30
#define POPVIEW_LABEL_H     10

@interface PopButtonView()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *tagArray;
@property (nonatomic) CGPoint showPoint;

@property (nonatomic, strong) UIButton *handerView;

@end


@implementation PopButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images tags:(NSArray *)tags
{
    self = [super init];
    if (self)
    {
        self.showPoint = point;
        self.titleArray = titles;
        self.imageArray = images;
        self.tagArray = tags;
        
        self.frame = [self getViewFrame];
        [self addSubButtons];
    }
    return self;
}

- (CGRect)getViewFrame
{
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y = self.showPoint.y;
    frame.size.width = [UIApplication sharedApplication].keyWindow.frame.size.width;
    frame.size.height = POPVIEW_HEIGHT;
    
    return frame;
}

- (void)addSubButtons
{
    float startX = 0;
    long buttonCount = [self.imageArray count];
    startX = (self.frame.size.width - (buttonCount*POPVIEW_BUTTON_W + (buttonCount-1)*POPVIEW_BUTTON_INTERVAL))/2;
    
    long i = 0;
    for(i = 0; i < buttonCount; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(startX + i*POPVIEW_BUTTON_W + (i+0)*POPVIEW_BUTTON_INTERVAL,POPVIEW_BUTTON_Y,POPVIEW_BUTTON_W,POPVIEW_BUTTON_H)];
        [button setImage:[UIImage imageNamed:[self.imageArray objectAtIndex:i]] forState:UIControlStateNormal];
        [button setTag:[[self.tagArray objectAtIndex:i] intValue]];
        [button addTarget:self action:@selector(button1Clicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UILabel *theTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX + i*POPVIEW_LABEL_W + (i+0)*POPVIEW_BUTTON_INTERVAL, POPVIEW_LABEL_Y+3, POPVIEW_LABEL_W, POPVIEW_LABEL_H)];
        theTitleLabel.textAlignment = NSTextAlignmentCenter;
        theTitleLabel.textColor = [UIColor whiteColor];
        theTitleLabel.text = [self.titleArray objectAtIndex:i];
        theTitleLabel.font = [UIFont systemFontOfSize:8];
        [self addSubview:theTitleLabel];
        theTitleLabel = nil;
    }
}

- (void)button1Clicked:(UIButton *)sender
{
    self.selectButtonIndex([sender tag]);
    [self dismiss:YES];
}

#pragma mark ---

- (void)show
{
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionTransitionNone animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionTransitionNone animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)dismiss
{
    self.selectButtonIndex(-1);
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animate
{
    if(!animate)
    {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
}

#pragma mark ---

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //UIImage *img = [UIImage imageNamed:@"ViewTitleImageBG.png"];
    //[img drawInRect:rect];
    
    [self.borderColor set]; //设置线条颜色
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    
    float xMax = CGRectGetMaxX(frame);
    float yMax = CGRectGetMaxY(frame);
    
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    [popoverPath moveToPoint:CGPointMake(xMin, yMin)];//左上角
    [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];//右上角
    [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];//右下角
    [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];//左下角
    
    //填充颜色
    //[[UIColor colorWithWhite:0 alpha:0.8] setFill];
    [[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] setFill]; // addByChen
    //[[UIColor orangeColor] setFill];
    [popoverPath fill];
}

@end
