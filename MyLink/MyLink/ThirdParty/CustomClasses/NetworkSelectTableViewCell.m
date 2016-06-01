//
//  NetworkSelectTableViewCell.m
//  MyLink
//
//  Created by chen on 16/1/20.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "NetworkSelectTableViewCell.h"

#define DEBUG_BG_COLOR  0

@interface NetworkSelectTableViewCell()
{
}
@end

@implementation NetworkSelectTableViewCell

@synthesize operatorLabel,serviceLabel,statusLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        if(DEBUG_BG_COLOR)
            self.backgroundColor = [UIColor whiteColor];
        else
            self.backgroundColor = [UIColor clearColor];
        
        float startX = 15;
        float labelHeight = 15;
        float labelWidth = (self.frame.size.width - startX)/3;
        
        operatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX, 5, labelWidth, labelHeight)];
        operatorLabel.font = [UIFont systemFontOfSize:12];
        operatorLabel.textColor = [UIColor blackColor];
        operatorLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            operatorLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:operatorLabel];
        
        serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(operatorLabel.frame.origin.x + operatorLabel.frame.size.width + 1, 5, labelWidth - 1, labelHeight)];
        serviceLabel.font = [UIFont systemFontOfSize:12];
        serviceLabel.textColor = [UIColor blackColor];
        serviceLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            serviceLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:serviceLabel];

        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(serviceLabel.frame.origin.x + serviceLabel.frame.size.width + 1, 5, labelWidth, labelHeight)];
        statusLabel.font = [UIFont systemFontOfSize:12];
        statusLabel.textColor = [UIColor blackColor];
        statusLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            statusLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:statusLabel];

    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
