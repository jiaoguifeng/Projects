//
//  SDItem.h
//  EasyWIFI
//
//  Created by chen on 3/13/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SDItem : NSObject
{
    BOOL isRootItem;
    
    BOOL isItemSelected;
    
    NSString *itemType;
    NSString *itemName;
    NSString *itemPath;
    NSString *itemSize;
    NSString *itemSizeDisplay;
    NSString *itemTime;
    NSString *itemTimeDisplay;
    
    UIImage *thumbnailImage;
    
    NSMutableArray *itemChildList;
}

@property (nonatomic, assign) BOOL isRootItem;
@property (nonatomic) BOOL isItemSelected;
@property (nonatomic,retain) NSString *itemType;
@property (nonatomic,retain) NSString *itemName;
@property (nonatomic,retain) NSString *itemPath;
@property (nonatomic,retain) NSString *itemSize;
@property (nonatomic,retain) NSString *itemSizeDisplay;
@property (nonatomic,retain) NSString *itemTime;
@property (nonatomic,retain) NSString *itemTimeDisplay;
@property (nonatomic,retain) UIImage *thumbnailImage;
@property (nonatomic,retain) NSMutableArray *itemChildList;

- (void)setItemDisplayField;
- (NSComparisonResult)compareByName:(SDItem *)item;

@end
