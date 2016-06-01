//
//  PopButtonView.h
//  EasyWIFI
//
//  Created by chen on 5/8/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopButtonView : UIView

- (id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images tags:(NSArray *)tags;
- (void)show;
- (void)dismiss;
- (void)dismiss:(BOOL)animated;

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectButtonIndex)(NSInteger index);

@end
