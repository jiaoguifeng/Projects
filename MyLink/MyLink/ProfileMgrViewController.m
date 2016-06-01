//
//  ProfileMgrViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "ProfileMgrViewController.h"

#define APN_Select_Header_Menu @[NSLocalizedStringFromTable(@"autoMatchStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"createNewStr",NULL,@"TipStrings")]

#define AutyType_Menu @[NSLocalizedStringFromTable(@"papStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"chapStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"noneStr",NULL,@"TipStrings")]

@interface ProfileMgrViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    //
    DataContainer *container;
    
    UILabel *setDefaultLabel;
    SelectionButton *setDefaultSelectionButton;
    
    UILabel *profileNameLabel;
    InputTextField *profileNameInput;
    
    UILabel *userNameLabel;
    InputTextField *userNameInput;
    
    UILabel *passwordLabel;
    InputTextField *passwordInput;
    
    UILabel *apnLabel;
    InputTextField *apnInput;
    
    UILabel *dialNumberLabel;
    InputTextField *dialNumberInput;
    
    UILabel *authTypeLabel;
    SelectionButton *authTypeSelectionButton;
    
    UIButton *deleteButton;
    UIButton *okButton;
    
    //
    InputTextField *focusedInputTextField;
    
    //
    float heightLevel1;
    float heightLevel2;
    
    NSMutableArray *apnDictList;
    NSInteger oldDefaultIndex;
    BOOL isCurrentDefault;
}
@end

@implementation ProfileMgrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"profileMgrStr",NULL,@"WanUIStrings")];
    
    [self setupUIControls];
    
    [self getProfileManagementData];
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

#pragma mark - Selection Button action

- (void)selectionButtonAction:(id)sender
{
    BOOL needToPopup = YES;
    
    __weak SelectionButton *selButton = sender;
    NSMutableArray *buttonMenuList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(sender == setDefaultSelectionButton)
    {
        [buttonMenuList setArray:APN_Select_Header_Menu];
        
        for(NSDictionary *apnDict in apnDictList)
        {
            NSString *proFileName = [apnDict objectForKey:APN_ProfileName];
            
            if([[apnDict objectForKey:APN_WhetherDefault] isEqualToString:@"1"])
                proFileName = [NSString stringWithFormat:@"%@ \u2713",proFileName];
            
            [buttonMenuList addObject:proFileName];
        }
    }
    else if(sender == authTypeSelectionButton)
    {
        [buttonMenuList setArray:AutyType_Menu];
        if(isCurrentDefault)
            needToPopup = NO;
    }
    
    if(!needToPopup)
        return;
    
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:buttonMenuList];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            if(selectedIndex >= 2)
                [selButton setButtonTitle:[[apnDictList objectAtIndex:selectedIndex-2] objectForKey:APN_ProfileName]];
            else
                [selButton setButtonTitle:[buttonMenuList objectAtIndex:selectedIndex]];
            selButton.tag = selectedIndex;
            
            if(selButton == setDefaultSelectionButton)
            {
                if(selectedIndex == 0)
                {
                    [self setLevelHeight:heightLevel1];
                }
                else
                {
                    [self setLevelHeight:heightLevel2];
                    [self showAPNInfo:selectedIndex];
                }
                
                [self updateUIStatus];
            }
        }
    }];
}

#pragma mark - OK button actions

- (void)buttonAction:(id)sender
{
    if(sender == okButton)
        [self setProfileManagementData];
    else
        [self deleteCurrentAPN];
}

#pragma mark - set/get data

- (void)getProfileManagementData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWanProfileManagementData:^(id data, NSError *error) {
        if(data)
        {
            //
            if(apnDictList)
                apnDictList = nil;
            apnDictList = [[NSMutableArray alloc] initWithCapacity:0];
            [apnDictList setArray:[[data objectForKey:Web_APN_List] objectForKey:@"apnList"]];
            
            oldDefaultIndex = [self indexOfDefaultAPN];
            
            if(oldDefaultIndex == -1)
            {
                [self setLevelHeight:heightLevel1];
                
                [setDefaultSelectionButton setButtonTitle:[APN_Select_Header_Menu objectAtIndex:0]];
                setDefaultSelectionButton.tag = 0;
            }
            else
            {
                [self setLevelHeight:heightLevel2];
                
                [setDefaultSelectionButton setButtonTitle:[[apnDictList objectAtIndex:oldDefaultIndex] objectForKey:APN_ProfileName]];
                setDefaultSelectionButton.tag = oldDefaultIndex+2;
                
                [self showAPNInfo:setDefaultSelectionButton.tag];
            }
            
            [self updateUIStatus];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setProfileManagementData
{
    NSInteger selIndex = setDefaultSelectionButton.tag;
    if(selIndex == 0)   // Auto Match
    {
        [self setNewDefaultAPN:-1];
    }
    else if(selIndex == 1)  // Create New
    {
        if ([self limitedProfileSetting] == NO)
        {
            return;
        }
        
        NSInteger authTypeIndex = authTypeSelectionButton.tag + 1;
        if(authTypeIndex == 3)
            authTypeIndex += 1;
        
        NSDictionary *newAPNDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    profileNameInput.text,APN_ProfileName,
                                    userNameInput.text,APN_UserName,
                                    passwordInput.text,APN_Password,
                                    apnInput.text,APN_Apn,
                                    dialNumberInput.text,APN_DialNum,
                                    [[NSNumber numberWithInteger:authTypeIndex] stringValue],APN_AuthType,
                                    @"3",APN_NetMode,
                                    @"3",APN_IPMode,
                                    [[NSNumber numberWithInteger:apnDictList.count] stringValue],APN_Index,
                                    @"1",APN_WhetherDefault,
                                    nil];
        
        [apnDictList addObject:newAPNDict];
        
        [self setNewDefaultAPN:apnDictList.count - 1];
    }
    else    // Change Default
    {
        [self setNewDefaultAPN:selIndex - 2];
    }
    
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_APN_List,URL_CONFIG_ID,
                                 [[NSNumber numberWithInteger:apnDictList.count] stringValue],APN_ApnListSize,
                                 [[NSNumber numberWithInteger:oldDefaultIndex] stringValue],APN_OldDefaultIndex,
                                 @"3",APN_OldNetMode,
                                 @"1",APN_SendMsg,
                                 apnDictList,APN_ApnList,nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            // add new apn success, change new oldDefaultIndex and set new setDefaultSelectionButton title
            oldDefaultIndex = [self indexOfDefaultAPN];
            if(oldDefaultIndex >= 0)
            {
                [setDefaultSelectionButton setButtonTitle:[[apnDictList objectAtIndex:oldDefaultIndex] objectForKey:APN_ProfileName]];
                setDefaultSelectionButton.tag = oldDefaultIndex+2;
            }
            
            [self updateUIStatus];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)showAPNInfo:(NSInteger)menuSelIndex
{
    if(menuSelIndex == 1)
    {
        // create new apn
        profileNameInput.text = @"";
        userNameInput.text = @"";
        passwordInput.text = @"";
        apnInput.text = @"";
        dialNumberInput.text = @"";
        [authTypeSelectionButton setButtonTitle:[AutyType_Menu objectAtIndex:2]];
        authTypeSelectionButton.tag = 2;
    }
    else
    {
        // show exists apn
        NSDictionary *selectedAPNDict = [apnDictList objectAtIndex:menuSelIndex - 2];
        if(selectedAPNDict)
        {
            profileNameInput.text = [selectedAPNDict objectForKey:APN_ProfileName];
            userNameInput.text = [selectedAPNDict objectForKey:APN_UserName];
            passwordInput.text = [selectedAPNDict objectForKey:APN_Password];
            apnInput.text = [selectedAPNDict objectForKey:APN_Apn];
            dialNumberInput.text = [selectedAPNDict objectForKey:APN_DialNum];
            
            // PAP:0 CHAP:1 NONE:4
            int theAuthType = [[selectedAPNDict objectForKey:APN_AuthType] intValue];
            int menuIndex = theAuthType - 1;
            if(menuIndex == 3)
                menuIndex -= 1;
            
            [authTypeSelectionButton setButtonTitle:[AutyType_Menu objectAtIndex:menuIndex]];
            authTypeSelectionButton.tag = 2;
        }
    }
}

- (NSInteger)indexOfDefaultAPN
{
    NSInteger defaultIndex = -1;
    
    NSDictionary *tempDict = nil;
    for(int i = 0; i < apnDictList.count; i++)
    {
        tempDict = [apnDictList objectAtIndex:i];
        if([[tempDict objectForKey:APN_WhetherDefault] isEqualToString:@"1"])
        {
            defaultIndex = i;
            break;
        }
    }
    
    return defaultIndex;
}

- (void)setNewDefaultAPN:(NSInteger)newDefaultIndex
{
    for(int i = 0; i < apnDictList.count; i++)
    {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:[apnDictList objectAtIndex:i]];
        if(i == newDefaultIndex)
        {
            [tempDict setObject:@"1" forKey:APN_WhetherDefault];
        }
        else
        {
            [tempDict setObject:@"0" forKey:APN_WhetherDefault];
        }
        
        [apnDictList replaceObjectAtIndex:i withObject:tempDict];
    }
}

- (void)deleteCurrentAPN
{
    NSInteger currentIndex = setDefaultSelectionButton.tag - 2;
    if(currentIndex >= 0)
    {
        [apnDictList removeObjectAtIndex:currentIndex];
        
        NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     Config_APN_List,URL_CONFIG_ID,
                                     [[NSNumber numberWithInteger:apnDictList.count] stringValue],APN_ApnListSize,
                                     [[NSNumber numberWithInteger:oldDefaultIndex] stringValue],APN_OldDefaultIndex,
                                     @"3",APN_OldNetMode,
                                     @"1",APN_SendMsg,
                                     apnDictList,APN_ApnList,nil];
        
        [[Utility defaultUtility] hudShowWithTitle:@""];
        [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
            if(data)
            {
                // delete apn success
                oldDefaultIndex = [self indexOfDefaultAPN];
                if(oldDefaultIndex >= 0)
                {
                    [setDefaultSelectionButton setButtonTitle:[[apnDictList objectAtIndex:oldDefaultIndex] objectForKey:APN_ProfileName]];
                    setDefaultSelectionButton.tag = oldDefaultIndex+2;
                }
                
                [self showAPNInfo:setDefaultSelectionButton.tag];
                [self updateUIStatus];
            }
            
            [[Utility defaultUtility] hudClose];
        }];
    }
}

- (void)updateUIStatus
{
    NSInteger selIndex = setDefaultSelectionButton.tag;
    if(selIndex >= 2)
    {
        int defaultValue = [[[apnDictList objectAtIndex:selIndex-2] objectForKey:APN_WhetherDefault] intValue];
        if(defaultValue == 0)
        {
            isCurrentDefault = NO;
            okButton.hidden = NO;
            deleteButton.hidden = NO;
            [self setControlEditable:YES];
        }
        else
        {
            isCurrentDefault = YES;
            okButton.hidden = YES;
            deleteButton.hidden = YES;
            [self setControlEditable:NO];
        }
    }
    else
    {
        isCurrentDefault = NO;
        okButton.hidden = NO;
        deleteButton.hidden = YES;
        [self setControlEditable:YES];
    }
    
    [self adjustContentHeight];
}

- (void)setControlEditable:(BOOL)isEditable
{
    profileNameInput.enabled = isEditable;
    userNameInput.enabled = isEditable;
    passwordInput.enabled = isEditable;
    apnInput.enabled = isEditable;
    dialNumberInput.enabled = isEditable;
    authTypeSelectionButton.enabled = isEditable;
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
    
    // Set the default APN TitleLabel
    setDefaultLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"profileMgrSetDefaultStr",NULL,@"profileMgrUIStrings")];
    [container addSubview:setDefaultLabel];
    
    // Set the default APN Selection Button
    setDefaultSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, setDefaultLabel.frame.origin.y + setDefaultLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    setDefaultSelectionButton.tag = 0;
    [setDefaultSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"autoMatchStr",NULL,@"TipStrings")];
    [container addSubview:setDefaultSelectionButton];
    
    //
    heightLevel1 = setDefaultSelectionButton.frame.origin.y + setDefaultSelectionButton.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;
    
    // Profile Name TitleLabel
    profileNameLabel = [self titleLabel:CGRectMake(controlsXDelta, setDefaultSelectionButton.frame.origin.y+setDefaultSelectionButton.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"profileMgrProfileNameStr",NULL,@"profileMgrUIStrings")];
    [container addSubview:profileNameLabel];
    
    // Profile Name InputTextField
    profileNameInput = [self inputTextField:CGRectMake(controlsXDelta, profileNameLabel.frame.origin.y + profileNameLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    profileNameInput.delegate = self;
    [container addSubview:profileNameInput];

    // User Name TitleLabel
    userNameLabel = [self titleLabel:CGRectMake(controlsXDelta, profileNameInput.frame.origin.y+profileNameInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"profileMgrUserNameStr",NULL,@"profileMgrUIStrings")];
    [container addSubview:userNameLabel];
    
    // User Name InputTextField
    userNameInput = [self inputTextField:CGRectMake(controlsXDelta, userNameLabel.frame.origin.y + userNameLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    userNameInput.delegate = self;
    [container addSubview:userNameInput];
    
    // Password TitleLabel
    passwordLabel = [self titleLabel:CGRectMake(controlsXDelta, userNameInput.frame.origin.y+userNameInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"profileMgrPasswordStr",NULL,@"profileMgrUIStrings")];
    [container addSubview:passwordLabel];
    
    // Password InputTextField
    passwordInput = [self inputTextField:CGRectMake(controlsXDelta, passwordLabel.frame.origin.y + passwordLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    passwordInput.delegate = self;
    [container addSubview:passwordInput];
    
    // APN TitleLabel
    apnLabel = [self titleLabel:CGRectMake(controlsXDelta, passwordInput.frame.origin.y+passwordInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"profileMgrAPNStr",NULL,@"profileMgrUIStrings")];
    [container addSubview:apnLabel];
    
    // APN InputTextField
    apnInput = [self inputTextField:CGRectMake(controlsXDelta, apnLabel.frame.origin.y + apnLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    apnInput.delegate = self;
    [container addSubview:apnInput];
    
    // Dial number TitleLabel
    dialNumberLabel = [self titleLabel:CGRectMake(controlsXDelta, apnInput.frame.origin.y+apnInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"profileMgrDialupNumberStr",NULL,@"profileMgrUIStrings")];
    [container addSubview:dialNumberLabel];
    
    // Dial number InputTextField
    dialNumberInput = [self inputTextField:CGRectMake(controlsXDelta, dialNumberLabel.frame.origin.y + dialNumberLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    dialNumberInput.delegate = self;
    [container addSubview:dialNumberInput];

    // Auth Type TitleLabel
    authTypeLabel = [self titleLabel:CGRectMake(controlsXDelta, dialNumberInput.frame.origin.y+dialNumberInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"profileMgrAutyTypeStr",NULL,@"profileMgrUIStrings")];
    [container addSubview:authTypeLabel];
    
    // Auth Type Selection Button
    authTypeSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, authTypeLabel.frame.origin.y + authTypeLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    authTypeSelectionButton.tag = 0;
    [authTypeSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"noneStr",NULL,@"TipStrings")];
    [container addSubview:authTypeSelectionButton];

    //
    heightLevel2 = authTypeSelectionButton.frame.origin.y + authTypeSelectionButton.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;

    [container setHeight:authTypeSelectionButton.frame.origin.y + authTypeSelectionButton.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2];
    
    //
    deleteButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width/2-5, 30) title:NSLocalizedStringFromTable(@"deleteStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    deleteButton.hidden = YES;
    [self addSubview:deleteButton];
    
    okButton = [self baseButton:CGRectMake(deleteButton.frame.origin.x + deleteButton.frame.size.width + 10 , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width/2-5, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
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
    
    profileNameLabel.hidden = toHide;
    profileNameInput.hidden = toHide;
    userNameLabel.hidden = toHide;
    userNameInput.hidden = toHide;
    passwordLabel.hidden = toHide;
    passwordInput.hidden = toHide;
    apnLabel.hidden = toHide;
    apnInput.hidden = toHide;
    dialNumberLabel.hidden = toHide;
    dialNumberInput.hidden = toHide;
    authTypeLabel.hidden = toHide;
    authTypeSelectionButton.hidden = toHide;
    
    deleteButton.frame = CGRectMake(DATA_CONTAINER_GAP , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width/2-5, 30);
    okButton.frame = CGRectMake(deleteButton.frame.origin.x + deleteButton.frame.size.width + 10 , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width/2-5, 30);
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)container.superview;
    float controlsHeight = container.frame.size.height + okButton.frame.size.height + DATA_CONTAINER_GAP*3;
    if(okButton.hidden == YES)
        controlsHeight = container.frame.size.height + DATA_CONTAINER_GAP*2;
    
    if(controlsHeight > containerScrollView.frame.size.height)
        [self setContentHeight:controlsHeight];
    else
    {
        [self setContentHeight:containerScrollView.frame.size.height+1];
    }
    
    CGRect okButtonRect = okButton.frame;
    okButtonRect.origin.y = container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP;
    okButton.frame = okButtonRect;
    
    if(okButton.hidden == YES)
    {
        CGRect okButtonRect = okButton.frame;
        okButtonRect.origin.y = container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP;
        okButton.frame = okButtonRect;
    }
    else
    {
        CGRect okButtonRect = okButton.frame;
        okButtonRect.origin.y = container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP;
        okButton.frame = okButtonRect;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(isCurrentDefault)
    {
        if(textField == profileNameInput || textField == userNameInput || textField == passwordInput || textField == apnInput || textField == dialNumberInput)
            return NO;
    }
    
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


#pragma mark - Input Limited
- (void)textFieldDidChanged:(NSNotification *)notification
{
    InputTextField *tmpIputField = (InputTextField *)notification.object;
    if (tmpIputField == profileNameInput || tmpIputField == userNameInput || tmpIputField == passwordInput)
    {
        NSString *tmpStr = tmpIputField.text;
        if ([self isContainDoubleBytes:tmpStr])
        {
            if (tmpStr.length >= 20)
            {
                NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 20)];
                tmpIputField.text = newStr;
            }
        }
        else
        {
            if (tmpStr.length >= 30)
            {
                NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 30)];
                tmpIputField.text = newStr;
            }
        }
    }
    else if (tmpIputField == apnInput || tmpIputField == dialNumberInput)
    {
        NSString *tmpStr = tmpIputField.text;
        if (tmpStr.length >= 30)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 30)];
            tmpIputField.text = newStr;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSArray *limitCharacter = @[@"&",@">",@"."];
    if (textField == profileNameInput || textField == userNameInput || textField == passwordInput)
    {
        if ([limitCharacter containsObject:string])
        {
            return NO;
        }
    }
    else if (textField == apnInput)
    {
        NSArray *apnList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"G",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@".",@"-",@""];
        if (![apnList containsObject:[string uppercaseString]])
        {
            return NO;
        }
    }
    else if (textField == dialNumberInput)
    {
        NSArray *dailNmumList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"*",@"#",@"P",@""];
        if (![dailNmumList containsObject:string])
        {
            return NO;
        }
    }
    return YES;
}

//判断是否是双字节(例如汉子)，其特点是转换成Char之后长度为3
- (BOOL)isContainDoubleBytes:(NSString *)string
{
    BOOL isContain = NO;
    for (int i = 0; i < string.length; i++)
    {
        NSString *tmpStr = [string substringWithRange:NSMakeRange(i, 1)];
        const char *character = [tmpStr UTF8String];
        if (strlen(character) == 3)
        {
            isContain = YES;
            break;
        }
    }
    return isContain;
}

- (BOOL)legalProfileName
{
    if ([profileNameInput.text isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}

- (BOOL)legalAPN
{
    if ([apnInput.text isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}


- (BOOL)limitedProfileSetting
{
    if ([self legalProfileName] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyProfileNameStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self legalAPN] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyAPNStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }

    return YES;
}
@end
