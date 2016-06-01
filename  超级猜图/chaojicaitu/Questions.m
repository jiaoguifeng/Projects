//
//  Questions.m
//  chaojicaitu
//
//  Created by jiaoguifeng on 8/19/15.
//  Copyright (c) 2015 jiaoguifeng. All rights reserved.
//

#import "Questions.h"

@interface Questions ()

@end

@implementation Questions

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init])
    {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)questionsWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)questions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *arrayModel = [NSMutableArray array];
    for (NSDictionary *dict in array)
    {
        Questions *question = [Questions questionsWithDict:dict];
        [arrayModel addObject:question];
    }

    return arrayModel;
}
@end
