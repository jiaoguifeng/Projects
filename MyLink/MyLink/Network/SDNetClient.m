//
//  SDNetClient.m
//  MyLink
//
//  Created by chen on 16/2/22.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "SDNetClient.h"

@implementation SDNetClient

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
    self.requestSerializer.timeoutInterval = 10.0;
    
    self.securityPolicy.allowInvalidCertificates = YES;
    
    return self;
}

- (void)requestDataWithPath:(NSString *)aPath
                 withParams:(NSDictionary*)params
             withMethodType:(NetworkRequestMethod)method
                   andBlock:(void (^)(id data, NSError *error))block
{
    [self requestDataWithPath:aPath withParams:params withMethodType:method autoShowError:NO andBlock:block];
}

- (void)requestDataWithPath:(NSString *)aPath
                 withParams:(NSDictionary*)params
             withMethodType:(NetworkRequestMethod)method
              autoShowError:(BOOL)autoShowError
                   andBlock:(void (^)(id data, NSError *error))block
{
    if(!aPath || aPath.length <= 0)
    {
        return;
    }
    // Log请求数据
    
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 发起请求
    switch (method)
    {
        case Get:
        {
            // 所有 Get 请求，增加缓存机制
            NSMutableString *localPath = [aPath mutableCopy];
            if (params)
            {
                [localPath appendString:params.description];
            }
            
            [self GET:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:operation autoShowError:autoShowError];
                if(error)
                {
                    //responseObject = [NSObject loadResponseWithPath:localPath];
                    block(responseObject, error);
                }
                else
                {
                    if([responseObject isKindOfClass:[NSDictionary class]])
                    {
                        //判断数据是否符合预期，给出提示
                        if([responseObject[@"data"] isKindOfClass:[NSDictionary class]])
                        {
                            if (responseObject[@"data"][@"too_many_files"])
                            {
                                NSLog(@"文件太多，不能正常显示");
                            }
                        }
                    }
                    
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //id responseObject = [NSObject loadResponseWithPath:[localPath ]];
                block(nil, error);
            }];
            break;
        }
        case Post:
        {
            [self POST:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:operation autoShowError:autoShowError];
                if(error)
                {
                    block(nil, error);
                }
                else
                {
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                block(nil, error);
            }];
            break;
        }
        case Put:
        {
            [self PUT:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:operation autoShowError:autoShowError];
                if(error)
                {
                    block(nil, error);
                }
                else
                {
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                block(nil, error);
            }];
            break;
        }
        case Delete:
        {
            [self DELETE:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:operation autoShowError:autoShowError];
                if(error)
                {
                    block(nil, error);
                }
                else
                {
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                block(nil, error);
            }];
        }
            
        default:
            break;
    }
}

- (id)handleResponse:(AFHTTPRequestOperation *)responseOperation autoShowError:(BOOL)autoShowError
{
    NSError *error = nil;
    
    NSInteger retCode = responseOperation.response.statusCode;
    if(retCode != 200)
    {
        error = [NSError errorWithDomain:BASE_URL_STR code:retCode userInfo:responseOperation.response.allHeaderFields];
    }
    // 此处根据服务器端的返回值判断请求是否成功
    //code为非0值时，表示有错
    /*NSNumber *resultCode = [responseJSON valueForKeyPath:@"code"];
     
     if(resultCode.intValue != 0)
     {
     error = [NSError errorWithDomain:BASE_URL_STR code:resultCode.intValue userInfo:responseJSON];
     // 此处可以添加HUD消息显示
     // ...
     }*/
    
    return error;
}

@end
