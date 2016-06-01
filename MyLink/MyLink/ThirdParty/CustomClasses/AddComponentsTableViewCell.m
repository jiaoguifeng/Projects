//
//  AddComponentsTableViewCell.m
//  MyLink
//
//  Created by chen on 15/12/29.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "AddComponentsTableViewCell.h"

@interface AddComponentsTableViewCell()
{
}
@end

@implementation AddComponentsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        //_titleLabel.backgroundColor = [UIColor orangeColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        //_subTitleLabel.backgroundColor = [UIColor redColor];
        _subTitleLabel.textColor = [UIColor darkGrayColor];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        _subTitleLabel.numberOfLines = 0;
        _subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_subTitleLabel];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor grayColor];

    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect selFrame = self.frame;
    
    _titleLabel.frame = CGRectMake(20, 20, selFrame.size.width - 20, 20);
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    
    CGSize retSize = [_subTitleLabel.text boundingRectWithSize:CGSizeMake(_subTitleLabel.frame.size.width, 0)
                                             options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    _subTitleLabel.frame = CGRectMake(20, _titleLabel.frame.origin.y+_titleLabel.frame.size.height, selFrame.size.width - 20, retSize.height);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
