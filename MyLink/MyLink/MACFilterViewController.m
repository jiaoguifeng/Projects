//
//  MACFilterViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "MACFilterViewController.h"

#define TITLE_LIST  @[@"Mac Address: ",@"Name: "]
#define WiFi_Mac_Filter_Enable_Value [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"Disable",@"1",@"Enable",nil]
#define WiFi_Mac_Filter_Enable_Key [NSDictionary dictionaryWithObjectsAndKeys:@"Disable",@"0",@"Enable",@"1",nil]
#define WiFi_Mac_Filter_Control_Value [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"Allow all in list",@"2",@"Block all in list",nil]
#define WiFi_Mac_Filter_Control_Key [NSDictionary dictionaryWithObjectsAndKeys:@"Allow all in list",@"1",@"Block all in list",@"2",nil]

@interface MACFilterViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    BAND_TYPE                 bandType;
    
    DataContainer             *macFilterContainer;
    UILabel                   *macFilterLbl;
    SelectionButton           *macFilterSelectBtn;
    UILabel                   *macFilterModeLbl;
    SelectionButton           *macFilterModeSelectBtn;
    UIButton                  *saveBtn;
    
    DataContainer             *macAddressContainer;
    UILabel                   *macAddressLbl;
    InputTextField            *macAddress;
    UILabel                   *macNameLbl;
    InputTextField            *macName;
    UIButton                  *addBtn;
    
    DataContainer             *macFilterListContainer;
    NSMutableArray            *macFilterList;
    UITableView               *macFilterTableView;
    UIButton                  *deleteBtn;
    
    NSMutableDictionary       *responseData;
    
    InputTextField            *focusedInputTextField;
}
@end

@implementation MACFilterViewController

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
        [self setTitleText:NSLocalizedStringFromTable(@"24GMacFilterStr",NULL,@"WiFiUIStrings")];
    else
        [self setTitleText:NSLocalizedStringFromTable(@"5GMacFilterStr",NULL,@"WiFiUIStrings")];
    
    //add tap event
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignEditing)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    
    //init Dictionary
    responseData = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    macFilterList = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self setUpMacFilterMainUI];
    
    //get Data From Server
    if (bandType == BAND_TYPE_24G)
    {
        [self requestWiFiFilterDataFor2G];
    }
    else
    {
        [self requestWiFiFilterDataFor5G];
    }

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

#pragma mark - Set up Wi-Fi Setting UI
- (void)setUpMacFilterMainUI
{
    [self setUpMacFilterContainer];
    
    [self setUpMacAddressContainer];
    
    [self setUpMacFilterListContainer];
    
    [self adjustScrolView];
}

- (void)setUpMacFilterContainer
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = DATA_CONTAINER_GAP;
    CGFloat width = self.view.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = 200;
    
    macFilterContainer = [[DataContainer alloc] initWithFrame:CGRectMake(x, y, width, heigth) title:NSLocalizedStringFromTable(@"MacFilterStr",NULL,@"macFilterUSStrings")];
    [self addSubview:macFilterContainer];
    
    
    y = macFilterContainer.headerHeight +  DATA_CONTAINER_GAP * 0.5;
    width = macFilterContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    heigth = INPUT_TEXTFIELD_HEIGHT;
    macFilterLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"MacFilterStr",NULL,@"macFilterUSStrings")];
    [macFilterContainer addSubview:macFilterLbl];
    
    y = macFilterLbl.frame.origin.y + macFilterLbl.frame.size.height;
    macFilterSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(macFilterSelectAction:)];
    [macFilterContainer addSubview:macFilterSelectBtn];
    
    y = macFilterSelectBtn.frame.origin.y + macFilterSelectBtn.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    macFilterModeLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"MacFilterModeStr",NULL,@"macFilterUSStrings")];
    [macFilterContainer addSubview:macFilterModeLbl];
    
    y = macFilterModeLbl.frame.origin.y + macFilterModeLbl.frame.size.height;
    macFilterModeSelectBtn = [self selectionButton:CGRectMake(x, y, width, heigth) title:@"" action:@selector(macFilterModeSelectAction:)];
    [macFilterContainer addSubview:macFilterModeSelectBtn];

    y = macFilterModeSelectBtn.frame.origin.y + macFilterModeSelectBtn.frame.size.height + DATA_CONTAINER_GAP;
    saveBtn = [self baseButton:CGRectMake(x, y, width, heigth) title:NSLocalizedStringFromTable(@"okStr",NULL,@"macFilterUSStrings") action:@selector(submitMacFilter:)];
    [macFilterContainer addSubview:saveBtn];
    
    //adjust container's height
    CGFloat newHight = macFilterContainer.frame.size.height;
    newHight = saveBtn.frame.origin.y + saveBtn.frame.size.height + DATA_CONTAINER_GAP;
    [macFilterContainer setHeight:newHight];
}

- (void)setUpMacAddressContainer
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = macFilterContainer.frame.origin.y + macFilterContainer.frame.size.height + DATA_CONTAINER_GAP;
    CGFloat width = self.view.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = 200;

    macAddressContainer = [[DataContainer alloc] initWithFrame:CGRectMake(x, y, width, heigth) title:NSLocalizedStringFromTable(@"MacAddressStr",NULL,@"macFilterUSStrings")];
    [self addSubview:macAddressContainer];
    
    y = macAddressContainer.headerHeight +  DATA_CONTAINER_GAP * 0.5;
    width = macAddressContainer.frame.size.width - DATA_CONTAINER_GAP * 2;
    heigth = INPUT_TEXTFIELD_HEIGHT;
    macAddressLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"MacAddressStr",NULL,@"macFilterUSStrings")];
    [macAddressContainer addSubview:macAddressLbl];
    
    y = macAddressLbl.frame.origin.y + macAddressLbl.frame.size.height;
    macAddress = [self inputTextField:CGRectMake(x, y, width, heigth)];
    [macAddressContainer addSubview:macAddress];
    
    y = macAddress.frame.origin.y + macAddress.frame.size.height + DATA_CONTAINER_IN_Y_GAP;
    macNameLbl = [self titleLabel:CGRectMake(x, y, width, heigth) withTitle:NSLocalizedStringFromTable(@"MacAddressNameStr",NULL,@"macFilterUSStrings")];
    [macAddressContainer addSubview:macNameLbl];

    y = macNameLbl.frame.origin.y + macNameLbl.frame.size.height;
    macName = [self inputTextField:CGRectMake(x, y, width, heigth)];
    [macAddressContainer addSubview:macName];

    y = macName.frame.origin.y + macName.frame.size.height + DATA_CONTAINER_GAP;
    addBtn = [self baseButton:CGRectMake(x, y, width, heigth) title:NSLocalizedStringFromTable(@"AddStr",NULL,@"macFilterUSStrings") action:@selector(submitMacFilter:)];
    [macAddressContainer addSubview:addBtn];
    
    CGFloat newHight = macAddressContainer.frame.size.height;
    newHight = saveBtn.frame.origin.y + saveBtn.frame.size.height + DATA_CONTAINER_GAP;
    [macAddressContainer setHeight:newHight];
}

- (void)setUpMacFilterListContainer
{
    CGFloat x = DATA_CONTAINER_GAP;
    CGFloat y = macAddressContainer.frame.origin.y + macAddressContainer.frame.size.height + DATA_CONTAINER_GAP;
    CGFloat width = self.view.frame.size.width - DATA_CONTAINER_GAP * 2;
    CGFloat heigth = 200;

    macFilterListContainer = [[DataContainer alloc] initWithFrame:CGRectMake(x, y, width, heigth) title:NSLocalizedStringFromTable(@"MacFilterListStr",NULL,@"macFilterUSStrings")];
    [self addSubview:macFilterListContainer];
    
    x = macFilterListContainer.bounds.origin.x;
    y = macFilterListContainer.headerHeight;
    width = macFilterListContainer.frame.size.width;
    heigth = macFilterListContainer.frame.size.height;
    
    macFilterTableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, width, heigth) style:UITableViewStylePlain];
    macFilterTableView.dataSource = self;
    macFilterTableView.delegate = self;
    macFilterTableView.backgroundColor = [UIColor clearColor];
    macFilterTableView.separatorColor = [UIColor darkGrayColor];
    macFilterTableView.allowsSelection = NO;
    [macFilterListContainer addSubview:macFilterTableView];
    
    CGFloat newHight = macFilterListContainer.frame.size.height;
    newHight = macFilterTableView.frame.origin.y + macFilterTableView.frame.size.height + DATA_CONTAINER_GAP;
    [macFilterListContainer setHeight:newHight];
}

- (void)updateMacFilterMainUI
{
    if (responseData.count > 0)
    {
        //更新的时候，首先清空list
        if (macFilterList.count > 0)
        {
            [macFilterList removeAllObjects];
        }
        
        if (bandType == BAND_TYPE_24G)
        {
            macFilterSelectBtn.titleLabel.text = [WiFi_Mac_Filter_Enable_Key objectForKey:[responseData objectForKey:WiFi_MacFilter_Enable_2G]];
            macFilterModeSelectBtn.titleLabel.text = [WiFi_Mac_Filter_Control_Key objectForKey:[responseData objectForKey:Mac_Filter_Control_2G]];
            NSString *ruleString = [responseData objectForKey:WiFi_MacFilter_Rule_String_2G];
            [macFilterList addObjectsFromArray:[self macFilterListFromString:ruleString]];
        }
        else
        {
            macFilterSelectBtn.titleLabel.text = [WiFi_Mac_Filter_Enable_Key objectForKey:[responseData objectForKey:WiFi_MacFilter_Enable_5G]];
            macFilterModeSelectBtn.titleLabel.text = [WiFi_Mac_Filter_Control_Key objectForKey:[responseData objectForKey:Mac_Filter_Control_5G]];
            NSString *ruleString = [responseData objectForKey:WiFi_MacFilter_Rule_String_5G];
            [macFilterList addObjectsFromArray:[self macFilterListFromString:ruleString]];
        }
        
        [macFilterTableView reloadData];
    }
}

- (void)resignEditing
{
    [self.view endEditing:YES];
}

//解析Mac Filter List
- (NSArray *)macFilterListFromString:(NSString *)ruleString
{
    NSMutableArray *tmpFilterList = [NSMutableArray array];

    if (ruleString == nil)
    {
        return tmpFilterList;
    }
    
    NSArray *tmpArray = [ruleString componentsSeparatedByString:@">"];

    for (NSString *str in tmpArray)
    {
        if ([str isEqualToString:@""])
        {
            break;
        }
        
        NSArray *tmpArr = [str componentsSeparatedByString:@","];
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];

        [tmpDic setObject:[tmpArr objectAtIndex:0] forKey:@"Mac Address"];
        [tmpDic setObject:[tmpArr objectAtIndex:1] forKey:@"Mac Name"];
        
        [tmpFilterList addObject:tmpDic];
    }
    
    return tmpFilterList;
}

//组合Mac Filter List
- (NSString *)macFilterStringFromList:(NSArray *)list
{
    if (list.count == 0)
    {
        return @"";
    }
    
    NSMutableString *result = [NSMutableString string];
    for (NSDictionary *dict in list)
    {
        [result appendString:[dict objectForKey:@"Mac Address"]];
        [result appendString:@","];
        [result appendString:[dict objectForKey:@"Mac Name"]];
        [result appendString:@">"];
    }
    return result;
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


#pragma mark - Adjust Scroll View
- (void)adjustScrolView
{
    float newHeight = macFilterListContainer.frame.origin.y + macFilterListContainer.frame.size.height + DATA_CONTAINER_GAP;
    if(newHeight > [self contentHeight])
    {
        [self setContentHeight:newHeight];
    }
}


#pragma mark - Control Action
- (void)macFilterSelectAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    NSArray *tmpArr = @[@"Disable",@"Enable"];
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:tmpArr];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[tmpArr objectAtIndex:selectedIndex]];
        }
    }];
}

- (void)macFilterModeSelectAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    NSArray *tmpArr = @[@"Allow all in list",@"Block all in list"];
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:tmpArr];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[tmpArr objectAtIndex:selectedIndex]];
        }
    }];
}

- (void)submitMacFilter:(id)sender
{
    if (sender == addBtn)
    {
        if ([self limitedMacFilterSetting] == NO)
        {
            return;
        }
        
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:macAddress.text,@"Mac Address",macName.text,@"Mac Name", nil];
        [macFilterList addObject:tmpDic];
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
        [self setWiFiFilterData];
    }
}


- (void)deleteMacFilterCondition
{
    NSLog(@"cmd : %@",NSStringFromSelector(_cmd));
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return macFilterList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";

    ListTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier subTitleWidth:100.0 subTitleCount:2];
    }
    
    [theCell setTitleList:TITLE_LIST];
    NSDictionary *tempDict = [macFilterList objectAtIndex:indexPath.row];
    [theCell contentLabelAtIndex:0].text = [tempDict objectForKey:@"Mac Address"];
    [theCell contentLabelAtIndex:1].text = [tempDict objectForKey:@"Mac Name"];
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [macFilterList removeObjectAtIndex:indexPath.row];
        
        NSString *alertStr = NSLocalizedStringFromTable(@"storageRestartWiFiStr",NULL,@"TipStrings");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alertStr
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        
       // [macFilterTableView reloadData];
    }
}
#pragma mark - Interaction With Server
- (void)requestWiFiFilterDataFor2G
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWiFiFilterDataFor2G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateMacFilterMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)requestWiFiFilterDataFor5G
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWiFiFilterDataFor5G:^(id data, NSError *error) {
        if (!error)
        {
            if (responseData.count > 0)
            {
                [responseData removeAllObjects];
            }
            
            [responseData setDictionary:(NSDictionary *)data];
            [self updateMacFilterMainUI];
        }
        else
        {
            NSLog(@"error occurs");
        }
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setWiFiFilterData
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:WiFi_Mac_Filter_Name forKey:URL_CONFIG_ID];
    if (bandType == BAND_TYPE_24G)
    {
        [param setObject:@"0" forKey:WiFi_Type];
    }
    else
    {
        [param setObject:@"1" forKey:WiFi_Type];
    }
    
    [param setObject:[WiFi_Mac_Filter_Enable_Value objectForKey:macFilterSelectBtn.titleLabel.text] forKey:WiFi_Mac_Filter_Enable];
    [param setObject:[WiFi_Mac_Filter_Control_Value objectForKey:macFilterModeSelectBtn.titleLabel.text] forKey:WiFi_Mac_Filter_Control];
    [param setObject:[self macFilterStringFromList:macFilterList] forKey:WiFi_Mac_Filter_Rule_String];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:param andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"modifyOKStr",NULL,@"TipStrings")];
                [macFilterTableView reloadData];
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

- (BOOL)legalMacAddress
{
    NSString *tmpStr = macAddress.text;
    
    NSArray *tmpArr = [tmpStr componentsSeparatedByString:@":"];
    
    if (tmpArr.count != 6)
        return NO;
    
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

- (BOOL)legalMacName
{
    NSString *tmpStr = macName.text;
    if (tmpStr.length < 1 || tmpStr.length > 15)
    {
        return NO;
    }
    
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"-"];

    NSInteger lengthCount = 0;
    for (int i = 0; i < tmpStr.length; i++)
    {
        NSString *tmp = [[tmpStr substringWithRange:NSMakeRange(i, 1)] lowercaseString];
        
        if (![characterList containsObject:tmp])
        {
            return NO;
        }
        else
        {
            lengthCount++;
        }
    }
    
    if (lengthCount == tmpStr.length)
    {
        return YES;
    }
    return NO;
}

- (BOOL)limitedMacFilterSetting
{
    if ([self legalMacAddress] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidMacAddressStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        
        return NO;
    }
    
    if ([self legalMacName] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidMacNameStr",NULL,@"TipStrings")
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
