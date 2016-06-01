//
//  lanViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "LanViewController.h"

@interface LanViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    DataContainer *container;
    
    float heightLevel1;
    float heightLevel2;
    float heightLevel3;
    
    InputTextField *ipAddressInputField;
    InputTextField *subnetMaskInputField;
    InputTextField *hostNameInputField;
    SevenSwitch *dhcpSwitch;
    
    UILabel *dhcpIPPoolTitleLabel;
    InputTextField *dhcpIPPoolStartInputField;
    InputTextField *dhcpIPPoolEndInputField;
    UILabel *dhcpLeaseTimeTitleLabel;
    SelectionButton *dhcpLeaseTimeSelectionButton;
    UILabel *dnsModeTitleLabel;
    SevenSwitch *dnsModeSwitch;
    
    UILabel *primaryDNSServerTitleLabel;
    InputTextField *primaryDNSServerInputField;
    UILabel *senondaryDNSServerTitleLabel;
    InputTextField *secondaryDNSServerInputField;
    UILabel *dnsRelayTitleLabel;
    SevenSwitch *dnsRelaySwitch;
    
    //
    InputTextField *focusedInputTextField;
    
    //
    UIButton *okButton;
}
@end

@implementation LanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"lanStr",NULL,@"RouterUIStrings")];
    
    [self setupUIControls];
    
    [self getLanData];
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

#pragma mark - Switch Control action

- (void)switchControlAction:(id)sender
{
    [self updateLevelUIStatus];
}

#pragma mark - Selection Button action

- (void)selectionButtonAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:Lan_Lease_Time_Menu];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[Lan_Lease_Time_Menu objectAtIndex:selectedIndex]];
            selButton.tag = selectedIndex;
        }
    }];
}

#pragma mark - OK/Cancel button actions

- (void)okCancelButtonAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"setLanRebootStr",NULL,@"TipStrings")
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                          otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if ([self limitedLanSetting] == NO)
        {
            return;
        }
        
        [self setLanData];
    }
}

#pragma mark - get/set function

- (void)getLanData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterLanData:^(id data, NSError *error) {
        if(data)
        {
            //
            ipAddressInputField.text = [data objectForKey:RT_LanIP];
            subnetMaskInputField.text = [data objectForKey:RT_NetMask];
            dhcpSwitch.on = ([[data objectForKey:RT_DHCPS_Enable] isEqualToString:@"1"]) ? YES : NO;
            
            if(dhcpSwitch.on)   // Enable:1 Disable:0
            {
                dhcpIPPoolStartInputField.text = [data objectForKey:RT_DHCPS_StartIP];
                dhcpIPPoolEndInputField.text = [data objectForKey:RT_DHCPS_EndIP];
                
                [dhcpLeaseTimeSelectionButton setButtonTitle:[Lan_Lease_Time_Value objectForKey:[data objectForKey:RT_DHCPS_Lease]]];
                dnsModeSwitch.on = ([[data objectForKey:RT_DNS_Mode] isEqualToString:@"1"]) ? YES : NO;
                
                if(!dnsModeSwitch.on)    // Auto:1 Manual:0
                {
                    NSString *dnsList = [data objectForKey:RT_DNS_List];
                    primaryDNSServerInputField.text = [[dnsList componentsSeparatedByString:@","] objectAtIndex:0];
                    secondaryDNSServerInputField.text = [[dnsList componentsSeparatedByString:@","] objectAtIndex:1];
                    
                    dnsRelaySwitch.on = ([[data objectForKey:RT_DNS_Relay_Enable] isEqualToString:@"1"]) ? YES : NO;
                }
            }
            
            [self updateLevelUIStatus];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setLanData
{
    NSString *dhcpEnabledStr = dhcpSwitch.on ? @"1" : @"0";
    NSString *dnsModeStr = dnsModeSwitch.on ? @"1" : @"0";
    NSString *dnsList = @"";
    if(!dnsModeSwitch.on)
        dnsList = [NSString stringWithFormat:@"%@,%@",primaryDNSServerInputField.text,secondaryDNSServerInputField.text];
    
    NSString *dnsRelalyStr = dnsRelaySwitch.on ? @"1" : @"0";
    
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_Router_DHCP,URL_CONFIG_ID,
                                ipAddressInputField.text,RT_LanIP,
                                subnetMaskInputField.text,RT_NetMask,
                                @"",RT_HostName,
                                dhcpEnabledStr,RT_DHCPS_Enable,
                                dhcpIPPoolStartInputField.text,RT_DHCPS_StartIP,
                                dhcpIPPoolEndInputField.text,RT_DHCPS_EndIP,
                                [Lan_Lease_Time_Key objectForKey:[[NSNumber numberWithInteger:dhcpLeaseTimeSelectionButton.tag] stringValue]],RT_DHCPS_Lease,
                                @"32",RT_DHCPS_MaxClient,
                                dnsModeStr,RT_DNS_Mode,
                                dnsList,RT_DNS_List,
                                dnsRelalyStr,RT_DNS_Relay_Enable,nil];
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [[Utility defaultUtility] rebootSystem];
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
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:NSLocalizedStringFromTable(@"lanStr",NULL,@"RouterUIStrings")];
    [self addSubview:container];

    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;

    // IP Address TitleLabel
    UILabel *ipAddressTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanIPAddrStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:ipAddressTitleLabel];
    
    // IP Address InputTextField
    ipAddressInputField = [self inputTextField:CGRectMake(controlsXDelta, ipAddressTitleLabel.frame.origin.y + ipAddressTitleLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    ipAddressInputField.delegate = self;
    [container addSubview:ipAddressInputField];
    
    // Subnet Mask TitleLabel
    UILabel *subnetMaskTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, ipAddressInputField.frame.origin.y+ipAddressInputField.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanSubnetMaskStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:subnetMaskTitleLabel];

    // Subnet Mask InputTextField
    subnetMaskInputField = [self inputTextField:CGRectMake(controlsXDelta, subnetMaskTitleLabel.frame.origin.y + subnetMaskTitleLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    subnetMaskInputField.delegate = self;
    [container addSubview:subnetMaskInputField];

    // Host name TitleLabel
    /*UILabel *hostNameTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, subnetMaskInputField.frame.origin.y+subnetMaskInputField.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanHostNameStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:hostNameTitleLabel];

    // Host name InputTextField
    hostNameInputField = [self inputTextField:CGRectMake(controlsXDelta, hostNameTitleLabel.frame.origin.y + hostNameTitleLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    hostNameInputField.delegate = self;
    [container addSubview:hostNameInputField];*/

    // DHCP Server TitleLabel
    UILabel *dhcpServerTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, subnetMaskInputField.frame.origin.y+subnetMaskInputField.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanDhcpServerStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:dhcpServerTitleLabel];

    // DHCP Server Switch
    dhcpSwitch = [self switchControl:CGRectMake(controlsXDelta, dhcpServerTitleLabel.frame.origin.y + dhcpServerTitleLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    dhcpSwitch.on = NO;
    [container addSubview:dhcpSwitch];

    // --------------------------------------------------------------------------------------------------
    // level1 height
    heightLevel1 = dhcpSwitch.frame.origin.y + dhcpSwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    
    // DHCP IP Pool TitleLabel
    dhcpIPPoolTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, dhcpSwitch.frame.origin.y+dhcpSwitch.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanDhcpIPPoolStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:dhcpIPPoolTitleLabel];

    // DHCP IP Pool Start/End InputTextField
    dhcpIPPoolStartInputField = [self inputTextField:CGRectMake(controlsXDelta, dhcpIPPoolTitleLabel.frame.origin.y + dhcpIPPoolTitleLabel.frame.size.height, controlsWidth/2 - 10, INPUT_TEXTFIELD_HEIGHT)];
    dhcpIPPoolStartInputField.delegate = self;
    [container addSubview:dhcpIPPoolStartInputField];

    dhcpIPPoolEndInputField = [self inputTextField:CGRectMake(dhcpIPPoolStartInputField.frame.origin.x + dhcpIPPoolStartInputField.frame.size.width + 20, dhcpIPPoolTitleLabel.frame.origin.y + dhcpIPPoolTitleLabel.frame.size.height, controlsWidth/2 - 10, INPUT_TEXTFIELD_HEIGHT)];
    dhcpIPPoolEndInputField.delegate = self;
    [container addSubview:dhcpIPPoolEndInputField];

    // DHCP IP Pool TitleLabel
    dhcpLeaseTimeTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, dhcpIPPoolStartInputField.frame.origin.y+dhcpIPPoolStartInputField.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanDhcpLeaseTimeStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:dhcpLeaseTimeTitleLabel];

    // DHCP IP Pool SelectionButton
    dhcpLeaseTimeSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, dhcpLeaseTimeTitleLabel.frame.origin.y + dhcpLeaseTimeTitleLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    [container addSubview:dhcpLeaseTimeSelectionButton];

    // DNS Mode TitleLabel
    dnsModeTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, dhcpLeaseTimeSelectionButton.frame.origin.y+dhcpLeaseTimeSelectionButton.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanDNSModeStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:dnsModeTitleLabel];

    // DNS Mode Switch
    dnsModeSwitch = [self switchControl:CGRectMake(controlsXDelta, dnsModeTitleLabel.frame.origin.y + dnsModeTitleLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"manualStr",NULL,@"TipStrings")];
    dnsModeSwitch.on = NO;
    [container addSubview:dnsModeSwitch];

    // --------------------------------------------------------------------------------------------------
    // level2 height
    heightLevel2 = dnsModeSwitch.frame.origin.y + dnsModeSwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP;

    // Manual DNS Server (Primary) TitleLabel
    primaryDNSServerTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, dnsModeSwitch.frame.origin.y+dnsModeSwitch.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanDNSServerPrimaryStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:primaryDNSServerTitleLabel];

    // Manual DNS Server (Primary) InputTextField
    primaryDNSServerInputField = [self inputTextField:CGRectMake(controlsXDelta, primaryDNSServerTitleLabel.frame.origin.y + primaryDNSServerTitleLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    primaryDNSServerInputField.delegate = self;
    [container addSubview:primaryDNSServerInputField];

    // Manual DNS Server (Primary) TitleLabel
    senondaryDNSServerTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, primaryDNSServerInputField.frame.origin.y+primaryDNSServerInputField.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanDNSServerSecondaryStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:senondaryDNSServerTitleLabel];

    // Manual DNS Server (Secondary) InputTextField
    secondaryDNSServerInputField = [self inputTextField:CGRectMake(controlsXDelta, senondaryDNSServerTitleLabel.frame.origin.y + senondaryDNSServerTitleLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    secondaryDNSServerInputField.delegate = self;
    [container addSubview:secondaryDNSServerInputField];

    // DNS Relay TitleLabel
    dnsRelayTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, secondaryDNSServerInputField.frame.origin.y+secondaryDNSServerInputField.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"landDNSRelayStr",NULL,@"RouterLANUIStrings")];
    [container addSubview:dnsRelayTitleLabel];

    // DNS Relay InputTextField
    dnsRelaySwitch = [self switchControl:CGRectMake(controlsXDelta, dnsRelayTitleLabel.frame.origin.y + dnsRelayTitleLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    dnsRelaySwitch.on = NO;
    [container addSubview:dnsRelaySwitch];

    // --------------------------------------------------------------------------------------------------
    // level3 height
    heightLevel3 = dnsRelaySwitch.frame.origin.y + dnsRelaySwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP;

    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
    
    //
    [self updateLevelUIStatus];
    //[self setLevel2UIControls:YES];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okCancelButtonAction:)];
    [self addSubview:okButton];
}

#pragma mark -

- (void)updateLevelUIStatus
{
    if(dhcpSwitch.on)
    {
        [self setLevel2UIControls:NO];
        
        if(!dnsModeSwitch.on)
        {
            [container setHeight:heightLevel3];
            [self setLevel3UIControls:NO];
        }
        else
        {
            [container setHeight:heightLevel2];
            [self setLevel3UIControls:YES];
        }
    }
    else
    {
        [container setHeight:heightLevel1];
        [self setLevel2UIControls:YES];
        [self setLevel3UIControls:YES];
    }
    
    [self adjustContentHeight];
}

- (void)setLevel2UIControls:(BOOL)toHide
{
    dhcpIPPoolTitleLabel.hidden = toHide;
    dhcpIPPoolStartInputField.hidden = toHide;
    dhcpIPPoolEndInputField.hidden = toHide;
    dhcpLeaseTimeTitleLabel.hidden = toHide;
    dhcpLeaseTimeSelectionButton.hidden = toHide;
    dnsModeTitleLabel.hidden = toHide;
    dnsModeSwitch.hidden = toHide;
}

- (void)setLevel3UIControls:(BOOL)toHide
{
    primaryDNSServerTitleLabel.hidden = toHide;
    primaryDNSServerInputField.hidden = toHide;
    senondaryDNSServerTitleLabel.hidden = toHide;
    secondaryDNSServerInputField.hidden = toHide;
    dnsRelayTitleLabel.hidden = toHide;
    dnsRelaySwitch.hidden = toHide;
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)container.superview;
    float controlsHeight = container.frame.size.height + DATA_CONTAINER_GAP*2 + DATA_CONTAINER_GAP + 30;
    if(controlsHeight > containerScrollView.frame.size.height)
        [self setContentHeight:controlsHeight];
    else
    {
        [self setContentHeight:containerScrollView.frame.size.height+1];
    }
    
    CGRect okButtonRect = okButton.frame;
    okButtonRect.origin.y = container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP;
    okButton.frame = okButtonRect;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    focusedInputTextField = (InputTextField *)textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboardInView:nil];
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

#pragma mark - Hide Keyboard manually

- (void)hideKeyboardInView:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark -input limited
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@""];
    
    if (ipAddressInputField == textField || subnetMaskInputField == textField || dhcpIPPoolStartInputField == textField || dhcpIPPoolEndInputField == textField || primaryDNSServerInputField == textField || secondaryDNSServerInputField == textField)
    {
        if (![characterList containsObject:string])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)legalIpAddress:(NSString *)ipAddress
{
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"."];
    for (int i = 0; i < ipAddress.length; i++)
    {
        NSString *tmpChar = [ipAddress substringWithRange:NSMakeRange(i, 1)];
        if (![characterList containsObject:tmpChar])
        {
            return NO;
        }
    }
    
    NSArray *subArray = [ipAddress componentsSeparatedByString:@"."];
    if (subArray.count != 4)
    {
        return NO;
    }
    
    for (int i = 0; i < subArray.count; i++)
    {
        if (i == 0)
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub1 = [indexStr integerValue];
            
            if (sub1 <=0 || sub1 > 255 || sub1 == 127)
            {
                return NO;
            }
        }
        else if ( i == subArray.count - 1)
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub4 = [indexStr integerValue];
            
            if (sub4 <=0 || sub4 >= 255)
            {
                return NO;
            }
        }
        else
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub = [indexStr integerValue];
            if (sub < 0 || sub > 255)
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)legalSubnetMask:(NSString *)mask
{
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"."];
    for (int i = 0; i < mask.length; i++)
    {
        NSString *tmpChar = [mask substringWithRange:NSMakeRange(i, 1)];
        if (![characterList containsObject:tmpChar])
        {
            return NO;
        }
    }

    NSArray *subArray = [mask componentsSeparatedByString:@"."];
    if (subArray.count != 4)
    {
        return NO;
    }
    
    for (int i = 0; i < subArray.count; i++)
    {
        if (i == 0)
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub1 = [indexStr integerValue];
            
            if (sub1 < 1 || sub1 > 255)
            {
                return NO;
            }
        }
        else if ( i == subArray.count - 1)
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub4 = [indexStr integerValue];
            
            if (sub4 < 0 || sub4 > 254)
            {
                return NO;
            }
        }
        else
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub = [indexStr integerValue];
            if (sub < 0 || sub > 255)
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)legalDNS:(NSString *)dns
{
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"."];
    for (int i = 0; i < dns.length; i++)
    {
        NSString *tmpChar = [dns substringWithRange:NSMakeRange(i, 1)];
        if (![characterList containsObject:tmpChar])
        {
            return NO;
        }
    }
    
    NSArray *subArray = [dns componentsSeparatedByString:@"."];
    if (subArray.count != 4)
    {
        return NO;
    }
    
    for (int i = 0; i < subArray.count; i++)
    {
        if (i == 0)
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub1 = [indexStr integerValue];
            
            if (sub1 < 1 || sub1 > 224 || sub1 != 127)
            {
                return NO;
            }
        }
        else
        {
            NSString *indexStr = [subArray objectAtIndex:i];
            NSInteger sub = [indexStr integerValue];
            if (sub < 0 || sub > 255)
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)limitedLanSetting
{
    if ([self legalIpAddress:ipAddressInputField.text] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidIpAddressStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self legalSubnetMask:subnetMaskInputField.text] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidsubnetMaskStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }

    if (dhcpSwitch.on)
    {
        if ([self legalIpAddress:dhcpIPPoolStartInputField.text] == NO || [self legalIpAddress:dhcpIPPoolEndInputField.text] == NO)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidIpAddressStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if (!dnsModeSwitch.on)
        {
            if ([self legalIpAddress:primaryDNSServerInputField.text] == NO || [self legalIpAddress:secondaryDNSServerInputField.text] == NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidIpAddressStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return NO;
            }
            
            if ([primaryDNSServerInputField.text isEqualToString:secondaryDNSServerInputField.text])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"DuplicateDNSAddressStr",NULL,@"TipStrings")
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
