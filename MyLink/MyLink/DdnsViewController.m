//
//  DdnsViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "ddnsViewController.h"

#define MENU_LIST @[NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"dnyDNSStr",NULL,@"TipStrings")]

@interface DdnsViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    //
    DataContainer *container;
    
    UILabel *ddnsServerLabel;
    SelectionButton *ddnsServerSelectionButton;
    
    UILabel *userNameLabel;
    InputTextField *userNameInput;
    
    UILabel *passwordLabel;
    InputTextField *passwordInput;
    
    UILabel *domainNameLabel;
    InputTextField *domainNameInput;
    
    UIButton *okButton;
    
    //
    float heightLevel1;
    float heightLevel2;
    
    //
    InputTextField *focusedInputTextField;
}
@end

@implementation DdnsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"ddnsStr",NULL,@"RouterUIStrings")];
    
    [self setupUIControls];
    
    [self getDDNSData];
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

#pragma mark - Selection Button action

- (void)selectionButtonAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:MENU_LIST];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[MENU_LIST objectAtIndex:selectedIndex]];
            selButton.tag = selectedIndex;
            
            if(selectedIndex == 0)
                [self setLevelHeight:heightLevel1];
            else
                [self setLevelHeight:heightLevel2];
        }
    }];
}

#pragma mark - OK button actions

- (void)okButtonAction:(id)sender
{
    if ([self limitedDDNSSetting] == NO)
    {
        return;
    }
    
    [self setDDNSData];
}

#pragma mark - set/get data

- (void)getDDNSData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterDDNSData:^(id data, NSError *error) {
        if(data)
        {
            //
            int selectButtonIndex = [[data objectForKey:RT_DDNS_Server] intValue];
            [ddnsServerSelectionButton setButtonTitle:[MENU_LIST objectAtIndex:selectButtonIndex]];
            userNameInput.text = [data objectForKey:RT_DDNS_UserName];
            passwordInput.text = [data objectForKey:RT_DDNS_Password];
            domainNameInput.text = [data objectForKey:RT_DDNS_Domain];
            
            if(selectButtonIndex == 0)
                [self setLevelHeight:heightLevel1];
            else if(selectButtonIndex == 1)
                [self setLevelHeight:heightLevel2];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setDDNSData
{
    int controlIndex = 0;
    if(ddnsServerSelectionButton.tag == 0)
        controlIndex = 0;
    else if(ddnsServerSelectionButton.tag == 1)
        controlIndex = 1;

    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_Router_DDNS,URL_CONFIG_ID,
                                [NSNumber numberWithInt:controlIndex],RT_DDNS_Server,
                                userNameInput.text,RT_DDNS_UserName,
                                passwordInput.text,RT_DDNS_Password,
                                domainNameInput.text,RT_DDNS_Domain,nil];
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
        }
        
        [[Utility defaultUtility] hudClose];
    }];
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
    
    // DDNS Server TitleLabel
    ddnsServerLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"ddnsServerStr",NULL,@"RouterDDNSUIStrings")];
    [container addSubview:ddnsServerLabel];
    
    // DDNS Server Selection Button
    ddnsServerSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, ddnsServerLabel.frame.origin.y + ddnsServerLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    ddnsServerSelectionButton.tag = 0;
    [ddnsServerSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    [container addSubview:ddnsServerSelectionButton];
    
    //
    heightLevel1 = ddnsServerSelectionButton.frame.origin.y + ddnsServerSelectionButton.frame.size.height + controlsYDelta*2;
    
    // Uer Name TitleLabel
    userNameLabel = [self titleLabel:CGRectMake(controlsXDelta, ddnsServerSelectionButton.frame.origin.y+ddnsServerSelectionButton.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"ddnsUserNameStr",NULL,@"RouterDDNSUIStrings")];
    [container addSubview:userNameLabel];
    
    // Uer Name InputTextField
    userNameInput = [self inputTextField:CGRectMake(controlsXDelta, userNameLabel.frame.origin.y + userNameLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    userNameInput.delegate = self;
    [container addSubview:userNameInput];
    
    // Password TitleLabel
    passwordLabel = [self titleLabel:CGRectMake(controlsXDelta, userNameInput.frame.origin.y+userNameInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"ddnsPasswordStr",NULL,@"RouterDDNSUIStrings")];
    [container addSubview:passwordLabel];
    
    // Password InputTextField
    passwordInput = [self inputTextField:CGRectMake(controlsXDelta, passwordLabel.frame.origin.y + passwordLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    passwordInput.delegate = self;
    [container addSubview:passwordInput];
    
    // Domain Name TitleLabel
    domainNameLabel = [self titleLabel:CGRectMake(controlsXDelta, passwordInput.frame.origin.y+passwordInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"ddnsDomainNameStr",NULL,@"RouterDDNSUIStrings")];
    [container addSubview:domainNameLabel];
    
    // Domain Name InputTextField
    domainNameInput = [self inputTextField:CGRectMake(controlsXDelta, domainNameLabel.frame.origin.y + domainNameLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    domainNameInput.delegate = self;
    [container addSubview:domainNameInput];
    
    //
    heightLevel2 = domainNameInput.frame.origin.y + domainNameInput.frame.size.height + controlsYDelta*2;

    //
    [self setLevelHeight:heightLevel1];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];
    
    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
}

- (void)setLevelHeight:(float)levelHeight
{
    [container setHeight:levelHeight];
    
    BOOL toHide = NO;
    if(levelHeight == heightLevel1)
    {
        toHide = YES;
    }
    else
    {
        toHide = NO;
    }
    
    userNameLabel.hidden = toHide;
    userNameInput.hidden = toHide;
    passwordLabel.hidden = toHide;
    passwordInput.hidden = toHide;
    domainNameLabel.hidden = toHide;
    domainNameInput.hidden = toHide;

    okButton.frame = CGRectMake(DATA_CONTAINER_GAP , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30);
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

- (BOOL)limitedDDNSSetting
{
    if ([ddnsServerSelectionButton.titleLabel.text isEqualToString:NSLocalizedStringFromTable(@"dnyDNSStr",NULL,@"TipStrings")])
    {
        if ([userNameInput.text isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyDDNSUserNameStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        if ([passwordInput.text isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyDDNSPasswordStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        if ([domainNameInput.text isEqualToString:@""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyDDNSDomainNameStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}







@end
