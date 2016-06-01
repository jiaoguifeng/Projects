//
//  PopView.m
//  MyLink
//
//  Created by chen on 15/12/29.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "PopView.h"
#import "AppConst.h"

@interface PopView()
{
    CompletionBlock completionBlock;
    BOOL isCanceled;
    POPVIEW_BUTTON_ID popButtonID;
    
    UILabel *titleLabel;
}
@end

@implementation PopView

- (instancetype)initWithTitle:(NSString *)title buttonList:(NSArray *)buttonList
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    CGFloat screenHeight = CGRectGetHeight(screenRect);
    
    self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        isCanceled = NO;
                
        CGFloat startX = 20.0;
        NSString *deviceType = [UIDevice currentDevice].model;
        if([deviceType rangeOfString:@"iPad"].length > 0)
            startX = screenWidth/4;

        CGFloat bottomViewHeight = 0;
        CGFloat buttonHeight = 35;
        CGFloat gap = 10;
        
        float bottomViewStartX = 10;

        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, 0, screenWidth-startX*2-bottomViewStartX*2, CGFLOAT_MAX)];
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        //titleLabel.backgroundColor = [UIColor grayColor];

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style};
        
        CGRect theRect = [titleLabel.text boundingRectWithSize:CGSizeMake(titleLabel.frame.size.width,CGFLOAT_MAX)
                                                           options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                                        attributes:attribute
                                                           context:nil];
        
        //
        NSInteger buttonCount = buttonList.count;
        bottomViewHeight = theRect.size.height + buttonHeight*buttonCount + gap*(buttonCount+2);
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(startX, (screenHeight - bottomViewHeight)/2, screenWidth - startX*2, bottomViewHeight)];
        bottomView.layer.cornerRadius = 6;
        bottomView.layer.masksToBounds = YES;
        bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomView];
        
        //
        titleLabel.frame = CGRectMake(bottomViewStartX, bottomViewStartX, bottomView.frame.size.width-bottomViewStartX*2, theRect.size.height);
        [bottomView addSubview:titleLabel];
        
        //
        float buttonStartY = titleLabel.frame.origin.y+titleLabel.frame.size.height+10;
        float buttonWidth = titleLabel.frame.size.width;
        for(NSInteger i = 0; i < buttonCount; i++)
        {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(bottomViewStartX,buttonStartY + (buttonHeight*i + 10*i),buttonWidth,buttonHeight)];
            tempButton.tag = [[[buttonList objectAtIndex:i] objectForKey:@"buttonID"] integerValue];
            [tempButton setTitle:[[buttonList objectAtIndex:i] objectForKey:@"buttonTitle"] forState:UIControlStateNormal];
            [tempButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [tempButton setBackgroundColor:[UIColor colorWithRed:234/255.0 green:66/255.0 blue:62/255.0 alpha:1]];
            [tempButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [tempButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:234/255.0 green:66/255.0 blue:62/255.0 alpha:1] size:tempButton.frame.size] forState:UIControlStateNormal];
            [tempButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:199/255.0 green:10/255.0 blue:20/255.0 alpha:1] size:tempButton.frame.size] forState:UIControlStateHighlighted];
            [bottomView addSubview:tempButton];
        }
    }
    
    return self;
}

- (void)changePopViewTitle:(NSString *)newTitle
{
    titleLabel.text = newTitle;
}

- (void)showWithcompletion:(CompletionBlock)completion
{
    completionBlock = completion;
    
    [self show];
}

#pragma mark -

- (void)buttonClicked:(id)sender
{
    UIButton *theButton = (UIButton *)sender;
    popButtonID = theButton.tag;
    switch(popButtonID)
    {
        case POPVIEW_BUTTON_CANCEL:
            isCanceled = YES;
            break;
        case POPVIEW_BUTTON_ADD:
            isCanceled = NO;
            break;
        case POPVIEW_BUTTON_REMOVE:
            isCanceled = NO;
            break;
        case POPVIEW_BUTTON_MANAGE:
            isCanceled = NO;
            break;
        case POPVIEW_BUTTON_CONFIG:
            isCanceled = NO;
            break;
            
        default:
            break;
    }
    [self dismiss];
}

#pragma mark -

- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if(isCanceled)
                completionBlock(nil,nil);
            else
            {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:popButtonID],@"buttonID", nil];
                completionBlock(dict,nil);
            }
        }
    }];
}


- (void)show
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f, keywindow.bounds.size.height/2.0f);
    [self fadeIn];
}

- (void)dismiss
{
    [self fadeOut];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark -

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

@end
