//
//  PINMgrViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "PINMgrViewController.h"

@interface PINMgrViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    DataContainer *container;
    
    UILabel *pinStatusTitle;
    InputTextField *pinStatusInput;
    
    UILabel *pinRetainTitle;
    InputTextField *pinRetainInput;
    
    UILabel *pukRetainTitle;
    InputTextField *pukRetainInput;
    
    UILabel *pinOperationTitle;
    SevenSwitch *pinSwitch;
    
    //
    DataContainer *modifyPIINContainer;
    
    UILabel *oldPinLabel;
    InputTextField *oldPinInput;
    
    UILabel *newPinLabel;
    InputTextField *newPinInput;
    
    UILabel *confirmNewPinLabel;
    InputTextField *confirmNewPinInput;
    
    UIButton *okButton;
    
    //
    InputTextField *focusedInputTextField;
    
    //
    BOOL isPINEnabled;
    int pinRetainTimes;
    int pukRetainTimes;
}
@end

@implementation PINMgrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"pinMgrStr",NULL,@"WanUIStrings")];
    
    [self setupUIControls];
    
    [self getPINData:YES];
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button action

- (void)okButtonAction:(id)sender
{
    [self hideKeyboardInView:nil];
    [self modifyPIN];
}

#pragma mark - Switch Control action

- (void)switchControlAction:(id)sender
{
    NSString *retainStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"pinInputSubStr",NULL,@"PINInputStrings"),pinRetainTimes];
    UIAlertView *pinInputDialog = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"pinInputStr",NULL,@"PINInputStrings")
                                                message:retainStr
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    pinInputDialog.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [pinInputDialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [pinInputDialog textFieldAtIndex:0].placeholder = NSLocalizedStringFromTable(@"pinInputFieldTipStr",NULL,@"PINInputStrings");
    pinInputDialog.tag = 0;
    [pinInputDialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1) //OK
    {
        if(alertView.tag == 0) //pinInputDialog
        {
            NSString *pinStr = [[alertView textFieldAtIndex:0] text];
            
            [self performSelectorOnMainThread:@selector(enableDisablePIN:) withObject:pinStr waitUntilDone:YES];
        }
    }
    else
    {
        pinSwitch.on = isPINEnabled;
    }
}

- (void)enableDisablePIN:(id)sender
{
    NSString *pinStr = sender;
    if(pinStr.length < 4 || pinStr.length > 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"wrongPINFormatStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        alert.tag = 1;
        [alert show];
        return;
    }
    
    if(isPINEnabled)
    {
        // current is pin enabled, disable it
        NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     Config_PIN_Disable,URL_CONFIG_ID,
                                     pinStr,SIM_PIN_Num,nil];
        
        [[Utility defaultUtility] hudShowWithTitle:@"" forView:container.superview];
        [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
            if(data)
            {
                NSString *result = [data objectForKey:@"result"];
                if([result isEqualToString:@"success"])
                {
                    [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"disablePINOKStr",NULL,@"TipStrings")];
                }
                else if([result isEqualToString:@"error"])
                {
                    if(pinRetainTimes > 1)
                        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"wrongPINStr",NULL,@"TipStrings")];
                }
            }
            
            [self getPINData:NO];
            [[Utility defaultUtility] hudClose];
        }];
    }
    else
    {
        // current is pin disabled, enable it
        [[Utility defaultUtility] hudShowWithTitle:@"" forView:container.superview];
        NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     Config_PIN_Enable,URL_CONFIG_ID,
                                     pinStr,SIM_PIN_Num,nil];
        
        [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
            if(data)
            {
                NSString *result = [data objectForKey:@"result"];
                if([result isEqualToString:@"success"])
                {
                    [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"enablePINOKStr",NULL,@"TipStrings")];
                }
                else if([result isEqualToString:@"error"])
                {
                    if(pinRetainTimes > 1)
                        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"wrongPINStr",NULL,@"TipStrings")];
                }
            }
            
            [self getPINData:NO];
            [[Utility defaultUtility] hudClose];
        }];
    }
}

- (void)modifyPIN
{
    NSString *oldPinStr = oldPinInput.text;
    NSString *newPinStr = newPinInput.text;
    NSString *confimPinStr = confirmNewPinInput.text;
    
    if(oldPinStr.length == 0)
    {
        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"oldPinEmptyStr",NULL,@"TipStrings")];
        return;
    }

    if(newPinStr.length == 0)
    {
        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"newPinEmptyStr",NULL,@"TipStrings")];
        return;
    }

    if(confimPinStr.length == 0)
    {
        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"confirmEmptyStr",NULL,@"TipStrings")];
        return;
    }
    
    if(![newPinStr isEqualToString:confimPinStr])
    {
        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"newConfirmErrorStr",NULL,@"TipStrings")];
        return;
    }

    if(oldPinStr.length < 4 || oldPinStr.length > 8 || newPinStr.length < 4 || newPinStr.length > 8 || confimPinStr.length < 4 || confimPinStr.length > 8)
    {
        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"wrongPINFormatStr",NULL,@"TipStrings")];
        return;
    }

    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_PIN_Change,URL_CONFIG_ID,
                                 oldPinStr,SIM_Old_PIN_Num,
                                 newPinStr,SIM_New_PIN_Num,nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@"" forView:container.superview];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"modifyPINOKStr",NULL,@"TipStrings")];
            }
            else if([result isEqualToString:@"error"])
            {
                if(pinRetainTimes > 1)
                    [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"modifyPINNOStr",NULL,@"TipStrings")];
            }
        }
        
        oldPinInput.text = @"";
        newPinInput.text = @"";
        confirmNewPinInput.text = @"";
        
        [self getPINData:NO];
        [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - get/set data

- (void)getPINData:(BOOL)needHUD
{
    if(needHUD)
        [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requesetWanPINStatusData:^(id data, NSError *error) {
        if(data)
        {            
            //
            NSString *simStatusStr = [data objectForKey:SIM_Status];
            if([simStatusStr isEqualToString:@"pin_enable"])
            {
                pinStatusInput.text = NSLocalizedStringFromTable(@"pinMgrPinEnableStatusStr",NULL,@"pinMgrUIStrings");
                pinSwitch.on = YES;
                isPINEnabled = YES;
            }
            else if([simStatusStr isEqualToString:@"pin_disable"])
            {
                pinStatusInput.text = NSLocalizedStringFromTable(@"pinMgrPinDsiableStatusStr",NULL,@"pinMgrUIStrings");
                pinSwitch.on = NO;
                isPINEnabled = NO;
            }
            else
                pinStatusInput.text = simStatusStr;
            
            pinRetainInput.text = [data objectForKey:SIM_PIN_Remain_Num];
            pinRetainTimes = [[data objectForKey:SIM_PIN_Remain_Num] intValue];
            
            pukRetainInput.text = [data objectForKey:SIM_PUK_Remain_Num];
            pukRetainTimes = [[data objectForKey:SIM_PUK_Remain_Num] intValue];
        }
        
        //
        [self updateUIStatus];
        
        if(needHUD)
            [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - Init UI Controls

- (void)setupUIControls
{
    CGRect sFrame = self.view.bounds;
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:NSLocalizedStringFromTable(@"pinMgrPinInfoTitleStr",NULL,@"pinMgrUIStrings")];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // PIN Status Title Label
    pinStatusTitle = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"pinMgrPinStatusStr",NULL,@"pinMgrUIStrings")];
    [container addSubview:pinStatusTitle];
    
    // PIN Status Input Label
    pinStatusInput = [self inputTextField:CGRectMake(controlsXDelta, pinStatusTitle.frame.origin.y+pinStatusTitle.frame.size.height, controlsWidth, TITLE_LABEL_HEIGHT)];
    pinStatusInput.delegate = self;
    pinStatusInput.enabled = NO;
    [container addSubview:pinStatusInput];

    // PIN Retain Times Title Label
    pinRetainTitle = [self titleLabel:CGRectMake(controlsXDelta, pinStatusInput.frame.origin.y+pinStatusInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"pinMgrPinRemainStr",NULL,@"pinMgrUIStrings")];
    [container addSubview:pinRetainTitle];

    //PIN Retain Times Input
    pinRetainInput = [self inputTextField:CGRectMake(controlsXDelta, pinRetainTitle.frame.origin.y+pinRetainTitle.frame.size.height, controlsWidth, TITLE_LABEL_HEIGHT)];
    pinRetainInput.delegate = self;
    pinRetainInput.enabled = NO;
    [container addSubview:pinRetainInput];

    // PUK Retain Times Title Label
    pukRetainTitle = [self titleLabel:CGRectMake(controlsXDelta, pinRetainInput.frame.origin.y+pinRetainInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"pinMgrPukRemainStr",NULL,@"pinMgrUIStrings")];
    [container addSubview:pukRetainTitle];
    
    //PUK Retain Times Input
    pukRetainInput = [self inputTextField:CGRectMake(controlsXDelta, pukRetainTitle.frame.origin.y+pukRetainTitle.frame.size.height, controlsWidth, TITLE_LABEL_HEIGHT)];
    pukRetainInput.delegate = self;
    pukRetainInput.enabled = NO;
    [container addSubview:pukRetainInput];

    // PIN Operation Title
    pinOperationTitle = [self titleLabel:CGRectMake(controlsXDelta, pukRetainInput.frame.origin.y+pukRetainInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"pinMgrPinOperationStr",NULL,@"pinMgrUIStrings")];
    [container addSubview:pinOperationTitle];
    
    // PIN Operation Switch
    pinSwitch = [self switchControl:CGRectMake(controlsXDelta, pinOperationTitle.frame.origin.y + pinOperationTitle.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    pinSwitch.on = NO;
    [container addSubview:pinSwitch];

    //
    [container setHeight:pinSwitch.frame.origin.y + pinSwitch.frame.size.height + controlsYDelta*2];

    //
    modifyPIINContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:NSLocalizedStringFromTable(@"pinMgrModifyPINStr",NULL,@"pinMgrUIStrings")];
    [self addSubview:modifyPIINContainer];

    // Old PIN TitleLabel
    oldPinLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [modifyPIINContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"oldPinStr",NULL,@"PINInputStrings")];
    [modifyPIINContainer addSubview:oldPinLabel];
    
    // Old PIN InputTextField
    oldPinInput = [self inputTextField:CGRectMake(controlsXDelta, oldPinLabel.frame.origin.y + oldPinLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    oldPinInput.secureTextEntry = YES;
    oldPinInput.keyboardType = UIKeyboardTypeNumberPad;
    oldPinInput.delegate = self;
    [modifyPIINContainer addSubview:oldPinInput];

    // New PIN TitleLabel
    newPinLabel = [self titleLabel:CGRectMake(controlsXDelta, oldPinInput.frame.origin.y+oldPinInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"newPinStr",NULL,@"PINInputStrings")];
    [modifyPIINContainer addSubview:newPinLabel];
    
    // New PIN InputTextField
    newPinInput = [self inputTextField:CGRectMake(controlsXDelta, newPinLabel.frame.origin.y + newPinLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    newPinInput.secureTextEntry = YES;
    newPinInput.keyboardType = UIKeyboardTypeNumberPad;
    newPinInput.delegate = self;
    [modifyPIINContainer addSubview:newPinInput];

    // Confirm New PIN TitleLabel
    confirmNewPinLabel = [self titleLabel:CGRectMake(controlsXDelta, newPinInput.frame.origin.y+newPinInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"confirmPinStr",NULL,@"PINInputStrings")];
    [modifyPIINContainer addSubview:confirmNewPinLabel];
    
    // Confirm New PIN InputTextField
    confirmNewPinInput = [self inputTextField:CGRectMake(controlsXDelta, confirmNewPinLabel.frame.origin.y + confirmNewPinLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    confirmNewPinInput.secureTextEntry = YES;
    confirmNewPinInput.keyboardType = UIKeyboardTypeNumberPad;
    confirmNewPinInput.delegate = self;
    [modifyPIINContainer addSubview:confirmNewPinInput];

    //
    [modifyPIINContainer setHeight:confirmNewPinInput.frame.origin.y + confirmNewPinInput.frame.size.height + controlsYDelta*2];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, modifyPIINContainer.frame.origin.y + modifyPIINContainer.frame.size.height + DATA_CONTAINER_GAP, modifyPIINContainer.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];

    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
}

- (void)updateUIStatus
{
    BOOL toHide = NO;
    if(pinSwitch.on)
    {
        toHide = NO;
    }
    else
    {
        toHide = YES;
    }
    
    modifyPIINContainer.hidden = toHide;
    oldPinLabel.hidden = toHide;
    oldPinInput.hidden = toHide;
    newPinLabel.hidden = toHide;
    newPinInput.hidden = toHide;
    confirmNewPinLabel.hidden = toHide;
    confirmNewPinInput.hidden = toHide;
    okButton.hidden = toHide;
    
    okButton.frame = CGRectMake(DATA_CONTAINER_GAP, modifyPIINContainer.frame.origin.y + modifyPIINContainer.frame.size.height + DATA_CONTAINER_GAP, modifyPIINContainer.frame.size.width, 30);
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)modifyPIINContainer.superview;
    float controlsHeight = container.frame.size.height + modifyPIINContainer.frame.size.height + okButton.frame.size.height + DATA_CONTAINER_GAP*4;
    if(controlsHeight > containerScrollView.frame.size.height)
        [self setContentHeight:controlsHeight];
    else
    {
        [self setContentHeight:containerScrollView.frame.size.height+1];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == pinStatusInput || textField == pinRetainInput || textField == pukRetainInput)
        return NO;
    
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

@end
