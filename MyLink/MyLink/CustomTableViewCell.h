//
//  CustomTableViewCell.h
//  EasyWIFI
//
//  Created by chen on 3/11/15.
//  Copyright (c) 2015 lct. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTableViewCellDelegate

- (void)customButtonActions:(int)tag;

@end

@interface CustomTableViewCell : UITableViewCell
{
    id delegate;
    
    BOOL isSelected;
}

@property (nonatomic, strong) UIImageView *checkImageView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsTitleLabel;
@property (nonatomic,strong)  UIProgressView *progress;
@property (nonatomic, strong) UIButton *customButton;

@property (nonatomic, strong) id boundData;

- (id)delegate;
- (void)setDelegate:(id)theDelegate;

- (void)setMultiSelectMode:(BOOL)selectMode;

- (BOOL)rowSelected;
- (void)selectRow:(BOOL)toSelect;

@end
