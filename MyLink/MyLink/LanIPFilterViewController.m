//
//  LanIPFilterViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "LanIPFilterViewController.h"

#define IP_Filter_Control_Menu @[NSLocalizedStringFromTable(@"controlNoFilteringStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"controlBlockAllInListStr",NULL,@"TipStrings")]

#define Protocol_Menu @[NSLocalizedStringFromTable(@"protocolTCPStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"protocolUDPStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"protocolBothStr",NULL,@"TipStrings")]

#define TITLE_LIST  @[NSLocalizedStringFromTable(@"lanIPFilterIPAddrFromStr",NULL,@"RouterLanIPFilterUIStrings"),NSLocalizedStringFromTable(@"lanIPFilterIPAddrToStr",NULL,@"RouterLanIPFilterUIStrings"),NSLocalizedStringFromTable(@"lanIPFilterPortStr",NULL,@"RouterLanIPFilterUIStrings"),NSLocalizedStringFromTable(@"lanIPFilterProtocolStr",NULL,@"RouterLanIPFilterUIStrings")]

#define CELL_HEIGHT 70

@interface LanIPFilterViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    //
    DataContainer *controlContainer;
    
    UILabel *ipFilterControlLabel;
    SelectionButton *ipFilterControlSelectionButton;
    
    UIButton *okButton;
    
    //
    DataContainer *addContainer;
    
    UILabel *ipAddrSrcLabel;
    InputTextField *ipAddrSrcInput;
    
    UILabel *ipAddrDstLabel;
    InputTextField *ipAddrDstInput;
    
    UILabel *portLabel;
    InputTextField *portInput;
    
    UILabel *protocolLabel;
    SelectionButton *protocolSelectionButton;
    
    UIButton *addButton;
    
    //
    DataContainer *ipFilterListContainer;
    UITableView *ipFilterTableView;
    NSMutableArray *ipFilterList;
    NSMutableArray *titleList;
    
    //
    InputTextField *focusedInputTextField;

}
@end

@implementation LanIPFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"lanIpFilterStr",NULL,@"RouterUIStrings")];
    
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
    [self setLanIPFilterData];
}

#pragma mark - Selection Button action

- (void)selectionButtonAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    NSArray *selectionButtonTitleList = nil;
    
    if(sender == ipFilterControlSelectionButton)
    {
        selectionButtonTitleList = IP_Filter_Control_Menu;
    }
    else
    {
        selectionButtonTitleList = Protocol_Menu;

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
    if ([self limitedLanIpFilterSetting] == NO)
    {
        return;
    }
    
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              ipAddrSrcInput.text,@"srcIPAddr",
                              ipAddrDstInput.text,@"dstIPAddr",
                              portInput.text,@"port",
                              [Protocol_Menu objectAtIndex:protocolSelectionButton.tag],@"protocol", nil];
    [ipFilterList addObject:tempDict];
    
    [self adjustDeviceContainer];
    
    [ipFilterTableView reloadData];
    
    [self setLanIPFilterData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ipFilterList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    ListTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier subTitleWidth:150.0 subTitleCount:4];
        theCell.backgroundColor = [UIColor clearColor];
    }
    
    [theCell setTitleList:titleList];
    NSDictionary *tempDict = [ipFilterList objectAtIndex:indexPath.row];
    [theCell contentLabelAtIndex:0].text = [tempDict objectForKey:@"srcIPAddr"];
    [theCell contentLabelAtIndex:1].text = [tempDict objectForKey:@"dstIPAddr"];
    [theCell contentLabelAtIndex:2].text = [tempDict objectForKey:@"port"];
    [theCell contentLabelAtIndex:3].text = [tempDict objectForKey:@"protocol"];
    
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
        [ipFilterList removeObjectAtIndex:indexPath.row];
        [self adjustDeviceContainer];
        [ipFilterTableView reloadData];
        
        [self setLanIPFilterData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
}

#pragma mark - get/set data

- (void)initData
{
    ipFilterList = [[NSMutableArray alloc] initWithCapacity:0];
    
    titleList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < TITLE_LIST.count; i++)
        [titleList addObject:[NSString stringWithFormat:@"%@:",[TITLE_LIST objectAtIndex:i]]];
    
    [self getLanIPFilterData];
}

- (void)getLanIPFilterData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterLanIPFilterData:^(id data, NSError *error) {
        if(data)
        {
            //
            if([[data objectForKey:RT_IP_Filter_Control] isEqualToString:@"0"])
            {
                [ipFilterControlSelectionButton setButtonTitle:[IP_Filter_Control_Menu objectAtIndex:0]];
            }
            else if([[data objectForKey:RT_IP_Filter_Control] isEqualToString:@"2"])
            {
                [ipFilterControlSelectionButton setButtonTitle:[IP_Filter_Control_Menu objectAtIndex:1]];
            }
            
            NSArray *theList = [[data objectForKey:RT_IP_Filter_Rule] componentsSeparatedByString:@">"];
            NSDictionary *tempDict = nil;
            for(int i = 0; i < theList.count; i++)
            {
                NSArray *oneItemList = [[theList objectAtIndex:i] componentsSeparatedByString:@";"];
                if(oneItemList.count == 3)
                {
                    NSString *srcIPStr = [[[oneItemList objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:0];
                    NSString *dstIPStr = [[[oneItemList objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:1];
                    int protocolIndex = [[oneItemList objectAtIndex:2] intValue];
                    
                    tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                srcIPStr,@"srcIPAddr",
                                dstIPStr,@"dstIPAddr",
                                [oneItemList objectAtIndex:1],@"port",
                                [Protocol_Menu objectAtIndex:protocolIndex],@"protocol", nil];
                    [ipFilterList addObject:tempDict];
                }
            }
            [self adjustDeviceContainer];
            
            [ipFilterTableView reloadData];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setLanIPFilterData
{
    int controlIndex = 0;
    if(ipFilterControlSelectionButton.tag == 0)
        controlIndex = 1;
    else if(ipFilterControlSelectionButton.tag == 1)
        controlIndex = 2;
    
    NSMutableString *lanIPRuleString = [NSMutableString stringWithString:@""];
    for(NSDictionary *tempDict in ipFilterList)
    {
        NSString *tempStr = [NSString stringWithFormat:@"%@-%@;%@;%@>",[tempDict objectForKey:@"srcIPAddr"],[tempDict objectForKey:@"dstIPAddr"],[tempDict objectForKey:@"port"],[Protocol_Menu_Index objectForKey:[tempDict objectForKey:@"protocol"]]];
        [lanIPRuleString appendString:tempStr];
    }
    
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_IP_Filter,URL_CONFIG_ID,
                                [[NSNumber numberWithInt:controlIndex] stringValue],RT_IP_Filter_Control,
                                lanIPRuleString,RT_IP_Filter_Rule,nil];
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
    ipFilterControlLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [controlContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanIPFilterControlStr",NULL,@"RouterLanIPFilterUIStrings")];
    [controlContainer addSubview:ipFilterControlLabel];
    
    // IP Filter Control Selection Button
    ipFilterControlSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, ipFilterControlLabel.frame.origin.y + ipFilterControlLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    ipFilterControlSelectionButton.tag = 0;
    [ipFilterControlSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"controlNoFilteringStr",NULL,@"TipStrings")];
    [controlContainer addSubview:ipFilterControlSelectionButton];
    
    //
    [controlContainer setHeight:ipFilterControlSelectionButton.frame.origin.y + ipFilterControlSelectionButton.frame.size.height + controlsYDelta*2];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + controlContainer.frame.size.width/2, controlContainer.frame.origin.y + controlContainer.frame.size.height + DATA_CONTAINER_GAP, controlContainer.frame.size.width/2, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];
    
    // ---------------------------------------------------------------------------------------------------------
    //
    addContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, okButton.frame.origin.y + okButton.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 100) title:@""];
    [self addSubview:addContainer];

    // Source IP Address TitleLabel
    ipAddrSrcLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [addContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanIPFilterIPAddrFromStr",NULL,@"RouterLanIPFilterUIStrings")];
    [addContainer addSubview:ipAddrSrcLabel];
    
    // ource IP Address InputTextField
    ipAddrSrcInput = [self inputTextField:CGRectMake(controlsXDelta, ipAddrSrcLabel.frame.origin.y + ipAddrSrcLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    ipAddrSrcInput.delegate = self;
    [addContainer addSubview:ipAddrSrcInput];
    
    // Dest IP Address TitleLabel
    ipAddrDstLabel = [self titleLabel:CGRectMake(controlsXDelta, ipAddrSrcInput.frame.origin.y+ipAddrSrcInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanIPFilterIPAddrToStr",NULL,@"RouterLanIPFilterUIStrings")];
    [addContainer addSubview:ipAddrDstLabel];
    
    // Dest IP Address InputTextField
    ipAddrDstInput = [self inputTextField:CGRectMake(controlsXDelta, ipAddrDstLabel.frame.origin.y + ipAddrDstLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    ipAddrDstInput.delegate = self;
    [addContainer addSubview:ipAddrDstInput];
    
    // Port TitleLabel
    portLabel = [self titleLabel:CGRectMake(controlsXDelta, ipAddrDstInput.frame.origin.y+ipAddrDstInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanIPFilterPortStr",NULL,@"RouterLanIPFilterUIStrings")];
    [addContainer addSubview:portLabel];
    
    // Port InputTextField
    portInput = [self inputTextField:CGRectMake(controlsXDelta, portLabel.frame.origin.y + portLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    portInput.delegate = self;
    portInput.keyboardType = UIKeyboardTypeNumberPad;
    [addContainer addSubview:portInput];
    
    // Protocol TitleLabel
    protocolLabel = [self titleLabel:CGRectMake(controlsXDelta, portInput.frame.origin.y+portInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"lanIPFilterProtocolStr",NULL,@"RouterLanIPFilterUIStrings")];
    [addContainer addSubview:protocolLabel];
    
    // Protocol Selection Button
    protocolSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, protocolLabel.frame.origin.y + protocolLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    protocolSelectionButton.tag = 0;
    [protocolSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"protocolTCPStr",NULL,@"TipStrings")];
    [addContainer addSubview:protocolSelectionButton];
    
    //
    [addContainer setHeight:protocolSelectionButton.frame.origin.y + protocolSelectionButton.frame.size.height + controlsYDelta*2];
    
    //
    addButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + addContainer.frame.size.width/2, addContainer.frame.origin.y + addContainer.frame.size.height + DATA_CONTAINER_GAP, addContainer.frame.size.width/2, 30) title:NSLocalizedStringFromTable(@"addStr",NULL,@"ButtonStrings") action:@selector(addButtonAction:)];
    [self addSubview:addButton];

    // ---------------------------------------------------------------------------------------------------------
    //
    ipFilterListContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, addButton.frame.origin.y + addButton.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 30) title:NSLocalizedStringFromTable(@"lanIPFilterListStr",NULL,@"RouterLanIPFilterUIStrings")];
    [self addSubview:ipFilterListContainer];

    ipFilterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [ipFilterListContainer headerHeight], ipFilterListContainer.frame.size.width, ipFilterListContainer.frame.size.height - [ipFilterListContainer headerHeight]) style:UITableViewStylePlain];
    ipFilterTableView.dataSource = self;
    ipFilterTableView.delegate = self;
    ipFilterTableView.backgroundColor = [UIColor clearColor];
    ipFilterTableView.separatorColor = [UIColor darkGrayColor];
    [ipFilterListContainer addSubview:ipFilterTableView];
    
    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];

}

- (void)adjustDeviceContainer
{
    [ipFilterListContainer setHeight:[ipFilterListContainer headerHeight] + ipFilterList.count*CELL_HEIGHT];
    
    CGRect tableRect = ipFilterTableView.frame;
    tableRect.size.height = ipFilterList.count*CELL_HEIGHT;
    ipFilterTableView.frame = tableRect;
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)ipFilterListContainer.superview;
    float controlsHeight = controlContainer.frame.size.height + okButton.frame.size.height + addContainer.frame.size.height + addButton.frame.size.height + ipFilterListContainer.frame.size.height + DATA_CONTAINER_GAP*6;
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
    if (ipAddrSrcInput == textField || ipAddrDstInput == textField)
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

- (BOOL)differWithSrcIPandDstIP
{
    NSString *srcIP = ipAddrSrcInput.text;
    NSString *dstIP = ipAddrDstInput.text;
    
    if ([srcIP isEqualToString:dstIP])
    {
        return NO;
    }
    return YES;
}

- (BOOL)srcIPLargerThanDstIP
{
    NSString *srcIP = ipAddrSrcInput.text;
    NSString *dstIP = ipAddrDstInput.text;
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

- (BOOL)legalPort
{
    if ([portInput.text isEqualToString:@""])
    {
        return NO;
    }
    
    NSInteger portNumber = [portInput.text integerValue];
    
    if (portNumber < 1 || portNumber > 65535)
    {
        return NO;
    }
    return YES;
}

- (BOOL)limitedLanIpFilterSetting
{
    if ([self legalIpAddress:[ipAddrSrcInput text]] == NO || [self legalIpAddress:[ipAddrDstInput text]] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidIpAddressStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self differWithSrcIPandDstIP] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"DuplicateIPrangeStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if ([self srcIPLargerThanDstIP] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"LanIPFilterOverlapIPStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    if ([self legalPort] == NO)
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
