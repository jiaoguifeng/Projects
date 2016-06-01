//
//  SettingContainer.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "SettingContainer.h"
#import "TouchButton.h"

#define CONTAINER_START_Y   70
#define CONTAINER_GAP       5

@interface SettingContainer()<TouchButtonDelegate>
{
    CGFloat contentViewHeight;
    UIView *bottomView;
    
    TouchButton *btnLogin;
}

@end

@implementation SettingContainer

@synthesize isShown,delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    return [self initWithHeight:0];
}

- (instancetype)initWithHeight:(CGFloat)height
{
    isShown = NO;
    contentViewHeight = height;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    CGFloat screenHeight = CGRectGetHeight(screenRect);
    
    contentViewHeight = screenHeight - CONTAINER_START_Y;
    
    self = [super initWithFrame:CGRectMake(-screenWidth, CONTAINER_START_Y, screenWidth, screenHeight - CONTAINER_START_Y)];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:211/255.0 green:203/255.0 blue:205/255.0 alpha:1.0];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
        [self addGestureRecognizer:singleTap];

        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth/3*2 + CONTAINER_GAP*3, screenHeight - CONTAINER_START_Y)];
        bottomView.backgroundColor = [UIColor colorWithRed:211/255.0 green:203/255.0 blue:205/255.0 alpha:1.0];
        [self addSubview:bottomView];
        
        [self addSettingButtons];
    }
    
    return self;
}

#pragma mark - Setting buttons init

- (void)addSettingButtons
{
    float tempWidth = CGRectGetWidth([[UIScreen mainScreen] bounds])/3;
    float tempHeight = tempWidth;

    btnLogin = [[TouchButton alloc] initWithFrame:CGRectMake(CONTAINER_GAP, CONTAINER_GAP, tempWidth, tempHeight)];
    btnLogin.delegate = self;
    btnLogin.bgColor = [UIColor colorWithRed:179/255.0 green:52/255.0 blue:54/255.0 alpha:1.0];
    btnLogin.buttonImage = @"Personal change small";
    btnLogin.buttonTitle = NSLocalizedStringFromTable(@"loginStr",NULL,@"SettingMainUIStrings");
    btnLogin.buttonID = TOUCH_BUTTON_LOGINOUT;
    [bottomView addSubview:btnLogin];
    
    tempHeight = (contentViewHeight - CONTAINER_GAP*4 - btnLogin.frame.size.height)/2;
    
    TouchButton *btnStatus = [[TouchButton alloc] initWithFrame:CGRectMake(CONTAINER_GAP, btnLogin.frame.origin.y + btnLogin.frame.size.height + CONTAINER_GAP, tempWidth, tempHeight)];
    btnStatus.delegate = self;
    btnStatus.bgColor = [UIColor colorWithRed:128/255.0 green:127/255.0 blue:132/255.0 alpha:1.0];
    btnStatus.buttonImage = @"status";
    btnStatus.buttonTitle = NSLocalizedStringFromTable(@"statusStr",NULL,@"SettingMainUIStrings");
    btnStatus.buttonID = TOUCH_BUTTON_STATUS;
    [bottomView addSubview:btnStatus];
    
    TouchButton *btnConnection = [[TouchButton alloc] initWithFrame:CGRectMake(CONTAINER_GAP, btnStatus.frame.origin.y + btnStatus.frame.size.height + CONTAINER_GAP, tempWidth, tempHeight)];
    btnConnection.delegate = self;
    btnConnection.bgColor = [UIColor colorWithRed:48/255.0 green:60/255.0 blue:76/255.0 alpha:1.0];
    btnConnection.buttonImage = @"connection";
    btnConnection.buttonTitle = NSLocalizedStringFromTable(@"connectionStr",NULL,@"SettingMainUIStrings");
    btnConnection.buttonID = TOUCH_BUTTON_CONNECTION;
    [bottomView addSubview:btnConnection];
    
    tempHeight = (contentViewHeight - CONTAINER_GAP*3)/2;
    
    TouchButton *btnWiFiDisk = [[TouchButton alloc] initWithFrame:CGRectMake(tempWidth + CONTAINER_GAP*2, CONTAINER_GAP, tempWidth, tempHeight)];
    btnWiFiDisk.delegate = self;
    btnWiFiDisk.bgColor = [UIColor colorWithRed:231/255.0 green:145/255.0 blue:79/255.0 alpha:1.0];
    btnWiFiDisk.buttonImage = @"wifi_disk chang";
    btnWiFiDisk.buttonTitle = NSLocalizedStringFromTable(@"wifiDiskStr",NULL,@"SettingMainUIStrings");
    btnWiFiDisk.buttonID = TOUCH_BUTTON_WIFIDISK;
    [bottomView addSubview:btnWiFiDisk];
    
    TouchButton *btnSetting = [[TouchButton alloc] initWithFrame:CGRectMake(tempWidth + CONTAINER_GAP*2, btnWiFiDisk.frame.origin.y + btnWiFiDisk.frame.size.height + CONTAINER_GAP, tempWidth, tempHeight)];
    btnSetting.delegate = self;
    btnSetting.bgColor = [UIColor colorWithRed:179/255.0 green:52/255.0 blue:54/255.0 alpha:1.0];
    btnSetting.buttonImage = @"setting";
    btnSetting.buttonTitle = NSLocalizedStringFromTable(@"settingStr",NULL,@"SettingMainUIStrings");
    btnSetting.buttonID = TOUCH_BUTTON_SETTING;
    [bottomView addSubview:btnSetting];
}

#pragma mark - Setting sheet show/hide

- (void)show
{
    [self animateContentViewToShow:YES];
}

- (void)hide
{
    [self animateContentViewToShow:NO];
}

- (void)animateContentViewToShow:(BOOL)toShow
{
    isShown = toShow;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect selfFame = self.frame;
    if(toShow)
        selfFame.origin.x += selfFame.size.width;
    else
        selfFame.origin.x -= selfFame.size.width;
    [self setFrame:selfFame];
    
    [UIView commitAnimations];
}

#pragma mark - TouchButtonDelegate

- (void)buttonSinglePressed:(TOUCH_BUTTON_ID)buttonID buttonTag:(ADD_COMPONENT_INDEX)buttonTag;
{
    //NSLog(@"buttonSinglePressed: %ld",buttonID);
    [delegate settingContainerAction:buttonID];
}

- (void)buttonLongPressed:(TOUCH_BUTTON_ID)buttonID buttonTag:(ADD_COMPONENT_INDEX)buttonTag
{
    NSLog(@"buttonLongPressed: %ld",(long)buttonID);
}

#pragma mark - Tap to hide button sheet

- (void)tapEvent:(UITapGestureRecognizer *)gesture
{
    [self endEditing:YES];
    
    CGPoint tapPoint = [gesture locationInView:self];
    if(tapPoint.y >= bottomView.frame.origin.y)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SettingSheetDisappearNotification object: self userInfo:nil];
    }
    else
    {
    }
}

#pragma mark - Login/Logout button status update

- (void)setLoginButtonStatus:(BOOL)isLoginStatus
{
    if(isLoginStatus)
        btnLogin.buttonTitle = NSLocalizedStringFromTable(@"logoutStr",NULL,@"SettingMainUIStrings");
    else
        btnLogin.buttonTitle = NSLocalizedStringFromTable(@"loginStr",NULL,@"SettingMainUIStrings");
}

@end
