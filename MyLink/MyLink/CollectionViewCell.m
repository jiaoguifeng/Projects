//
//  CollectionViewCell.m
//  EasyWIFI
//
//  Created by chen on 5/26/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        
        //self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.frame)-10, CGRectGetWidth(self.frame)-10)];
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        //self.imgView.backgroundColor = [UIColor whiteColor];//[UIColor groupTableViewBackgroundColor];
        [self addSubview:_imgView];
        /*
        self.text = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(self.imgView.frame), CGRectGetWidth(self.frame)-10, 20)];
        self.text.backgroundColor = [UIColor brownColor];
        self.text.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.text];
        
        self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn.frame = CGRectMake(5, CGRectGetMaxY(self.text.frame), CGRectGetWidth(self.frame)-10,30);
        [self.btn setTitle:@"按钮" forState:UIControlStateNormal];
        self.btn.backgroundColor = [UIColor orangeColor];
        [self addSubview:self.btn];*/
    }
    return self;
}

@end
