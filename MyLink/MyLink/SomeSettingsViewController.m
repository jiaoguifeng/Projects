//
//  SomeSettingsViewController.m
//  MyLink
//
//  Created by chen on 15/12/29.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "SomeSettingsViewController.h"
#import "PopView.h"

@interface SomeSettingsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *someFunctionTable;
    NSMutableArray *someFunctionList;
    
    PopView *popView;
}
@end

@implementation SomeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"someSettings1UIStr",NULL,@"AddComponentUIStrings")];
    
    someFunctionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) style:UITableViewStylePlain];
    someFunctionTable.dataSource = self;
    someFunctionTable.delegate = self;
    someFunctionTable.backgroundColor = [UIColor clearColor];
    someFunctionTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:someFunctionTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"quickSetupStr",NULL,@"SettingUIStrings"),
                         NSLocalizedStringFromTable(@"24GMacFilterStr",NULL,@"WiFiUIStrings"),
                         NSLocalizedStringFromTable(@"5GMacFilterStr",NULL,@"WiFiUIStrings"),
                         NSLocalizedStringFromTable(@"pinMgrStr",NULL,@"WanUIStrings"),nil];
    NSArray *descriptionList = [NSArray arrayWithObjects:
                                NSLocalizedStringFromTable(@"quickSettingTipsStr",NULL,@"AddComponentUIStrings"),
                                NSLocalizedStringFromTable(@"macFilterTipsStr",NULL,@"AddComponentUIStrings"),
                                NSLocalizedStringFromTable(@"macFilterTipsStr",NULL,@"AddComponentUIStrings"),
                                NSLocalizedStringFromTable(@"pinSettingTipsStr",NULL,@"AddComponentUIStrings"), nil];
    NSArray *imageList = [NSArray arrayWithObjects:@"config_tool",@"firewall",@"firewall",@"uim2", nil];
    NSArray *buttonIDList = [NSArray arrayWithObjects:
                             [NSNumber numberWithInteger:TOUCH_BUTTON_QUICKSETTING],
                             [NSNumber numberWithInteger:TOUCH_BUTTON_MACFILTER_24G],
                             [NSNumber numberWithInteger:TOUCH_BUTTON_MACFILTER_5G],
                             [NSNumber numberWithInteger:TOUCH_BUTTON_PINSETTING],nil];

    NSDictionary *tempDict = nil;
    someFunctionList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [tempList objectAtIndex:i],@"itemTitle",
                    [descriptionList objectAtIndex:i],@"itemDescription",
                    [NSNumber numberWithInt:i],@"itemIndex",
                    [imageList objectAtIndex:i],@"itemButtonImage",
                    [buttonIDList objectAtIndex:i],@"itemButtonID",nil];
        [someFunctionList addObject:tempDict];
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
    return someFunctionList.count;
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
    theCell.textLabel.text = [[someFunctionList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
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
    
    NSDictionary *infoDict = [someFunctionList objectAtIndex:indexPath.row];
    
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
