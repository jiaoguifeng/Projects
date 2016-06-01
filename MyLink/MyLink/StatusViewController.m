//
//  StatusViewController.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "StatusViewController.h"
#import "DeviceListTableViewCell.h"

#define Basic_Title_List [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"statusWiFiSwitchStr",NULL,@"StatusUIStrings"),NSLocalizedStringFromTable(@"statusWiFiSSIDStr",NULL,@"StatusUIStrings"),NSLocalizedStringFromTable(@"statusWiFiChannelStr",NULL,@"StatusUIStrings"),NSLocalizedStringFromTable(@"statusWiFiSecurityStr",NULL,@"StatusUIStrings"), nil]

#define TITLE_LIST  @[NSLocalizedStringFromTable(@"statusHostNameStr",NULL,@"StatusUIStrings"),NSLocalizedStringFromTable(@"statusIPAddressStr",NULL,@"StatusUIStrings"),NSLocalizedStringFromTable(@"statusMACAddressStr",NULL,@"StatusUIStrings"),NSLocalizedStringFromTable(@"statusConnectModeStr",NULL,@"StatusUIStrings"),NSLocalizedStringFromTable(@"statusConnectTimeStr",NULL,@"StatusUIStrings")]

@interface StatusViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    DataContainer *container1;
    UITableView *container1TableView;
    NSMutableArray *container1List;

    DataContainer *container2;
    UITableView *container2TableView;
    NSMutableArray *container2List;
    
    DataContainer *deviceContainer;
    UITableView *deviceListTable;
    NSMutableArray *deviceList;
}
@end

@implementation StatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"statusStr",NULL,@"SettingMainUIStrings")];
    
    container1List = [[NSMutableArray alloc] initWithCapacity:0];
    container2List = [[NSMutableArray alloc] initWithCapacity:0];
    deviceList = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self setupUIControls];
    
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    if(tableView == container1TableView)
        return container1List.count;
    else if(tableView == container2TableView)
        return container2List.count;
    else if(tableView == deviceListTable)
        return deviceList.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    if(tableView == deviceListTable)
    {
        ListTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(theCell == NULL)
        {
            theCell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier subTitleWidth:100.0 subTitleCount:5];
        }
        
        [theCell setTitleList:TITLE_LIST];
        NSDictionary *tempDict = [deviceList objectAtIndex:indexPath.row];
        [theCell contentLabelAtIndex:0].text = [tempDict objectForKey:Device_HostName];
        [theCell contentLabelAtIndex:1].text = [tempDict objectForKey:Device_IP];
        [theCell contentLabelAtIndex:2].text = [tempDict objectForKey:Device_MacAddress];
        [theCell contentLabelAtIndex:3].text = [WiFi_Connect_Mode_Value objectForKey:[tempDict objectForKey:Device_Mode]];
        
        int linkRouterTime = [[tempDict objectForKey:Device_Connect_Duration] intValue];
        NSString* linkRouterTimeStr = [NSString stringWithFormat:@"%02d:%02d:%02d",linkRouterTime/3600,(linkRouterTime%3600)/60, linkRouterTime%60];
        [theCell contentLabelAtIndex:4].text = linkRouterTimeStr;
        
        return theCell;
    }
    else
    {
        UITableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(theCell == NULL)
        {
            theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            theCell.backgroundColor = [UIColor clearColor];
            
            theCell.textLabel.font = [UIFont systemFontOfSize:12];
            
            theCell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            theCell.detailTextLabel.textColor = [UIColor darkGrayColor];
        }
        
        NSDictionary *tempDict = nil;
        if(tableView == container1TableView)
            tempDict = [container1List objectAtIndex:indexPath.row];
        else
            tempDict = [container2List objectAtIndex:indexPath.row];

        theCell.textLabel.text = [tempDict objectForKey:@"itemTitle"];
        theCell.detailTextLabel.text = [tempDict objectForKey:@"itemValue"];
        
        return theCell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == deviceListTable)
        return 85.0;
    
    return 40.0;
}

#pragma mark - 

- (void)initData
{
    NSArray *basic24List = [NSArray arrayWithObjects:@"-",@"-",@"-",@"-", nil];
    NSArray *basic5List = [NSArray arrayWithObjects:@"-",@"-",@"-",@"-", nil];
    
    NSDictionary *tempDict = nil;
    for(int i = 0; i < 4; i++)
    {
        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [Basic_Title_List objectAtIndex:i],@"itemTitle",
                    [basic24List objectAtIndex:i],@"itemValue", nil];
        [container1List addObject:tempDict];

        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [Basic_Title_List objectAtIndex:i],@"itemTitle",
                    [basic5List objectAtIndex:i],@"itemValue", nil];
        [container2List addObject:tempDict];
    }
    
    [self getStatusData];
}

- (void)getStatusData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestStatusData:^(id data, NSError *error) {
        if(data)
        {
            // 2.4G WiFi basic info
            NSString *wifiSwitch2G = ([[data objectForKey:WiFi_Enable_2G] isEqualToString:@"1"]) ? NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") : NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings");
            NSString *wifiSSID2G = [data objectForKey:WiFi_SSID_2G];
            NSString *wifiChannel2G = ([[data objectForKey:WiFi_Channel_2G] isEqualToString:@"0"] ? NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings") : [data objectForKey:WiFi_Channel_2G]);
            NSString *wifiSecurityMode2G = [WiFi_SecurityMode_Value objectForKey:[data objectForKey:WiFi_SecurityMode_2G]];
            NSArray *basic24List = [NSArray arrayWithObjects:wifiSwitch2G,wifiSSID2G,wifiChannel2G,wifiSecurityMode2G, nil];
            
            // 4G WiFi basic info
            NSString *wifiSwitch5G = ([[data objectForKey:WiFi_Enable_5G] isEqualToString:@"1"]) ? NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") : NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings");
            NSString *wifiSSID5G = [data objectForKey:WiFi_SSID_5G];
            NSString *wifiChannel5G = ([[data objectForKey:WiFi_Channel_5G] isEqualToString:@"0"] ? NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings") : [data objectForKey:WiFi_Channel_5G]);
            NSString *wifiSecurityMode5G = [WiFi_SecurityMode_Value objectForKey:[data objectForKey:WiFi_SecurityMode_5G]];
            NSArray *basic5List = [NSArray arrayWithObjects:wifiSwitch5G,wifiSSID5G,wifiChannel5G,wifiSecurityMode5G, nil];
            
            NSDictionary *tempDict = nil;
            [container1List removeAllObjects];
            [container2List removeAllObjects];
            for(int i = 0; i < 4; i++)
            {
                tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [Basic_Title_List objectAtIndex:i],@"itemTitle",
                            [basic24List objectAtIndex:i],@"itemValue", nil];
                [container1List addObject:tempDict];
                
                tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [Basic_Title_List objectAtIndex:i],@"itemTitle",
                            [basic5List objectAtIndex:i],@"itemValue", nil];
                [container2List addObject:tempDict];
            }

            [container1TableView reloadData];
            [container2TableView reloadData];

            // Device list
            NSArray *tempDeviceList = [[data objectForKey:Get_Device_list] objectForKey:Device_List_Clients];
            for(NSDictionary *dict in tempDeviceList)
            {
                [deviceList addObject:dict];
            }
            
            [self adjustDeviceContainer];
            [deviceListTable reloadData];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - Init UI Controls

- (void)setupUIControls
{
    CGRect sFrame = self.view.bounds;
    
    //
    container1 = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 190) title:NSLocalizedStringFromTable(@"statusWiFi24GTitleStr",NULL,@"StatusUIStrings")];
    [self addSubview:container1];

    container1TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [container1 headerHeight], container1.frame.size.width, container1.frame.size.height - [container1 headerHeight]) style:UITableViewStylePlain];
    container1TableView.dataSource = self;
    container1TableView.delegate = self;
    container1TableView.backgroundColor = [UIColor clearColor];
    container1TableView.separatorColor = [UIColor darkGrayColor];
    container1TableView.allowsSelection = NO;
    [container1 addSubview:container1TableView];

    //
    container2 = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, container1.frame.origin.y + container1.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 190) title:NSLocalizedStringFromTable(@"statusWiFi5GTitleStr",NULL,@"StatusUIStrings")];
    [self addSubview:container2];

    container2TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [container2 headerHeight], container2.frame.size.width, container2.frame.size.height - [container2 headerHeight]) style:UITableViewStylePlain];
    container2TableView.dataSource = self;
    container2TableView.delegate = self;
    container2TableView.backgroundColor = [UIColor clearColor];
    container2TableView.separatorColor = [UIColor darkGrayColor];
    container2TableView.allowsSelection = NO;
    [container2 addSubview:container2TableView];
    
    //
    deviceContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, container2.frame.origin.y + container2.frame.size.height + DATA_CONTAINER_GAP, self.view.bounds.size.width-DATA_CONTAINER_GAP*2, 30) title:NSLocalizedStringFromTable(@"statusDeviceListTitleStr",NULL,@"StatusUIStrings")];
    [self addSubview:deviceContainer];
    
    deviceListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, [deviceContainer headerHeight], deviceContainer.frame.size.width, deviceContainer.frame.size.height - [deviceContainer headerHeight]) style:UITableViewStylePlain];
    deviceListTable.dataSource = self;
    deviceListTable.delegate = self;
    deviceListTable.backgroundColor = [UIColor clearColor];
    deviceListTable.separatorColor = [UIColor darkGrayColor];
    deviceListTable.allowsSelection = NO;
    [deviceContainer addSubview:deviceListTable];

}

- (void)adjustDeviceContainer
{
    [deviceContainer setHeight:[deviceContainer headerHeight] + deviceList.count*85];
    
    CGRect tableRect = deviceListTable.frame;
    tableRect.size.height += deviceList.count*85;
    deviceListTable.frame = tableRect;
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    float controlsHeight = container1.frame.size.height + container2.frame.size.height + deviceContainer.frame.size.height + DATA_CONTAINER_GAP*4;
    if(controlsHeight > [self contentHeight])
        [self setContentHeight:controlsHeight];
}

@end
