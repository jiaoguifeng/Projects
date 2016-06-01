//
//  ListTableViewCell.h
//  MyLink
//
//  Created by chen on 1/18/16.
//  Copyright © 2016 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier subTitleWidth:(float)subTitleWidth subTitleCount:(NSInteger)subTitleCount;

- (void)setTitleList:(NSArray *)titleList;
- (UILabel *)contentLabelAtIndex:(NSInteger )index;

@end
