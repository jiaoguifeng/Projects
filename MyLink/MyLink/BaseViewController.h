//
//  BaseViewController.h
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//
//
/*
 BaseViewControll，所有ViewControlle的基类，提供基础共用功能
 
 1. 设置背景底图，设置标题背景底图，设置标题
 2. 提供键盘显示、隐藏的接口
 3. 预留 MBProgressHUD 接口
 4.
 
 */

#import <UIKit/UIKit.h>
#import "AppConst.h"
#import "DataContainer.h"
#import "Utility.h"
#import "NetManager.h"
#import "SelectionButton.h"
#import "InputTextField.h"
#import "SevenSwitch.h"
#import "SelectionButton.h"
#import "PopSelectView.h"
#import "ListTableViewCell.h"
#import "NetworkSelectTableViewCell.h"
#import "KVNProgress.h"

@interface BaseViewController : UIViewController
{
}

@property (nonatomic, assign) BOOL isKeyboardShown;

- (void)onBackButtonClicked:(id)sender;

- (void)setBackgroundImageWithName:(NSString *)name;
- (void)setTitleText:(NSString *)titleStr;
- (void)setTItleTextFont:(UIFont *)font;
- (void)setTitleImageHide:(BOOL)hide;

- (UIButton *)baseButton:(CGRect)rect title:(NSString *)title action:(SEL)action;
- (SelectionButton *)selectionButton:(CGRect)rect title:(NSString *)title action:(SEL)action;
- (InputTextField *)inputTextField:(CGRect)rect;
- (UILabel *)titleLabel:(CGRect)rect withTitle:(NSString *)title;
- (SevenSwitch *)switchControl:(CGRect)rect action:(SEL)action onTitle:(NSString *)onStr offTitle:(NSString *)offStr;

- (void)addSubview:(UIView *)view;
- (float)contentHeight;
- (void)setContentHeight:(CGFloat)contentHeight;

@end
