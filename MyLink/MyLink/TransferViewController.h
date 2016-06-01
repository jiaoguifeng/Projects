//
//  TransferViewController.h
//  EasyWIFI
//
//  Created by chen on 7/7/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransferViewController : UIViewController
{
}

+ (TransferViewController *)defaultTransferViewController;

- (void)appendDownloadList:(NSArray *)dataList;
- (void)appendUploadList:(NSArray *)dataList withPath:(NSString *)uploadPath;

@end
