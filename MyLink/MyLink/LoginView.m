//
//  LoginView.m
//  MyLink
//
//  Created by chen on 16/1/1.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "LoginView.h"
#import "Utility.h"
#import "KVNProgress.h"
#import "NetManager.h"
#import "Utility.h"

#define CONTENTVIEW_HEIGHT  260

@interface LoginView()<UITextFieldDelegate>
{
    CompletionBlock completionBlock;
    BOOL isCanceled;
    
    UIScrollView *scrollViewContainer;
    UIImageView *bgImageView;
    UITextField *userNameInputText;
    UITextField *userPassInputText;
    UIButton *checkButton;
}
@end

@implementation LoginView

- (instancetype)init
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    CGFloat screenHeight = CGRectGetHeight(screenRect);
    
    self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    if(self)
    {
        isCanceled = NO;
        
        // ----------------------------------------------------------------------------------------
        // add keyboard notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

        //
        scrollViewContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollViewContainer.backgroundColor=[UIColor clearColor];
        [scrollViewContainer setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [scrollViewContainer setContentSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
        scrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollViewContainer.scrollEnabled = YES;
        scrollViewContainer.showsVerticalScrollIndicator = NO;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
        [scrollViewContainer addGestureRecognizer:singleTap];
        [self addSubview:scrollViewContainer];
        
        // login background image
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (scrollViewContainer.frame.size.height - CONTENTVIEW_HEIGHT)/2,
                                                                    scrollViewContainer.frame.size.width-20, CONTENTVIEW_HEIGHT)];
        bgImageView.contentMode = UIViewContentModeScaleToFill;
        bgImageView.image = [UIImage imageNamed:@"MainViewBG2"];
        bgImageView.layer.cornerRadius = 6;
        bgImageView.layer.masksToBounds = YES;
        [scrollViewContainer addSubview:bgImageView];

        //
        CGFloat startX = 30;
        CGFloat startY = bgImageView.frame.origin.y + 10;
        CGFloat controlWidth = self.frame.size.width - startX*2;
        CGFloat buttonWidth = (controlWidth - 10)/2;
        
        UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-180)/2, startY, 180, 30)];
        logoImage.contentMode = UIViewContentModeScaleToFill;
        logoImage.image = [UIImage imageNamed:@"smartfren4gLTE"];
        [scrollViewContainer addSubview:logoImage];
        
        UILabel *userNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(startX, logoImage.frame.origin.y+logoImage.frame.size.height+10, controlWidth, 20)];
        userNameTitle.text = NSLocalizedStringFromTable(@"userNameStr",NULL,@"SettingMainUIStrings");
        userNameTitle.textColor = [UIColor whiteColor];
        userNameTitle.font = [UIFont systemFontOfSize:14.0];
        //userNameTitle.backgroundColor = [UIColor lightGrayColor];
        [scrollViewContainer addSubview:userNameTitle];
        
        userNameInputText = [[UITextField alloc] initWithFrame:CGRectMake(startX,userNameTitle.frame.origin.y+userNameTitle.frame.size.height,controlWidth,30)];
        userNameInputText.backgroundColor = [UIColor whiteColor];
        userNameInputText.delegate = self;
        [userNameInputText setReturnKeyType:UIReturnKeyNext];
        [userNameInputText addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [scrollViewContainer addSubview:userNameInputText];
        
        UILabel *passwordTitle = [[UILabel alloc] initWithFrame:CGRectMake(startX,userNameInputText.frame.origin.y+userNameInputText.frame.size.height+10, controlWidth,20)];
        passwordTitle.text = NSLocalizedStringFromTable(@"passwordStr",NULL,@"SettingMainUIStrings");
        passwordTitle.textColor = [UIColor whiteColor];
        passwordTitle.font = [UIFont systemFontOfSize:14.0];
        //passwordTitle.backgroundColor = [UIColor lightGrayColor];
        [scrollViewContainer addSubview:passwordTitle];
        
        userPassInputText = [[UITextField alloc] initWithFrame:CGRectMake(startX,passwordTitle.frame.origin.y+passwordTitle.frame.size.height,controlWidth,30)];
        userPassInputText.backgroundColor = [UIColor whiteColor];
        userPassInputText.delegate = self;
        userPassInputText.secureTextEntry = YES;
        [userPassInputText setReturnKeyType:UIReturnKeyNext];
        [userPassInputText addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [scrollViewContainer addSubview:userPassInputText];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(startX,userPassInputText.frame.origin.y+userPassInputText.frame.size.height+20,buttonWidth,30)];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [cancelButton setTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(buttonCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setBackgroundColor:[UIColor colorWithRed:151/255.0 green:25/255.0 blue:35/255.0 alpha:1]];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:234/255.0 green:66/255.0 blue:62/255.0 alpha:1] size:cancelButton.frame.size] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:199/255.0 green:10/255.0 blue:20/255.0 alpha:1] size:cancelButton.frame.size] forState:UIControlStateHighlighted];
        [scrollViewContainer addSubview:cancelButton];

        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(startX+buttonWidth+10,userPassInputText.frame.origin.y+userPassInputText.frame.size.height+20,buttonWidth,30)];
        loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [loginButton setTitle:NSLocalizedStringFromTable(@"loginBtnStr",NULL,@"ButtonStrings") forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(buttonLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
        [loginButton setBackgroundColor:[UIColor colorWithRed:151/255.0 green:25/255.0 blue:35/255.0 alpha:1]];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:234/255.0 green:66/255.0 blue:62/255.0 alpha:1] size:loginButton.frame.size] forState:UIControlStateNormal];
        [loginButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:199/255.0 green:10/255.0 blue:20/255.0 alpha:1] size:loginButton.frame.size] forState:UIControlStateHighlighted];
        [scrollViewContainer addSubview:loginButton];
        
        checkButton = [[UIButton alloc] initWithFrame:CGRectMake(startX, loginButton.frame.origin.y+loginButton.frame.size.height+10, 20, 20)];
        [checkButton addTarget:self action:@selector(buttonCheckClicked:) forControlEvents:UIControlEventTouchUpInside];
        [checkButton setBackgroundImage:[UIImage imageNamed:@"btnCheckNo"] forState:UIControlStateNormal];
        checkButton.tag = 0;
        [scrollViewContainer addSubview:checkButton];
        
        UILabel *checkTitle = [[UILabel alloc] initWithFrame:CGRectMake(checkButton.frame.origin.x+checkButton.frame.size.width+5, loginButton.frame.origin.y+loginButton.frame.size.height+10, controlWidth, 20)];
        checkTitle.textColor = [UIColor whiteColor];
        checkTitle.font = [UIFont systemFontOfSize:12.0];
        checkTitle.text = NSLocalizedStringFromTable(@"rememberPasswordStr",NULL,@"SettingMainUIStrings");
        [scrollViewContainer addSubview:checkTitle];
    }
    
    return self;
}

- (void)showWithcompletion:(CompletionBlock)completion
{
    completionBlock = completion;
    
    NSDictionary *dict = [[Utility defaultUtility] loginConfigData];
    if(dict)
    {
        BOOL isChecked = [[dict objectForKey:@"isRemember"] boolValue];
        if(isChecked)
        {
            checkButton.tag = 1;
            [checkButton setBackgroundImage:[UIImage imageNamed:@"btnCheckYes"] forState:UIControlStateNormal];
            userNameInputText.text = [dict objectForKey:@"userName"];
            userPassInputText.text = [dict objectForKey:@"password"];
        }
        else
        {
            checkButton.tag = 0;
            [checkButton setBackgroundImage:[UIImage imageNamed:@"btnCheckNo"] forState:UIControlStateNormal];
            userNameInputText.text = @"";
            userPassInputText.text = @"";
        }
    }
    
    [self show];
}

- (void)tapEvent:(UITapGestureRecognizer *)gesture
{
    [self endEditing:YES];
    
    /*CGPoint tapPoint = [gesture locationInView:self];
    if(tapPoint.y < bgImageView.frame.origin.y || tapPoint.y > bgImageView.frame.origin.y + bgImageView.frame.size.height)
    {
        [self endEditing:YES];
        [self dismiss];
        completionBlock(nil,nil);
    }
    else
    {
        [self endEditing:YES];
    }*/
}

#pragma mark -

- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

            if(isCanceled)
                completionBlock(nil,nil);
            else
            {
                //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0],@"buttonID", nil];
                completionBlock(nil,nil);
            }
        }
    }];
}

- (void)show
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f, keywindow.bounds.size.height/2.0f);
    [self fadeIn];
}

- (void)dismiss
{
    [self fadeOut];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == userNameInputText)
    {
        userPassInputText.returnKeyType = UIReturnKeyNext;
        
        userNameInputText.clearButtonMode = UITextFieldViewModeAlways;
        userPassInputText.clearButtonMode = UITextFieldViewModeNever;
    }
    else if(textField == userPassInputText)
    {
        userPassInputText.returnKeyType = UIReturnKeyDone;
        
        userNameInputText.clearButtonMode = UITextFieldViewModeNever;
        userPassInputText.clearButtonMode = UITextFieldViewModeAlways;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == userNameInputText)
    {
        return [userPassInputText becomeFirstResponder];
    }
    else if(textField == userPassInputText)
    {
        userNameInputText.clearButtonMode = UITextFieldViewModeNever;
        userPassInputText.clearButtonMode = UITextFieldViewModeNever;
        [self endEditing:YES];
    }
    
    return YES;
}

- (void)textFieldDidChange
{
}

#pragma mark - Event response

- (void)buttonCancelClicked:(id)sender
{
    [self endEditing:YES];
    [self dismiss];
    
    completionBlock(nil,nil);
}

- (void)buttonLoginClicked:(id)sender
{
    userNameInputText.clearButtonMode = UITextFieldViewModeNever;
    userPassInputText.clearButtonMode = UITextFieldViewModeNever;
    [self endEditing:YES];
    
    if(userNameInputText.text.length == 0)
    {
        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"loginUserNameErrStr",NULL,@"TipStrings")];
        return;
    }
    if(userPassInputText.text.length == 0)
    {
        [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"loginPasswordErrStr",NULL,@"TipStrings")];
        return;
    }
    
    //[KVNProgress showWithStatus:@"Login..."];
    [[NetManager sharedNetManager] loginWithName:userNameInputText.text password:userPassInputText.text andBlock:^(id data, id error) {
        if(data)
        {
            // login success, then create session
            int commitCode = [[NetManager sharedNetManager] commitLoginSession];
            if(commitCode == 0) // longin success
            {
                [[NetManager sharedNetManager] resetAppTimer];
                //[KVNProgress showSuccessWithStatus:NSLocalizedStringFromTable(@"loginSuccessStr",NULL,@"TipStrings")];
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      userNameInputText.text,@"userName",
                                      userPassInputText.text,@"password",
                                      [NSNumber numberWithBool:checkButton.tag],@"isRemember",nil];
                [[Utility defaultUtility] setLoginConfigData:dict];
                
                completionBlock(data,nil);
            }
            else if(commitCode == 2) // already login
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"loginAlreadyStr",NULL,@"TipStrings")];
                completionBlock(nil,nil);
            }
            else if(commitCode == -1)  // The session could not be created or the connection has been lost!
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"loginErrorStr",NULL,@"TipStrings")];
                completionBlock(nil,nil);
            }
            else
            {
                [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"loginErrorStr",NULL,@"TipStrings")];
                completionBlock(nil,nil);
            }
            
            [self endEditing:YES];
            [self dismiss];
        }
        else
        {
            //
            if(error)
            {
                int loginRetCode = [error intValue];
                if(loginRetCode == 0) //password failed
                {
                    [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"loginPasswordFailedStr",NULL,@"TipStrings")];
                }
                else if(loginRetCode == -1) // userName failed
                {
                    [KVNProgress showErrorWithStatus:NSLocalizedStringFromTable(@"loginNameFailedStr",NULL,@"TipStrings")];
                }
            }
            
            completionBlock(nil,nil);
        }
    }];
}

- (void)buttonCheckClicked:(id)sender
{
    UIButton *theBtn = (UIButton *)sender;
    if(theBtn.tag == 0)
    {
        theBtn.tag = 1;
        [theBtn setBackgroundImage:[UIImage imageNamed:@"btnCheckYes"] forState:UIControlStateNormal];
    }
    else
    {
        theBtn.tag = 0;
        [theBtn setBackgroundImage:[UIImage imageNamed:@"btnCheckNo"] forState:UIControlStateNormal];
    }
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfoDictionary = [notification userInfo];
    //CGFloat duration = [[userInfoDictionary objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyBoardHeight = [[userInfoDictionary objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    if(keyBoardHeight > (self.frame.size.height - scrollViewContainer.frame.origin.y - scrollViewContainer.frame.size.height))
    {
        float adjustY = 0;
        float deltaY = scrollViewContainer.frame.size.height - bgImageView.frame.origin.y - bgImageView.frame.size.height;
        if(deltaY > keyBoardHeight)
            adjustY = deltaY - keyBoardHeight;
        else
            adjustY = keyBoardHeight - deltaY;
        adjustY += 5;
        
        //
        CGSize scrollSize = self.frame.size;
        scrollSize.height += adjustY;
        scrollViewContainer.contentSize = scrollSize;
        
        CGRect visiableRect = scrollViewContainer.frame;
        visiableRect.origin.y += adjustY;
        [scrollViewContainer scrollRectToVisible:visiableRect animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //NSDictionary *userInfoDictionary = [notification userInfo];
    //CGFloat duration = [[userInfoDictionary objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //
    CGSize theSize = self.frame.size;
    scrollViewContainer.contentSize = theSize;
}

@end
