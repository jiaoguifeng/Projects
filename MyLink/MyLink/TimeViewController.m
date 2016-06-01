//
//  TimeViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "TimeViewController.h"

#define Mode_Menu @[NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"manualStr",NULL,@"TipStrings")]
#define Week_Day @[@"NULL",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday"]

@interface TimeViewController ()<UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    //
    DataContainer *container;
    
    UILabel *currentTimeLabel;
    UILabel *currentTimeContentLabel;
    
    UILabel *modeLabel;
    SelectionButton *modeSelectionButton;
    
    // Auto
    UILabel *ntpServerLabel;
    InputTextField *ntpServerInput;
    
    UILabel *timeZoneLabel;
    SelectionButton *timeZoneSelectionButton;
    
    // Manual
    UILabel *yearLabel;
    InputTextField *yearInput;
   
    UILabel *monthLabel;
    InputTextField *monthInput;

    UILabel *dayLabel;
    InputTextField *dayInput;

    UILabel *hourLabel;
    InputTextField *hourInput;

    UILabel *minuteLabel;
    InputTextField *minuteInput;

    UILabel *secondLabel;
    InputTextField *secondInput;

    //
    UIButton *okButton;
    
    //
    float heightLevel1;
    float heightLevelAuto;
    float heightLevelManual;
    
    //
    InputTextField *focusedInputTextField;
    
    //
    BOOL needRefresh;
}
@end

@implementation TimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"timeStr",NULL,@"SystemUIStrings")];
    
    [self setupUIControls];
    
    [self getSystemTimeData];
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
    NSArray *itemList = nil;
    
    if(sender == modeSelectionButton)
    {
        itemList = Mode_Menu;
    }
    else if(sender == timeZoneSelectionButton)
    {
        itemList = System_Time_Zone_Menu;
    }
    
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:itemList];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[itemList objectAtIndex:selectedIndex]];
            selButton.tag = selectedIndex;
            
            if(selButton == modeSelectionButton)
            {
                if(selectedIndex == 0)
                {
                    [self adjustContainerHeight:heightLevelAuto];
                }
                else
                {
                    [self adjustContainerHeight:heightLevelManual];
                }
            }
        }
    }];
}

#pragma mark - OK button actions

- (void)okButtonAction:(id)sender
{
    if ([self limitedCurrentTime] == NO)
    {
        return;
    }
    
    [self setSystemTimeData];
}

#pragma mark - get/set data

- (void)getSystemTimeData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestSystemTimeData:^(id data, NSError *error) {
        if(data)
        {
            //
            currentTimeContentLabel.text = [self formattedTime:[data objectForKey:SYS_Current_Time]];
            
            NSString *modeStr = [data objectForKey:SYS_Time_Mode];  // Auto:0 Manual:1
            if([modeStr isEqualToString:@"0"])
            {
                [modeSelectionButton setButtonTitle:[Mode_Menu objectAtIndex:[modeStr intValue]]];

                ntpServerInput.text = [data objectForKey:SYS_NTP_Server];
                
                NSString *timeZone = [System_Time_Zone_Value objectForKey:[data objectForKey:SYS_Time_Zone]];
                [timeZoneSelectionButton setButtonTitle:timeZone];
                
                [self adjustContainerHeight:heightLevelAuto];
            }
            else
            {
                [modeSelectionButton setButtonTitle:[Mode_Menu objectAtIndex:[modeStr intValue]]];
                [self adjustContainerHeight:heightLevelManual];
            }
            
            needRefresh = YES;
            [NSThread detachNewThreadSelector:@selector(refreshCurrentTime:) toTarget:self withObject:nil];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)refreshCurrentTime:(id)sender
{
    while(needRefresh)
    {
        @autoreleasepool
        {
            [[NetManager sharedNetManager] requestSystemCurrentTime:^(id data, NSError *error) {
                if(data)
                {
                    //
                    currentTimeContentLabel.text = [self formattedTime:[data objectForKey:SYS_Current_Time]];
                    //NSLog(@"Current Time: %@",currentTimeContentLabel.text);
                }
            }];
            
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}

- (NSString *)formattedTime:(NSString *)timeStr
{
    NSString *theTimeStr = @"";
    NSArray *timeList = [timeStr componentsSeparatedByString:@"-"];
    if(timeList.count == 7)
    {
        int weekDay = [[timeList objectAtIndex:3] intValue];
        NSString *weekDayStr = [Week_Day objectAtIndex:weekDay];
        
        theTimeStr = [NSString stringWithFormat:@"%@/%@/%@ %@ %@:%@:%@",[timeList objectAtIndex:2],[timeList objectAtIndex:1],[timeList objectAtIndex:0],weekDayStr,[timeList objectAtIndex:4],[timeList objectAtIndex:5],[timeList objectAtIndex:6]];
    }
    
    return theTimeStr;
}

- (void)setSystemTimeData
{
    NSDictionary *configDict =  nil;
    if(modeSelectionButton.tag == 0)    // Auto
    {
        NSInteger timeZoneIndex = timeZoneSelectionButton.tag;
        configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                      Config_System_Time,URL_CONFIG_ID,
                      @"0",SYS_Time_Mode,
                      ntpServerInput.text,SYS_NTP_Server,
                      [System_Time_Zone_Key objectForKey:[[NSNumber numberWithInteger:timeZoneIndex] stringValue]],SYS_Time_Zone,
                      nil];
    }
    else
    {
        configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                      Config_System_Time,URL_CONFIG_ID,
                      @"1",SYS_Time_Mode,
                      yearInput.text,SYS_Year,
                      monthInput.text,SYS_Month,
                      dayInput.text,SYS_Day,
                      hourInput.text,SYS_Hour,
                      minuteInput.text,SYS_Minute,
                      nil];
    }
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        [[Utility defaultUtility] hudClose];

        if(data)
        {
            yearInput.text = @"";
            monthInput.text = @"";
            dayInput.text = @"";
            hourInput.text = @"";
            minuteInput.text = @"";
            
            [self getSystemTimeData];
        }
    }];
}

#pragma mark - Init UI Controls

- (void)setupUIControls
{
    CGRect sFrame = self.view.bounds;
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:NSLocalizedStringFromTable(@"timeSystemTimeStr",NULL,@"TimeUISstrings")];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // Current Time TitleLabel
    currentTimeLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeCurrentTimeStr",NULL,@"TimeUISstrings")];
    [container addSubview:currentTimeLabel];
    
    // Current Time Content Label
    currentTimeContentLabel = [self titleLabel:CGRectMake(controlsXDelta, currentTimeLabel.frame.origin.y + currentTimeLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:@"--"];
    [container addSubview:currentTimeContentLabel];

    // Mode TitleLabel
    modeLabel = [self titleLabel:CGRectMake(controlsXDelta, currentTimeContentLabel.frame.origin.y + currentTimeContentLabel.frame.size.height + controlsYDelta, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeModeStr",NULL,@"TimeUISstrings")];
    [container addSubview:modeLabel];

    modeSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, modeLabel.frame.origin.y + modeLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    modeSelectionButton.tag = 0;
    [modeSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings")];
    [container addSubview:modeSelectionButton];
    
    //
    heightLevel1 = modeSelectionButton.frame.origin.y + modeSelectionButton.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;
    
    // -------------------------------------------------------------------------------------------------------------------------
    // NTP Server TitleLabel
    ntpServerLabel = [self titleLabel:CGRectMake(controlsXDelta, modeSelectionButton.frame.origin.y+modeSelectionButton.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeNTPServerStr",NULL,@"TimeUISstrings")];
    [container addSubview:ntpServerLabel];
    
    // NTP Server InputTextField
    ntpServerInput = [self inputTextField:CGRectMake(controlsXDelta, ntpServerLabel.frame.origin.y + ntpServerLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    ntpServerInput.delegate = self;
    [container addSubview:ntpServerInput];

    // Time Zone TitleLabel
    timeZoneLabel = [self titleLabel:CGRectMake(controlsXDelta, ntpServerInput.frame.origin.y+ntpServerInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeTimeZoneStr",NULL,@"TimeUISstrings")];
    [container addSubview:timeZoneLabel];
    
    // Time Zone Selection Button
    timeZoneSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, timeZoneLabel.frame.origin.y + timeZoneLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    timeZoneSelectionButton.tag = 0;
    [timeZoneSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"autoMatchStr",NULL,@"TipStrings")];
    [container addSubview:timeZoneSelectionButton];

    //
    heightLevelAuto = timeZoneSelectionButton.frame.origin.y + timeZoneSelectionButton.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;

    // -------------------------------------------------------------------------------------------------------------------------
    // Year TitleLabel
    yearLabel = [self titleLabel:CGRectMake(controlsXDelta, modeSelectionButton.frame.origin.y+modeSelectionButton.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeYearStr",NULL,@"TimeUISstrings")];
    [container addSubview:yearLabel];
    
    // Year InputTextField
    yearInput = [self inputTextField:CGRectMake(controlsXDelta, yearLabel.frame.origin.y + yearLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    yearInput.delegate = self;
    yearInput.keyboardType = UIKeyboardTypeNumberPad;
    [container addSubview:yearInput];

    // Month TitleLabel
    monthLabel = [self titleLabel:CGRectMake(controlsXDelta, yearInput.frame.origin.y+yearInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeMonthStr",NULL,@"TimeUISstrings")];
    [container addSubview:monthLabel];
    
    // Month InputTextField
    monthInput = [self inputTextField:CGRectMake(controlsXDelta, monthLabel.frame.origin.y + monthLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    monthInput.delegate = self;
    monthInput.keyboardType = UIKeyboardTypeNumberPad;
    [container addSubview:monthInput];

    // Day TitleLabel
    dayLabel = [self titleLabel:CGRectMake(controlsXDelta, monthInput.frame.origin.y+monthInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeDayStr",NULL,@"TimeUISstrings")];
    [container addSubview:dayLabel];
    
    // Day InputTextField
    dayInput = [self inputTextField:CGRectMake(controlsXDelta, dayLabel.frame.origin.y + dayLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    dayInput.delegate = self;
    dayInput.keyboardType = UIKeyboardTypeNumberPad;
    [container addSubview:dayInput];

    // Hour TitleLabel
    hourLabel = [self titleLabel:CGRectMake(controlsXDelta, dayInput.frame.origin.y+dayInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeHourStr",NULL,@"TimeUISstrings")];
    [container addSubview:hourLabel];
    
    // Hour InputTextField
    hourInput = [self inputTextField:CGRectMake(controlsXDelta, hourLabel.frame.origin.y + hourLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    hourInput.delegate = self;
    hourInput.keyboardType = UIKeyboardTypeNumberPad;
    [container addSubview:hourInput];

    // Minute TitleLabel
    minuteLabel = [self titleLabel:CGRectMake(controlsXDelta, hourInput.frame.origin.y+hourInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeMinuteStr",NULL,@"TimeUISstrings")];
    [container addSubview:minuteLabel];
    
    // Minute InputTextField
    minuteInput = [self inputTextField:CGRectMake(controlsXDelta, minuteLabel.frame.origin.y + minuteLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    minuteInput.delegate = self;
    minuteInput.keyboardType = UIKeyboardTypeNumberPad;
    [container addSubview:minuteInput];

    /*// Second TitleLabel
    secondLabel = [self titleLabel:CGRectMake(controlsXDelta, minuteInput.frame.origin.y+minuteInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"timeSecondStr",NULL,@"TimeUISstrings")];
    [container addSubview:secondLabel];
    
    // Second InputTextField
    secondInput = [self inputTextField:CGRectMake(controlsXDelta, secondLabel.frame.origin.y + secondLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    secondInput.delegate = self;
    secondInput.keyboardType = UIKeyboardTypeNumberPad;
    [container addSubview:secondInput];*/

    //
    heightLevelManual = minuteInput.frame.origin.y + minuteInput.frame.size.height + DATA_CONTAINER_IN_Y_GAP*2;
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];
    
    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
    
    [self adjustContainerHeight:heightLevel1];
}

#pragma mark - adjust container size

- (void)adjustContainerHeight:(float)theHeight
{
    if(heightLevel1 == theHeight)
    {
        [container setHeight:heightLevel1];
        [self setLevelAutoHide:YES];
        [self setLevelManualHide:YES];
    }
    else if(heightLevelAuto == theHeight)
    {
        [container setHeight:heightLevelAuto];
        [self setLevelAutoHide:NO];
        [self setLevelManualHide:YES];
    }
    else if(heightLevelManual == theHeight)
    {
        [container setHeight:heightLevelManual];
        [self setLevelAutoHide:YES];
        [self setLevelManualHide:NO];
    }
    
    [self adjustContentHeight];
}

- (void)setLevelAutoHide:(BOOL)toHide
{
    ntpServerLabel.hidden = toHide;
    ntpServerInput.hidden = toHide;
    timeZoneLabel.hidden = toHide;
    timeZoneSelectionButton.hidden = toHide;
}

- (void)setLevelManualHide:(BOOL)toHide
{
    yearLabel.hidden = toHide;
    yearInput.hidden = toHide;
    monthLabel.hidden = toHide;
    monthInput.hidden = toHide;
    dayLabel.hidden = toHide;
    dayInput.hidden = toHide;
    hourLabel.hidden = toHide;
    hourInput.hidden = toHide;
    minuteLabel.hidden = toHide;
    minuteInput.hidden = toHide;
    secondLabel.hidden = toHide;
    secondInput.hidden = toHide;
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
- (void)textFieldDidChanged:(NSNotification *)notification
{
    InputTextField *tmpObject = (InputTextField *)notification.object;
    
    if (yearInput == tmpObject)
    {
        NSString *tmpStr = tmpObject.text;
        if (tmpStr.length >= 4)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 4)];
            tmpObject.text = newStr;
        }
    }
    else if (monthInput == tmpObject || dayInput == tmpObject || hourInput == tmpObject || minuteInput == tmpObject)
    {
        NSString *tmpStr = tmpObject.text;
        if (tmpStr.length >= 2)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 2)];
            tmpObject.text = newStr;
        }
    }
}

- (BOOL)limitedCurrentTime
{
    if (![modeSelectionButton.titleLabel.text isEqualToString:NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings")])
    {
        
        if ([self emptyYearInput])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyYearStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if ([self emptyMonthInput])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyMouthStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if ([self emptyDayInput])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyDayStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if ([self emptyHourInput])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyHourStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if ([self emptyMinuteInput])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"EmptyMinuteStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if (![self legalYear])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidYearStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        
        if (![self legalMonth])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidMouthStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        
        if (![self legalDay])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidDayStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        
        if (![self legalHour])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidHourStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if (![self legalMinute])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidMinuteStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            return NO;
        }
        
        if (![self legalYearMouthDay])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidDateStr",NULL,@"TipStrings")
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


- (BOOL)legalYear
{
    NSInteger year = [[yearInput text] integerValue];
    if (year >= 1970 && year <= 2037)
    {
        return YES;
    }
    return NO;
}

- (BOOL)emptyYearInput
{
    if ([[yearInput text] length] == 0)
    {
        return YES;
    }
    return NO;
}

- (BOOL)legalMonth
{
    NSInteger year = [[monthInput text] integerValue];
    if (year >= 1 && year <= 12)
    {
        return YES;
    }
    return NO;
}

- (BOOL)emptyMonthInput
{
    if ([[monthInput text] length] == 0)
    {
        return YES;
    }
    return NO;
}

- (BOOL)legalDay
{
    NSInteger year = [[dayInput text] integerValue];
    if (year >= 1 && year <= 31)
    {
        return YES;
    }
    return NO;
}

- (BOOL)emptyDayInput
{
    if ([[dayInput text] length] == 0)
    {
        return YES;
    }
    return NO;
}

- (BOOL)legalHour
{
    NSInteger year = [[hourInput text] integerValue];
    if (year >= 0 && year <= 23)
    {
        return YES;
    }
    return NO;
}

- (BOOL)emptyHourInput
{
    if ([[hourInput text] length] == 0)
    {
        return YES;
    }
    return NO;
}

- (BOOL)legalMinute
{
    NSInteger year = [[minuteInput text] integerValue];
    if (year >= 0 && year <= 59)
    {
        return YES;
    }
    return NO;
}

- (BOOL)emptyMinuteInput
{
    if ([[minuteInput text] length] == 0)
    {
        return YES;
    }
    return NO;
}

- (BOOL)legalYearMouthDay
{
    if ([monthInput.text integerValue] == 1 || [monthInput.text integerValue] == 3 || [monthInput.text integerValue] == 5 || [monthInput.text integerValue] == 7 ||
        [monthInput.text integerValue] == 8 || [monthInput.text integerValue] == 10 || [monthInput.text integerValue] == 12)
    {
        if (dayInput.text.integerValue >= 1 && dayInput.text.integerValue <= 31)
        {
            return YES;
        }
    }
    else if([monthInput.text integerValue] == 4 || [monthInput.text integerValue] == 6 || [monthInput.text integerValue] == 9 || [monthInput.text integerValue] == 11)
    {
        if (dayInput.text.integerValue >= 1 && dayInput.text.integerValue <= 30)
        {
            return YES;
        }
    }
    else if ([monthInput.text integerValue] == 2)
    {
        if ([self leapYear:[yearInput.text integerValue]])
        {
            if (dayInput.text.integerValue >= 1 && dayInput.text.integerValue <= 29)
            {
                return YES;
            }
        }
        else
        {
            if (dayInput.text.integerValue >= 1 && dayInput.text.integerValue <= 28)
            {
                return YES;
            }
        }
    }
    return NO;
}


- (BOOL)leapYear:(NSInteger)year
{
    if ((year%4 == 0 && year%100 != 0) || year%400 == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    return NO;
}
@end
