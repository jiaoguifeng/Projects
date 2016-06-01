//
//  ConnectionViewController.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "ConnectionViewController.h"
#import "PopSelectView.h"

@interface ConnectionViewController ()<UITextFieldDelegate>
{
    DataContainer *container;
    
    UILabel *connectLabel;
    UIButton *connectButton;
    
    //
    DataContainer *trafficContainer;
    
    UILabel *startDateLabel;
    UILabel *startDateContentLabel;
    
    UILabel *totalConnectTimeLabel;
    UILabel *totalConnectTimeContentLabel;
    
    UILabel *dataReceivedLabel;
    UILabel *dateReceivedContentLabel;
    
    UILabel *dateTransmittedLabel;
    UILabel *dateTransmittedContentLabel;
    
    UILabel *totalDataLabel;
    UILabel *totalDataContentLabel;
    
    UIButton *resetButton;
    
    //
    BOOL shouldBeExit;
}
@end

@implementation ConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"connectionStr",NULL,@"SettingMainUIStrings")];
    
    [self setupUIControls];
    
    [self getConnectionData:YES];
    
    shouldBeExit = NO;
    [NSThread detachNewThreadSelector:@selector(refreshConnectionData:) toTarget:self withObject:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    shouldBeExit = YES;
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

#pragma mark - Connectino UI refresh

- (void)refreshConnectionData:(id)sender
{
    while(YES)
    {
        @autoreleasepool
        {
            BOOL isNetworkConnected = YES;
            if(isNetworkConnected)
            {
                [self getConnectionData:NO];
            }

            if(shouldBeExit)
            {
                break;
            }
            
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}


#pragma mark - set/get data

- (void)getConnectionData:(BOOL)needHUD
{
    if(needHUD)
        [[Utility defaultUtility] hudShowWithTitle:@""];
    
    [[NetManager sharedNetManager] requestConnectionData:^(id data, NSError *error) {
        if(data)
        {
            //
            NSString *networkStatus = [data objectForKey:NETWORK_CONNECT_STATUS];
            if([networkStatus isEqualToString:NETWORK_DISCONNECTED])
            {
                connectButton.tag = 0;
                [connectButton setTitle:NSLocalizedStringFromTable(@"connectStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
                [connectButton setEnabled:YES];
            }
            else if([networkStatus isEqualToString:NETWORK_CONNECTED])
            {
                connectButton.tag = 1;
                [connectButton setTitle:NSLocalizedStringFromTable(@"disconnectStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
                [connectButton setEnabled:YES];
            }
            else if([networkStatus isEqualToString:NETWORK_CONNECTING])
            {
                [connectButton setTitle:NSLocalizedStringFromTable(@"connectingStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
                [connectButton setEnabled:NO];
            }
            else if([networkStatus isEqualToString:NETWORK_DISCONNECTING])
            {
                [connectButton setTitle:NSLocalizedStringFromTable(@"disconnectingStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
                [connectButton setEnabled:NO];
            }
            
            //
            startDateContentLabel.text = [data objectForKey:Network_Connect_StartDate];
            int connectTimes = [[data objectForKey:Network_Connect_Time_All] intValue];
            totalConnectTimeContentLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",connectTimes/3600,(connectTimes%3600)/60, connectTimes%60];
            
            long long sizeNum = 0;

            sizeNum = [[[[data objectForKey:Network_Connect_Sent_All] componentsSeparatedByString:@","] objectAtIndex:0] longLongValue];
            dateTransmittedContentLabel.text = [NSByteCountFormatter stringFromByteCount:sizeNum countStyle:NSByteCountFormatterCountStyleFile];

            sizeNum = [[[[data objectForKey:Network_Connect_Received_All] componentsSeparatedByString:@","] objectAtIndex:0] longLongValue];
            dateReceivedContentLabel.text = [NSByteCountFormatter stringFromByteCount:sizeNum countStyle:NSByteCountFormatterCountStyleFile];
            
            sizeNum = [[[[data objectForKey:Network_Connect_TotalData_All] componentsSeparatedByString:@","] objectAtIndex:0] longLongValue];
            totalDataContentLabel.text = [NSByteCountFormatter stringFromByteCount:sizeNum countStyle:NSByteCountFormatterCountStyleFile];
        }
        
        if(needHUD)
            [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - button actions

- (void)buttonAction:(id)sender
{
    if(sender == connectButton)
    {
        [self connectToNetwork];
    }
    else if(sender == resetButton)
    {
        [self resetTrafficData];
    }
}

- (void)connectToNetwork
{
    NSString *connectStr = @"0";
    if(connectButton.tag == 0)
        connectStr = @"1";
    
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_Network_Connect,URL_CONFIG_ID,
                                 connectStr,Network_Connect,
                                 nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        
        NSString *processStr = connectStr;
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                //[self getConnectionData:NO];
            }
            else
            {
                if([processStr isEqualToString:@"1"])
                    [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"connectNetworkErrStr",NULL,@"TipStrings")];
                else
                    [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"disconnectNetworkErrStr",NULL,@"TipStrings")];
            }
        }
        else
        {
            if([processStr isEqualToString:@"1"])
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"connectNetworkErrStr",NULL,@"TipStrings")];
            else
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"disconnectNetworkErrStr",NULL,@"TipStrings")];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)resetTrafficData
{
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_Traffic_Reset,URL_CONFIG_ID,
                                 nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [self getConnectionData:NO];
            }
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - Init UI Controls

- (void)setupUIControls
{
    CGRect sFrame = self.view.bounds;
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 100) title:NSLocalizedStringFromTable(@"connectionConnectStr",NULL,@"ConnectionUIStrings")];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // Connect TitleLabel
    //connectLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"connectionConnectStr",NULL,@"ConnectionUIStrings")];
    //[container addSubview:connectLabel];
    
    // Connect Button
    connectButton = [self baseButton:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP*2 + [container headerHeight], controlsWidth, 30) title:NSLocalizedStringFromTable(@"connectStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [container addSubview:connectButton];
    
    [container setHeight:connectButton.frame.origin.y + connectButton.frame.size.height + controlsYDelta*2];
    
    // ---------------------------------------------------------------------------------------------------------
    //
    trafficContainer = [[DataContainer alloc] initWithFrame:CGRectMake(controlsXDelta, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 100) title:NSLocalizedStringFromTable(@"connectionTrafficCounterStr",NULL,@"ConnectionUIStrings")];
    [self addSubview:trafficContainer];
    
    // Start Date TitleLabel
    startDateLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [trafficContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"connectionStareDateStr",NULL,@"ConnectionUIStrings")];
    [trafficContainer addSubview:startDateLabel];

    // Start Date Content TitleLabel
    startDateContentLabel = [self titleLabel:CGRectMake(controlsXDelta, startDateLabel.frame.origin.y + startDateLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:@"--"];
    startDateContentLabel.textColor = [UIColor darkGrayColor];
    startDateContentLabel.font = [UIFont systemFontOfSize:14.0];
    [trafficContainer addSubview:startDateContentLabel];

    // Total Connection Time TitleLabel
    totalConnectTimeLabel = [self titleLabel:CGRectMake(controlsXDelta, startDateContentLabel.frame.origin.y + startDateContentLabel.frame.size.height+controlsYDelta, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:NSLocalizedStringFromTable(@"connectionTotalConnectionTimeStr",NULL,@"ConnectionUIStrings")];
    [trafficContainer addSubview:totalConnectTimeLabel];
    
    // Total Connection Time Content TitleLabel
    totalConnectTimeContentLabel = [self titleLabel:CGRectMake(controlsXDelta, totalConnectTimeLabel.frame.origin.y + totalConnectTimeLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:@"--"];
    totalConnectTimeContentLabel.textColor = [UIColor darkGrayColor];
    totalConnectTimeContentLabel.font = [UIFont systemFontOfSize:14.0];
    [trafficContainer addSubview:totalConnectTimeContentLabel];

    // Data Received TitleLabel
    dataReceivedLabel = [self titleLabel:CGRectMake(controlsXDelta, totalConnectTimeContentLabel.frame.origin.y + totalConnectTimeContentLabel.frame.size.height+controlsYDelta, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:NSLocalizedStringFromTable(@"connectionReceivedStr",NULL,@"ConnectionUIStrings")];
    [trafficContainer addSubview:dataReceivedLabel];
    
    // Data Received Content TitleLabel
    dateReceivedContentLabel = [self titleLabel:CGRectMake(controlsXDelta, dataReceivedLabel.frame.origin.y + dataReceivedLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:@"--"];
    dateReceivedContentLabel.textColor = [UIColor darkGrayColor];
    dateReceivedContentLabel.font = [UIFont systemFontOfSize:14.0];
    [trafficContainer addSubview:dateReceivedContentLabel];
    
    // Data Transmitted TitleLabel
    dateTransmittedLabel = [self titleLabel:CGRectMake(controlsXDelta, dateReceivedContentLabel.frame.origin.y + dateReceivedContentLabel.frame.size.height+controlsYDelta, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:NSLocalizedStringFromTable(@"connectionTransmittedStr",NULL,@"ConnectionUIStrings")];
    [trafficContainer addSubview:dateTransmittedLabel];
    
    // Data Transmitted Content TitleLabel
    dateTransmittedContentLabel = [self titleLabel:CGRectMake(controlsXDelta, dateTransmittedLabel.frame.origin.y + dateTransmittedLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:@"--"];
    dateTransmittedContentLabel.textColor = [UIColor darkGrayColor];
    dateTransmittedContentLabel.font = [UIFont systemFontOfSize:14.0];
    [trafficContainer addSubview:dateTransmittedContentLabel];

    // Total Data TitleLabel
    totalDataLabel = [self titleLabel:CGRectMake(controlsXDelta, dateTransmittedContentLabel.frame.origin.y + dateTransmittedContentLabel.frame.size.height+controlsYDelta, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:NSLocalizedStringFromTable(@"connectionTotalDataStr",NULL,@"ConnectionUIStrings")];
    [trafficContainer addSubview:totalDataLabel];
    
    // Total Data Content TitleLabel
    totalDataContentLabel = [self titleLabel:CGRectMake(controlsXDelta, totalDataLabel.frame.origin.y + totalDataLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:@"--"];
    totalDataContentLabel.textColor = [UIColor darkGrayColor];
    totalDataContentLabel.font = [UIFont systemFontOfSize:14.0];
    [trafficContainer addSubview:totalDataContentLabel];

    [trafficContainer setHeight:totalDataContentLabel.frame.origin.y + totalDataContentLabel.frame.size.height + controlsYDelta*2];
    
    //
    resetButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, trafficContainer.frame.origin.y + trafficContainer.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"clearDataStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [self addSubview:resetButton];

    //
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)trafficContainer.superview;
    float controlsHeight = container.frame.size.height + trafficContainer.frame.size.height + resetButton.frame.size.height + DATA_CONTAINER_GAP*4;
    if(controlsHeight > containerScrollView.frame.size.height)
        [self setContentHeight:controlsHeight];
    else
    {
        [self setContentHeight:containerScrollView.frame.size.height+1];
    }
}

@end
