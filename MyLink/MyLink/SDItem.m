//
//  SDItem.m
//  EasyWIFI
//
//  Created by chen on 3/13/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "SDItem.h"

@implementation SDItem

@synthesize isRootItem,isItemSelected,itemType,itemName,itemPath,itemSize,itemSizeDisplay,itemTime,itemTimeDisplay,thumbnailImage,itemChildList;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.isRootItem = NO;
        self.isItemSelected = NO;
        self.itemType = @"";
        self.itemName = @"";
        self.itemPath = @"";
        self.itemSize = @"";
        self.itemSizeDisplay = @"0 KB";
        self.itemTime = @"";
        self.itemTimeDisplay = @"";
        self.thumbnailImage = NULL;
        self.itemChildList = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

- (void)setItemDisplayField
{
    if(self.itemSize.length > 0)
    {
        long long sizeNum = [[NSString stringWithString:self.itemSize] longLongValue];
        self.itemSizeDisplay = [NSByteCountFormatter stringFromByteCount:sizeNum countStyle:NSByteCountFormatterCountStyleFile];
        /*if(sizeNum <= 1024.0)
            self.itemSizeDisplay = [NSString stringWithFormat:@"%.2f B",sizeNum/1.0];
        else if(sizeNum/1024.0 < 1024.0)
            self.itemSizeDisplay = [NSString stringWithFormat:@"%.2f KB",sizeNum/1024.0];
        else if(sizeNum/(1024.0*1024.0) < 1024.0)
            self.itemSizeDisplay = [NSString stringWithFormat:@"%.2f MB",sizeNum/(1024.0*1024.0)];
        else
            self.itemSizeDisplay = [NSString stringWithFormat:@"%.2f GB",sizeNum/(1024.0*1024.0*1024.0)];*/
    }
    
    if(self.itemTime.length > 0)
    {
        NSArray *timeSepList = [self.itemTime componentsSeparatedByString:@"-"];
        if([timeSepList count] == 6)
        {
            self.itemTimeDisplay = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",[timeSepList objectAtIndex:0],[timeSepList objectAtIndex:1],[timeSepList objectAtIndex:2],[timeSepList objectAtIndex:3],[timeSepList objectAtIndex:4],[timeSepList objectAtIndex:5]];
        }
    }
}

- (NSComparisonResult)compareByName:(SDItem *)item
{
    return [self.itemName localizedCaseInsensitiveCompare:item.itemName];
}

@end
