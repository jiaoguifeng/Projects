//
//  NetworkSettingViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "NetworkSettingViewController.h"

#define CELL_HEIGHT 25

@interface NetworkSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    DataContainer *container;
    
    UILabel *networkSelectLabel;
    SevenSwitch *networkSelectSwitch;

    //
    DataContainer *tableContainer;
    UITableView *networkSelectTable;
    NSMutableArray *networkList;
    
    //
    UIButton *okButton;
    UIButton *searchButton;
    
    //
    float heightLevel1;
    float heightLevel2;
    
    //
    NSInteger currentSelectedNetworkIndex;
}
@end

@implementation NetworkSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"networkSettingStr",NULL,@"WanUIStrings")];
    
    [self setupUIControls];
    
    [self initData];
    
    [self getNeworkSettingData];
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

#pragma mark - Switch Control action

- (void)switchControlAction:(id)sender
{
    if(!networkSelectSwitch.on)
    {
        [self setLevelHeight:heightLevel2];
    }
    else
    {
        [self setLevelHeight:heightLevel1];
    }
}

#pragma mark - OK/Cancel button actions

- (void)buttonAction:(id)sender
{
    if(sender == searchButton)
    {
        [self searchingNework];
    }
    else if(sender == okButton)
    {
        [self setNeworkSettingData];
    }
}

#pragma mark - set/get data

- (void)getNeworkSettingData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWanNetworkSettingData:^(id data, NSError *error) {
        if(data)
        {
            //
            networkSelectSwitch.on = [[data objectForKey:Net_Search_Mode] isEqualToString:@"0"] ? YES : NO;
            if(networkSelectSwitch.on)
                [self setLevelHeight:heightLevel1];
            else
                [self setLevelHeight:heightLevel2];
            
            [networkSelectTable reloadData];
        }

        [[Utility defaultUtility] hudClose];
    }];
}

- (void)searchingNework
{
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Net_Search_List,URL_CONFIG_ID,
                                 nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *operatorListStr = [data objectForKey:@"result"];
            if([operatorListStr isEqualToString:@"error"])
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"networkSearchErrorStr",NULL,@"TipStrings")];
            }
            else
            {
                NSArray *operatorList = [operatorListStr componentsSeparatedByString:@">"];
                for(int i = 0; i < operatorList.count; i++)
                {
                    NSArray *tempOperator = [[operatorList objectAtIndex:i] componentsSeparatedByString:@","];
                    if(tempOperator.count == 5)
                    {
                        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [tempOperator objectAtIndex:0],Operator_Name,
                                                  [tempOperator objectAtIndex:1],Operator_Network_Type,
                                                  [tempOperator objectAtIndex:2],Operator_Currrent_Status,
                                                  [tempOperator objectAtIndex:3],Operator_Identity,
                                                  [tempOperator objectAtIndex:4],Operator_Rrat, nil];
                        [networkList addObject:tempDict];
                        [networkSelectTable reloadData];
                    }
                }
                
                [self adjustContainer];
            }
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setNeworkSettingData
{
    if(networkSelectSwitch.on)
    {
        NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     Config_Net_Search_Setting,URL_CONFIG_ID,
                                     @"0",Net_Search_Select_Changed,
                                     @"0",Net_Search_Mode,
                                     nil];
        
        [[Utility defaultUtility] hudShowWithTitle:@""];
        [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
            if(data)
            {
            }
            
            [[Utility defaultUtility] hudClose];
        }];
    }
    else
    {
        NSUInteger theSelectdIndex = -1;
        NSIndexPath *selectedIndexPath = [networkSelectTable indexPathForSelectedRow];
        if(selectedIndexPath.length > 0)
            theSelectdIndex = [selectedIndexPath indexAtPosition:0];
        
        //if(selectedIndexPath == nil || theSelectdIndex == -1)
        if(selectedIndexPath == nil || currentSelectedNetworkIndex == -1)
        {
            [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"networkOKErrorStr",NULL,@"TipStrings")];
        }
        else
        {
            NSDictionary *selectedDict = [networkList objectAtIndex:currentSelectedNetworkIndex];
            if(selectedDict)
            {
                NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                             Config_Net_Search_Setting,URL_CONFIG_ID,
                                             @"1",Net_Search_Select_Changed,
                                             @"1",Net_Search_Mode,
                                             [selectedDict objectForKey:Operator_Currrent_Status],Net_Search_Select_ID1,
                                             [selectedDict objectForKey:Operator_Rrat],Net_Search_Select_ID2,
                                             [selectedDict objectForKey:Operator_Network_Type],Net_Search_Select_Type,
                                             nil];
                
                [[Utility defaultUtility] hudShowWithTitle:@""];
                [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
                    if(data)
                    {
                    }
                    
                    [[Utility defaultUtility] hudClose];
                }];
            }
            else
            {
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return networkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    NetworkSelectTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[NetworkSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        theCell.backgroundColor = [UIColor clearColor];
    }
    
    NSDictionary *tempDict = [networkList objectAtIndex:indexPath.row];
    if(tempDict)
    {
        theCell.operatorLabel.text = [tempDict objectForKey:Operator_Name];
        theCell.serviceLabel.text = [tempDict objectForKey:Operator_Network_Type];
        theCell.statusLabel.text = [tempDict objectForKey:Operator_Currrent_Status];
    }
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentSelectedNetworkIndex = indexPath.row;
}

#pragma mark - Init data

- (void)initData
{
    currentSelectedNetworkIndex = -1;
    networkList = [[NSMutableArray alloc] initWithCapacity:0];
    [self setLevelHeight:heightLevel1];
}

#pragma mark - Init UI Controls

- (void)setupUIControls
{
    CGRect sFrame = self.view.bounds;
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:@""];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // Network Selection TitleLabel
    networkSelectLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"networkSettingSelectionStr",NULL,@"networkSettingUIStrings")];
    [container addSubview:networkSelectLabel];
    
    // Network Selection Switch
    networkSelectSwitch = [self switchControl:CGRectMake(controlsXDelta, networkSelectLabel.frame.origin.y + networkSelectLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"manualStr",NULL,@"TipStrings")];
    networkSelectSwitch.on = NO;
    [container addSubview:networkSelectSwitch];
    
    //
    heightLevel1 = networkSelectSwitch.frame.origin.y + networkSelectSwitch.frame.size.height + controlsYDelta*2;
    [container setHeight:heightLevel1];
    
    //
    tableContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 30) title:NSLocalizedStringFromTable(@"networkSettingNetworkList",NULL,@"networkSettingUIStrings")];
    [self addSubview:tableContainer];
    
    networkSelectTable = [[UITableView alloc] initWithFrame:CGRectMake(0, [tableContainer headerHeight], tableContainer.frame.size.width, tableContainer.frame.size.height - [tableContainer headerHeight]) style:UITableViewStylePlain];
    networkSelectTable.dataSource = self;
    networkSelectTable.delegate = self;
    networkSelectTable.backgroundColor = [UIColor clearColor];
    networkSelectTable.separatorColor = [UIColor darkGrayColor];
    [tableContainer addSubview:networkSelectTable];

    //
    heightLevel2 = tableContainer.frame.origin.y + tableContainer.frame.size.height + controlsYDelta*2;
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + tableContainer.frame.size.width/2 + 5, tableContainer.frame.origin.y + tableContainer.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width/2 - 5, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [self addSubview:okButton];

    //
    searchButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, tableContainer.frame.origin.y + tableContainer.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width/2 - 5, 30) title:NSLocalizedStringFromTable(@"searchStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [self addSubview:searchButton];

    //
    [self setLevelHeight:heightLevel1];
    //[tableContainer setHeight:heightLevel2];
}

- (void)setLevelHeight:(float)levelHeight
{
    BOOL toHide = NO;
    if(levelHeight == heightLevel1)
    {
        toHide = YES;
        [tableContainer setHeight:heightLevel1];
    }
    else
    {
        toHide = NO;
        [tableContainer setHeight:heightLevel2];
    }
    
    tableContainer.hidden = toHide;
    networkSelectTable.hidden = toHide;
    searchButton.hidden = toHide;
    
    [self adjustContainer];
}

- (void)adjustContainer
{
    [tableContainer setHeight:[tableContainer headerHeight] + networkList.count*CELL_HEIGHT];
    
    CGRect tableRect = networkSelectTable.frame;
    tableRect.size.height = networkList.count*CELL_HEIGHT;
    networkSelectTable.frame = tableRect;
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)tableContainer.superview;
    float controlsHeight = container.frame.size.height + okButton.frame.size.height + tableContainer.frame.size.height + searchButton.frame.size.height + DATA_CONTAINER_GAP*6;
    if(controlsHeight > containerScrollView.frame.size.height)
        [self setContentHeight:controlsHeight];
    else
    {
        [self setContentHeight:containerScrollView.frame.size.height+1];
    }
    
    CGRect searchButtonRect = searchButton.frame;
    searchButtonRect.origin.y = tableContainer.frame.origin.y + tableContainer.frame.size.height + DATA_CONTAINER_GAP;
    searchButton.frame = searchButtonRect;

    if(searchButton.hidden == YES)
    {
        CGRect okButtonRect = okButton.frame;
        okButtonRect.origin.y = container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP;
        okButton.frame = okButtonRect;
    }
    else
    {
        CGRect okButtonRect = okButton.frame;
        okButtonRect.origin.y = tableContainer.frame.origin.y + tableContainer.frame.size.height + DATA_CONTAINER_GAP;
        okButton.frame = okButtonRect;
    }
}

@end
