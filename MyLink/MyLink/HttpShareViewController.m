//
//  HttpShareViewController.m
//  MyLink
//
//  Created by chen on 16/2/19.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "HttpShareViewController.h"

@interface HttpShareViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    NSInteger httpShareType;
    
    //
    UILabel *infoLabel;
    
    //
    DataContainer *container;
    
    UILabel *urlLabel;
    InputTextField *urlInput;
    
    UILabel *userNameLabel;
    InputTextField *userNameInput;
    
    UILabel *passwordLabel;
    InputTextField *passwordInput;
    
    UIButton *okButton;

    //
    InputTextField *focusedInputTextField;
}
@end

@implementation HttpShareViewController

- (instancetype)initWithType:(NSInteger)type
{
    self = [super init];
    if(self)
    {
        httpShareType = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(httpShareType == 0)
        [self setTitleText:NSLocalizedStringFromTable(@"httpShareConfigStr",NULL,@"SettingMainUIStrings")];
    else
        [self setTitleText:NSLocalizedStringFromTable(@"httpShareLoginStr",NULL,@"SettingMainUIStrings")];
    
    [self initUIControls];
    
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDictionary *statusDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"addComponentStatus", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDCOMPONENTSTAUSNOTIFICATION object: self userInfo:statusDict];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSDictionary *statusDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"addComponentStatus", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDCOMPONENTSTAUSNOTIFICATION object: self userInfo:statusDict];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - OK button actions

- (void)buttonAction:(id)sender
{
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              urlInput.text,@"httpShareURL",
                              userNameInput.text,@"httpShareUsername",
                              passwordInput.text,@"httpSharePassword",nil];
    [[Utility defaultUtility] setHttpShareConfigData:tempDict];
    
    if(httpShareType == 0)  // ok
        [self.navigationController popViewControllerAnimated:YES];
    else    // login
    {
        
    }
}

#pragma mark - Init data

- (void)initData
{
    NSDictionary *tempDict = [[Utility defaultUtility] httpShareConfigData];
    if(tempDict)
    {
        urlInput.text = [tempDict objectForKey:@"httpShareURL"];
        userNameInput.text = [tempDict objectForKey:@"httpShareUsername"];
        passwordInput.text = [tempDict objectForKey:@"httpSharePassword"];
    }
}

#pragma mark - Init UI Controls

- (void)initUIControls
{
    CGRect sFrame = self.view.bounds;
    
    // info label
    infoLabel = [self titleLabel:CGRectMake(DATA_CONTAINER_GAP*2, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*4, 80) withTitle:NSLocalizedStringFromTable(@"httpShareInfoStr",NULL,@"TipStrings")];
    infoLabel.font = [UIFont systemFontOfSize:10.0];
    infoLabel.numberOfLines = 0;
    [self addSubview:infoLabel];
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, infoLabel.frame.origin.y + infoLabel.frame.size.height + DATA_CONTAINER_IN_Y_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:@""];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // URL TitleLabel
    urlLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:@"URL"];
    [container addSubview:urlLabel];
    
    // URL InputTextField
    urlInput = [self inputTextField:CGRectMake(controlsXDelta, urlLabel.frame.origin.y + urlLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    urlInput.delegate = self;
    [container addSubview:urlInput];
    
    // userName TitleLabel
    userNameLabel = [self titleLabel:CGRectMake(controlsXDelta, urlInput.frame.origin.y+urlInput.frame.size.height+controlsYDelta*2, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"userNameStr",NULL,@"SettingMainUIStrings")];
    [container addSubview:userNameLabel];
    userNameLabel.hidden = YES;
    
    // userName InputTextField
    userNameInput = [self inputTextField:CGRectMake(controlsXDelta, userNameLabel.frame.origin.y + userNameLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    userNameInput.delegate = self;
    [container addSubview:userNameInput];
    userNameInput.hidden = YES;
    
    // Password TitleLabel
    passwordLabel = [self titleLabel:CGRectMake(controlsXDelta, userNameInput.frame.origin.y+userNameInput.frame.size.height+controlsYDelta*2, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"passwordStr",NULL,@"SettingMainUIStrings")];
    [container addSubview:passwordLabel];
    passwordLabel.hidden = YES;
    
    // Password InputTextField
    passwordInput = [self inputTextField:CGRectMake(controlsXDelta, passwordLabel.frame.origin.y + passwordLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    passwordInput.secureTextEntry = YES;
    passwordInput.delegate = self;
    [container addSubview:passwordInput];
    passwordInput.hidden = YES;
    
    //float tempY = passwordInput.frame.origin.y + passwordInput.frame.size.height + controlsYDelta*3;
    float tempY = urlInput.frame.origin.y + urlInput.frame.size.height + controlsYDelta*3;
    
    if(httpShareType == 0)
        okButton = [self baseButton:CGRectMake(controlsXDelta, tempY, controlsWidth, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    else
        okButton = [self baseButton:CGRectMake(controlsXDelta, tempY, controlsWidth, 30) title:NSLocalizedStringFromTable(@"loginBtnStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [container addSubview:okButton];

    [container setHeight:okButton.frame.origin.y + okButton.frame.size.height + controlsYDelta*2];
    
    //
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInView:)];
    tapInView.delegate = self;
    [self.view addGestureRecognizer:tapInView];
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
