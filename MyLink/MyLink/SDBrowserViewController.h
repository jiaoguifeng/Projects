//
//  SDBrowserViewController.h
//  EasyWIFI
//
//  Created by chen on 6/30/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDBrowserViewController : UIViewController
{
    id delegate;
}

@property (nonatomic,retain) id delegate;

@end
