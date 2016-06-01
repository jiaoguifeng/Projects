//
//  staticDhcpViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "StaticDhcpViewController.h"

#define TITLE_LIST  @[NSLocalizedStringFromTable(@"statisticHhcpHostNameStr",NULL,@"RouterStaticsDHCPUIStrings"),NSLocalizedStringFromTable(@"statisticMacAddressStr",NULL,@"RouterStaticsDHCPUIStrings"),NSLocalizedStringFromTable(@"statisticIPAddressStr",NULL,@"RouterStaticsDHCPUIStrings"),NSLocalizedStringFromTable(@"statisticStateStr",NULL,@"RouterStaticsDHCPUIStrings")]

#define CELL_HEIGHT 70


@interface StaticDhcpViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    //
    DataContainer *container;
    
    UILabel *hostNameLabel;
    InputTextField *hostNameInput;
    
    UILabel *macAddrLabel;
    InputTextField *macAddrInput;
    
    UILabel *ipAddrLabel;
    InputTextField *ipAddrInput;
    
    UILabel *stateLabel;
    SelectionButton *stateSelectionButton;
    
    UIButton *addButton;
    
    //
    DataContainer *listContainer;
    UITableView *listTable;
    
    NSMutableArray *titleList;
    NSMutableArray *list;

    //
    InputTextField *focusedInputTextField;
}
@end

@implementation StaticDhcpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"staticDhcpStr",NULL,@"RouterUIStrings")];
    
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
    __weak SelectionButton *selButton = sender;
    NSArray *testList = @[NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:testList];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[testList objectAtIndex:selectedIndex]];
            selButton.tag = selectedIndex;
        }
    }];
}

#pragma mark - Add button actions

- (void)addButtonAction:(id)sender
{
    if ([self limitedStaticDHCPSetting] == NO)
    {
        return;
    }
    
    [self addStaticDhcpData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    ListTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier subTitleWidth:100.0 subTitleCount:4];
        theCell.backgroundColor = [UIColor clearColor];
    }
    
    [theCell setTitleList:titleList];
    NSDictionary *tempDict = [list objectAtIndex:indexPath.row];
    [theCell contentLabelAtIndex:0].text = [tempDict objectForKey:@"hostName"];
    [theCell contentLabelAtIndex:1].text = [tempDict objectForKey:@"macAddress"];
    [theCell contentLabelAtIndex:2].text = [tempDict objectForKey:@"ipAddress"];
    [theCell contentLabelAtIndex:3].text = [tempDict objectForKey:@"state"];
    
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
        [self deleteStaticDhcpData:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
}

#pragma mark - get/set data

- (void)initData
{
    list = [[NSMutableArray alloc] initWithCapacity:0];
    
    titleList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < TITLE_LIST.count; i++)
        [titleList addObject:[NSString stringWithFormat:@"%@:",[TITLE_LIST objectAtIndex:i]]];
    
    [self getStaticsDHCPData];
}

- (void)getStaticsDHCPData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterStaticDHCPData:^(id data, NSError *error) {
        if(data)
        {
            //
            NSString *staticDhcpList = [data objectForKey:RT_DHCP_Static];
            NSArray *theList = [staticDhcpList componentsSeparatedByString:@">"];
            for(NSString *tempStr in theList)
            {
                if(tempStr.length > 0)
                {
                    NSDictionary *tempDict = nil;
                    NSArray *itemList = [tempStr componentsSeparatedByString:@","];
                    if(itemList.count == 4)
                    {
                        tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [itemList objectAtIndex:0],@"hostName",
                                    [itemList objectAtIndex:1],@"macAddress",
                                    [itemList objectAtIndex:2],@"ipAddress",
                                    ([[itemList objectAtIndex:3] isEqualToString:@"1"]) ? NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") : NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings"),@"state", nil];
                        [list addObject:tempDict];
                        
                        [self adjustDeviceContainer];
                        [listTable reloadData];
                    }
                }
            }
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)addStaticDhcpData
{
    NSMutableString *configStr = [[NSMutableString alloc] initWithCapacity:0];
    for(NSDictionary *tempDict in list)
    {
        NSString *tmpStateStr = ([[tempDict objectForKey:@"state"] isEqualToString:@"0"]) ? @"1" : @"0";
        NSString *oldStr = [NSString stringWithFormat:@"%@,%@,%@,%@>",[tempDict objectForKey:@"hostName"],[tempDict objectForKey:@"macAddress"],[tempDict objectForKey:@"ipAddress"],tmpStateStr];
        [configStr appendString:oldStr];
    }
    
    NSString *stateStr = ([NSNumber numberWithInteger:stateSelectionButton.tag] == 0) ? @"1" : @"0";
    NSString *newStr = [NSString stringWithFormat:@"%@,%@,%@,%@>",hostNameInput.text,macAddrInput.text,ipAddrInput.text,stateStr];
    [configStr appendString:newStr];
    
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_Router_Static_Dhcp,URL_CONFIG_ID,
                                configStr,RT_DHCP_Static,nil];
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

- (void)deleteStaticDhcpData:(NSInteger)delIndex
{
    [list removeObjectAtIndex:delIndex];
    [listTable reloadData];
    
    NSMutableString *configStr = [[NSMutableString alloc] initWithCapacity:0];
    for(NSDictionary *tempDict in list)
    {
        NSString *tmpStateStr = ([[tempDict objectForKey:@"state"] isEqualToString:@"0"]) ? @"1" : @"0";
        NSString *oldStr = [NSString stringWithFormat:@"%@,%@,%@,%@>",[tempDict objectForKey:@"hostName"],[tempDict objectForKey:@"macAddress"],[tempDict objectForKey:@"ipAddress"],tmpStateStr];
        [configStr appendString:oldStr];
    }
    
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_Router_Static_Dhcp,URL_CONFIG_ID,
                                configStr,RT_DHCP_Static,nil];
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
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:@""];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // Host Name TitleLabel
    hostNameLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"statisticHhcpHostNameStr",NULL,@"RouterStaticsDHCPUIStrings")];
    [container addSubview:hostNameLabel];
    
    // Host Name InputTextField
    hostNameInput = [self inputTextField:CGRectMake(controlsXDelta, hostNameLabel.frame.origin.y + hostNameLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    hostNameInput.delegate = self;
    [container addSubview:hostNameInput];

    // Mac Address TitleLabel
    macAddrLabel = [self titleLabel:CGRectMake(controlsXDelta, hostNameInput.frame.origin.y+hostNameInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"statisticMacAddressStr",NULL,@"RouterStaticsDHCPUIStrings")];
    [container addSubview:macAddrLabel];
    
    // Mac Addres InputTextField
    macAddrInput = [self inputTextField:CGRectMake(controlsXDelta, macAddrLabel.frame.origin.y + macAddrLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    macAddrInput.text = @"00:00:00:00:00:00";
    macAddrInput.delegate = self;
    [container addSubview:macAddrInput];

    // IP Address TitleLabel
    ipAddrLabel = [self titleLabel:CGRectMake(controlsXDelta, macAddrInput.frame.origin.y+macAddrInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"statisticIPAddressStr",NULL,@"RouterStaticsDHCPUIStrings")];
    [container addSubview:ipAddrLabel];
    
    // IP Addres InputTextField
    ipAddrInput = [self inputTextField:CGRectMake(controlsXDelta, ipAddrLabel.frame.origin.y + ipAddrLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    ipAddrInput.text = @"0.0.0.0";
    ipAddrInput.delegate = self;
    [container addSubview:ipAddrInput];

    // State TitleLabel
    stateLabel = [self titleLabel:CGRectMake(controlsXDelta, ipAddrInput.frame.origin.y+ipAddrInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"statisticStateStr",NULL,@"RouterStaticsDHCPUIStrings")];
    [container addSubview:stateLabel];
    
    // State Selection Button
    stateSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, stateLabel.frame.origin.y + stateLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    stateSelectionButton.tag = 0;
    [stateSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings")];
    [container addSubview:stateSelectionButton];

    //
    [container setHeight:stateSelectionButton.frame.origin.y + stateSelectionButton.frame.size.height + controlsYDelta*2];
    
    //
    addButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + container.frame.size.width/2, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width/2, 30) title:NSLocalizedStringFromTable(@"addStr",NULL,@"ButtonStrings") action:@selector(addButtonAction:)];
    [self addSubview:addButton];
    
    // ---------------------------------------------------------------------------------------------------------
    //
    listContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, addButton.frame.origin.y + addButton.frame.size.height + DATA_CONTAINER_GAP, self.view.bounds.size.width-DATA_CONTAINER_GAP*2, 30) title:NSLocalizedStringFromTable(@"statisticAssignmentListStr",NULL,@"RouterStaticsDHCPUIStrings")];
    [self addSubview:listContainer];
    
    listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, [listContainer headerHeight], listContainer.frame.size.width, listContainer.frame.size.height - [listContainer headerHeight]) style:UITableViewStylePlain];
    listTable.dataSource = self;
    listTable.delegate = self;
    listTable.backgroundColor = [UIColor clearColor];
    listTable.separatorColor = [UIColor darkGrayColor];
    [listContainer addSubview:listTable];

    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
}

- (void)adjustDeviceContainer
{
    [listContainer setHeight:[listContainer headerHeight] + list.count*CELL_HEIGHT];
    
    CGRect tableRect = listTable.frame;
    tableRect.size.height = list.count*CELL_HEIGHT;
    listTable.frame = tableRect;
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)container.superview;
    float controlsHeight = container.frame.size.height + listContainer.frame.size.height + addButton.frame.size.height + DATA_CONTAINER_GAP*4;
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
- (void)textFieldDidChanged:(NSNotification *)notification
{
    if (hostNameInput == (InputTextField *)notification.object)
    {
        NSString *tmpStr = hostNameInput.text;
        if (tmpStr.length >= 15)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 15)];
            hostNameInput.text = newStr;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == hostNameInput)
    {
        NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"-"];
        
        if (![characterList containsObject:[string lowercaseString]])
        {
            return NO;
        }

    }
    return YES;
}
//- (BOOL)legalHostName
//{
//    NSString *tmpStr = hostNameInput.text;
//    if (tmpStr.length < 1 || tmpStr.length > 15)
//    {
//        return NO;
//    }
//    
//    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"-"];
//    
//    NSInteger lengthCount = 0;
//    for (int i = 0; i < tmpStr.length; i++)
//    {
//        NSString *tmp = [[tmpStr substringWithRange:NSMakeRange(i, 1)] lowercaseString];
//        
//        if (![characterList containsObject:tmp])
//        {
//            return NO;
//        }
//        else
//        {
//            lengthCount++;
//        }
//    }
//    
//    if (lengthCount == tmpStr.length)
//    {
//        return YES;
//    }
//    return NO;
//}

- (BOOL)legalMacAddress
{
    NSString *tmpStr = macAddrInput.text;
    
    NSArray *tmpArr = [tmpStr componentsSeparatedByString:@":"];
    
    if (tmpArr.count != 6)
        return NO;
    
    NSInteger subsCount = 0;
    for (NSString *subs in tmpArr)
    {
        if ([subs isEqualToString:@"00"])
        {
            subsCount++;
        }
    }
    if (subsCount == 6)
    {
        return NO;
    }
    
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"a",@"b",@"c",@"d",@"e",@"f"];
    NSArray *forbiddenList = @[@"1",@"3",@"5",@"7",@"9",@"B",@"b",@"D",@"d",@"F",@"f"];
    
    NSString *firstItem = [tmpArr objectAtIndex:0];
    NSString *firstCharacter = [firstItem substringWithRange:NSMakeRange(0, 1)];
    NSString *secondCharacter = [firstItem substringWithRange:NSMakeRange(1, 1)];
    
    if ([forbiddenList containsObject:secondCharacter])
    {
        return NO;
    }
    
    NSInteger legalCount = 0;
    for (NSString *tmp in tmpArr)
    {
        if (tmp.length != 2)
        {
            break;
        }
        
        firstCharacter = [tmp substringWithRange:NSMakeRange(0, 1)];
        secondCharacter = [tmp substringWithRange:NSMakeRange(1, 1)];
        
        if ([characterList containsObject:firstCharacter] && [characterList containsObject:secondCharacter])
        {
            legalCount++;
        }
        else
        {
            break;
        }
    }
    
    if (legalCount == 6)
    {
        return YES;
    }
    
    return NO;
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

- (BOOL)limitedStaticDHCPSetting
{
    if (![self legalMacAddress])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidMacAddressStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return NO;
    }
    
    if (![self legalIpAddress:ipAddrInput.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidIpAddressStr",NULL,@"TipStrings")
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
