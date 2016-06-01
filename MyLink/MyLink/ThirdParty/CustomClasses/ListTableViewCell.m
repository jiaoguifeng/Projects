//
//  ListTableViewCell.m
//  MyLink
//
//  Created by chen on 1/18/16.
//  Copyright © 2016 tricheer. All rights reserved.
//

#import "ListTableViewCell.h"

#define DEBUG_BG_COLOR  0

@interface ListTableViewCell()
{
    NSMutableArray *subTitlelList;
    NSMutableArray *subContentList;
    
    float titleLabelWidth;
}
@end

@implementation ListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier subTitleWidth:(float)subTitleWidth subTitleCount:(NSInteger)subTitleCount
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        if(DEBUG_BG_COLOR)
            self.backgroundColor = [UIColor whiteColor];
        else
            self.backgroundColor = [UIColor clearColor];
        
        titleLabelWidth = subTitleWidth;
        subTitlelList = [[NSMutableArray alloc] initWithCapacity:0];
        subContentList = [[NSMutableArray alloc] initWithCapacity:0];
        
        UILabel *titleLabel = nil;
        UILabel *contentLabel = nil;
        
        for(int i = 0; i < subTitleCount; i++)
        {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            titleLabel.font = [UIFont systemFontOfSize:12];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            if(DEBUG_BG_COLOR)
                titleLabel.backgroundColor = [UIColor orangeColor];
            [self.contentView addSubview:titleLabel];
            [subTitlelList addObject:titleLabel];

            contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            contentLabel.font = [UIFont systemFontOfSize:12];
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            if(DEBUG_BG_COLOR)
                contentLabel.backgroundColor = [UIColor orangeColor];
            [self.contentView addSubview:contentLabel];
            [subContentList addObject:contentLabel];
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect theFrame = self.frame;
    
    float labelHeight = 15;
    float delta = 15;
    float gap_y = 0;
    
    for(int i = 0; i < subTitlelList.count; i++)
    {
        UILabel *titleLabel = [subTitlelList objectAtIndex:i];
        UILabel *contentLabel = [subContentList objectAtIndex:i];
        float startY = 5;
        if(i > 0)
        {
            UILabel *lastLabel = [subTitlelList objectAtIndex:i-1];
            startY = lastLabel.frame.origin.y + lastLabel.frame.size.height + gap_y;
        }
        
        titleLabel.frame = CGRectMake(delta, startY, titleLabelWidth, labelHeight);
        contentLabel.frame = CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width + 1, startY, theFrame.size.width - delta*2 - titleLabelWidth, labelHeight);
    }
}

- (void)setTitleList:(NSArray *)titleList
{
    UILabel *tempLabel = nil;
    for(int i = 0; i < subTitlelList.count; i++)
    {
        tempLabel = [subTitlelList objectAtIndex:i];
        tempLabel.text = [titleList objectAtIndex:i];
    }
}

- (UILabel *)contentLabelAtIndex:(NSInteger )index
{
    return [subContentList objectAtIndex:index];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
