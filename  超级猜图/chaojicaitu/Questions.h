//
//  Questions.h
//  chaojicaitu
//
//  Created by jiaoguifeng on 8/19/15.
//  Copyright (c) 2015 jiaoguifeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Questions : NSObject

@property (nonatomic, copy) NSString *answer;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *options;


- (instancetype)initWithDict:(NSDictionary*)dict;
+ (instancetype)questionsWithDict:(NSDictionary*)dict;
+ (NSArray*)questions;
@end
