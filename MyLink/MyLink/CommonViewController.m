//
//  CommonViewController.m
//  MyLink
//
//  Created by chen on 15/12/29.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "CommonViewController.h"
#import "PopView.h"

@interface CommonViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *commonFunctionTable;
    NSMutableArray *commonFunctionList;
    
    PopView *popView;
}
@end

@implementation CommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self setTItleTextFont:[UIFont systemFontOfSize:13.0]];
    [self setTitleText:NSLocalizedStringFromTable(@"commonFunctionUIStr",NULL,@"AddComponentUIStrings")];
    
    commonFunctionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250) style:UITableViewStylePlain];
    commonFunctionTable.dataSource = self;
    commonFunctionTable.delegate = self;
    commonFunctionTable.backgroundColor = [UIColor clearColor];
    commonFunctionTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:commonFunctionTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"loginAndOutStr",NULL,@"AddComponentUIStrings"),
                         NSLocalizedStringFromTable(@"statusStr",NULL,@"SettingMainUIStrings"),
                         NSLocalizedStringFromTable(@"connectionStr",NULL,@"SettingMainUIStrings"),
                         NSLocalizedStringFromTable(@"wifiDiskStr",NULL,@"SettingMainUIStrings"),
                         NSLocalizedStringFromTable(@"settingStr",NULL,@"SettingMainUIStrings"),nil];
    NSArray *descriptionList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"loginAndOutTipsStr",NULL,@"AddComponentUIStrings"),
                                NSLocalizedStringFromTable(@"statusStr",NULL,@"SettingMainUIStrings"),
                                NSLocalizedStringFromTable(@"connectionStr",NULL,@"SettingMainUIStrings"),
                                NSLocalizedStringFromTable(@"wifiDiskStr",NULL,@"SettingMainUIStrings"),
                                NSLocalizedStringFromTable(@"settingTipsStr",NULL,@"AddComponentUIStrings"), nil];
    NSArray *imageList = [NSArray arrayWithObjects:@"Personal change small",@"status",@"connection",@"wifi_disk chang",@"setting", nil];
    NSArray *buttonIDList = [NSArray arrayWithObjects:
                             [NSNumber numberWithInteger:TOUCH_BUTTON_LOGINOUT],
                             [NSNumber numberWithInteger:TOUCH_BUTTON_STATUS],
                             [NSNumber numberWithInteger:TOUCH_BUTTON_CONNECTION],
                             [NSNumber numberWithInteger:TOUCH_BUTTON_WIFIDISK],
                             [NSNumber numberWithInteger:TOUCH_BUTTON_SETTING],nil];

    NSDictionary *tempDict = nil;
    commonFunctionList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [tempList objectAtIndex:i],@"itemTitle",
                    [descriptionList objectAtIndex:i],@"itemDescription",
                    [NSNumber numberWithInt:i],@"itemIndex",
                    [imageList objectAtIndex:i],@"itemButtonImage",
                    [buttonIDList objectAtIndex:i],@"itemButtonID",nil];
        [commonFunctionList addObject:tempDict];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDictionary *statusDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"addComponentStatus", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDCOMPONENTSTAUSNOTIFICATION object: self userInfo:statusDict];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSDictionary *statusDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"addComponentStatus", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDCOMPONENTSTAUSNOTIFICATION object: self userInfo:statusDict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return commonFunctionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    UITableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        theCell.backgroundColor = [UIColor clearColor];
        theCell.selectedBackgroundView = [[UIView alloc] initWithFrame:theCell.frame];
        theCell.selectedBackgroundView.backgroundColor = [UIColor grayColor];
    }
    
    theCell.textLabel.font = [UIFont systemFontOfSize:16.0];
    theCell.textLabel.text = [[commonFunctionList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
    return theCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *infoDict = [commonFunctionList objectAtIndex:indexPath.row];

    if(popView)
        popView = nil;
    NSArray *btnList = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"addComponentStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_ADD],@"buttonID", nil],[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_CANCEL],@"buttonID", nil],nil];
    popView = [[PopView alloc] initWithTitle:[infoDict objectForKey:@"itemDescription"] buttonList:btnList];
    [popView showWithcompletion:^(id data, NSError *error) {
        if(data)
            [[NSNotificationCenter defaultCenter] postNotificationName:ADDCOMPONENTNOTIFICATION object: self userInfo:infoDict];
    }];
}

@end
