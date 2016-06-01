//
//  PopSelectView.m
//  MyLink
//
//  Created by chen on 16/1/14.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "PopSelectView.h"

@interface PopSelectView()<UITableViewDataSource,UITableViewDelegate>
{
    CompletionBlock completionBlock;
    
    UIView *bottomView;
    
    UITableView *contentListView;
    NSMutableArray *contentList;
}
@end

@implementation PopSelectView

- (instancetype)initWithContentList:(NSArray *)list
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    CGFloat screenHeight = CGRectGetHeight(screenRect);
    
    self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        
        CGFloat startX = 40.0;
        CGFloat bottomViewHeight = 30*list.count + 25;
        if(bottomViewHeight > screenHeight - 100)
            bottomViewHeight = screenHeight - 100;
        
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(startX, (screenHeight - bottomViewHeight)/2, screenWidth - startX*2, bottomViewHeight)];
        bottomView.layer.cornerRadius = 6;
        bottomView.layer.masksToBounds = YES;
        bottomView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:bottomView];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, 25)];
        titleLabel.text = @"Please Select";
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor colorWithRed:52/255.0 green:72/255.0 blue:90/255.0 alpha:1.0];
        titleLabel.textColor = [UIColor whiteColor];
        [bottomView addSubview:titleLabel];
        
        //
        contentList = [[NSMutableArray alloc] initWithArray:list];
        
        //
        contentListView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height, bottomView.frame.size.width, bottomView.frame.size.height - titleLabel.frame.size.height) style:UITableViewStylePlain];
        contentListView.dataSource = self;
        contentListView.delegate = self;
        contentListView.backgroundColor = [UIColor clearColor];
        contentListView.separatorColor = [UIColor darkGrayColor];
        [bottomView addSubview:contentListView];
    }
    
    return self;
}

- (void)showWithcompletion:(CompletionBlock)completion
{
    completionBlock = completion;
    
    [self show];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
    completionBlock(nil,nil);
}

#pragma mark -

- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}


- (void)show
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f, keywindow.bounds.size.height/2.0f);
    [self fadeIn];
}

- (void)dismiss
{
    [self fadeOut];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";

    UITableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        theCell.backgroundColor = [UIColor clearColor];
        
        theCell.textLabel.font = [UIFont systemFontOfSize:12];
        
        theCell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        theCell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    
    theCell.textLabel.text = [contentList objectAtIndex:indexPath.row];
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismiss];
    completionBlock([NSNumber numberWithInteger:indexPath.row],nil);
}

@end
