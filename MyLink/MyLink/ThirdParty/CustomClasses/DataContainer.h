//
//  DataContainer.h
//  MyLink
//
//  Created by chen on 16/1/1.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataContainer : UIView
{
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;
- (float)headerHeight;
- (void)setHeight:(float)height;

@end
