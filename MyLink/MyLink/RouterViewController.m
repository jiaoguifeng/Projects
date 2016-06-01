//
//  RouterViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "RouterViewController.h"

#import "UpnpSettingViewController.h"
#import "LanViewController.h"
#import "StaticDhcpViewController.h"
#import "DdnsViewController.h"
#import "LanIPFilterViewController.h"
#import "UrlFilterViewController.h"
#import "PortforwardViewController.h"
#import "DmzSettingViewController.h"

@interface RouterViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *routerTable;
    NSMutableArray *routerList;
    
    UpnpSettingViewController *upnpSettingVC;
    LanViewController *lanVC;
    StaticDhcpViewController *staticDhcpVC;
    DdnsViewController *ddnsVc;
    LanIPFilterViewController *lanIpFilterVC;
    UrlFilterViewController *urlFilterVC;
    PortforwardViewController *portForwardVC;
    DmzSettingViewController *dmzSettingVC;
}
@end

@implementation RouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"routerStr",NULL,@"SettingUIStrings")];
    
    routerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 400) style:UITableViewStylePlain];
    routerTable.dataSource = self;
    routerTable.delegate = self;
    routerTable.backgroundColor = [UIColor clearColor];
    routerTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:routerTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"upnpStr",NULL,@"RouterUIStrings"),
                         NSLocalizedStringFromTable(@"lanStr",NULL,@"RouterUIStrings"),
                         NSLocalizedStringFromTable(@"staticDhcpStr",NULL,@"RouterUIStrings"),
                         NSLocalizedStringFromTable(@"ddnsStr",NULL,@"RouterUIStrings"),
                         NSLocalizedStringFromTable(@"lanIpFilterStr",NULL,@"RouterUIStrings"),
                         NSLocalizedStringFromTable(@"urlFilterStr",NULL,@"RouterUIStrings"),
                         NSLocalizedStringFromTable(@"portForwardStr",NULL,@"RouterUIStrings"),
                         NSLocalizedStringFromTable(@"dmzStr",NULL,@"RouterUIStrings"),nil];
    
    NSDictionary *tempDict = nil;
    routerList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[tempList objectAtIndex:i],@"itemTitle",[NSNumber numberWithInt:i],@"itemIndex", nil];
        [routerList addObject:tempDict];
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
    return routerList.count;
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
    theCell.textLabel.text = [[routerList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
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
            if(upnpSettingVC)
                upnpSettingVC = nil;
            upnpSettingVC = [[UpnpSettingViewController alloc] init];
            [self.navigationController pushViewController:upnpSettingVC animated:YES];
            break;
            
        case 1:
            if(lanVC)
                lanVC = nil;
            lanVC = [[LanViewController alloc] init];
            [self.navigationController pushViewController:lanVC animated:YES];
            break;
            
        case 2:
            if(staticDhcpVC)
                staticDhcpVC = nil;
            staticDhcpVC = [[StaticDhcpViewController alloc] init];
            [self.navigationController pushViewController:staticDhcpVC animated:YES];
            break;
            
        case 3:
            if(ddnsVc)
                ddnsVc = nil;
            ddnsVc = [[DdnsViewController alloc] init];
            [self.navigationController pushViewController:ddnsVc animated:YES];
            break;
            
        case 4:
            if(lanIpFilterVC)
                lanIpFilterVC = nil;
            lanIpFilterVC = [[LanIPFilterViewController alloc] init];
            [self.navigationController pushViewController:lanIpFilterVC animated:YES];
            break;
            
        case 5:
            if(urlFilterVC)
                urlFilterVC = nil;
            urlFilterVC = [[UrlFilterViewController alloc] init];
            [self.navigationController pushViewController:urlFilterVC animated:YES];
            break;
            
        case 6:
            if(portForwardVC)
                portForwardVC = nil;
            portForwardVC = [[PortforwardViewController alloc] init];
            [self.navigationController pushViewController:portForwardVC animated:YES];
            break;

        case 7:
            if(dmzSettingVC)
                dmzSettingVC = nil;
            dmzSettingVC = [[DmzSettingViewController alloc] init];
            [self.navigationController pushViewController:dmzSettingVC animated:YES];
            break;

        default:
            break;
    }
}

@end
