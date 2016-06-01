//
//  UrlFilterViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "UrlFilterViewController.h"

#define TITLE_LIST  @[NSLocalizedStringFromTable(@"urlFilterURLAddrStr",NULL,@"RouterURLFilterUIStrings")]

#define URL_Filter_Control_Menu @[NSLocalizedStringFromTable(@"controlNoFilteringStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"controlBlockAllInListStr",NULL,@"TipStrings")]

#define CELL_HEIGHT 25

@interface UrlFilterViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    //
    DataContainer *controlContainer;
    
    UILabel *urlFilterControlLabel;
    SelectionButton *urlFilterControlSelectionButton;
    
    UIButton *okButton;
    
    //
    DataContainer *addContainer;
    
    UILabel *urlAddrLabel;
    InputTextField *urlAddrInput;

    UIButton *addButton;
    
    //
    DataContainer *urlFilterListContainer;
    UITableView *urlFilterTableView;
    NSMutableArray *urlFilterList;
    NSMutableArray *titleList;
    
    //
    InputTextField *focusedInputTextField;
}
@end

@implementation UrlFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"urlFilterStr",NULL,@"RouterUIStrings")];
    
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
    [self setURLFilterData];
}

#pragma mark - Selection Button action

- (void)selectionButtonAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    NSArray *selectionButtonTitleList = URL_Filter_Control_Menu;
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
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              urlAddrInput.text,@"urlAddress", nil];
    [urlFilterList addObject:tempDict];
    
    [self adjustDeviceContainer];
    
    [urlFilterTableView reloadData];
    
    [self setURLFilterData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return urlFilterList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemID";
    // Configure the cell...
    ListTableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(theCell == NULL)
    {
        theCell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier subTitleWidth:80 subTitleCount:1];
        theCell.backgroundColor = [UIColor clearColor];
    }
    
    [theCell setTitleList:titleList];
    NSDictionary *tempDict = [urlFilterList objectAtIndex:indexPath.row];
    [theCell contentLabelAtIndex:0].text = [tempDict objectForKey:@"urlAddress"];
    
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
        [urlFilterList removeObjectAtIndex:indexPath.row];
        [urlFilterTableView reloadData];
        [self adjustDeviceContainer];
        
        [self setURLFilterData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
}

#pragma mark - get/set data

- (void)initData
{
    urlFilterList = [[NSMutableArray alloc] initWithCapacity:0];
    
    titleList = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < TITLE_LIST.count; i++)
        [titleList addObject:[NSString stringWithFormat:@"%@:",[TITLE_LIST objectAtIndex:i]]];
    
    [self getURLFilterData];
}

- (void)getURLFilterData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterURLFilterData:^(id data, NSError *error) {
        if(data)
        {
            //
            if([[data objectForKey:RT_URL_Filter_Control] isEqualToString:@"0"])
            {
                [urlFilterControlSelectionButton setButtonTitle:[URL_Filter_Control_Menu objectAtIndex:0]];
            }
            else if([[data objectForKey:RT_URL_Filter_Control] isEqualToString:@"2"])
            {
                [urlFilterControlSelectionButton setButtonTitle:[URL_Filter_Control_Menu objectAtIndex:1]];
            }

            //
            NSArray *theList = [[data objectForKey:RT_URL_Filter_Rule] componentsSeparatedByString:@">"];
            
            NSDictionary *tempDict = nil;
            for(int i = 0; i < theList.count; i++)
            {
                NSString *tempURL = [theList objectAtIndex:i];
                if(tempURL && tempURL.length > 0)
                {
                    tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                tempURL,@"urlAddress", nil];
                    [urlFilterList addObject:tempDict];
                }
            }
            
            [self adjustDeviceContainer];
            [urlFilterTableView reloadData];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setURLFilterData
{
    int controlIndex = 0;
    if(urlFilterControlSelectionButton.tag == 0)
        controlIndex = 1;
    else if(urlFilterControlSelectionButton.tag == 1)
        controlIndex = 2;
    
    NSMutableString *urlRuleString = [NSMutableString stringWithString:@""];
    for(NSDictionary *urlAddrDict in urlFilterList)
    {
        NSString *tempStr = [NSString stringWithFormat:@"%@>",[urlAddrDict objectForKey:@"urlAddress"]];
        [urlRuleString appendString:tempStr];
    }
    
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_URL_Filter,URL_CONFIG_ID,
                                [[NSNumber numberWithInt:controlIndex] stringValue],RT_URL_Filter_Control,
                                urlRuleString,RT_URL_Filter_Rule,nil];
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
    
    // URL Filter Control TitleLabel
    urlFilterControlLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [controlContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"urlFilterControlStr",NULL,@"RouterURLFilterUIStrings")];
    [controlContainer addSubview:urlFilterControlLabel];
    
    // URL Filter Control Selection Button
    urlFilterControlSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, urlFilterControlLabel.frame.origin.y + urlFilterControlLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    urlFilterControlSelectionButton.tag = 0;
    [urlFilterControlSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"controlNoFilteringStr",NULL,@"TipStrings")];
    [controlContainer addSubview:urlFilterControlSelectionButton];
    
    //
    [controlContainer setHeight:urlFilterControlSelectionButton.frame.origin.y + urlFilterControlSelectionButton.frame.size.height + controlsYDelta*2];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + controlContainer.frame.size.width/2, controlContainer.frame.origin.y + controlContainer.frame.size.height + DATA_CONTAINER_GAP, controlContainer.frame.size.width/2, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];
    
    // ---------------------------------------------------------------------------------------------------------
    //
    addContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, okButton.frame.origin.y + okButton.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 100) title:@""];
    [self addSubview:addContainer];
    
    // URL Address TitleLabel
    urlAddrLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [addContainer headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"urlFilterURLAddrStr",NULL,@"RouterURLFilterUIStrings")];
    [addContainer addSubview:urlAddrLabel];
    
    // URL Address InputTextField
    urlAddrInput = [self inputTextField:CGRectMake(controlsXDelta, urlAddrLabel.frame.origin.y + urlAddrLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    urlAddrInput.delegate = self;
    [addContainer addSubview:urlAddrInput];
    
    //
    [addContainer setHeight:urlAddrInput.frame.origin.y + urlAddrInput.frame.size.height + controlsYDelta*2];
    
    //
    addButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP + addContainer.frame.size.width/2, addContainer.frame.origin.y + addContainer.frame.size.height + DATA_CONTAINER_GAP, addContainer.frame.size.width/2, 30) title:NSLocalizedStringFromTable(@"addStr",NULL,@"ButtonStrings") action:@selector(addButtonAction:)];
    [self addSubview:addButton];
    
    // ---------------------------------------------------------------------------------------------------------
    //
    urlFilterListContainer = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, addButton.frame.origin.y + addButton.frame.size.height + DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 30) title:NSLocalizedStringFromTable(@"urlFilterListStr",NULL,@"RouterURLFilterUIStrings")];
    [self addSubview:urlFilterListContainer];
    
    urlFilterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [urlFilterListContainer headerHeight], urlFilterListContainer.frame.size.width, urlFilterListContainer.frame.size.height - [urlFilterListContainer headerHeight]) style:UITableViewStylePlain];
    urlFilterTableView.dataSource = self;
    urlFilterTableView.delegate = self;
    urlFilterTableView.backgroundColor = [UIColor clearColor];
    urlFilterTableView.separatorColor = [UIColor darkGrayColor];
    [urlFilterListContainer addSubview:urlFilterTableView];
    
    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
}

- (void)adjustDeviceContainer
{
    [urlFilterListContainer setHeight:[urlFilterListContainer headerHeight] + urlFilterList.count*CELL_HEIGHT];
    
    CGRect tableRect = urlFilterTableView.frame;
    tableRect.size.height = urlFilterList.count*CELL_HEIGHT;
    urlFilterTableView.frame = tableRect;
    
    [self adjustContentHeight];
}

- (void)adjustContentHeight
{
    UIScrollView *containerScrollView = (UIScrollView *)urlFilterListContainer.superview;
    float controlsHeight = controlContainer.frame.size.height + okButton.frame.size.height + addContainer.frame.size.height + addButton.frame.size.height + urlFilterListContainer.frame.size.height + DATA_CONTAINER_GAP*6;
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


@end
