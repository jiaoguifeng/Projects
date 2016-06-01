//
//  AddComponentsViewController.m
//  MyLink
//
//  Created by chen on 15/12/29.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "AddComponentsViewController.h"
#import "AddComponentsTableViewCell.h"

#import "ExtendedViewController.h"
#import "SomeSettingsViewController.h"
#import "CommonViewController.h"

@interface AddComponentsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *addComponentsTable;
    NSMutableArray *addComponentsList;
    
    ExtendedViewController *extendedVC;
    SomeSettingsViewController *someSettingsVC;
    CommonViewController *commonVC;
}
@end

@implementation AddComponentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"addComponentsStr",NULL,@"AddComponentUIStrings")];
    
    //
    addComponentsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) style:UITableViewStylePlain];
    addComponentsTable.dataSource = self;
    addComponentsTable.delegate = self;
    addComponentsTable.backgroundColor = [UIColor clearColor];
    addComponentsTable.separatorColor = [UIColor darkGrayColor];
    [self addSubview:addComponentsTable];
    
    //
    NSArray *tempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"functionsUIStr",NULL,@"AddComponentUIStrings"),
                         NSLocalizedStringFromTable(@"someSettingsUIStr",NULL,@"AddComponentUIStrings"),
                         NSLocalizedStringFromTable(@"commonFunctionUIStr",NULL,@"AddComponentUIStrings"),nil];
    NSArray *subTempList = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"functionsUISubStr",NULL,@"AddComponentUIStrings"),
                            NSLocalizedStringFromTable(@"someSettingsUISubStr",NULL,@"AddComponentUIStrings"),
                            NSLocalizedStringFromTable(@"commonFunctionUISubStr",NULL,@"AddComponentUIStrings"),nil];
    
    NSDictionary *tempDict = nil;
    addComponentsList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < tempList.count - 1; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[tempList objectAtIndex:i],@"itemTitle",[subTempList objectAtIndex:i],@"itemSubTitle",[NSNumber numberWithInt:i],@"itemIndex", nil];
        [addComponentsList addObject:tempDict];
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
    return addComponentsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    AddComponentsTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[AddComponentsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    theCell.titleLabel.text = [[addComponentsList objectAtIndex:indexPath.row] objectForKey:@"itemTitle"];
    theCell.subTitleLabel.text = [[addComponentsList objectAtIndex:indexPath.row] objectForKey:@"itemSubTitle"];

    return theCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch(indexPath.row)
    {
        case 0:
            if(extendedVC)
                extendedVC = nil;
            extendedVC = [[ExtendedViewController alloc] init];
            [self.navigationController pushViewController:extendedVC animated:YES];
            break;
            
        case 1:
            if(someSettingsVC)
                someSettingsVC = nil;
            someSettingsVC = [[SomeSettingsViewController alloc] init];
            [self.navigationController pushViewController:someSettingsVC animated:YES];
            break;
        case 2:
            if(commonVC)
                commonVC = nil;
            commonVC = [[CommonViewController alloc] init];
            [self.navigationController pushViewController:commonVC animated:YES];
            break;
            
        default:
            break;
    }

}

@end
