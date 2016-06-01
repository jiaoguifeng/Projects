//
//  SettingContainer.h
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConst.h"

@protocol SettingContainerDelegate

- (void)settingContainerAction:(TOUCH_BUTTON_ID)buttonID;

@end

@interface SettingContainer : UIView
{
}

@property (nonatomic, weak) id<SettingContainerDelegate> delegate;
@property (nonatomic, assign) BOOL isShown;

- (void)show;
- (void)hide;

- (void)setLoginButtonStatus:(BOOL)isLoginStatus;

@end
