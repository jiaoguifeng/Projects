//
//  WiFiViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "WiFiViewController.h"

#import "WiFiSettingViewController.h"
#import "MACFilterViewController.h"
#import "WPSViewController.h"

@interface WiFiViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *wifiTable;
    NSMutableArray *wifiList;

    WiFiSettingViewController *wifiSettingVC;
    MACFilterViewController *macFilterVC;
    WPSViewController *wpsVC;
}

@end

@implementation WiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"wifiStr",NULL,@"SettingUIStrings")];
    
    wifiTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) style:UITableViewStylePlain];
    wifiTable.dataSource = self;
    wifiTable.delegate = self;
    wifiTable.backgroundColor = [UIColor clearColor];
    wifiTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:wifiTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"24GWiFiSettingStr",NULL,@"WiFiUIStrings"),
                         NSLocalizedStringFromTable(@"5GWiFiSettingStr",NULL,@"WiFiUIStrings"),
                         NSLocalizedStringFromTable(@"24GMacFilterStr",NULL,@"WiFiUIStrings"),
                         NSLocalizedStringFromTable(@"5GMacFilterStr",NULL,@"WiFiUIStrings"),
                         NSLocalizedStringFromTable(@"24GWPSStr",NULL,@"WiFiUIStrings"),
                         NSLocalizedStringFromTable(@"5GWPSStr",NULL,@"WiFiUIStrings"),nil];
    
    NSDictionary *tempDict = nil;
    wifiList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[tempList objectAtIndex:i],@"itemTitle",[NSNumber numberWithInt:i],@"itemIndex", nil];
        [wifiList addObject:tempDict];
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
    return wifiList.count;
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
    theCell.textLabel.text = [[wifiList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
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
            if(wifiSettingVC)
                wifiSettingVC = nil;
            wifiSettingVC = [[WiFiSettingViewController alloc] initWithType:BAND_TYPE_24G];
            [self.navigationController pushViewController:wifiSettingVC animated:YES];
            break;
            
        case 1:
            if(wifiSettingVC)
                wifiSettingVC = nil;
            wifiSettingVC = [[WiFiSettingViewController alloc] initWithType:BAND_TYPE_5G];
            [self.navigationController pushViewController:wifiSettingVC animated:YES];
            break;
            
        case 2:
            if(macFilterVC)
                macFilterVC = nil;
            macFilterVC = [[MACFilterViewController alloc] initWithType:BAND_TYPE_24G];
            [self.navigationController pushViewController:macFilterVC animated:YES];
            break;

        case 3:
            if(macFilterVC)
                macFilterVC = nil;
            macFilterVC = [[MACFilterViewController alloc] initWithType:BAND_TYPE_5G];
            [self.navigationController pushViewController:macFilterVC animated:YES];
            break;

        case 4:
            if(wpsVC)
                wpsVC = nil;
            wpsVC = [[WPSViewController alloc] initWithType:BAND_TYPE_24G];
            [wpsVC setTitleText:NSLocalizedStringFromTable(@"24GWPSStr",NULL,@"WiFiUIStrings")];
            [self.navigationController pushViewController:wpsVC animated:YES];
            break;

        case 5:
            if(wpsVC)
                wpsVC = nil;
            wpsVC = [[WPSViewController alloc] initWithType:BAND_TYPE_5G];
            [wpsVC setTitleText:NSLocalizedStringFromTable(@"5GWPSStr",NULL,@"WiFiUIStrings")];
            [self.navigationController pushViewController:wpsVC animated:YES];
            break;

        default:
            break;
    }
}

@end
