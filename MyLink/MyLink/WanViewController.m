//
//  WanViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "WanViewController.h"

#import "ProfileMgrViewController.h"
#import "NetworkSettingViewController.h"
#import "MobileConnectViewController.h"
#import "PINMgrViewController.h"

@interface WanViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *wanTable;
    NSMutableArray *wanList;
    
    ProfileMgrViewController *profileMgrVC;
    NetworkSettingViewController *networkSetingVC;
    MobileConnectViewController *mobileConnectVC;
    PINMgrViewController *pinMgrVC;
}
@end

@implementation WanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"wanStr",NULL,@"SettingUIStrings")];
    
    wanTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) style:UITableViewStylePlain];
    wanTable.dataSource = self;
    wanTable.delegate = self;
    wanTable.backgroundColor = [UIColor clearColor];
    wanTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:wanTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"profileMgrStr",NULL,@"WanUIStrings"),
                         NSLocalizedStringFromTable(@"networkSettingStr",NULL,@"WanUIStrings"),
                         NSLocalizedStringFromTable(@"mobileConnStr",NULL,@"WanUIStrings"),
                         NSLocalizedStringFromTable(@"pinMgrStr",NULL,@"WanUIStrings"),nil];
    
    NSDictionary *tempDict = nil;
    wanList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[tempList objectAtIndex:i],@"itemTitle",[NSNumber numberWithInt:i],@"itemIndex", nil];
        [wanList addObject:tempDict];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return wanList.count;
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
    theCell.textLabel.text = [[wanList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
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
    
    if ([[Utility defaultUtility] currentModemStatus] == NO)
    {
        return;
    }
    
    switch(indexPath.row)
    {
        case 0:
            if(profileMgrVC)
                profileMgrVC = nil;
            profileMgrVC = [[ProfileMgrViewController alloc] init];
            [self.navigationController pushViewController:profileMgrVC animated:YES];
            break;
            
        case 1:
            if(networkSetingVC)
                networkSetingVC = nil;
            networkSetingVC = [[NetworkSettingViewController alloc] init];
            [self.navigationController pushViewController:networkSetingVC animated:YES];
            break;
            
        case 2:
            if(mobileConnectVC)
                mobileConnectVC = nil;
            mobileConnectVC = [[MobileConnectViewController alloc] init];
            [self.navigationController pushViewController:mobileConnectVC animated:YES];
            break;
            
        case 3:
            if(pinMgrVC)
                pinMgrVC = nil;
            pinMgrVC = [[PINMgrViewController alloc] init];
            [self.navigationController pushViewController:pinMgrVC animated:YES];
            break;
            
        default:
            break;
    }
}

@end
