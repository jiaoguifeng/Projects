//
//  WPSViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "WPSViewController.h"

@interface WPSViewController ()<UIGestureRecognizerDelegate>
{
    BAND_TYPE bandType;
    
    DataContainer              *wpsSettingContainer;
    UILabel                    *wpsLbl;
    SevenSwitch                *wpsSwitch;
    
    UILabel                    *wpsConnectionModeLbl;
    SelectionButton            *wpsConnectionMode;
    
    UILabel                    *clientPINLbl;
    InputTextField             *clientPin;
    
    UILabel                    *connectionModeMsg;
    
    UIButton                   *saveBtn;
    
    NSInteger                  wpsModeSelectedIndex;
    
    NSMutableDictionary        *responseData;
    
    BOOL                       wpsOriginalState;
}
@end

@implementation WPSViewController

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
        [self setTitleText:NSLocalizedStringFromTable(@"24GWPSStr",NULL,@"WiFiUIStrings")];
    else
        [self setTitleText:NSLocalizedStringFromTable(@"5GWPSStr",NULL,@"WiFiUIStrings")];
    
    //add tap event
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignEditing)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    //init Dictionary
    responseData = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //init WPS Switch
    wpsOriginalState = NO;
    
    wpsModeSelectedIndex = 0;
    
    [self setUpWPSMainUI];
    
    //get Data From Server
    if (bandType == BAND_TYPE_24G)
    {
        [self requestWiFiWPSDataFor2G];
    }
    else
    {
        [self requestWiFiWPSDataFor5G];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - Set up Wi-Fi Setting UI
- (void)setUpWPSMainUI
{
    [self setUpWPSSettingContainer];
    
    [self adjustWPSSettingContainerView];
    
    [self setUpSubmitControl];
    
    [self adjustScrolView];
    
    [self defaultMainUISetting];
}

- (void)defaultMainUISetting
{
    wpsSwitch.on = 1;
    wpsConnectionMode.titleLabel.text = [WiFi_WPS_Mode_Value objectForKey:@"0"];
    
    [self adjustWpsMainUI];
}

- (void)setUpWPSSettingContainer
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = DATA_CONTAINER_GAP;
    CGFloat width = self.view.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = 200;
    
    wpsSettingContainer = [[DataContainer alloc] initWithFrame:CGRectMake(x, y, width, heigth) title:NSLocalizedStringFromTable(@"WPSSettingStr",NULL,@"wpsUSStrings")];
    [self addSubview: wpsSettingContainer];
    
    
    y = wpsSettingContainer.headerHeight + DATA_CONTAINER_GAP * 0.5;
    width = wpsSettingContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    heigth = INPUT_TEXTFIELD_HEIGHT;
    
    wpsLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"WPSStr",NULL,@"wpsUSStrings")];
    [wpsSettingContainer addSubview:wpsLbl];
    
    y = wpsLbl.frame.origin.y + wpsLbl.frame.size.height;
    wpsSwitch = [self switchControl:CGRectMake(x, y, 75, heigth) action:@selector(wpsSwitchAction) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    wpsSwitch.on = YES;
    [wpsSettingContainer addSubview:wpsSwitch];
    
    
    y = wpsSwitch.frame.origin.y + wpsSwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    wpsConnectionModeLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"ConnectionModeStr",NULL,@"wpsUSStrings")];
    [wpsSettingContainer addSubview:wpsConnectionModeLbl];
    
    y = wpsConnectionModeLbl.frame.origin.y + wpsConnectionModeLbl.frame.size.height;
    wpsConnectionMode = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"Client PIN Mode" action:@selector(wpsConnectionSelectAction:)];
    [wpsSettingContainer addSubview:wpsConnectionMode];

    
    y = wpsConnectionMode.frame.origin.y + wpsConnectionMode.frame.size.height;
    clientPINLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"ClientPINStr",NULL,@"wpsUSStrings")];
    [wpsSettingContainer addSubview:clientPINLbl];
    
    y = clientPINLbl.frame.origin.y + clientPINLbl.frame.size.height;
    clientPin = [self inputTextField:CGRectMake(x, y, width, heigth)];
    clientPin.keyboardType = UIKeyboardTypeNumberPad;
    [wpsSettingContainer addSubview:clientPin];
    
    y = wpsConnectionMode.frame.origin.y + wpsConnectionMode.frame.size.height;
    connectionModeMsg = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:@"This is a message"];
    connectionModeMsg.lineBreakMode = NSLineBreakByTruncatingMiddle;
    connectionModeMsg.hidden = YES;
    [wpsSettingContainer addSubview:connectionModeMsg];
}

- (void)adjustWPSSettingContainerView
{
    CGFloat newHight = wpsSettingContainer.frame.size.height;
    if (connectionModeMsg.hidden)
    {
        newHight = clientPin.frame.origin.y + clientPin.frame.size.height + DATA_CONTAINER_GAP;
    }
    else if(clientPINLbl.hidden == YES && clientPin.hidden == YES)
    {
        newHight = connectionModeMsg.frame.origin.y + connectionModeMsg.frame.size.height + DATA_CONTAINER_GAP;
    }
    
    [wpsSettingContainer setHeight:newHight];
}

- (void)setUpSubmitControl
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = wpsSettingContainer.frame.origin.y + wpsSettingContainer.frame.size.height + DATA_CONTAINER_GAP;
    CGFloat width = self.view.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = INPUT_TEXTFIELD_HEIGHT;
    
    if (saveBtn)
    {
        saveBtn.frame = CGRectMake(x, y, width, heigth);
    }
    else
    {
        saveBtn = [self baseButton:CGRectMake(x,y,width,heigth) title:NSLocalizedStringFromTable(@"okStr",NULL,@"QuickSetupUIStrings") action:@selector(submitDataAction)];
        [self addSubview:saveBtn];
    }
}

- (void)adjustScrolView
{
    float newHeight = saveBtn.frame.origin.y + saveBtn.frame.size.height + DATA_CONTAINER_GAP;
    if(newHeight > [self contentHeight])
    {
        [self setContentHeight:newHeight];
    }
}

- (void)updateWPSSettingMainUI
{
    if (responseData.count > 0)
    {
        if (bandType == BAND_TYPE_24G)
        {
            wpsSwitch.on = [[responseData objectForKey:WiFi_WPS_Enable_2G] intValue];
            wpsConnectionMode.titleLabel.text = [WiFi_WPS_Mode_Value objectForKey:[responseData objectForKey:WiFi_WPS_Mode_2G]];
            clientPin.text = [responseData objectForKey:WiFi_WPS_Client_Pin_2G];
        }
        else
        {
            wpsSwitch.on = [[responseData objectForKey:WiFi_WPS_Enable_5G] intValue];
            wpsConnectionMode.titleLabel.text = [WiFi_WPS_Mode_Value objectForKey:[responseData objectForKey:WiFi_WPS_Mode_5G]];
            clientPin.text = [responseData objectForKey:WiFi_WPS_Client_Pin_5G];
        }
        
        wpsOriginalState = wpsSwitch.on;
        
        [self adjustWpsMainUI];
    }

}

- (void)reloadWPSSetting
{
    if (bandType == BAND_TYPE_24G)
    {
        [self reloadWiFiWPSDataFor2G];
    }
    else
    {
        [self reloadWiFiWPSDataFor5G];
    }
}

- (void)resignEditing
{
    [self.view endEditing:YES];
}

- (void)wpsModeChanged:(BOOL)hidden
{
    clientPINLbl.hidden = hidden;
    clientPin.hidden = hidden;
    connectionModeMsg.hidden = !hidden;
    
    [self adjustWPSSettingContainerView];
    [self setUpSubmitControl];
    [self adjustScrolView];
}

- (void)wpsSwitchDisable:(BOOL)enabled
{
    wpsConnectionMode.enabled  = enabled;
    clientPin.enabled = enabled;
//    connectionModeMsg.enabled = enabled;
}

- (void)adjustWpsMainUI
{
    [self wpsSwitchDisable:wpsSwitch.on];
    
    if ([wpsConnectionMode.titleLabel.text isEqualToString:@"Client PIN Mode"])
    {
        [self wpsModeChanged:NO];
    }
    else if([wpsConnectionMode.titleLabel.text isEqualToString:@"PBC Mode"])
    {
        [self wpsModeChanged:YES];
        connectionModeMsg.text = NSLocalizedStringFromTable(@"PCBStr",NULL,@"wpsUSStrings");
    }
    else
    {
        [self wpsModeChanged:YES];
        connectionModeMsg.text = NSLocalizedStringFromTable(@"NoConnectionStr",NULL,@"wpsUSStrings");
    }
}

#pragma mark - Control Action
- (void)wpsSwitchAction
{
    [self wpsSwitchDisable:wpsSwitch.on];
}

- (void)wpsConnectionSelectAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_WPS_Mode_Menu];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[WiFi_WPS_Mode_Menu objectAtIndex:selectedIndex]];
            wpsModeSelectedIndex = selectedIndex;
            
            switch (wpsModeSelectedIndex)
            {
                case 0:
                    [self wpsModeChanged:NO];
                    break;
                default:
                {
                    [self wpsModeChanged:YES];
                    [self adjustWpsMainUI];
                }
                    break;
            }
        }
    }];
}

- (void)submitDataAction
{
    if ([self limitedWPSSetting] == NO)
    {
        return;
    }
    
    if (wpsSwitch.on != wpsOriginalState)
    {
        NSString *alertStr = NSLocalizedStringFromTable(@"storageRestartWiFiStr",NULL,@"TipStrings");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alertStr
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
    }
    else
    {
        [self setWPSSettingData];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self setWPSSettingData];
    }
}

#pragma mark - Interaction With Server
- (void)requestWiFiWPSDataFor2G
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWiFiWPSDataFor2G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateWPSSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)reloadWiFiWPSDataFor2G
{
    [[NetManager sharedNetManager] requestWiFiWPSDataFor2G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateWPSSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
    }];
}

- (void)requestWiFiWPSDataFor5G
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWiFiWPSDataFor5G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateWPSSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)reloadWiFiWPSDataFor5G
{
    [[NetManager sharedNetManager] requestWiFiWPSDataFor5G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateWPSSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
    }];
}


- (void)setWPSSettingData
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:WiFi_WPS_Set_Name forKey:URL_CONFIG_ID];
    if (bandType == BAND_TYPE_24G)
    {
        [param setObject:[NSString stringWithFormat:@"%ld",(long)bandType] forKey:WiFi_Type];
    }
    else
    {
        [param setObject:[NSString stringWithFormat:@"%ld",(long)bandType] forKey:WiFi_Type];
    }
    [param setObject:[NSString stringWithFormat:@"%d",wpsSwitch.on] forKey:WiFi_WPS_Set_Enable];
    [param setObject:[WiFi_WPS_Mode_Key objectForKey:wpsConnectionMode.titleLabel.text] forKey:WiFi_WPS_Set_Mode];
    [param setObject:clientPin.text forKey:WiFi_WPS_Set_Client_Pin];
    
    [[NetManager sharedNetManager] configDataWithParam:param andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                if (wpsSwitch.on != wpsOriginalState)
                {
                    [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"modifyOKStr",NULL,@"TipStrings")];
                    [[Utility defaultUtility] restarttWiFi];
                }
                else if(wpsSwitch.on)
                {
                    NSString *currentSelect = [WiFi_WPS_Mode_Key objectForKey:wpsConnectionMode.titleLabel.text];
                    
                    if ([currentSelect isEqualToString:@"2"] || [currentSelect isEqualToString:@"1"])
                    {
                        [[Utility defaultUtility] refreshWpsModeStatus:bandType];
                    }
                }
            }
            else if([result isEqualToString:@"error"])
            {
                //[KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"modifyNOStr",NULL,@"TipStrings")];
            }
        }
    }];
}


#pragma mark - Limited Input
- (void)textFieldDidChanged:(NSNotification *)notification
{
    if (clientPin == (InputTextField *)notification.object)
    {
        NSString *tmpStr = clientPin.text;
        if (tmpStr.length >= 8)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 8)];
            clientPin.text = newStr;
        }
    }
}

- (BOOL)legalClientPin
{
    NSString *tmpStr = clientPin.text;
    if (tmpStr.length == 0)
    {
        return NO;
    }
    return YES;
}



- (BOOL)limitedWPSSetting
{
    if (wpsSwitch.on && wpsSwitch.on == wpsOriginalState)
    {
        if ([wpsConnectionMode.titleLabel.text isEqualToString:@"Client PIN Mode"])
        {
            if ([self legalClientPin] == NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidClientPinStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return NO;
            }
        }
    }
    return YES;
}
@end
