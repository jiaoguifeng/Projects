//
//  LoginView.h
//  MyLink
//
//  Created by chen on 16/1/1.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id data, NSError *error);

@interface LoginView : UIView
{
}

- (void)showWithcompletion:(CompletionBlock)completion;

- (void)show;
- (void)dismiss;

@end
