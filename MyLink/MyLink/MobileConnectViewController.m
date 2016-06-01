//
//  MobileConnectViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "MobileConnectViewController.h"

@interface MobileConnectViewController ()
{
    DataContainer *container;
    
    UILabel *roamingLabel;
    SevenSwitch *roamingSwitch;
    
    UILabel *connectModeLabel;
    SevenSwitch *connectModeSwitch;
    
    UIButton *okButton;
}
@end

@implementation MobileConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"mobileConnStr",NULL,@"WanUIStrings")];
    
    [self setupUIControls];
    
    [self getMobileConnectionData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Switch Control action

- (void)switchControlAction:(id)sender
{
}

#pragma mark - OK/Cancel button actions

- (void)okCancelButtonAction:(id)sender
{
    [self setMobileConnectionData];
}

#pragma mark - get/set function

- (void)getMobileConnectionData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestWanMobileConnectionData:^(id data, NSError *error) {
        if(data)
        {
            //
            roamingSwitch.on = [[data objectForKey:Roaming_Switch] isEqualToString:@"1"] ? YES : NO;
            connectModeSwitch.on = [[data objectForKey:Net_Connect_Mode] isEqualToString:@"0"] ? YES : NO;
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setMobileConnectionData
{
    NSString *roamingStr = roamingSwitch.on ? @"1" : @"0";
    NSString *connectModeStr = connectModeSwitch.on ? @"0" : @"1";
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_Net_Set_Mode,URL_CONFIG_ID,
                                 @"3",Net_Work_Mode,
                                 roamingStr,Roaming_Switch,
                                 connectModeStr,Net_Connect_Mode,nil];
    
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
    
    //
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:@""];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // Roaming TitleLabel
    roamingLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"moblieConnectionRoamingStr",NULL,@"mobileConnectionUIStrings")];
    [container addSubview:roamingLabel];
    
    // Roaming Switch
    roamingSwitch = [self switchControl:CGRectMake(controlsXDelta, roamingLabel.frame.origin.y + roamingLabel.frame.size.height, 55, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"onStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"offStr",NULL,@"TipStrings")];
    roamingSwitch.on = NO;
    [container addSubview:roamingSwitch];
    
    // Connect Mode TitleLabel
    connectModeLabel = [self titleLabel:CGRectMake(controlsXDelta, roamingSwitch.frame.origin.y + roamingSwitch.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"mobileConnectionConnectMode",NULL,@"mobileConnectionUIStrings")];
    [container addSubview:connectModeLabel];
    
    // Connect Mode Switch
    connectModeSwitch = [self switchControl:CGRectMake(controlsXDelta, connectModeLabel.frame.origin.y + connectModeLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"autoStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"manualStr",NULL,@"TipStrings")];
    connectModeSwitch.on = NO;
    [container addSubview:connectModeSwitch];
    
    //
    [container setHeight:connectModeSwitch.frame.origin.y + connectModeSwitch.frame.size.height + controlsYDelta*2];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okCancelButtonAction:)];
    [self addSubview:okButton];
}

@end
