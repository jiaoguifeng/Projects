//
//  BaseViewController.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "BaseViewController.h"
#import "KVNProgress.h"

#define TITLE_IMAGEVIEW_HEIGHT  60

@interface BaseViewController ()
{
    UIButton *textFieldButton;
    UILabel *titleLabel;
    UIImageView *titleImageView;
    
    UIImageView *backImageView;
    UIScrollView *scrollViewContainer;
    
}
@end

@implementation BaseViewController

@synthesize isKeyboardShown;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.view.backgroundColor = [UIColor whiteColor];
    //self.view.backgroundColor = [UIColor colorWithRed:157/255.0 green:155/255.0 blue:156/255.0 alpha:0.7];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    CGRect frame = [self.view bounds];
    
    // ----------------------------------------------------------------------------------------
    // setup title bar
    CGRect theImageViewRect = CGRectMake(0, 0, frame.size.width, TITLE_IMAGEVIEW_HEIGHT);
    titleImageView = [[UIImageView alloc] initWithFrame:theImageViewRect];
    titleImageView.image = [UIImage imageNamed:@"ViewTitleImageBG.png"];
    [self.view addSubview:titleImageView];

    // ----------------------------------------------------------------------------------------
    // setup back button
    textFieldButton = [[UIButton alloc] initWithFrame:CGRectMake(5, (titleImageView.frame.size.height - 30)/2 + 10, 30, 30)];
    [textFieldButton setImage:[UIImage imageNamed:@"TitleBarBackButton"] forState:UIControlStateNormal];
    [textFieldButton addTarget:self action:@selector(onBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textFieldButton];
    
    // ----------------------------------------------------------------------------------------
    // setup title label
    float titleLabelWidth = (titleImageView.frame.size.width - (textFieldButton.frame.origin.x + textFieldButton.frame.size.width)*2);
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((titleImageView.frame.size.width - titleLabelWidth)/2, (titleImageView.frame.size.height - 30)/2 + 10, titleLabelWidth, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //titleLabel.backgroundColor = [UIColor grayColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:titleLabel];
    

    // ----------------------------------------------------------------------------------------
    // setup background image
    backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, TITLE_IMAGEVIEW_HEIGHT, frame.size.width, frame.size.height-TITLE_IMAGEVIEW_HEIGHT)];
    backImageView.contentMode = UIViewContentModeScaleToFill;
    backImageView.image = [UIImage imageNamed:@"MainViewBG"];
    [self.view addSubview:backImageView];

    // ----------------------------------------------------------------------------------------
    // all the control's baseview
    scrollViewContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, TITLE_IMAGEVIEW_HEIGHT, frame.size.width, frame.size.height-TITLE_IMAGEVIEW_HEIGHT)];
    scrollViewContainer.backgroundColor = [UIColor colorWithRed:157/255.0 green:155/255.0 blue:156/255.0 alpha:0.8];
    [scrollViewContainer setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [scrollViewContainer setContentSize:CGSizeMake(scrollViewContainer.bounds.size.width, scrollViewContainer.bounds.size.height+1)];
    scrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollViewContainer.scrollEnabled = YES;
    scrollViewContainer.showsVerticalScrollIndicator = YES;
    [self.view addSubview:scrollViewContainer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)onBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Common Controls

- (UIButton *)baseButton:(CGRect)rect title:(NSString *)title action:(SEL)action
{
    UIButton *baseButton = [[UIButton alloc] initWithFrame:rect];
    baseButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [baseButton setTitle:title forState:UIControlStateNormal];
    [baseButton setBackgroundColor:[UIColor colorWithRed:151/255.0 green:25/255.0 blue:35/255.0 alpha:1]];
    [baseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [baseButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [baseButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:234/255.0 green:66/255.0 blue:62/255.0 alpha:1] size:baseButton.frame.size] forState:UIControlStateNormal];
    [baseButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:199/255.0 green:10/255.0 blue:20/255.0 alpha:1] size:baseButton.frame.size] forState:UIControlStateHighlighted];
    [baseButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return baseButton;
}

- (SelectionButton *)selectionButton:(CGRect)rect title:(NSString *)title action:(SEL)action
{
    SelectionButton *selButton = [[SelectionButton alloc] initWithFrame:rect];
    //[selButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1] size:selButton.frame.size] forState:UIControlStateNormal];
    [selButton setBackgroundImage:[[Utility defaultUtility] imageWithColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:0.5] size:selButton.frame.size] forState:UIControlStateHighlighted];
    [selButton setButtonTitle:title];
    [selButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return selButton;
}

- (InputTextField *)inputTextField:(CGRect)rect
{
    InputTextField *inputField = [[InputTextField alloc] initWithFrame:rect];
    inputField.font = [UIFont systemFontOfSize:14.0];
    [inputField setReturnKeyType:UIReturnKeyDone];
    return inputField;
}

- (UILabel *)titleLabel:(CGRect)rect withTitle:(NSString *)title
{
    UILabel *theTitleLabel = [[UILabel alloc] initWithFrame:rect];
    theTitleLabel.text = title;
    theTitleLabel.font = [UIFont systemFontOfSize:12.0];
    
    BOOL debug_bg = NO;
    if(debug_bg)
        theTitleLabel.backgroundColor = [UIColor orangeColor];
    
    return theTitleLabel;
}

- (SevenSwitch *)switchControl:(CGRect)rect action:(SEL)action onTitle:(NSString *)onStr offTitle:(NSString *)offStr
{
    SevenSwitch *theSwitch = [[SevenSwitch alloc] initWithFrame:rect];
    theSwitch.onColor = [UIColor colorWithRed:52/255.0 green:72/255.0 blue:90/255.0 alpha:1.0];
    theSwitch.onTitle = onStr;
    theSwitch.offTitle = offStr;
    [theSwitch addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    
    return theSwitch;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - custom addSubview

- (void)addSubview:(UIView *)view
{
    [scrollViewContainer addSubview:view];
}

- (float)contentHeight
{
    return scrollViewContainer.contentSize.height;
}

- (void)setContentHeight:(CGFloat)contentHeight
{
    [scrollViewContainer setContentSize:CGSizeMake(scrollViewContainer.bounds.size.width, contentHeight)];
}

#pragma mark - UI appearance setup

- (void)setBackgroundImageWithName:(NSString *)name
{
    [backImageView setImage:[UIImage imageNamed:name]];
}

- (void)setTitleText:(NSString *)titleStr
{
    titleLabel.text = titleStr;
}

- (void)setTItleTextFont:(UIFont *)font
{
    titleLabel.font = font;
}

- (void)setTitleImageHide:(BOOL)hide
{
    if(hide)
        titleImageView.image = nil;
}

@end
