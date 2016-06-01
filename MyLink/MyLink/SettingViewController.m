//
//  SettingViewController.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "SettingViewController.h"
#import "QuickSetupViewController.h"
#import "WanViewController.h"
#import "WiFiViewController.h"
#import "RouterViewController.h"
#import "SystemViewController.h"
#import "AboutViewController.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *settingTable;
    NSMutableArray *settingList;
    
    QuickSetupViewController *quickSetupVC;
    WanViewController *wanVC;
    WiFiViewController *wifiVC;
    RouterViewController *routerVC;
    SystemViewController *systemVC;
    AboutViewController *aboutVC;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"settingStr",NULL,@"SettingMainUIStrings")];
    
    settingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) style:UITableViewStylePlain];
    settingTable.dataSource = self;
    settingTable.delegate = self;
    settingTable.backgroundColor = [UIColor clearColor];
    settingTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:settingTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"quickSetupStr",NULL,@"SettingUIStrings"),
                         NSLocalizedStringFromTable(@"wanStr",NULL,@"SettingUIStrings"),
                         NSLocalizedStringFromTable(@"wifiStr",NULL,@"SettingUIStrings"),
                         NSLocalizedStringFromTable(@"routerStr",NULL,@"SettingUIStrings"),
                         NSLocalizedStringFromTable(@"systemStr",NULL,@"SettingUIStrings"),
                         NSLocalizedStringFromTable(@"aboutStr",NULL,@"SettingUIStrings"),nil];
    
    NSDictionary *tempDict = nil;
    settingList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[tempList objectAtIndex:i],@"itemTitle",[NSNumber numberWithInt:i],@"itemIndex", nil];
        [settingList addObject:tempDict];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return settingList.count;
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
    theCell.textLabel.text = [[settingList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
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
    
    switch(indexPath.row)
    {
        case 0:
            if(quickSetupVC)
                quickSetupVC = nil;
            quickSetupVC = [[QuickSetupViewController alloc] init];
            [self.navigationController pushViewController:quickSetupVC animated:YES];
            break;
            
        case 1:
            if(wanVC)
                wanVC = nil;
            wanVC = [[WanViewController alloc] init];
            [self.navigationController pushViewController:wanVC animated:YES];
            break;
        case 2:
            if(wifiVC)
                wifiVC = nil;
            wifiVC = [[WiFiViewController alloc] init];
            [self.navigationController pushViewController:wifiVC animated:YES];
            break;
            
        case 3:
            if(routerVC)
                routerVC = nil;
            routerVC = [[RouterViewController alloc] init];
            [self.navigationController pushViewController:routerVC animated:YES];
            break;
            
        case 4:
            if(systemVC)
                systemVC = nil;
            systemVC = [[SystemViewController alloc] init];
            [self.navigationController pushViewController:systemVC animated:YES];
            break;
            
        case 5:
            if(aboutVC)
                aboutVC = nil;
            aboutVC = [[AboutViewController alloc] init];
            [self.navigationController pushViewController:aboutVC animated:YES];
            break;
           
        default:
            break;
    }
}


@end
