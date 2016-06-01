//
//  TransferTask.m
//  EasyWIFI
//
//  Created by chen on 7/21/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "TransferTask.h"
#import "AFNetworking.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import <Photos/Photos.h>

@interface TransferTask()
{
    NSURLRequest *downloadRequest;
    AFHTTPRequestOperation *downloadOperation;
    AFHTTPRequestOperation *uploadOperation;
    
    NSData *uploadData;
    Byte *buffer;
}
@end

@implementation TransferTask

- (instancetype)initWithURL:(NSString *)theURL
{
    self = [super init];
    if(self)
    {
        self.url = theURL;
        self.uploadURL = [NSURL URLWithString:theURL];
        self.isTaskProcessing = NO;
        self.isTaskPaused = NO;
        self.bytesProgress = @"0K";
        self.bytesTotal = @"0K";
        self.taskName = @"";
        self.uploadTempCacheFile = @"";
    }
    
    return self;
}

- (void)startDownload
{
    self.isTaskProcessing = YES;
    self.isTaskPaused = NO;
    
    __weak TransferTask *weakSelf = self;
    
    downloadRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.taskSrcPath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];
    downloadOperation.inputStream = [NSInputStream inputStreamWithURL:[NSURL URLWithString:self.taskSrcPath]];
    downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:self.taskDscPath append:NO];
    
    [downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        weakSelf.progress = (double)totalBytesRead / totalBytesExpectedToRead;
        weakSelf.bytesProgress = [NSString stringWithFormat:@"%@/%@", [weakSelf formatByteCount:totalBytesRead], [weakSelf formatByteCount:totalBytesExpectedToRead]];
    }];
    
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        weakSelf.bytesTotal = [weakSelf formatByteCount:operation.response.expectedContentLength];
        weakSelf.isCompleted = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf.isTaskPaused == YES)
        {
        }
        else
        {
            weakSelf.error = error.localizedDescription;
            weakSelf.isCompleted = YES;
        }
    }];
    
    [downloadOperation start];
}

- (void)stopDownload
{
    [downloadOperation cancel];
    self.isTaskProcessing = NO;
    self.isTaskPaused = YES;
}

- (void)startUpload
{
    self.isTaskProcessing = YES;
    self.isTaskPaused = NO;

    /*ALAssetsLibrary *theLibrary = [[ALAssetsLibrary alloc] init];
    [theLibrary assetForURL:self.uploadURL resultBlock:^(ALAsset *asset) {
        
        
        CGImageRef imageRef = [[asset defaultRepresentation] fullResolutionImage];
        //NSString *fileName = [[asset defaultRepresentation] filename];
        //NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[asset defaultRepresentation] size] countStyle:NSByteCountFormatterCountStyleFile];
        if(imageRef)
        {
            self.uploadImage = [UIImage imageWithCGImage:imageRef];
            [self startUploadTask];
        }
    } failureBlock:^(NSError *error) {
    }];*/
    
    /*//9223372036854775808 bytes max
    ALAssetsLibrary *theLibrary = [[ALAssetsLibrary alloc] init];
    [theLibrary assetForURL:self.uploadURL resultBlock:^(ALAsset *asset) {

        ALAssetRepresentation *rep = [asset defaultRepresentation];
        buffer = (Byte *)malloc((NSUInteger)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
        uploadData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
        [self startUploadTask];
        
    } failureBlock:^(NSError *error) {
    }];*/
    
    
    ALAssetsLibrary *theLibrary = [[ALAssetsLibrary alloc] init];
    [theLibrary assetForURL:self.uploadURL resultBlock:^(ALAsset *asset) {
        
        NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *upTemp = [NSString stringWithFormat:@"%@/Caches/TransferTemp/uploadTemp/",documentsPath];
        NSString *filePath = [upTemp stringByAppendingPathComponent:self.taskName];
        self.uploadTempCacheFile = filePath;
        
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        
        FILE *file = fopen([filePath UTF8String], "a+");
        if(file)
        {
            const int bufferSize = 1024 * 1024;
            // 初始化一个1M的buffer
            Byte *fileBuffer = (Byte *)malloc(bufferSize);
            NSUInteger read = 0, offset = 0, written = 0;
            NSError *err = nil;
            if(rep.size != 0)
            {
                do
                {
                    read = [rep getBytes:fileBuffer fromOffset:offset length:bufferSize error:&err];
                    written = fwrite(fileBuffer, sizeof(char), read, file);
                    offset += read;
                }while(read != 0 && !err);//没到结尾，没出错，ok继续
            }
            // 释放缓冲区，关闭文件
            free(fileBuffer);
            fileBuffer = nil;
            fclose(file);
            file = nil;
        }
        
        [self startUploadTask];
        
    } failureBlock:^(NSError *error) {
    }];

}

- (void)startUploadTask
{
    NSString *paramStr = [NSString stringWithFormat:@"longcheer_w>%@>",self.taskDscPath];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:paramStr,@"current_folder_dir", nil];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST"
                                                                    URLString:self.uploadURLString
                                                                   parameters:param
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:self.uploadTempCacheFile]
                                                                                   name:@"lc_upfile"
                                                                               fileName:self.taskName
                                                                               mimeType:@"image/png"
                                                                                  error:nil];}
                                                                        error:nil];

    __weak TransferTask *weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    uploadOperation = [manager HTTPRequestOperationWithRequest:request
                                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                           //weakSelf.bytesTotal = [weakSelf formatByteCount:operation.response.expectedContentLength];
                                                           weakSelf.isCompleted = YES;
                                                           if([[NSFileManager defaultManager] fileExistsAtPath:self.uploadTempCacheFile])
                                                               [[NSFileManager defaultManager] removeItemAtPath:self.uploadTempCacheFile error:nil];
                                                       }
                                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           if(weakSelf.isTaskPaused == YES)
                                                           {
                                                           }
                                                           else
                                                           {
                                                               weakSelf.error = error.localizedDescription;
                                                               weakSelf.isCompleted = YES;
                                                           }
                                                           
                                                           if([[NSFileManager defaultManager] fileExistsAtPath:self.uploadTempCacheFile])
                                                               [[NSFileManager defaultManager] removeItemAtPath:self.uploadTempCacheFile error:nil];
                                                       }];
    
    [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        weakSelf.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
        weakSelf.bytesProgress = [NSString stringWithFormat:@"%@/%@", [weakSelf formatByteCount:totalBytesWritten], [weakSelf formatByteCount:totalBytesExpectedToWrite]];
    }];
    
    [uploadOperation start];
}

/*
- (void)startUploadTask
{
    if(!uploadData)
        return;
    
    NSString *paramStr = [NSString stringWithFormat:@"longcheer_w>%@>",self.taskDscPath];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:paramStr,@"current_folder_dir", nil];
    
    __weak TransferTask *weakSelf = self;
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST"
                                                                    URLString:self.uploadURLString
                                                                   parameters:param
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                                                        [formData appendPartWithFileData:uploadData
                                                                                    name:@"lc_upfile"
                                                                                fileName:self.taskName
                                                                                mimeType:@"image/png"];}
                                                                        error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    uploadOperation = [manager HTTPRequestOperationWithRequest:request
                                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                           //weakSelf.bytesTotal = [weakSelf formatByteCount:operation.response.expectedContentLength];
                                                           weakSelf.isCompleted = YES;
                                                           if(buffer)
                                                           {
                                                               free(buffer);
                                                               buffer = nil;
                                                           }
                                                           uploadData = nil;
                                                           
                                                           if([[NSFileManager defaultManager] fileExistsAtPath:self.uploadTempCacheFile])
                                                               [[NSFileManager defaultManager] removeItemAtPath:self.uploadTempCacheFile error:nil];
                                                       }
                                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           if(buffer)
                                                           {
                                                               free(buffer);
                                                               buffer = nil;
                                                           }
                                                           uploadData = nil;
                                                           
                                                           if(weakSelf.isTaskPaused == YES)
                                                           {
                                                           }
                                                           else
                                                           {
                                                               weakSelf.error = error.localizedDescription;
                                                               weakSelf.isCompleted = YES;
                                                           }
                                                           
                                                           if([[NSFileManager defaultManager] fileExistsAtPath:self.uploadTempCacheFile])
                                                               [[NSFileManager defaultManager] removeItemAtPath:self.uploadTempCacheFile error:nil];
                                                       }];
    
    [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        weakSelf.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
        weakSelf.bytesProgress = [NSString stringWithFormat:@"%@/%@", [weakSelf formatByteCount:totalBytesWritten], [weakSelf formatByteCount:totalBytesExpectedToWrite]];
    }];
    
    [uploadOperation start];
}
*/
- (void)stopUpload
{
    [uploadOperation cancel];
    self.isTaskProcessing = NO;
    self.isTaskPaused = YES;
}

- (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

@end
