//
//  WiFiSettingViewController.m
//  MyLink
//
//  Created by chen on 1/18/16.
//  Copyright © 2016 tricheer. All rights reserved.
//

#import "WiFiSettingViewController.h"

@interface WiFiSettingViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    BAND_TYPE              bandType;
    DataContainer          *wifiSettingContainer;
    
    UILabel                *wifiSwitchLbl;
    SevenSwitch            *wifiSwitch;
    
    UILabel                *broadcastLbl;
    SevenSwitch            *broadcastSwitch;
    
    UILabel                *ssidLbl;
    InputTextField         *ssidName;
    NSString               *wifiName;
    
    UILabel                *wirelessInterfaceLbl;
    SelectionButton        *interfaceSelectBtn;
    
    UILabel                *regulatoryDominLbl;
    SelectionButton        *regulatoryDominSelectBtn;

    UILabel                *channelLbl;
    SelectionButton        *channelSelectBtn;

    UILabel                *beaconIntervalLbl;
    InputTextField         *beaconInterval;

    UILabel                *bandWidthLbl;
    SelectionButton        *bandWidthSelectBtn;

    UILabel                *maxNumUserLbl;
    SelectionButton        *maxNumUserSelectBtn;
    
    UILabel                *securityModeLbl;
    SelectionButton        *securityModeSelectBtn;

    UILabel                *wifiPasswordLbl;
    InputTextField         *wifiPassword;
    
    UIButton               *saveBtn;
    
    InputTextField         *focusedInputTextField;
    
    NSMutableDictionary    *responseData;
    
    //被修改的password
    NSString              *modifiedPassword;
    NSString              *modifiedSecurity;
}
@end

@implementation WiFiSettingViewController

- (instancetype)initWithType:(BAND_TYPE)type
{
    self = [super init];
    if(self)
    {
        bandType = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(bandType == BAND_TYPE_24G)
    {
        [self setTitleText:NSLocalizedStringFromTable(@"24GWiFiSettingStr",NULL,@"WiFiUIStrings")];
        wifiName = @"";
    }
    else
    {
        [self setTitleText:NSLocalizedStringFromTable(@"5GWiFiSettingStr",NULL,@"WiFiUIStrings")];
        wifiName = @"";
    }
    
    //init Dictionary
    responseData = [[NSMutableDictionary alloc] initWithCapacity:0];

    //add tap event
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignEditing)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    //Set up Main UI
    [self setUpWiFiSettingMainUI];
    
    //get Data From Server
    if (bandType == BAND_TYPE_24G)
    {
        [self requestWiFiSettingDataFor2G];
    }
    else
    {
        [self requestWiFiSettingDataFor5G];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Set up Wi-Fi Setting UI
- (void)setUpWiFiSettingMainUI
{
    //setUp Container and controls
    [self setUpWiFiSettingContainer];
    
    //add save btn
    [self setUpSaveControl];
    
    //adjust scroll view
    [self adjustScrolView];
}

- (void)setUpWiFiSettingContainer
{
    NSString *containerTitle = nil;
    
    if(bandType == BAND_TYPE_24G)
        containerTitle = NSLocalizedStringFromTable(@"24GWiFiSettingStr",NULL,@"WiFiUIStrings");
    else
        containerTitle = NSLocalizedStringFromTable(@"5GWiFiSettingStr",NULL,@"WiFiUIStrings");

    wifiSettingContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, self.view.frame.size.width - DATA_CONTAINER_GAP * 2, 300) title:containerTitle];
    [self addSubview:wifiSettingContainer];
    
    [self setUpWiFiSetting];
}

- (void)setUpWiFiSetting
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = wifiSettingContainer.headerHeight +  DATA_CONTAINER_GAP * 0.5;
    CGFloat width = wifiSettingContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = INPUT_TEXTFIELD_HEIGHT;

    wifiSwitchLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"WiFiSwitchStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:wifiSwitchLbl];
    
    y = wifiSwitchLbl.frame.origin.y + wifiSwitchLbl.frame.size.height;
    wifiSwitch = [self switchControl:CGRectMake(x, y, 75, heigth) action:@selector(wifiSwitchAction) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    [wifiSettingContainer addSubview:wifiSwitch];
    
    //默认情况下是显示所有控件的
    wifiSwitch.on = YES;
    
    [self wifiSwitchEnable];
    
    [self adjustWiFiSettingContainerView];
}

- (void)wifiSwitchEnable
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = wifiSwitch.frame.origin.y + wifiSwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    CGFloat width = wifiSettingContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = INPUT_TEXTFIELD_HEIGHT;

    broadcastLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"BroadCastStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:broadcastLbl];
    
    y = broadcastLbl.frame.origin.y + broadcastLbl.frame.size.height;
    broadcastSwitch = [self switchControl:CGRectMake(x, y, 75, heigth) action:@selector(broadcastSwitchAction) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    [wifiSettingContainer addSubview:broadcastSwitch];
    
    y = broadcastSwitch.frame.origin.y + broadcastSwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    ssidLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"SSIDStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:ssidLbl];
    
    y = ssidLbl.frame.origin.y + ssidLbl.frame.size.height;
    ssidName = [self inputTextField:CGRectMake(x, y, width, heigth)];
    ssidName.text = wifiName;
    ssidName.delegate = self;
    [wifiSettingContainer addSubview:ssidName];
    
    y = ssidName.frame.origin.y + ssidName.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    wirelessInterfaceLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"WirelessInterfaceStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:wirelessInterfaceLbl];
    
    y = wirelessInterfaceLbl.frame.origin.y + wirelessInterfaceLbl.frame.size.height;
    interfaceSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(interfaceSelectionAction:)];
    [wifiSettingContainer addSubview:interfaceSelectBtn];
    
    y = interfaceSelectBtn.frame.origin.y + interfaceSelectBtn.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    regulatoryDominLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"RegulatoryDomainStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:regulatoryDominLbl];
    
    y = regulatoryDominLbl.frame.origin.y + regulatoryDominLbl.frame.size.height;
    regulatoryDominSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(regulatoryDomainSelectionAction:)];
    [wifiSettingContainer addSubview:regulatoryDominSelectBtn];
    
    y = regulatoryDominSelectBtn.frame.origin.y + regulatoryDominSelectBtn.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    channelLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"ChannelStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:channelLbl];
    
    y = channelLbl.frame.origin.y + channelLbl.frame.size.height;
    channelSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(channelSelectionAction:)];
    [wifiSettingContainer addSubview:channelSelectBtn];
    
    y = channelSelectBtn.frame.origin.y + channelSelectBtn.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    beaconIntervalLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"BeaconIntervalStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:beaconIntervalLbl];
    
    y = beaconIntervalLbl.frame.origin.y + beaconIntervalLbl.frame.size.height;
    beaconInterval = [self inputTextField:CGRectMake(x, y, width, heigth)];
    beaconInterval.delegate = self;
    beaconInterval.keyboardType = UIKeyboardTypeNumberPad;
    [wifiSettingContainer addSubview:beaconInterval];

    y = beaconInterval.frame.origin.y + beaconInterval.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    bandWidthLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"BandWidthStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:bandWidthLbl];
    
    y = bandWidthLbl.frame.origin.y + bandWidthLbl.frame.size.height;
    bandWidthSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(bandWidthSelectionAction:)];
    [wifiSettingContainer addSubview:bandWidthSelectBtn];

    y = bandWidthSelectBtn.frame.origin.y + bandWidthSelectBtn.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    maxNumUserLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"MaxNumberofUsersStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:maxNumUserLbl];
    
    y = maxNumUserLbl.frame.origin.y + maxNumUserLbl.frame.size.height;
    maxNumUserSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(maxNumberUserSelectionAction:)];
    [wifiSettingContainer addSubview:maxNumUserSelectBtn];


    y = maxNumUserSelectBtn.frame.origin.y + maxNumUserSelectBtn.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    securityModeLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"SecurityModeStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:securityModeLbl];
    
    y = securityModeLbl.frame.origin.y + securityModeLbl.frame.size.height;
    securityModeSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(securityModeSelectionAction:)];
    [wifiSettingContainer addSubview:securityModeSelectBtn];
    
    y = securityModeSelectBtn.frame.origin.y + securityModeSelectBtn.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    wifiPasswordLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"WiFiPasswordStr",NULL,@"wifiSettingUSStrings")];
    [wifiSettingContainer addSubview:wifiPasswordLbl];
    
    y = wifiPasswordLbl.frame.origin.y + wifiPasswordLbl.frame.size.height;
    wifiPassword = [self inputTextField:CGRectMake(x, y, width, heigth)];
    wifiPassword.secureTextEntry = YES;
    wifiPassword.delegate = self;
    [wifiSettingContainer addSubview:wifiPassword];
}

- (void)setUpSaveControl
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = wifiSettingContainer.frame.origin.y + wifiSettingContainer.frame.size.height + DATA_CONTAINER_GAP;
    CGFloat width = self.view.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = INPUT_TEXTFIELD_HEIGHT;

    if (saveBtn == nil)
    {
        saveBtn = [self baseButton:CGRectMake(x,y,width,heigth) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(saveDataAction)];
        [self addSubview:saveBtn];
    }
    else
    {
        y = wifiSettingContainer.frame.origin.y + wifiSettingContainer.frame.size.height + DATA_CONTAINER_GAP;
        saveBtn.frame = CGRectMake(x, y, width, heigth);
    }
    
}

- (void)updateWiFiSettingMainUI
{

    if (responseData.count > 0)
    {
        
        if (bandType == BAND_TYPE_24G)
        {
            wifiSwitch.on = [[responseData objectForKey:WiFi_Enable_2G] intValue];
            broadcastSwitch.on = [[responseData objectForKey:WiFi_SSID_Broadcast_2G] intValue];
            ssidName.text = [responseData objectForKey:WiFi_SSID_2G];
            regulatoryDominSelectBtn.titleLabel.text = [self getRegDomainFullWithString:[responseData objectForKey:WiFi_Reg_Domain_2G]];
            interfaceSelectBtn.titleLabel.text = [WiFi_Interface_Value_2G objectForKey:[responseData objectForKey:WiFi_Interface_2G]];
            
            if ([[responseData objectForKey:WiFi_Channel_2G] isEqualToString:@"0"])
            {
                channelSelectBtn.titleLabel.text = [Change_Zero_To_Auto objectForKey:[responseData objectForKey:WiFi_Channel_2G]];
            }
            else
            {
                channelSelectBtn.titleLabel.text = [responseData objectForKey:WiFi_Channel_2G];
            }
            
            beaconInterval.text = [responseData objectForKey:WiFi_Bintval_2G];
            bandWidthSelectBtn.titleLabel.text = [WiFi_Band_Width_Value_2G objectForKey:[responseData objectForKey:WiFi_Bandwidth_2G]];
            maxNumUserSelectBtn.titleLabel.text = [responseData objectForKey:WiFi_MaxSta_2G];
            securityModeSelectBtn.titleLabel.text = [WiFi_SecurityMode_Value  objectForKey:[responseData objectForKey:WiFi_SecurityMode_2G]];
            
            //记录原始的加密方式
            modifiedSecurity = [WiFi_SecurityMode_Value  objectForKey:[responseData objectForKey:WiFi_SecurityMode_2G]];
            
            if ([securityModeSelectBtn.titleLabel.text isEqualToString:@"None"])
            {
                
            }
            else if ([securityModeSelectBtn.titleLabel.text hasPrefix:@"WPA"])
            {
                wifiPassword.text = [responseData objectForKey:WiFi_Wpa_Password_2G];
                
                //记录原始的密码
                modifiedPassword = [responseData objectForKey:WiFi_Wpa_Password_2G];
            }
            else
            {
                wifiPassword.text = [responseData objectForKey:WiFi_Wep_Password_2G];
                
                //记录原始的密码
                modifiedPassword = [responseData objectForKey:WiFi_Wep_Password_2G];
            }
        }
        else
        {
            wifiSwitch.on = [[responseData objectForKey:WiFi_Enable_5G] intValue];
            broadcastSwitch.on = [[responseData objectForKey:WiFi_SSID_Broadcast_5G] intValue];
            ssidName.text = [responseData objectForKey:WiFi_SSID_5G];
            regulatoryDominSelectBtn.titleLabel.text = [self getRegDomainFullWithString:[responseData objectForKey:WiFi_Reg_Domain_5G]];
            interfaceSelectBtn.titleLabel.text = [WiFi_Interface_Value_5G objectForKey:[responseData objectForKey:WiFi_Interface_5G]];
            
            if ([[responseData objectForKey:WiFi_Channel_5G] isEqualToString:@"0"])
            {
                channelSelectBtn.titleLabel.text = [Change_Zero_To_Auto objectForKey:[responseData objectForKey:WiFi_Channel_5G]];
            }
            else
            {
                channelSelectBtn.titleLabel.text = [responseData objectForKey:WiFi_Channel_5G];
            }

            beaconInterval.text = [responseData objectForKey:WiFi_Bintval_5G];
            bandWidthSelectBtn.titleLabel.text = [WiFi_Band_Width_Value_5G objectForKey:[responseData objectForKey:WiFi_Bandwidth_5G]];
            maxNumUserSelectBtn.titleLabel.text = [responseData objectForKey:WiFi_MaxSta_5G];
            securityModeSelectBtn.titleLabel.text = [WiFi_SecurityMode_Value  objectForKey:[responseData objectForKey:WiFi_SecurityMode_5G]];
            
            //记录原始的加密方式
            modifiedSecurity = [WiFi_SecurityMode_Value  objectForKey:[responseData objectForKey:WiFi_SecurityMode_5G]];
            
            if ([securityModeSelectBtn.titleLabel.text isEqualToString:@"None"])
            {
                
            }
            else if ([securityModeSelectBtn.titleLabel.text hasPrefix:@"WPA"])
            {
                wifiPassword.text = [responseData objectForKey:WiFi_Wpa_Password_5G];
                
                //记录原始的密码
                modifiedPassword = [responseData objectForKey:WiFi_Wpa_Password_5G];
            }
            else
            {
                wifiPassword.text = [responseData objectForKey:WiFi_Wep_Password_5G];
                
                //记录原始的密码
                modifiedPassword = [responseData objectForKey:WiFi_Wep_Password_5G];
            }
        }
        
        [self wifiSwitchAction];
    }
}

- (void)updateOtherWiFiSetting
{
    NSMutableDictionary *wifiSettingDict = [NSMutableDictionary dictionary];
    if (bandType == BAND_TYPE_24G)
    {
        //更新5G WiFi
        [[NetManager sharedNetManager] requestWiFiSettingDataFor5G:^(id data, NSError *error) {
            if (!error)
            {
                [wifiSettingDict setDictionary:(NSDictionary *)data];
                [self modifyOtherWiFiSetting:wifiSettingDict];
            }
            else
            {
                NSLog(@"error occurs");
            }
        }];
    }
    else
    {
        //更新2G WiFi
        [[NetManager sharedNetManager] requestWiFiSettingDataFor2G:^(id data, NSError *error) {
            if (!error)
            {
                [wifiSettingDict setDictionary:(NSDictionary *)data];
                [self modifyOtherWiFiSetting:wifiSettingDict];
            }
            else
            {
                NSLog(@"error occurs");
            }
        }];
    }
}

- (void)modifyOtherWiFiSetting:(NSDictionary *)wifiSetting
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:WiFi_Setting_Name forKey:URL_CONFIG_ID];
    if (bandType == BAND_TYPE_24G)
    {
        [param setValue:@"1" forKey:WiFi_Type];
        [param setValue:[wifiSetting objectForKey:WiFi_Bandwidth_5G] forKey:WiFi_BandWidth];
        [param setValue:[wifiSetting objectForKey:WiFi_Interface_5G] forKey:WiFi_Interface];
        [param setValue:[wifiSetting objectForKey:WiFi_Enable_5G] forKey:WiFi_Enable];
        [param setValue:[wifiSetting objectForKey:WiFi_Reg_Domain_5G] forKey:WiFi_Reg_Domain];
        [param setValue:[wifiSetting objectForKey:WiFi_Channel_5G] forKey:WiFi_Channel];
        [param setValue:[wifiSetting objectForKey:WiFi_Bintval_5G] forKey:WiFi_Bintval];
        [param setValue:[wifiSetting objectForKey:WiFi_SSID_5G] forKey:WiFi_SSID_Name];
        [param setValue:[wifiSetting objectForKey:WiFi_SSID_Broadcast_5G] forKey:WiFi_SSID_Broadcast];
        [param setValue:[wifiSetting objectForKey:WiFi_MaxSta_5G] forKey:WiFi_Max_Sta];
    }
    else
    {
        [param setValue:@"0" forKey:WiFi_Type];
        [param setValue:[wifiSetting objectForKey:WiFi_Bandwidth_2G] forKey:WiFi_BandWidth];
        [param setValue:[wifiSetting objectForKey:WiFi_Interface_2G] forKey:WiFi_Interface];
        [param setValue:[wifiSetting objectForKey:WiFi_Enable_2G] forKey:WiFi_Enable];
        [param setValue:[wifiSetting objectForKey:WiFi_Reg_Domain_2G] forKey:WiFi_Reg_Domain];
        [param setValue:[wifiSetting objectForKey:WiFi_Channel_2G] forKey:WiFi_Channel];
        [param setValue:[wifiSetting objectForKey:WiFi_Bintval_2G] forKey:WiFi_Bintval];
        [param setValue:[wifiSetting objectForKey:WiFi_SSID_2G] forKey:WiFi_SSID_Name];
        [param setValue:[wifiSetting objectForKey:WiFi_SSID_Broadcast_2G] forKey:WiFi_SSID_Broadcast];
        [param setValue:[wifiSetting objectForKey:WiFi_MaxSta_2G] forKey:WiFi_Max_Sta];
    }
    
    if ([modifiedSecurity isEqualToString:@"None"])
    {
        
    }
    else if ([modifiedSecurity hasPrefix:@"WPA"])
    {
        [param setValue:@"0" forKey:WiFi_Wep_Password];
    }
    else
    {
        [param setValue:@"1" forKey:WiFi_Wep_Password];
    }
    [param setValue:[self getSecurityModeWithString:modifiedSecurity] forKey:WiFi_Security_Mode];
    [param setValue:modifiedPassword forKey:WiFi_Password];

    [[NetManager sharedNetManager] configDataWithParam:param andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {

            }
        }
    }];
}

#pragma mark - Adjust height (调整Scroll View，Container高度)
- (void)adjustWiFiSettingContainerView
{
    CGFloat newHight = wifiSettingContainer.frame.size.height;
    if (wifiSwitch.on)
    {
        newHight = wifiPassword.frame.origin.y + wifiPassword.frame.size.height + DATA_CONTAINER_GAP;
        
        if ([securityModeSelectBtn.titleLabel.text isEqualToString:@"None"])
        {
            wifiPasswordLbl.hidden = YES;
            wifiPassword.hidden = YES;
            newHight = securityModeSelectBtn.frame.origin.y + securityModeSelectBtn.frame.size.height + DATA_CONTAINER_GAP;
        }
        else
        {
            wifiPasswordLbl.hidden = NO;
            wifiPassword.hidden = NO;
        }
    }
    else
    {
        newHight = wifiSwitch.frame.origin.y + wifiSwitch.frame.size.height + DATA_CONTAINER_GAP;
    }
    [wifiSettingContainer setHeight:newHight];
}

- (void)adjustScrolView
{
    float newHeight = saveBtn.frame.origin.y + saveBtn.frame.size.height + DATA_CONTAINER_GAP;
    if(newHeight > [self contentHeight])
    {
        [self setContentHeight:newHeight];
    }
}
#pragma mark - When Wi-Fi Switch changed, should hidden controls from superView first

- (void)hiddenControlsFromSuperView:(BOOL)hidden
{
    broadcastLbl.hidden = hidden;
    broadcastSwitch.hidden = hidden;
    ssidLbl.hidden = hidden;
    ssidName.hidden = hidden;
    wirelessInterfaceLbl.hidden = hidden;
    interfaceSelectBtn.hidden = hidden;
    regulatoryDominLbl.hidden = hidden;
    regulatoryDominSelectBtn.hidden  = hidden;
    channelLbl.hidden = hidden;
    channelSelectBtn.hidden = hidden;
    beaconIntervalLbl.hidden = hidden;
    beaconInterval.hidden = hidden;
    bandWidthLbl.hidden = hidden;
    bandWidthSelectBtn.hidden = hidden;
    maxNumUserLbl.hidden = hidden;
    maxNumUserSelectBtn.hidden = hidden;
    securityModeLbl.hidden = hidden;
    securityModeSelectBtn.hidden = hidden;
    wifiPasswordLbl.hidden = hidden;
    wifiPassword.hidden = hidden;
}


#pragma mark - convert btn title to a special str to Server
- (NSString *)getSecurityModeWithString:(NSString *)str
{
    
    if ([str isEqualToString:@""])
    {
        return [WiFi_SecurityMode_Key objectForKey:[NSString stringWithFormat:@"%d",0]];
    }
    
    NSInteger i = -1;
    NSInteger j;
    for (j = 0; j < WiFi_Security_Mode_Menu.count; j++)
    {
        NSString *tmpStr = [WiFi_Security_Mode_Menu objectAtIndex:j];
        
        if ([tmpStr isEqualToString:str])
        {
            i = j;
            break;
        }
    }
    
    if (i == -1)
    {
        return [WiFi_SecurityMode_Key objectForKey:[NSString stringWithFormat:@"%d",0]];
    }
    else
    {
        return [WiFi_SecurityMode_Key objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
    }
}

- (NSString *)getRegDomainBriefWithString:(NSString *)str
{
    for (NSDictionary *tmpDic in WiFi_regulatory_Domain_Menu)
    {
        if ([[tmpDic objectForKey:@"full"] isEqualToString:str])
        {
            return [tmpDic objectForKey:@"brief"];
        }
    }
    return @"";
}

- (NSString *)getRegDomainFullWithString:(NSString *)str
{
    for (NSDictionary *tmpDic in WiFi_regulatory_Domain_Menu)
    {
        if ([[tmpDic objectForKey:@"brief"] isEqualToString:str])
        {
            return [tmpDic objectForKey:@"full"];
        }
    }
    return @"";
}
#pragma mark - Control Action
- (void)resignEditing
{
    [self.view endEditing:YES];
}

- (void)wifiSwitchAction
{
    [self hiddenControlsFromSuperView:!wifiSwitch.on];
    [self adjustWiFiSettingContainerView];
    [self setUpSaveControl];
    [self adjustScrolView];
}

- (void)broadcastSwitchAction
{
    NSLog(@"cmd : %@ ,%d",NSStringFromSelector(_cmd),broadcastSwitch.on);
}

- (void)interfaceSelectionAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    if(bandType == BAND_TYPE_24G)
    {
        PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_Interface_Menu_2G];
        [selectView showWithcompletion:^(id data, NSError *error) {
            if(data)
            {
                NSInteger selectedIndex = [data integerValue];
                [selButton setButtonTitle:[WiFi_Interface_Menu_2G objectAtIndex:selectedIndex]];
            }
        }];
    }
    else if(bandType == BAND_TYPE_5G)
    {
        PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_Interface_Menu_5G];
        [selectView showWithcompletion:^(id data, NSError *error) {
            if(data)
            {
                NSInteger selectedIndex = [data integerValue];
                [selButton setButtonTitle:[WiFi_Interface_Menu_5G objectAtIndex:selectedIndex]];
            }
        }];
    }

}

- (void)regulatoryDomainSelectionAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    
    NSMutableArray *visibleList = [NSMutableArray array];
    for (NSDictionary *dict in WiFi_regulatory_Domain_Menu)
    {
        [visibleList  addObject:[dict objectForKey:@"full"]];
    }
    
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:visibleList];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[[WiFi_regulatory_Domain_Menu objectAtIndex:selectedIndex] objectForKey:@"full"]];
        }
    }];
}

- (void)channelSelectionAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    
    NSArray *tmpList = nil;
    if (bandType == BAND_TYPE_24G)
    {
        if ([WiFi_Reg_Domain_List_2G containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_2G_2;
        }
        else
        {
            tmpList = WiFi_Channel_Menu_2G_1;
        }
    }
    else
    {
        if ([WiFi_Reg_Domain_List_5G_1 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_1;
        }
        else if ([WiFi_Reg_Domain_List_5G_2 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_2;
        }
        else if ([WiFi_Reg_Domain_List_5G_3 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_3;
        }
        else if ([WiFi_Reg_Domain_List_5G_4 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_4;
        }
        else if ([WiFi_Reg_Domain_List_5G_5 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_5;
        }
        else if ([WiFi_Reg_Domain_List_5G_6 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_6;
        }
        else if ([WiFi_Reg_Domain_List_5G_7 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_7;
        }
        else if ([WiFi_Reg_Domain_List_5G_8 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_8;
        }
        else if ([WiFi_Reg_Domain_List_5G_9 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_9;
        }
        else if ([WiFi_Reg_Domain_List_5G_10 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_10;
        }
        else if ([WiFi_Reg_Domain_List_5G_11 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_11;
        }
        else if ([WiFi_Reg_Domain_List_5G_12 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_12;
        }
        else if ([WiFi_Reg_Domain_List_5G_13 containsObject:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text]])
        {
            tmpList = WiFi_Channel_Menu_5G_13;
        }
        else
        {
            tmpList = WiFi_Channel_Menu_5G_14;
        }
    }
    
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:tmpList];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[tmpList objectAtIndex:selectedIndex]];
        }
    }];
}

- (void)bandWidthSelectionAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    
    if(bandType == BAND_TYPE_24G)
    {
        PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_Band_Width_Menu_2G];
        [selectView showWithcompletion:^(id data, NSError *error) {
            if(data)
            {
                NSInteger selectedIndex = [data integerValue];
                [selButton setButtonTitle:[WiFi_Band_Width_Menu_2G objectAtIndex:selectedIndex]];
            }
        }];
    }
    else if(bandType == BAND_TYPE_5G)
    {
        PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_Band_Width_Menu_5G];
        [selectView showWithcompletion:^(id data, NSError *error) {
            if(data)
            {
                NSInteger selectedIndex = [data integerValue];
                [selButton setButtonTitle:[WiFi_Band_Width_Menu_5G objectAtIndex:selectedIndex]];
            }
        }];
    }
}

- (void)maxNumberUserSelectionAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_Max_Number_Users_Menu];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[WiFi_Max_Number_Users_Menu objectAtIndex:selectedIndex]];
        }
    }];
}

- (void)securityModeSelectionAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_Security_Mode_Menu];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[WiFi_Security_Mode_Menu objectAtIndex:selectedIndex]];
            
            [self adjustWiFiSettingContainerView];
            [self setUpSaveControl];
            [self adjustScrolView];
        }
    }];
}

- (void)saveDataAction
{
    if ([self limitedWifiSetting] == NO)
    {
        return;
    }
    
    NSString *alertStr = NSLocalizedStringFromTable(@"storageRestartWiFiStr",NULL,@"TipStrings");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:alertStr
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                          otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    [alert show];

    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self setWiFiSettingData];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    focusedInputTextField = (InputTextField *)textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignEditing];
    return YES;
}

#pragma mark - Keyboard show/hide Notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfoDictionary = [notification userInfo];
    CGFloat keyBoardHeight = [[userInfoDictionary objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    if(self.isKeyboardShown == NO)
    {
        self.isKeyboardShown = YES;
        float newContentHeight = [self contentHeight] + keyBoardHeight;
        [self setContentHeight:newContentHeight];
    }
    
    if(focusedInputTextField)
    {
        UIScrollView *containerScrollView = (UIScrollView *)focusedInputTextField.superview.superview;
        CGRect fieldRectInScrollView = [focusedInputTextField.superview convertRect:focusedInputTextField.frame toView:containerScrollView];
        
        CGRect theNewRect = containerScrollView.frame;
        theNewRect.origin.y = fieldRectInScrollView.origin.y - fieldRectInScrollView.size.height;
        
        [containerScrollView scrollRectToVisible:theNewRect animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfoDictionary = [notification userInfo];
    //CGFloat duration = [[userInfoDictionary objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyBoardHeight = [[userInfoDictionary objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    if(self.isKeyboardShown == YES)
    {
        self.isKeyboardShown = NO;
        float newContentHeight = [self contentHeight] - keyBoardHeight;
        [self setContentHeight:newContentHeight];
    }
    
    if(focusedInputTextField)
        focusedInputTextField = nil;
    
}

#pragma mark - Interaction With Server
- (void)requestWiFiSettingDataFor2G
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWiFiSettingDataFor2G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateWiFiSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)requestWiFiSettingDataFor5G
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWiFiSettingDataFor5G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateWiFiSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setWiFiSettingData
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    [param setValue:WiFi_Setting_Name forKey:URL_CONFIG_ID];
    
    if (bandType == BAND_TYPE_24G)
    {
        [param setValue:@"0" forKey:WiFi_Type];
        [param setValue:[WiFi_Band_Width_Key_2G objectForKey:bandWidthSelectBtn.titleLabel.text] forKey:WiFi_BandWidth];
        [param setValue:[WiFi_Interface_Key_2G objectForKey:interfaceSelectBtn.titleLabel.text] forKey:WiFi_Interface];

    }
    else
    {
        [param setValue:@"1" forKey:WiFi_Type];
        [param setValue:[WiFi_Band_Width_Key_5G objectForKey:bandWidthSelectBtn.titleLabel.text] forKey:WiFi_BandWidth];
        [param setValue:[WiFi_Interface_Key_5G objectForKey:interfaceSelectBtn.titleLabel.text] forKey:WiFi_Interface];
    }
    
    if ([modifiedSecurity isEqualToString:securityModeSelectBtn.titleLabel.text] == NO || [modifiedPassword isEqualToString:wifiPassword.text] == NO)
    {
        modifiedSecurity = securityModeSelectBtn.titleLabel.text;
        modifiedPassword = wifiPassword.text;
        
        [self updateOtherWiFiSetting];
    }
    
    if ([modifiedSecurity isEqualToString:@"None"])
    {
        
    }
    else if ([modifiedSecurity hasPrefix:@"WPA"])
    {
        [param setValue:@"0" forKey:WiFi_Wep_Password];
    }
    else
    {
        [param setValue:@"1" forKey:WiFi_Wep_Password];
    }
    
    [param setValue:[NSString stringWithFormat:@"%d",wifiSwitch.on] forKey:WiFi_Enable];
    [param setValue:[self getRegDomainBriefWithString:regulatoryDominSelectBtn.titleLabel.text] forKey:WiFi_Reg_Domain];
    
    if ([channelSelectBtn.titleLabel.text isEqualToString:NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings")])
    {
        [param setValue:[Change_Auto_To_Zero objectForKey:channelSelectBtn.titleLabel.text] forKey:WiFi_Channel];
    }
    else
    {
        [param setValue:channelSelectBtn.titleLabel.text forKey:WiFi_Channel];
    }
    
    [param setValue:beaconInterval.text forKey:WiFi_Bintval];
    [param setValue:ssidName.text forKey:WiFi_SSID_Name];
    [param setValue:[NSString stringWithFormat:@"%d",broadcastSwitch.on] forKey:WiFi_SSID_Broadcast];
    [param setValue:maxNumUserSelectBtn.titleLabel.text forKey:WiFi_Max_Sta];
    [param setValue:[self getSecurityModeWithString:securityModeSelectBtn.titleLabel.text] forKey:WiFi_Security_Mode];
    [param setValue:wifiPassword.text forKey:WiFi_Password];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:param andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"modifyPasswordOKStr",NULL,@"TipStrings")];
                [[Utility defaultUtility] restarttWiFi];
            }
            else if([result isEqualToString:@"error"])
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"modifyPasswordNOStr",NULL,@"TipStrings")];
            }
        }
        [[Utility defaultUtility] hudClose];
    }];
}
#pragma mark - Limited Input
- (void)textFieldDidChanged:(NSNotification *)notification
{
    if (beaconInterval == (InputTextField *)notification.object)
    {
        NSString *tmpStr = beaconInterval.text;
        if (tmpStr.length >= 4)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 4)];
            beaconInterval.text = newStr;
        }
    }
}

- (BOOL)legalbeaconIntervalValue
{
    NSInteger binvalValue = [beaconInterval.text integerValue];

    if (binvalValue < 50 || binvalValue > 4000)
    {
        return NO;
    }
    return YES;
}

- (BOOL)legalSSIDName
{
    NSString *tmpStr = ssidName.text;
    NSString *firstCharacter = [tmpStr substringWithRange:NSMakeRange(0, 1)];
    NSString *lastCharacter = [tmpStr substringWithRange:NSMakeRange(tmpStr.length - 1, 1)];
    
    if ([firstCharacter isEqualToString:@" "] || [lastCharacter isEqualToString:@" "])
    {
        return NO;
    }
    return YES;
}

- (INVALIDPASSWORD_TYPE)legalWiFiPassword
{
    NSString *securityMode = [self getSecurityModeWithString:securityModeSelectBtn.titleLabel.text];
    NSString *password = wifiPassword.text;
    
    if ([securityMode isEqualToString:@"0201,2"] || [securityMode isEqualToString:@"0200,4"])
    {
        if ([self isAllHex:password])
        {
            if (password.length != 10)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Invalid64BitPasswordStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return INVALID_TYPE_64B;
            }
        }
        else
        {
            if (password.length != 5)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Invalid64BitPasswordStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return INVALID_TYPE_64B;
            }

        }
    }
    else if ([securityMode isEqualToString:@"0201,3"] || [securityMode isEqualToString:@"0200,5"])
    {
        if ([self isAllHex:password])
        {
            if (password.length != 26)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Invalid128BitPasswordStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return INVALID_TYPE_128B;
            }
        }
        else
        {
            if (password.length != 13)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Invalid128BitPasswordStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return INVALID_TYPE_128B;
            }
            
        }
    }
    else if ([securityMode isEqualToString:@"0100,1"])
    {
        
    }
    else
    {
        if (password.length < 8 || password.length > 63)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidNormalPasswordStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return INVALID_TYPE_NOR;
        }
    }
    return INVALID_TYPE_NONE;
}


- (BOOL)isAllHex:(NSString *)string
{
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"a",@"b",@"c",@"d",@"e",@"f"];
    NSInteger characterCount = 0;
    for (int i = 0; i < string.length; i++)
    {
        NSString *tmpStr = [string substringWithRange:NSMakeRange(i, 1)];
        if ([characterList containsObject:tmpStr])
        {
            characterCount++;
        }
        else
        {
            break;
        }
    }
    
    if (characterCount == string.length)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)limitedWifiSetting
{
    if ([self legalSSIDName] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidSSIDNameStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self legalbeaconIntervalValue] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidBeaconIntervalStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    INVALIDPASSWORD_TYPE type = [self legalWiFiPassword];
    
    if (type == INVALID_TYPE_128B || type == INVALID_TYPE_64B || type == INVALID_TYPE_NOR)
    {
        return NO;
    }
    
    return YES;
}
@end
