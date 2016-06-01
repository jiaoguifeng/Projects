//
//  ModifyPasswordViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "ModifyPasswordViewController.h"

@interface ModifyPasswordViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    DataContainer *container;
    
    UILabel *newUserNameLabel;
    InputTextField *newUserNameInput;
    
    UILabel *newPasswordLabel;
    InputTextField *newPasswordInput;
    
    UILabel *confirmPasswordLabel;
    InputTextField *confirmPasswordInput;
    
    UIButton *okButton;
    
    //
    InputTextField *focusedInputTextField;
}
@end

@implementation ModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"modifyPassStr",NULL,@"SystemUIStrings")];
    
    [self setupUIControls];
    
    [self getModifyPasswordData];
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

#pragma mark - set/get data

- (void)getModifyPasswordData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestSystemUserNamePassworkData:^(id data, NSError *error) {
        if(data)
        {
            //
            newUserNameInput.text = [data objectForKey:SYS_New_UserName];
            newPasswordInput.text = [data objectForKey:SYS_New_Password];
            confirmPasswordInput.text = [data objectForKey:SYS_New_Password];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setModifyPasswordData
{
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                  Config_System_Setting,URL_CONFIG_ID,
                  newUserNameInput.text,SYS_New_UserName,
                  newPasswordInput.text,SYS_New_Password,nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                [KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"modifyPasswordOKStr",NULL,@"TipStrings")];
            }
            else if([result isEqualToString:@"error"])
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"modifyPasswordNOStr",NULL,@"TipStrings")];
            }
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

#pragma mark - OK button actions

- (void)buttonAction:(id)sender
{
    if ([self legalUsername] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidUserNameStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return;
    }
    
    if ([self legalNewPassword] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidPasswordStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return;
    }
    
    if ([self isDifferWithPassword] == YES)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"DifferPasswordStr",NULL,@"TipStrings")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
        [alert show];
        return;
    }
    
    
    [self setModifyPasswordData];
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
    
    // New Username TitleLabel
    newUserNameLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"modifyPasswordNewUserNameStr",NULL,@"ModifyPasswordUIStrings")];
    [container addSubview:newUserNameLabel];
    
    // New Username InputTextField
    newUserNameInput = [self inputTextField:CGRectMake(controlsXDelta, newUserNameLabel.frame.origin.y + newUserNameLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    newUserNameInput.delegate = self;
    [container addSubview:newUserNameInput];
    
    // New Password TitleLabel
    newPasswordLabel = [self titleLabel:CGRectMake(controlsXDelta, newUserNameInput.frame.origin.y+newUserNameInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"modifyPasswordNewPasswordStr",NULL,@"ModifyPasswordUIStrings")];
    [container addSubview:newPasswordLabel];
    
    // New Password InputTextField
    newPasswordInput = [self inputTextField:CGRectMake(controlsXDelta, newPasswordLabel.frame.origin.y + newPasswordLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    newPasswordInput.secureTextEntry = YES;
    newPasswordInput.delegate = self;
    [container addSubview:newPasswordInput];
    
    // Confirm Password TitleLabel
    confirmPasswordLabel = [self titleLabel:CGRectMake(controlsXDelta, newPasswordInput.frame.origin.y+newPasswordInput.frame.size.height+controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"modifyPasswordConformPasswordStr",NULL,@"ModifyPasswordUIStrings")];
    [container addSubview:confirmPasswordLabel];
    
    // Confirm Password InputTextField
    confirmPasswordInput = [self inputTextField:CGRectMake(controlsXDelta, confirmPasswordLabel.frame.origin.y + confirmPasswordLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT)];
    confirmPasswordInput.secureTextEntry = YES;
    confirmPasswordInput.delegate = self;
    [container addSubview:confirmPasswordInput];
    
    [container setHeight:confirmPasswordInput.frame.origin.y + confirmPasswordInput.frame.size.height + controlsYDelta*2];
    
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(buttonAction:)];
    [self addSubview:okButton];
    
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


#pragma mark -input limited
- (void)textFieldDidChanged:(NSNotification *)notification
{
    InputTextField *tmpObject = (InputTextField *)notification.object;
    if (newUserNameInput == tmpObject || newPasswordInput == tmpObject || confirmPasswordInput == tmpObject)
    {
        NSString *tmpStr = tmpObject.text;
        if (tmpStr.length >= 20)
        {
            NSString *newStr = [tmpStr substringWithRange:NSMakeRange(0, 20)];
            tmpObject.text = newStr;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSArray *characterList = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"G",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"`",@"~",@"!",@"@",@"$",@"^",@"&",@"*",@"(",@")",@"[",@"]",@"{",@"}",@";",@":",@",",@".",@""];
    
    if (newUserNameInput == textField || newPasswordInput == textField || confirmPasswordInput == textField)
    {
        if (![characterList containsObject:string])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)legalUsername
{
    if (newUserNameInput.text.length == 0)
    {
        return NO;
    }
    return YES;
}

- (BOOL)legalNewPassword
{
    if (newPasswordInput.text.length == 0 || confirmPasswordInput.text.length == 0)
    {
        return NO;
    }
    return YES;
}

- (BOOL)isDifferWithPassword
{
    if ([newPasswordInput.text isEqualToString:confirmPasswordInput.text])
    {
        return NO;
    }
    return YES;
}

@end
