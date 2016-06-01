//
//  DmzSettingViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "dmzSettingViewController.h"

@interface DmzSettingViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    DataContainer *container;
    
    UILabel *dmzLabel;
    SevenSwitch *dmzSwitch;
    
    UILabel *dstIPAddressLabel;
    InputTextField *dstIPAddressInput;
    
    UILabel *srcIPAddressLabel;
    SevenSwitch *srcIPAddressSwitch;
    
    UILabel *fromLabel;
    InputTextField *fromInput;
    
    UILabel *toLabel;
    InputTextField *toInput;
    
    UIButton *okButton;
    
    //
    float heightLevel1;
    float heightLevel2;
    float heightLevel3;
    
    //
    InputTextField *focusedInputTextField;
    
    NSString *lanIP;
}
@end

@implementation DmzSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"dmzStr",NULL,@"RouterUIStrings")];
    
    [self setupUIControls];
    
    [self initData];
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

#pragma mark - get/set data

- (void)initData
{
    [self getPortForwardData];
}

- (void)getPortForwardData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterDMZSettingData:^(id data, NSError *error) {
        if(data)
        {            
            //
            dmzSwitch.on = [[data objectForKey:RT_DMZ_Enabled] isEqualToString:@"1"] ? YES : NO;
            dstIPAddressInput.text = [data objectForKey:RT_DMZ_Host];
            
            lanIP = [data objectForKey:RT_LanIP];
            
            NSString *dmzIPStr = [data objectForKey:RT_DMZ_Src];
            if(dmzIPStr.length > 0)
            {
                srcIPAddressSwitch.on = NO;
                fromInput.text = [[dmzIPStr componentsSeparatedByString:@"-"] objectAtIndex:0];
                toInput.text = [[dmzIPStr componentsSeparatedByString:@"-"] objectAtIndex:1];
            }
            else
            {
                srcIPAddressSwitch.on = YES;
            }
            
            [self updateLevelUIStatus];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setPortForwardData
{
    NSString *dmzEnableStr = dmzSwitch.on ? @"1" : @"0";
    NSString *dmzSrcStr = [NSString stringWithFormat:@"%@-%@",fromInput.text,toInput.text];
    if(srcIPAddressSwitch.on)
        dmzSrcStr = @"";
    NSDictionary *configDict = nil;
    configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_DMZ,URL_CONFIG_ID,
                                dmzEnableStr,RT_DMZ_Enabled,
                                dstIPAddressInput.text,RT_DMZ_Host,
                                dmzSrcStr,RT_DMZ_Src,nil];
    
    if(!dmzSwitch.on)
        configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                      Config_DMZ,URL_CONFIG_ID,
                      dmzEnableStr,RT_DMZ_Enabled,
                      @"",RT_DMZ_Host,
                      @"",RT_DMZ_Src,nil];

    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - Switch Control action

- (void)switchControlAction:(id)sender
{
    [self updateLevelUIStatus];
}

#pragma mark - OK Button action

- (void)okButtonAction:(id)sender
{
    if ([self limitedDMZSetting] == NO)
    {
        return;
    }
    
    [self setPortForwardData];
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
    
    // DMZ TitleLabel
    dmzLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"dmzSettingStr",NULL,@"RouterDMZSettingUIStrings")];
    [container addSubview:dmzLabel];
    
    // DMZ Switch
    dmzSwitch = [self switchControl:CGRectMake(controlsXDelta, dmzLabel.frame.origin.y + dmzLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    dmzSwitch.on = NO;
    [container addSubview:dmzSwitch];
    
    //
    heightLevel1 = dmzSwitch.frame.origin.y + dmzSwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;
    
    // Destination IP Address TitleLabel
    dstIPAddressLabel = [self titleLabel:CGRectMake(controlsXDelta, dmzSwitch.frame.origin.y + dmzSwitch.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"dmzSettingDstIPAddressStr",NULL,@"RouterDMZSettingUIStrings")];
    [container addSubview:dstIPAddressLabel];
    
    // Destination IP Address InputTextField
    dstIPAddressInput = [self inputTextField:CGRectMake(controlsXDelta, dstIPAddressLabel.frame.origin.y + dstIPAddressLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    dstIPAddressInput.delegate = self;
    [container addSubview:dstIPAddressInput];
    
    // Source IP Address TitleLabel
    srcIPAddressLabel = [self titleLabel:CGRectMake(controlsXDelta, dstIPAddressInput.frame.origin.y + dstIPAddressInput.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"dmzSettingSrcIPAddressStr",NULL,@"RouterDMZSettingUIStrings")];
    [container addSubview:srcIPAddressLabel];
    
    // Source IP Address Switch
    srcIPAddressSwitch = [self switchControl:CGRectMake(controlsXDelta, srcIPAddressLabel.frame.origin.y + srcIPAddressLabel.frame.size.height, 100, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"anyStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"restrictionStr",NULL,@"TipStrings")];
    srcIPAddressSwitch.on = NO;
    [container addSubview:srcIPAddressSwitch];

    //
    heightLevel2 = srcIPAddressSwitch.frame.origin.y + srcIPAddressSwitch.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;

    // Source IP From TitleLabel
    fromLabel = [self titleLabel:CGRectMake(controlsXDelta, srcIPAddressSwitch.frame.origin.y + srcIPAddressSwitch.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"dmzSettingFromStr",NULL,@"RouterDMZSettingUIStrings")];
    [container addSubview:fromLabel];
    
    // Source IP From InputTextField
    fromInput = [self inputTextField:CGRectMake(controlsXDelta, fromLabel.frame.origin.y + fromLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    fromInput.delegate = self;
    [container addSubview:fromInput];

    // Source IP To TitleLabel
    toLabel = [self titleLabel:CGRectMake(controlsXDelta, fromInput.frame.origin.y + fromInput.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"dmzSettingToStr",NULL,@"RouterDMZSettingUIStrings")];
    [container addSubview:toLabel];
    
    // Source IP To InputTextField
    toInput = [self inputTextField:CGRectMake(controlsXDelta, toLabel.frame.origin.y + toLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    toInput.delegate = self;
    [container addSubview:toInput];

    //
    heightLevel3 = toInput.frame.origin.y + toInput.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;

    //
    [container setHeight:toInput.frame.origin.y + toInput.frame.size.height + controlsYDelta*2];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];
    
    [self updateLevelUIStatus];
    
    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];

}

- (void)updateLevelUIStatus
{
    if(dmzSwitch.on)
    {
        [self setLevel2toHide:NO];

        if(!srcIPAddressSwitch.on)
        {
            [container setHeight:heightLevel3];
            [self setLevel3toHide:NO];
        }
        else
        {
            [container setHeight:heightLevel2];
            [self setLevel3toHide:YES];
        }
    }
    else
    {
        [container setHeight:heightLevel1];
        [self setLevel2toHide:YES];
        [self setLevel3toHide:YES];
    }
    
    CGRect okButtonRect = okButton.frame;
    okButtonRect.origin.y = container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP;
    okButton.frame = okButtonRect;
}

- (void)setLevel2toHide:(BOOL)toHide
{
    dstIPAddressLabel.hidden = toHide;
    dstIPAddressInput.hidden = toHide;
    srcIPAddressLabel.hidden = toHide;
    srcIPAddressSwitch.hidden = toHide;
}

- (void)setLevel3toHide:(BOOL)toHide
{
    fromLabel.hidden = toHide;
    fromInput.hidden = toHide;
    toLabel.hidden = toHide;
    toInput.hidden = toHide;
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
    if (dstIPAddressInput == textField || fromInput == textField || toInput == textField)
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
    if ([ipAddress isEqualToString:@""])
    {
        return NO;
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

- (BOOL)differWithLanIP:(NSString *)ipAddress
{
    if ([ipAddress isEqualToString:lanIP])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)suitableInputIP:(NSString *)ipAddress
{
    NSArray *inputIPArray = [ipAddress componentsSeparatedByString:@"."];
    NSArray *lanIPArray = [lanIP componentsSeparatedByString:@"."];
    
    NSInteger count = 0;
    for (int i = 0; i < inputIPArray.count; i++)
    {
        if (i == inputIPArray.count - 1)
        {
            if (![[inputIPArray objectAtIndex:i] isEqualToString:[lanIPArray objectAtIndex:i]])
            {
                count++;
            }
        }
        else
        {
            if ([[inputIPArray objectAtIndex:i] isEqualToString:[lanIPArray objectAtIndex:i]])
            {
                count++;
            }
        }
    }
    
    if (count != inputIPArray.count)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)largerThanToInput
{
    NSString *srcIP = fromInput.text;
    NSString *dstIP = toInput.text;
    NSArray *srcArray = [srcIP componentsSeparatedByString:@"."];
    NSArray *dstArray = [dstIP componentsSeparatedByString:@"."];
    
    if (srcArray.count != dstArray.count)
    {
        return NO;
    }
    
    for (int i = 0; i < srcArray.count; i++)
    {
        if (i == srcArray.count - 1)
        {
            if ([[srcArray objectAtIndex:i] integerValue] >= [[dstArray objectAtIndex:i] integerValue])
            {
                return NO;
            }
        }
        else if ([[srcArray objectAtIndex:i] integerValue] != [[dstArray objectAtIndex:i] integerValue])
        {
            return NO;
        }
    }
    return YES;
}
- (BOOL)limitedDMZSetting
{
    if (dmzSwitch.on)
    {
        if ([self legalIpAddress:dstIPAddressInput.text] == NO)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidDstIPStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if ([self differWithLanIP:dstIPAddressInput.text] == NO)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidDstIPEqualLanIPStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if ([self suitableInputIP:dstIPAddressInput.text] == NO)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"OutofNetworkSegmentStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        
        if (!srcIPAddressSwitch.on)
        {
            if ([self legalIpAddress:fromInput.text] == NO || [self legalIpAddress:toInput.text] == NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidDstIPStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return NO;
            }
            
            if ([self differWithLanIP:fromInput.text] == NO || [self differWithLanIP:toInput.text] == NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidDstIPEqualLanIPStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return NO;
            }
            
            if ([self suitableInputIP:fromInput.text] == NO || [self suitableInputIP:toInput.text] == NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidPortStr",NULL,@"TipStrings")
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [alert show];
                return NO;
            }
            
            if ([self largerThanToInput] == NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"OutofNetworkSegmentStr",NULL,@"TipStrings")
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
