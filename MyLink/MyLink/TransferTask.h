//
//  TransferTask.h
//  EasyWIFI
//
//  Created by chen on 7/21/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TransferTask : NSObject
{
}

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSURL *uploadURL;
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSString *bytesProgress;
@property (nonatomic, strong) NSString *bytesTotal;

@property (nonatomic, assign) BOOL isTaskProcessing;
@property (nonatomic, assign) BOOL isTaskPaused;
@property (nonatomic, strong) NSString *taskType;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *taskSrcPath;
@property (nonatomic, strong) NSString *taskDscPath;

@property (nonatomic, strong) UIImage *uploadImage;
@property (nonatomic, strong) NSString *uploadURLString;

@property (nonatomic, strong) NSString *uploadTempCacheFile;

- (instancetype)initWithURL:(NSString *)theURL;
- (void)startDownload;
- (void)stopDownload;
- (void)startUpload;
- (void)stopUpload;

@end
