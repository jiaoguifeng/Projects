//
//  QuickSetupViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "QuickSetupViewController.h"

@interface QuickSetupViewController ()<UITextFieldDelegate>
{
    //Login info
    DataContainer         *loginSettingContainer;
    UILabel               *newUsrNameLbl;
    InputTextField        *newUsrName;
    UILabel               *newPasswordLbl;
    InputTextField        *newPassword;
    UILabel               *confirmPasswordLbl;
    InputTextField        *confirmPassword;
    
    //2.4G Wi-Fi info
    DataContainer         *wlanSettingContainer;
    UILabel               *ssidLbl;
    InputTextField        *ssid;
    UILabel               *securityModeLbl;
    SelectionButton       *securityMode;
    UILabel               *wlanPasswordLbl;
    InputTextField        *wlanPassword;

    //5G Wi-Fi info
    DataContainer         *wlan5SettingContainer;
    UILabel               *ssidLbl5;
    InputTextField        *ssid5;
    UILabel               *securityModeLbl5;
    SelectionButton       *securityMode5;
    UILabel               *wlanPasswordLbl5;
    InputTextField        *wlanPassword5;
    
    //被修改的password
    NSString              *modifiedPassword;
    NSString              *modifiedSecurity;
    
    //焦点
    InputTextField        *focusedInputTextField;
    
    //submit
    UIButton              *loginConfirm;
    UIButton              *submit;
    
    //Data
    NSMutableDictionary   *responseData2;
    NSMutableDictionary   *responseData5;
}


@end

@implementation QuickSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"quickSetupStr",NULL,@"SettingUIStrings")];
    
    //add tap event
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignEditing)];
    [self.view addGestureRecognizer:tap];
    
    //init Dictionary
    responseData2 = [[NSMutableDictionary alloc] initWithCapacity:0];
    responseData5 = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //Setup UI
    [self setUpQuickSettingUI];
    
    //获取服务器数据并更新
    [self requestQuickSettingData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

//- res
#pragma mark - Setup Quick Setting Main UI
- (void)setUpQuickSettingUI
{
    [self setUpLoginSettingContainer];
    
    [self setUpUserLoginConfrim];

    [self setUpWlanSettingContainer];
    
    [self setUpSubmitControl];
    
    [self adjustScrolView];
}

#pragma mark - Setup Containter (组织各个块)
- (void)setUpLoginSettingContainer
{
    loginSettingContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, self.view.frame.size.width - DATA_CONTAINER_GAP * 2, 200) title:NSLocalizedStringFromTable(@"LoginSettingStr",NULL,@"QuickSetupUIStrings")];
    [self addSubview:loginSettingContainer];
    [self setUpLoginSetting];
    [self adjustLoginContainerView];
}

- (void)setUpWlanSettingContainer
{
    wlanSettingContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, loginConfirm.frame.origin.y + loginConfirm.frame.size.height + DATA_CONTAINER_GAP, self.view.frame.size.width - DATA_CONTAINER_GAP * 2, 200) title:NSLocalizedStringFromTable(@"statusWiFi24GTitleStr",NULL,@"StatusUIStrings")];
    [self addSubview:wlanSettingContainer];
    [self setUp24GWlanSetting];
    [self adjustWlanContainerView];
    
    wlan5SettingContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, wlanSettingContainer.frame.origin.y + wlanSettingContainer.frame.size.height + DATA_CONTAINER_GAP, self.view.frame.size.width - DATA_CONTAINER_GAP * 2, 200) title:NSLocalizedStringFromTable(@"statusWiFi5GTitleStr",NULL,@"StatusUIStrings")];
    [self addSubview:wlan5SettingContainer];
    [self setUp5GWlanSetting];
    [self adjustWlan5ContainerView];
}

#pragma mark - Setup Control (添加控件到View上)
//Login Setting
- (void)setUpLoginSetting
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = loginSettingContainer.headerHeight +  DATA_CONTAINER_GAP * 0.5;
    CGFloat width = loginSettingContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = INPUT_TEXTFIELD_HEIGHT;
    
    newUsrNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, heigth)];
    newUsrNameLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"NewUserNameStr",NULL,@"QuickSetupUIStrings")];
    [loginSettingContainer addSubview:newUsrNameLbl];
    
    y = newUsrNameLbl.frame.origin.y + newUsrNameLbl.frame.size.height;
    newUsrName = [self inputTextField:CGRectMake(x, y, width, heigth)];
    newUsrName.delegate = self;
    [loginSettingContainer addSubview:newUsrName];
    
    y = newUsrName.frame.origin.y + newUsrName.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    newPasswordLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"NewPasswordStr",NULL,@"QuickSetupUIStrings")];
    [loginSettingContainer addSubview:newPasswordLbl];
    
    y = newPasswordLbl.frame.origin.y + newPasswordLbl.frame.size.height;
    newPassword = [self inputTextField:CGRectMake(x, y, width, heigth)];
    newPassword.secureTextEntry = YES;
    confirmPassword.delegate = self;
    [loginSettingContainer addSubview:newPassword];
    
    y = newPassword.frame.origin.y + newPassword.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    confirmPasswordLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"ConfirmPasswordStr",NULL,@"QuickSetupUIStrings")];
    [loginSettingContainer addSubview:confirmPasswordLbl];
    
    y = confirmPasswordLbl.frame.origin.y + confirmPasswordLbl.frame.size.height;
    confirmPassword = [self inputTextField:CGRectMake(x, y, width, heigth)];
    confirmPassword.secureTextEntry = YES;
    confirmPassword.delegate = self;
    [loginSettingContainer addSubview:confirmPassword];
}

- (void)setUpUserLoginConfrim
{
    loginConfirm = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, loginSettingContainer.frame.origin.y + loginSettingContainer.frame.size.height + DATA_CONTAINER_GAP, self.view.frame.size.width - DATA_CONTAINER_GAP * 2, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"QuickSetupUIStrings") action:@selector(loginConfirm)];
    [self addSubview:loginConfirm];
}

//Wlan 2.4G Setting
- (void)setUp24GWlanSetting
{
    //设置每一个控件的坐标
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = wlanSettingContainer.headerHeight +  DATA_CONTAINER_GAP * 0.5;
    CGFloat width = wlanSettingContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = INPUT_TEXTFIELD_HEIGHT;
    
    //控件
    ssidLbl = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, heigth)];
    ssidLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"SSIDStr",NULL,@"QuickSetupUIStrings")];
    [wlanSettingContainer addSubview:ssidLbl];
    
    y = ssidLbl.frame.origin.y + ssidLbl.frame.size.height;
    ssid = [self inputTextField:CGRectMake(x, y, width, heigth)];
    ssid.delegate = self;
    [wlanSettingContainer addSubview:ssid];
    
    y = ssid.frame.origin.y + ssid.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    securityModeLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"SecurityModeStr",NULL,@"QuickSetupUIStrings")];
    [wlanSettingContainer addSubview:securityModeLbl];
    
    y = securityModeLbl.frame.origin.y + securityModeLbl.frame.size.height;
    securityMode = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(securityModeSelelctAction:)];
    [wlanSettingContainer addSubview:securityMode];
    
    y = securityMode.frame.origin.y + securityMode.frame.size.height  + DATA_CONTAINER_IN_Y_GAP;
    wlanPasswordLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"WlanPasswordStr",NULL,@"QuickSetupUIStrings")];
    [wlanSettingContainer addSubview:wlanPasswordLbl];
    
    y = wlanPasswordLbl.frame.origin.y + wlanPasswordLbl.frame.size.height;
    wlanPassword = [self inputTextField:CGRectMake(x, y, width, heigth)];
    wlanPassword.secureTextEntry = YES;
    wlanPassword.delegate = self;
    [wlanSettingContainer addSubview:wlanPassword];
}

//Wlan 5G Setting
- (void)setUp5GWlanSetting
{
    //设置每一个控件的坐标
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = wlan5SettingContainer.headerHeight + DATA_CONTAINER_GAP * 0.5;
    CGFloat width = wlan5SettingContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = INPUT_TEXTFIELD_HEIGHT;
    
    //控件
    ssidLbl5 = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, heigth)];
    ssidLbl5 = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"SSIDStr",NULL,@"QuickSetupUIStrings")];
    [wlan5SettingContainer addSubview:ssidLbl5];
    
    y = ssidLbl5.frame.origin.y + ssidLbl5.frame.size.height;
    ssid5 = [self inputTextField:CGRectMake(x, y, width, heigth)];
    ssid5.delegate = self;
    [wlan5SettingContainer addSubview:ssid5];
    
    y = ssid5.frame.origin.y + ssid5.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    securityModeLbl5 = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"SecurityModeStr",NULL,@"QuickSetupUIStrings")];
    [wlan5SettingContainer addSubview:securityModeLbl5];
    
    y = securityModeLbl5.frame.origin.y + securityModeLbl5.frame.size.height;
    securityMode5 = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(securityModeSelelctAction:)];;
    [wlan5SettingContainer addSubview:securityMode5];
    
    y = securityMode5.frame.origin.y + securityMode5.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    wlanPasswordLbl5 = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"WlanPasswordStr",NULL,@"QuickSetupUIStrings")];
    [wlan5SettingContainer addSubview:wlanPasswordLbl5];
    
    y = wlanPasswordLbl5.frame.origin.y + wlanPasswordLbl5.frame.size.height;
    wlanPassword5 = [self inputTextField:CGRectMake(x, y, width, heigth)];
    wlanPassword5.secureTextEntry = YES;
    wlanPassword5.delegate = self;
    [wlan5SettingContainer addSubview:wlanPassword5];
}

- (void)setUpSubmitControl
{
    if (submit)
    {
        submit.frame = CGRectMake(DATA_CONTAINER_GAP, wlan5SettingContainer.frame.origin.y + wlan5SettingContainer.frame.size.height + DATA_CONTAINER_GAP, self.view.frame.size.width - DATA_CONTAINER_GAP * 2, 30);
    }
    else
    {
        submit = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, wlan5SettingContainer.frame.origin.y + wlan5SettingContainer.frame.size.height + DATA_CONTAINER_GAP, self.view.frame.size.width - DATA_CONTAINER_GAP * 2, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"QuickSetupUIStrings") action:@selector(wifiSettingSubmit)];
        [self addSubview:submit];
    }
    
}

#pragma mark - Adjust height (调整Scroll View，Container高度)
- (void)adjustScrolView
{
    float newHeight = submit.frame.origin.y + submit.frame.size.height + DATA_CONTAINER_GAP;
    if(newHeight > [self contentHeight])
    {
        [self setContentHeight:newHeight];
    }
}

- (void)adjustLoginContainerView
{
    CGRect frame = loginSettingContainer.frame;
    frame.size.height = confirmPassword.frame.origin.y + confirmPassword.frame.size.height + DATA_CONTAINER_GAP;
    loginSettingContainer.frame = frame;
}

- (void)adjustWlanContainerView
{
    CGRect frame = wlanSettingContainer.frame;
    if ([securityMode.titleLabel.text isEqualToString:@"None"])
    {
        wlanPassword.hidden = YES;
        wlanPasswordLbl.hidden = YES;
        
        frame.size.height = securityMode.frame.origin.y + securityMode.frame.size.height + DATA_CONTAINER_GAP;
    }
    else
    {
        wlanPassword.hidden = NO;
        wlanPasswordLbl.hidden = NO;
        
        frame.size.height = wlanPassword.frame.origin.y + wlanPassword.frame.size.height + DATA_CONTAINER_GAP;
    }
    wlanSettingContainer.frame = frame;
}

- (void)adjustWlan5ContainerView
{
    CGRect frame = wlan5SettingContainer.frame;

    if ([securityMode5.titleLabel.text isEqualToString:@"None"])
    {
        wlanPassword5.hidden = YES;
        wlanPasswordLbl5.hidden = YES;
        
        frame.origin.y = wlanSettingContainer.frame.origin.y + wlanSettingContainer.frame.size.height + DATA_CONTAINER_GAP;
        frame.size.height = securityMode5.frame.origin.y + securityMode5.frame.size.height + DATA_CONTAINER_GAP;
    }
    else
    {
        wlanPassword5.hidden = NO;
        wlanPasswordLbl5.hidden = NO;
        
        frame.origin.y = wlanSettingContainer.frame.origin.y + wlanSettingContainer.frame.size.height + DATA_CONTAINER_GAP;
        frame.size.height = wlanPassword5.frame.origin.y + wlanPassword5.frame.size.height + DATA_CONTAINER_GAP;
    }

    wlan5SettingContainer.frame = frame;
}

- (void)resignEditing
{
    [self.view endEditing:YES];
}
#pragma mark - Control Actions
- (void)loginConfirm
{
    if ([self limitedLoginSetting] == NO)
    {
        return;
    }
    
    [self setModifyPasswordData];
}

- (void)wifiSettingSubmit
{
    if ([self limitedWiFiSetting] == NO)
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



- (void)securityModeSelelctAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:WiFi_Security_Mode_Menu];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[WiFi_Security_Mode_Menu objectAtIndex:selectedIndex]];
            
            [self adjustWlanContainerView];
            
            [self adjustWlan5ContainerView];

            [self setUpSubmitControl];
            
            [self adjustScrolView];
        }
    }];
}

- (void)updateQuickSettingMainUI
{
    if (responseData2.count > 0 && responseData5.count > 0)
    {
        ssid.text = [responseData2 objectForKey:WiFi_SSID_2G];
        ssid5.text = [responseData5 objectForKey:WiFi_SSID_5G];
        
        securityMode.titleLabel.text = [WiFi_SecurityMode_Value  objectForKey:[responseData2 objectForKey:WiFi_SecurityMode_2G]];
        securityMode5.titleLabel.text = [WiFi_SecurityMode_Value  objectForKey:[responseData2 objectForKey:WiFi_SecurityMode_2G]];
        
        //记录初始的加密方式
        modifiedSecurity = [WiFi_SecurityMode_Value  objectForKey:[responseData2 objectForKey:WiFi_SecurityMode_2G]];
        
        
        if ([securityMode.titleLabel.text isEqualToString:@"None"])
        {
            wlanPassword.text = @"";
        }
        else if([securityMode.titleLabel.text hasPrefix:@"WPA"])
        {
            wlanPassword.text = [responseData2 objectForKey:WiFi_Wpa_Password_2G];
            
            //记录初始的密码
            modifiedPassword = [responseData2 objectForKey:WiFi_Wpa_Password_2G];
        }
        else
        {
            wlanPassword.text = [responseData2 objectForKey:WiFi_Wep_Password_2G];
            
            //记录初始的密码
            modifiedPassword = [responseData2 objectForKey:WiFi_Wep_Password_2G];
        }
        
        if ([securityMode5.titleLabel.text isEqualToString:@"None"])
        {
            wlanPassword5.text = @"";
        }
        else if([securityMode5.titleLabel.text hasPrefix:@"WPA"])
        {
            wlanPassword5.text = [responseData2 objectForKey:WiFi_Wpa_Password_2G];
        }
        else
        {
            wlanPassword5.text = [responseData2 objectForKey:WiFi_Wep_Password_2G];
        }
        
    }
}

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
#pragma mark - Interaction With Server
- (void)requestQuickSettingData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestSystemUserNamePassworkData:^(id data, NSError *error) {
        if(data)
        {
            newUsrName.text = [data objectForKey:SYS_New_UserName];
            newPassword.text = [data objectForKey:SYS_New_Password];
            confirmPassword.text = [data objectForKey:SYS_New_Password];
        }
    }];
    
    [[NetManager sharedNetManager] requestWiFiSettingDataFor2G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData2.count > 0)
            {
                [responseData2 removeAllObjects];
            }
            
            [responseData2 setDictionary:(NSDictionary *)data];
            [self updateQuickSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
    }];
    
    [[NetManager sharedNetManager] requestWiFiSettingDataFor5G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData5.count > 0)
            {
                [responseData5 removeAllObjects];
            }
            
            [responseData5 setDictionary:(NSDictionary *)data];
            [self updateQuickSettingMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
        [[Utility defaultUtility] hudClose];
    }];

}

#pragma mark - set/get data
- (void)setModifyPasswordData
{
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_System_Setting,URL_CONFIG_ID,
                                 newUsrName.text,SYS_New_UserName,
                                 confirmPassword.text,SYS_New_Password,nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"modifyOKStr",NULL,@"TipStrings")];
            }
            else if([result isEqualToString:@"error"])
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"modifyNOStr",NULL,@"TipStrings")];
            }
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setWiFiSettingData
{
    //Set 2.4G
    NSMutableDictionary *paramFor2G = [NSMutableDictionary dictionary];
    [paramFor2G setValue:WiFi_Setting_Name forKey:URL_CONFIG_ID];
    [paramFor2G setValue:@"0" forKey:WiFi_Type];
    
    //判断securityMode是不是改变,保持2G和5G一致
    if ([modifiedSecurity isEqualToString:securityMode.titleLabel.text] == NO)
    {
        modifiedSecurity = securityMode.titleLabel.text;
    }
    else if ([modifiedSecurity isEqualToString:securityMode5.titleLabel.text] == NO)
    {
        modifiedSecurity = securityMode5.titleLabel.text;
    }
    
    //判断password是不是改变,保持2G和5G一致
    if ([modifiedPassword isEqualToString:wlanPassword.text] == NO)
    {
        modifiedPassword = wlanPassword.text;
    }
    else if ([modifiedPassword isEqualToString:wlanPassword5.text] == NO)
    {
        modifiedPassword = wlanPassword5.text;
    }

    //判断securitymode的类型
    if ([modifiedSecurity isEqualToString:@"None"])
    {
        
    }
    else if ([modifiedSecurity hasPrefix:@"WPA"])
    {
        [paramFor2G setValue:@"0" forKey:WiFi_Wep_Password];
    }
    else
    {
        [paramFor2G setValue:@"1" forKey:WiFi_Wep_Password];
    }
    
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_Enable_2G] forKey:WiFi_Enable];
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_Interface_2G] forKey:WiFi_Interface];
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_Reg_Domain_2G] forKey:WiFi_Reg_Domain];
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_Channel_2G] forKey:WiFi_Channel];
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_Bintval_2G] forKey:WiFi_Bintval];
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_Bandwidth_2G] forKey:WiFi_BandWidth];
    [paramFor2G setValue:ssid.text forKey:WiFi_SSID_Name];
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_SSID_Broadcast_2G] forKey:WiFi_SSID_Broadcast];
    [paramFor2G setValue:[responseData2 objectForKey:WiFi_MaxSta_2G] forKey:WiFi_Max_Sta];
    [paramFor2G setValue:[self getSecurityModeWithString:modifiedSecurity] forKey:WiFi_Security_Mode];
    [paramFor2G setValue:modifiedPassword forKey:WiFi_Password];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:paramFor2G andBlock:^(id data, NSError *error) {

    }];
    
    //Set 5G
    NSMutableDictionary *paramFor5G = [NSMutableDictionary dictionary];
    [paramFor5G setValue:WiFi_Setting_Name forKey:URL_CONFIG_ID];
    [paramFor5G setValue:@"1" forKey:WiFi_Type];
    
    if ([modifiedSecurity isEqualToString:@"None"])
    {
        
    }
    else if ([modifiedSecurity hasPrefix:@"WPA"])
    {
        [paramFor5G setValue:@"0" forKey:WiFi_Wep_Password];
    }
    else
    {
        [paramFor5G setValue:@"1" forKey:WiFi_Wep_Password];
    }
    
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_Enable_5G] forKey:WiFi_Enable];
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_Interface_5G] forKey:WiFi_Interface];
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_Reg_Domain_5G] forKey:WiFi_Reg_Domain];
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_Channel_5G] forKey:WiFi_Channel];
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_Bintval_5G] forKey:WiFi_Bintval];
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_Bandwidth_5G] forKey:WiFi_BandWidth];
    [paramFor5G setValue:ssid5.text forKey:WiFi_SSID_Name];
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_SSID_Broadcast_5G] forKey:WiFi_SSID_Broadcast];
    [paramFor5G setValue:[responseData5 objectForKey:WiFi_MaxSta_5G] forKey:WiFi_Max_Sta];
    [paramFor5G setValue:[self getSecurityModeWithString:securityMode5.titleLabel.text] forKey:WiFi_Security_Mode];
    [paramFor5G setValue:modifiedPassword forKey:WiFi_Password];
    
    [[NetManager sharedNetManager] configDataWithParam:paramFor5G andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"modifyOKStr",NULL,@"TipStrings")];
                [[Utility defaultUtility] restarttWiFi];
            }
            else if([result isEqualToString:@"error"])
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"modifyNOStr",NULL,@"TipStrings")];
            }
        }
        [[Utility defaultUtility] hudClose];
    }];
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
    //CGFloat duration = [[userInfoDictionary objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
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

#pragma mark -input limited
- (void)textFieldDidChanged:(NSNotification *)notification
{
    InputTextField *tmpObject = (InputTextField *)notification.object;
    
    if (newUsrName == tmpObject || newPassword == tmpObject || confirmPassword == tmpObject)
    {
        NSString *tmpStr = tmpObject.text;
        if (tmpStr.length >= 20)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 20)];
            tmpObject.text = newStr;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"G",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"`",@"~",@"!",@"@",@"$",@"^",@"&",@"*",@"(",@")",@"[",@"]",@"{",@"}",@";",@":",@",",@".",@""];
    
    if (newUsrName == textField || newPassword == textField || confirmPassword == textField)
    {
        if (![characterList containsObject:string])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)legalUsername
{
    if (newUsrName.text.length == 0)
    {
        return NO;
    }
    return YES;
}

- (BOOL)legalNewPassword
{
    if (newPassword.text.length == 0 || confirmPassword.text.length == 0)
    {
        return NO;
    }
    return YES;
}

- (BOOL)isDifferWithPassword
{
    if ([newPassword.text isEqualToString:confirmPassword.text])
    {
        return NO;
    }
    return YES;
}

- (INVALIDPASSWORD_TYPE)legalWiFiPassword2
{
    NSString *security = [self getSecurityModeWithString:securityMode.titleLabel.text];
    NSString *password = wlanPassword.text;
    
    if ([security isEqualToString:@"0201,2"] || [security isEqualToString:@"0200,4"])
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
    else if ([security isEqualToString:@"0201,3"] || [security isEqualToString:@"0200,5"])
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
    else if ([security isEqualToString:@"0100,1"])
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

- (INVALIDPASSWORD_TYPE)legalWiFiPassword5
{
    NSString *security = [self getSecurityModeWithString:securityMode5.titleLabel.text];
    NSString *password = wlanPassword5.text;
    
    if ([security isEqualToString:@"0201,2"] || [security isEqualToString:@"0200,4"])
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
    else if ([security isEqualToString:@"0201,3"] || [security isEqualToString:@"0200,5"])
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
    else if ([security isEqualToString:@"0100,1"])
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


- (BOOL)limitedLoginSetting
{
    if ([self legalUsername] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidUserNameStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self legalNewPassword] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidPasswordStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self isDifferWithPassword] == YES)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"DifferPasswordStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }

    return YES;
}

- (BOOL)limitedWiFiSetting
{
    INVALIDPASSWORD_TYPE type = [self legalWiFiPassword2];
    
    if (type == INVALID_TYPE_128B || type == INVALID_TYPE_64B || type == INVALID_TYPE_NOR)
    {
        return NO;
    }
    
    type = [self legalWiFiPassword5];
    
    if (type == INVALID_TYPE_128B || type == INVALID_TYPE_64B || type == INVALID_TYPE_NOR)
    {
        return NO;
    }

    return YES;
}


@end
