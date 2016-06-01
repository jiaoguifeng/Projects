//
//  TouchButton.h
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConst.h"

@protocol TouchButtonDelegate

- (void)buttonSinglePressed:(TOUCH_BUTTON_ID)buttonID buttonTag:(ADD_COMPONENT_INDEX)buttonTag;
- (void)buttonLongPressed:(TOUCH_BUTTON_ID)buttonID buttonTag:(ADD_COMPONENT_INDEX)buttonTag;

@end

@interface TouchButton : UIView
{
}

@property (nonatomic, weak) id<TouchButtonDelegate> delegate;
@property (nonatomic, assign) NSInteger buttonID;
@property (nonatomic, assign) NSInteger buttonTag;
@property (nonatomic, retain) UIColor *bgColor;
@property (nonatomic, retain) NSString *buttonImage;
@property (nonatomic, retain) NSString *buttonTitle;

@end
