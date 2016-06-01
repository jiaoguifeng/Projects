//
//  DeviceListTableViewCell.h
//  MyLink
//
//  Created by chen on 16/1/14.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *hostNameLabel;
@property (nonatomic, strong) UILabel *ipAddressLabel;
@property (nonatomic, strong) UILabel *macAddressLabel;
@property (nonatomic, strong) UILabel *connectModeLabel;
@property (nonatomic, strong) UILabel *connectTimeLabel;

@end
