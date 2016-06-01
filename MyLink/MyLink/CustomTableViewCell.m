//
//  CustomTableViewCell.m
//  EasyWIFI
//
//  Created by chen on 3/11/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import "CustomTableViewCell.h"

#define DELTA_X 15

#define SELECT_IMAGE_VIEW_X     15
#define ICON_IMAGE_VIEW_X       30
#define TITLE_LABEL_X           55

@implementation CustomTableViewCell

@synthesize titleLabel,tipsTitleLabel,checkImageView,iconView,customButton,progress,boundData;

- (id)delegate
{
    return delegate;
}

- (void)setDelegate:(id)theDelegate
{
    if(delegate)
    {
        delegate = nil;
    }
    
    delegate = theDelegate;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        isSelected = NO;
        
        CGRect tempCellRect = self.frame;

        // Initialization code
        checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SELECT_IMAGE_VIEW_X, 10, 10, 10)];
        [checkImageView setImage:[UIImage imageNamed:@"Unselected.png"]];
        [self.contentView addSubview:checkImageView];
        [checkImageView setHidden:YES];
        
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(ICON_IMAGE_VIEW_X, 4, 22, 22)];
        [self.contentView addSubview:iconView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_LABEL_X, 4, tempCellRect.size.width - TITLE_LABEL_X - 10, 12)];
        titleLabel.font = [UIFont systemFontOfSize:10];
        titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:titleLabel];
        
        progress = [[UIProgressView alloc] initWithFrame:CGRectMake(TITLE_LABEL_X, 16, 200, 1)];
        progress.progress = 0.5;
        [self.contentView addSubview:progress];
        [progress setHidden:YES];

        tipsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_LABEL_X, 18, tempCellRect.size.width - TITLE_LABEL_X - 10, 8)];
        tipsTitleLabel.font = [UIFont systemFontOfSize:7];
        tipsTitleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:tipsTitleLabel];
        
        customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton setFrame:CGRectMake(tempCellRect.size.width - 35, 1, 28, 28)];
        [customButton setImage:[UIImage imageNamed:@"TransferPause.png"] forState:UIControlStateNormal];
        [customButton addTarget:self action:@selector(customButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:customButton];
        [customButton setHidden:YES];
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

- (void)customButtonAction:(id)sender
{
    [delegate customButtonActions:(int)self.tag];
}

- (void)setMultiSelectMode:(BOOL)selectMode
{
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.3];
    
    if(selectMode)
    {
        [checkImageView setHidden:NO];
        CGRect checkImageViewFrame = checkImageView.frame;
        checkImageViewFrame.origin.x = SELECT_IMAGE_VIEW_X;
        [checkImageView setFrame:checkImageViewFrame];
        
        CGRect iconViewFrame = iconView.frame;
        iconViewFrame.origin.x = ICON_IMAGE_VIEW_X;
        [iconView setFrame:iconViewFrame];
        
        CGRect titleLabelFrame = titleLabel.frame;
        titleLabelFrame.origin.x = TITLE_LABEL_X;
        [titleLabel setFrame:titleLabelFrame];
        
        CGRect progressFrame = progress.frame;
        progressFrame.origin.x = TITLE_LABEL_X;
        [progress setFrame:progressFrame];

        CGRect tipsTitleLabelFrame = tipsTitleLabel.frame;
        tipsTitleLabelFrame.origin.x = TITLE_LABEL_X;
        [tipsTitleLabel setFrame:tipsTitleLabelFrame];
        
        //[customButton setHidden:NO];
        
        [UIView commitAnimations];
    }
    else
    {
        [checkImageView setHidden:YES];
        CGRect checkImageViewFrame = checkImageView.frame;
        checkImageViewFrame.origin.x = SELECT_IMAGE_VIEW_X - DELTA_X;
        [checkImageView setFrame:checkImageViewFrame];
        
        CGRect iconViewFrame = iconView.frame;
        iconViewFrame.origin.x = ICON_IMAGE_VIEW_X - DELTA_X;
        [iconView setFrame:iconViewFrame];
        
        CGRect titleLabelFrame = titleLabel.frame;
        titleLabelFrame.origin.x = TITLE_LABEL_X  - DELTA_X;
        [titleLabel setFrame:titleLabelFrame];
        
        CGRect progressFrame = progress.frame;
        progressFrame.origin.x = TITLE_LABEL_X - DELTA_X;
        [progress setFrame:progressFrame];

        CGRect tipsTitleLabelFrame = tipsTitleLabel.frame;
        tipsTitleLabelFrame.origin.x = TITLE_LABEL_X - DELTA_X;
        [tipsTitleLabel setFrame:tipsTitleLabelFrame];
        
        //[customButton setHidden:NO];
        
        [UIView commitAnimations];
    }
}

- (BOOL)rowSelected
{
    return isSelected;
}

- (void)selectRow:(BOOL)toSelect
{
    isSelected = toSelect;
    
    if(isSelected)
        [checkImageView setImage:[UIImage imageNamed:@"Selected.png"]];
    else
        [checkImageView setImage:[UIImage imageNamed:@"Unselected.png"]];
}

@end
