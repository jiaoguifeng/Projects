//
//  ImageShowViewController.h
//  EasyWIFI
//
//  Created by chen on 5/26/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageShowViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
}

- (void)initImageList:(NSArray *)theImageList;

@end
