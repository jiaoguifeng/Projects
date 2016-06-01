//
//  PopView.h
//  MyLink
//
//  Created by chen on 15/12/29.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id data, NSError *error);

@interface PopView : UIView
{
}

- (instancetype)initWithTitle:(NSString *)title buttonList:(NSArray *)buttonList;
- (void)showWithcompletion:(CompletionBlock)completion;
- (void)changePopViewTitle:(NSString *)newTitle;


- (void)show;
- (void)dismiss;

@end
