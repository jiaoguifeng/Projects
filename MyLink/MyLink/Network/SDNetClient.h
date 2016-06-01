//
//  SDNetClient.h
//  MyLink
//
//  Created by chen on 16/2/22.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "NetClient.h"
#import <AFNetworking/AFNetworking.h>
#import "Net.h"
#import "Utility.h"

@interface SDNetClient : AFHTTPRequestOperationManager

- (id)initWithBaseURL:(NSURL *)url;

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
