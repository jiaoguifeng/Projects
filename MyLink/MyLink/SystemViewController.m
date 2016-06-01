//
//  SystemViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "SystemViewController.h"

#import "ModifyPasswordViewController.h"
#import "RestoreViewController.h"
#import "RebootViewController.h"
#import "TimeViewController.h"
#import "StorageViewController.h"

@interface SystemViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *systemTable;
    NSMutableArray *systemList;
    
    ModifyPasswordViewController *modifyPassVC;
    RestoreViewController *restoreVC;
    RebootViewController *rebootVC;
    TimeViewController *timeVC;
    StorageViewController *storageVC;
}
@end

@implementation SystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"systemStr",NULL,@"SettingUIStrings")];
    
    systemTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250) style:UITableViewStylePlain];
    systemTable.dataSource = self;
    systemTable.delegate = self;
    systemTable.backgroundColor = [UIColor clearColor];
    systemTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:systemTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"modifyPassStr",NULL,@"SystemUIStrings"),
                         NSLocalizedStringFromTable(@"restoreStr",NULL,@"SystemUIStrings"),
                         NSLocalizedStringFromTable(@"rebootStr",NULL,@"SystemUIStrings"),
                         NSLocalizedStringFromTable(@"timeStr",NULL,@"SystemUIStrings"),
                         NSLocalizedStringFromTable(@"storageStr",NULL,@"SystemUIStrings"),nil];
    
    NSDictionary *tempDict = nil;
    systemList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[tempList objectAtIndex:i],@"itemTitle",[NSNumber numberWithInt:i],@"itemIndex", nil];
        [systemList addObject:tempDict];
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
    return systemList.count;
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
    theCell.textLabel.text = [[systemList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
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
            if(modifyPassVC)
                modifyPassVC = nil;
            modifyPassVC = [[ModifyPasswordViewController alloc] init];
            [self.navigationController pushViewController:modifyPassVC animated:YES];
            break;
            
        case 1:
            if(restoreVC)
                restoreVC = nil;
            restoreVC = [[RestoreViewController alloc] init];
            [self.navigationController pushViewController:restoreVC animated:YES];
            break;
            
        case 2:
            if(rebootVC)
                rebootVC = nil;
            rebootVC = [[RebootViewController alloc] init];
            [self.navigationController pushViewController:rebootVC animated:YES];
            break;
            
        case 3:
            if(timeVC)
                timeVC = nil;
            timeVC = [[TimeViewController alloc] init];
            [self.navigationController pushViewController:timeVC animated:YES];
            break;
            
        case 4:
            if(storageVC)
                storageVC = nil;
            storageVC = [[StorageViewController alloc] init];
            [self.navigationController pushViewController:storageVC animated:YES];
            break;

        default:
            break;
    }
}

@end
