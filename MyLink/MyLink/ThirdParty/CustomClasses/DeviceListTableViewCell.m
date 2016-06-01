//
//  DeviceListTableViewCell.m
//  MyLink
//
//  Created by chen on 16/1/14.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "DeviceListTableViewCell.h"

#define DEBUG_BG_COLOR  0

@implementation DeviceListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        if(DEBUG_BG_COLOR)
            self.backgroundColor = [UIColor whiteColor];
        else
            self.backgroundColor = [UIColor clearColor];
        
        _hostNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _hostNameLabel.font = [UIFont systemFontOfSize:12];
        _hostNameLabel.textColor = [UIColor blackColor];
        _hostNameLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            _hostNameLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_hostNameLabel];
        
        _ipAddressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ipAddressLabel.font = [UIFont systemFontOfSize:12];
        _ipAddressLabel.textColor = [UIColor darkGrayColor];
        _ipAddressLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            _ipAddressLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_ipAddressLabel];

        _macAddressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _macAddressLabel.font = [UIFont systemFontOfSize:12];
        _macAddressLabel.textColor = [UIColor darkGrayColor];
        _macAddressLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            _macAddressLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_macAddressLabel];

        _connectModeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _connectModeLabel.font = [UIFont systemFontOfSize:12];
        _connectModeLabel.textColor = [UIColor darkGrayColor];
        _connectModeLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            _connectModeLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_connectModeLabel];

        _connectTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _connectTimeLabel.font = [UIFont systemFontOfSize:12];
        _connectTimeLabel.textColor = [UIColor darkGrayColor];
        _connectTimeLabel.textAlignment = NSTextAlignmentLeft;
        if(DEBUG_BG_COLOR)
            _connectTimeLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_connectTimeLabel];

    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect theFrame = self.frame;
    
    float delta = 15;
    float gap_y = 3;
    _hostNameLabel.frame = CGRectMake(delta, 5, theFrame.size.width - delta*2, 12);
    _ipAddressLabel.frame = CGRectMake(delta, _hostNameLabel.frame.origin.y + _hostNameLabel.frame.size.height + gap_y, theFrame.size.width - delta*2, 12);
    _macAddressLabel.frame = CGRectMake(delta, _ipAddressLabel.frame.origin.y + _ipAddressLabel.frame.size.height + gap_y, theFrame.size.width - delta*2, 12);
    _connectModeLabel.frame = CGRectMake(delta, _macAddressLabel.frame.origin.y + _macAddressLabel.frame.size.height + gap_y, theFrame.size.width - delta*2, 12);
    _connectTimeLabel.frame = CGRectMake(delta, _connectModeLabel.frame.origin.y + _connectModeLabel.frame.size.height + gap_y, theFrame.size.width - delta*2, 12);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
