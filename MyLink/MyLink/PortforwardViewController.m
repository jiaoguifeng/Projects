//
//  PortforwardViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "PortforwardViewController.h"

#define TITLE_LIST  @[NSLocalizedStringFromTable(@"portForwardingAppStr",NULL,@"RouterPortForwardingUIStrings"),NSLocalizedStringFromTable(@"portForwardingStartStr",NULL,@"RouterPortForwardingUIStrings"),NSLocalizedStringFromTable(@"portForwardingEndStr",NULL,@"RouterPortForwardingUIStrings"),NSLocalizedStringFromTable(@"portForwardingProtocolStr",NULL,@"RouterPortForwardingUIStrings"),NSLocalizedStringFromTable(@"portForwardingIPAddrStr",NULL,@"RouterPortForwardingUIStrings"),NSLocalizedStringFromTable(@"portForwardingStateStr",NULL,@"RouterPortForwardingUIStrings")]

#define Protocol_Menu @[NSLocalizedStringFromTable(@"protocolTCPStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"protocolUDPStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"protocolBothStr",NULL,@"TipStrings")]

#define CELL_HEIGHT 100

@interface PortforwardViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    //
    DataContainer *controlContainer;
    
    UILabel *portForwardControlLabel;
    SelectionButton *portForwardSelectionButton;
    
    UIButton *okButton;
    
    //
    DataContainer *addContainer;
    
    UILabel *appLabel;
    InputTextField *appInput;

    UILabel *startLabel;
    InputTextField *startInput;
    
    UILabel *endLabel;
    InputTextField *endInput;
    
    UILabel *protocolLabel;
    SelectionButton *protocolSelectionButton;
    
    UILabel *ipAddrLabel;
    InputTextField *ipAddrInput;
    
    UILabel *stateLebel;
    SelectionButton *stateSelectionButton;
    
    UIButton *addButton;
    
    //
    DataContainer *portForwardListContainer;
    UITableView *portForwardTableView;
    NSMutableArray *portForwardList;
    NSMutableArray *titleList;
    
    //
    InputTextField *focusedInputTextField;
    
    NSString    *lanIP;
}
@end

@implementation PortforwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"portForwardStr",NULL,@"RouterUIStrings")];
    
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

#pragma mark - OK Button action

- (void)okButtonAction:(id)sender
{
    [self setPortForwardData];
}

#pragma mark - Selection Button action

- (void)selectionButtonAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    NSArray *selectionButtonTitleList = nil;
    
    if(sender == portForwardSelectionButton)
    {
        selectionButtonTitleList = @[NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    }
    else if(sender == protocolSelectionButton)
    {
        selectionButtonTitleList = Protocol_Menu;
        
    }
    else
    {
        selectionButtonTitleList = @[NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    }
    
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:selectionButtonTitleList];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[selectionButtonTitleList objectAtIndex:selectedIndex]];
            selButton.tag = selectedIndex;
        }
    }];
}

#pragma mark - Add button actions

- (void)addButtonAction:(id)sender
{
    if ([self limitedPortForwardSetting] == NO)
    {
        return;
    }

    NSString *enableStr = NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings");
    if(stateSelectionButton.tag == 0)
        enableStr = NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings");
    
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              appInput.text,@"portApp",
                              startInput.text,@"portStart",
                              endInput.text,@"portEnd",
                              [Protocol_Menu objectAtIndex:protocolSelectionButton.tag],@"protocol",
                              ipAddrInput.text,@"ipAddress",
                              enableStr,@"portState",nil];
    [portForwardList addObject:tempDict];
    
    [self adjustDeviceContainer];
    
    [portForwardTableView reloadData];
    
    [self setPortForwardData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return portForwardList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    ListTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier subTitleWidth:90.0 subTitleCount:6];
        theCell.backgroundColor = [UIColor clearColor];
    }
    
    [theCell setTitleList:titleList];
    NSDictionary *tempDict = [portForwardList objectAtIndex:indexPath.row];
    [theCell contentLabelAtIndex:0].text = [tempDict objectForKey:@"portApp"];
    [theCell contentLabelAtIndex:1].text = [tempDict objectForKey:@"portStart"];
    [theCell contentLabelAtIndex:2].text = [tempDict objectForKey:@"portEnd"];
    [theCell contentLabelAtIndex:3].text = [tempDict objectForKey:@"protocol"];
    [theCell contentLabelAtIndex:4].text = [tempDict objectForKey:@"ipAddress"];
    [theCell contentLabelAtIndex:5].text = [tempDict objectForKey:@"portState"];
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [portForwardList removeObjectAtIndex:indexPath.row];
        [self adjustDeviceContainer];
        [portForwardTableView reloadData];
        
        [self setPortForwardData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
}

#pragma mark - get/set data

- (void)initData
{
    portForwardList = [[NSMutableArray alloc] initWithCapacity:0];
    
    titleList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < TITLE_LIST.count; i++)
        [titleList addObject:[NSString stringWithFormat:@"%@:",[TITLE_LIST objectAtIndex:i]]];
    
    [self getPortForwardData];
}

- (void)getPortForwardData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterPortForwardingData:^(id data, NSError *error) {
        if(data)
        {
            //
            NSArray *menuList = @[NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings")];
            [portForwardSelectionButton setButtonTitle:[menuList objectAtIndex:[[data objectForKey:RT_Port_Forward_Enabled] intValue]]];
            
            //
            lanIP = [data objectForKey:RT_LanIP];
            NSDictionary *tempDict = nil;
            NSArray *theList = [[data objectForKey:RT_Port_Forward_Rule] componentsSeparatedByString:@">"];
            for(NSString *itemStr in theList)
            {
                NSArray *itemList = [itemStr componentsSeparatedByString:@","];
                if(itemList.count == 5)
                {
                    NSArray *startEndPortList = [[itemList objectAtIndex:1] componentsSeparatedByString:@":"];
                    tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                [itemList objectAtIndex:0],@"portApp",
                                [startEndPortList objectAtIndex:0],@"portStart",
                                [startEndPortList objectAtIndex:1],@"portEnd",
                                [Protocol_Menu objectAtIndex:[[itemList objectAtIndex:2] intValue]-1],@"protocol",
                                [itemList objectAtIndex:3],@"ipAddress",
                                [menuList objectAtIndex:[[itemList objectAtIndex:4] intValue]],@"portState",nil];
                    [portForwardList addObject:tempDict];
                }
            }
            
            [self adjustDeviceContainer];
            
            [portForwardTableView reloadData];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setPortForwardData
{
    int controlIndex = 0;
    if(portForwardSelectionButton.tag == 0)
        controlIndex = 1;
    else if(portForwardSelectionButton.tag == 1)
        controlIndex = 0;
    
    NSMutableString *ruleString = [NSMutableString stringWithString:@""];
    for(NSDictionary *tempDict in portForwardList)
    {
        int protocolIndex = [[Protocol_Menu_Index objectForKey:[tempDict objectForKey:@"protocol"]] intValue] + 1;
        NSString *stateStr = @"0";
        if([[tempDict objectForKey:@"portState"] isEqualToString:@"Enable"])
            stateStr = @"1";

        NSString *tempStr = [NSString stringWithFormat:@"%@,%@:%@,%@,%@,%@>",[tempDict objectForKey:@"portApp"],[tempDict objectForKey:@"portStart"],[tempDict objectForKey:@"portEnd"],[[NSNumber numberWithInt:protocolIndex] stringValue],[tempDict objectForKey:@"ipAddress"],stateStr];

        [ruleString appendString:tempStr];
    }
    
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_Port_Forward,URL_CONFIG_ID,
                                [[NSNumber numberWithInt:controlIndex] stringValue],RT_Port_Forward_Enabled,
                                ruleString,RT_Port_Forward_Rule,nil];
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
    
    // ---------------------------------------------------------------------------------------------------------
    //
    controlContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 100) title:@""];
    [self addSubview:controlContainer];
    
    CGFloat controlsWidth = controlContainer.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // IP Filter Control TitleLabel
    portForwardControlLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [controlContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"portForwardingStr",NULL,@"RouterPortForwardingUIStrings")];
    [controlContainer addSubview:portForwardControlLabel];
    
    // IP Filter Control Selection Button
    portForwardSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, portForwardControlLabel.frame.origin.y + portForwardControlLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    portForwardSelectionButton.tag = 0;
    [portForwardSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings")];
    [controlContainer addSubview:portForwardSelectionButton];
    
    //
    [controlContainer setHeight:portForwardSelectionButton.frame.origin.y + portForwardSelectionButton.frame.size.height + controlsYDelta*2];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + controlContainer.frame.size.width/2, controlContainer.frame.origin.y + controlContainer.frame.size.height + DATA_CONTAINER_GAP, controlContainer.frame.size.width/2, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];
    
    // ---------------------------------------------------------------------------------------------------------
    //
    addContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, okButton.frame.origin.y + okButton.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 100) title:@""];
    [self addSubview:addContainer];
    
    // Application TitleLabel
    appLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [addContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"portForwardingAppStr",NULL,@"RouterPortForwardingUIStrings")];
    [addContainer addSubview:appLabel];
    
    // Application InputTextField
    appInput = [self inputTextField:CGRectMake(controlsXDelta, appLabel.frame.origin.y + appLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    appInput.delegate = self;
    [addContainer addSubview:appInput];
    
    // Start TitleLabel
    startLabel = [self titleLabel:CGRectMake(controlsXDelta, appInput.frame.origin.y+appInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"portForwardingStartStr",NULL,@"RouterPortForwardingUIStrings")];
    [addContainer addSubview:startLabel];
    
    // Start InputTextField
    startInput = [self inputTextField:CGRectMake(controlsXDelta, startLabel.frame.origin.y + startLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    startInput.delegate = self;
    startInput.keyboardType = UIKeyboardTypeNumberPad;
    [addContainer addSubview:startInput];
    
    // End TitleLabel
    endLabel = [self titleLabel:CGRectMake(controlsXDelta, startInput.frame.origin.y+startInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"portForwardingEndStr",NULL,@"RouterPortForwardingUIStrings")];
    [addContainer addSubview:endLabel];
    
    // End InputTextField
    endInput = [self inputTextField:CGRectMake(controlsXDelta, endLabel.frame.origin.y + endLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    endInput.delegate = self;
    endInput.keyboardType = UIKeyboardTypeNumberPad;
    [addContainer addSubview:endInput];
    
    // Protocol TitleLabel
    protocolLabel = [self titleLabel:CGRectMake(controlsXDelta, endInput.frame.origin.y+endInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"portForwardingProtocolStr",NULL,@"RouterPortForwardingUIStrings")];
    [addContainer addSubview:protocolLabel];
    
    // Protocol Selection Button
    protocolSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, protocolLabel.frame.origin.y + protocolLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    protocolSelectionButton.tag = 0;
    [protocolSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"protocolTCPStr",NULL,@"TipStrings")];
    [addContainer addSubview:protocolSelectionButton];
    
    // IP Address TitleLabel
    ipAddrLabel = [self titleLabel:CGRectMake(controlsXDelta, protocolSelectionButton.frame.origin.y+protocolSelectionButton.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"portForwardingIPAddrStr",NULL,@"RouterPortForwardingUIStrings")];
    [addContainer addSubview:ipAddrLabel];
    
    // IP Address InputTextField
    ipAddrInput = [self inputTextField:CGRectMake(controlsXDelta, ipAddrLabel.frame.origin.y + ipAddrLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    ipAddrInput.delegate = self;
    [addContainer addSubview:ipAddrInput];

    // Protocol TitleLabel
    stateLebel = [self titleLabel:CGRectMake(controlsXDelta, ipAddrInput.frame.origin.y+ipAddrInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"portForwardingStateStr",NULL,@"RouterPortForwardingUIStrings")];
    [addContainer addSubview:stateLebel];
    
    // Protocol Selection Button
    stateSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, stateLebel.frame.origin.y + stateLebel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    stateSelectionButton.tag = 0;
    [stateSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings")];
    [addContainer addSubview:stateSelectionButton];

    //
    [addContainer setHeight:stateSelectionButton.frame.origin.y + stateSelectionButton.frame.size.height + controlsYDelta*2];
    
    //
    addButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + addContainer.frame.size.width/2, addContainer.frame.origin.y + addContainer.frame.size.height + DATA_CONTAINER_GAP, addContainer.frame.size.width/2, 30) title:NSLocalizedStringFromTable(@"addStr",NULL,@"ButtonStrings") action:@selector(addButtonAction:)];
    [self addSubview:addButton];
    
    // ---------------------------------------------------------------------------------------------------------
    //
    portForwardListContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, addButton.frame.origin.y + addButton.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 30) title:NSLocalizedStringFromTable(@"portForwardingListStr",NULL,@"RouterPortForwardingUIStrings")];
    [self addSubview:portForwardListContainer];
    
    portForwardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [portForwardListContainer headerHeight], portForwardListContainer.frame.size.width, portForwardListContainer.frame.size.height - [portForwardListContainer headerHeight]) style:UITableViewStylePlain];
    portForwardTableView.dataSource = self;
    portForwardTableView.delegate = self;
    portForwardTableView.backgroundColor = [UIColor clearColor];
    portForwardTableView.separatorColor = [UIColor darkGrayColor];
    [portForwardListContainer addSubview:portForwardTableView];
    
    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
    
}

- (void)adjustDeviceContainer
{
    [portForwardListContainer setHeight:[portForwardListContainer headerHeight] + portForwardList.count*CELL_HEIGHT];
    
    CGRect tableRect = portForwardTableView.frame;
    tableRect.size.height = portForwardList.count*CELL_HEIGHT;
    portForwardTableView.frame = tableRect;
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)portForwardListContainer.superview;
    float controlsHeight = controlContainer.frame.size.height + okButton.frame.size.height + addContainer.frame.size.height + addButton.frame.size.height + portForwardListContainer.frame.size.height + DATA_CONTAINER_GAP*6;
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
    if (ipAddrInput == textField)
    {
        if (![characterList containsObject:string])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)legalPort:(NSString *)portInput
{
    if ([portInput isEqualToString:@""])
    {
        return NO;
    }
    
    NSInteger portNumber = [portInput integerValue];
    
    if (portNumber < 1 || portNumber > 65535)
    {
        return NO;
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

- (BOOL)differWithLanIP
{
    if ([ipAddrInput.text isEqualToString:lanIP])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)suitableInputIP
{
    NSArray *inputIPArray = [[ipAddrInput text] componentsSeparatedByString:@"."];
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



- (BOOL)limitedPortForwardSetting
{
    
    if ([self legalPort:[startInput text]] == NO || [self legalPort:[endInput text]] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidPortStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self legalIpAddress:ipAddrInput.text] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidIpAddressStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self differWithLanIP] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EqualLanIPStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }

    if ([self suitableInputIP] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"OutofNetworkSegmentStr",NULL,@"TipStrings")
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
