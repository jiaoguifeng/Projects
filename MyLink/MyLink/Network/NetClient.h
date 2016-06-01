//
//  NetClient.h
//  LookApp
//
//  Created by chen on 15/12/30.
//  Copyright © 2015年 tricheer. All rights reserved.
//
//
/*
  NetClient
 
  1.继承自AFHTTPRequestOperationManager，进行AFNetworking网络请求
  2.handleResponse对网络请求结果处理，判断请求是否成功，并且是否显示错误信息
 */

#import <AFNetworking/AFNetworking.h>
#import "Net.h"
#import "Utility.h"

@interface NetClient : AFHTTPRequestOperationManager

+ (NetClient *)sharedNetClient;

- (void)requestDataWithPath:(NSString *)aPath
                 withParams:(NSDictionary*)params
             withMethodType:(NetworkRequestMethod)method
                   andBlock:(void (^)(id data, NSError *error))block;

- (void)requestDataWithPath:(NSString *)aPath
                 withParams:(NSDictionary*)params
             withMethodType:(NetworkRequestMethod)method
              autoShowError:(BOOL)autoShowError
                   andBlock:(void (^)(id data, NSError *error))block;

@end
