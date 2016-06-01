//
//  AboutViewController.m
//  MyLink
//
//  Created by chen on 16/1/20.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "AboutViewController.h"
#import "Utility.h"

#define ABOUT_TITLE_LIST  @[NSLocalizedStringFromTable(@"aboutAppVerStr",NULL,@"AboutUIStrings"),NSLocalizedStringFromTable(@"aboutModemVerStr",NULL,@"AboutUIStrings"),NSLocalizedStringFromTable(@"aboutSoftwareVerStr",NULL,@"AboutUIStrings"),NSLocalizedStringFromTable(@"aboutHardwareVerStr",NULL,@"AboutUIStrings"),NSLocalizedStringFromTable(@"aboutIMEIStr",NULL,@"AboutUIStrings"),NSLocalizedStringFromTable(@"aboutMacAddrStr",NULL,@"AboutUIStrings"),NSLocalizedStringFromTable(@"aboutMacAddr5GStr",NULL,@"AboutUIStrings")]

@interface AboutViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    DataContainer *container;
    UITableView *containerTableView;
    NSMutableArray *containerList;
    
    NSInteger multiTapIndex;
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"aboutStr",NULL,@"SystemUIStrings")];
    
    [self setupUIControls];
    
    [self initData];
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
    return containerList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...

    UITableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        theCell.backgroundColor = [UIColor clearColor];
        theCell.selectedBackgroundView = [[UIView alloc] initWithFrame:theCell.frame];
        theCell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];

        
        theCell.textLabel.font = [UIFont systemFontOfSize:12];
        
        theCell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        theCell.detailTextLabel.textColor = [UIColor darkGrayColor];
        
        if(indexPath.row <= 3)
        {
            UITapGestureRecognizer *multiTabGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
            [multiTabGesture setNumberOfTapsRequired:5];
            [theCell addGestureRecognizer:multiTabGesture];
        }
    }
    
    NSDictionary *tempDict = [containerList objectAtIndex:indexPath.row];
    theCell.textLabel.text = [tempDict objectForKey:@"itemTitle"];
    theCell.detailTextLabel.text = [tempDict objectForKey:@"itemValue"];
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    multiTapIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (void)initData
{
    containerList = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self getStatusData];
}

- (void)getStatusData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestAboutData:^(id data, NSError *error) {
        if(data)
        {
            //[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            //[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
            //[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];

            NSString *tempStr = nil;
            NSMutableArray *valueList = [NSMutableArray arrayWithObjects:@"-",@"-",@"-",@"-",@"-",@"-",@"-", nil];
            
            tempStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            if(tempStr && tempStr.length > 0)
            {
                BOOL isAppStoreVer = NO;
                if(isAppStoreVer)
                    [valueList replaceObjectAtIndex:0 withObject:tempStr];
                else
                    [valueList replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@(Build %@)",tempStr,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
            }

            tempStr = [data objectForKey:About_Modem_Version];
            if(tempStr && tempStr.length > 0)
                [valueList replaceObjectAtIndex:1 withObject:[self removeFirstSpace:tempStr]];

            tempStr = [data objectForKey:About_Software_Version];
            if(tempStr && tempStr.length > 0)
                [valueList replaceObjectAtIndex:2 withObject:[self removeFirstSpace:tempStr]];

            tempStr = [data objectForKey:About_Hardware_Version];
            if(tempStr && tempStr.length > 0)
                [valueList replaceObjectAtIndex:3 withObject:[self removeFirstSpace:tempStr]];

            tempStr = [data objectForKey:About_IMEI];
            if(tempStr && tempStr.length > 0)
                [valueList replaceObjectAtIndex:4 withObject:tempStr];

            tempStr = [data objectForKey:About_MacAddress];
            if(tempStr && tempStr.length > 0)
                [valueList replaceObjectAtIndex:5 withObject:tempStr];

            tempStr = [data objectForKey:About_MacAddress5G];
            if(tempStr && tempStr.length > 0)
                [valueList replaceObjectAtIndex:6 withObject:tempStr];
            
            NSDictionary *tempDict = nil;
            for(int i = 0; i < valueList.count; i++)
            {
                tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [ABOUT_TITLE_LIST objectAtIndex:i],@"itemTitle",
                            [valueList objectAtIndex:i],@"itemValue",nil];
                
                [containerList addObject:tempDict];
            }
            
            [containerTableView reloadData];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - Init UI Controls

- (void)setupUIControls
{
    CGRect sFrame = self.view.bounds;
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 310) title:NSLocalizedStringFromTable(@"aboutTitleStr",NULL,@"AboutUIStrings")];
    [self addSubview:container];
    
    containerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [container headerHeight], container.frame.size.width, 280) style:UITableViewStylePlain];
    containerTableView.dataSource = self;
    containerTableView.delegate = self;
    containerTableView.backgroundColor = [UIColor clearColor];
    containerTableView.separatorColor = [UIColor darkGrayColor];
    containerTableView.allowsSelection = YES;
    [container addSubview:containerTableView];
}

#pragma mark - Utility

- (NSString *)removeFirstSpace:(NSString *)str
{
    NSMutableString *srcString = [NSMutableString stringWithString:str];
    unichar charStr = [srcString characterAtIndex:0];

    while(charStr == ' ')
    {
        [srcString setString:[srcString substringFromIndex:1]];
        charStr = [srcString characterAtIndex:0];
    }
    
    return srcString;
}

#pragma mark - Private setting

- (void)handleDoubleTap:(id)sender
{
    NSMutableDictionary *privateDict = [NSMutableDictionary dictionaryWithDictionary:[[Utility defaultUtility] privateConfigData]];
    
    NSString *keyValue = [NSString stringWithFormat:@"addr%@",[[NSNumber numberWithInteger:multiTapIndex] stringValue]];
    
    if([[privateDict objectForKey:keyValue] isEqualToString:@"0"])
    {
        [privateDict setObject:@"1" forKey:keyValue];
        [[Utility defaultUtility] showHudTipStr:[NSString stringWithFormat:@"%@ opened",keyValue]];
    }
    else
    {
        [privateDict setObject:@"0" forKey:keyValue];
        [[Utility defaultUtility] showHudTipStr:[NSString stringWithFormat:@"%@ closed",keyValue]];
    }
    
    [[Utility defaultUtility] setPrivateConfigData:privateDict];
}

@end
