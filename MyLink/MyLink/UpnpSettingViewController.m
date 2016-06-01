//
//  UpnpSettingViewController.m
//  MyLink
//
//  Created by chen on 16/1/12.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "UpnpSettingViewController.h"

@interface UpnpSettingViewController ()
{
    DataContainer *container;
    
    UILabel *upnpTitleLabel;
    SevenSwitch *upnpSwitch;
    
    UILabel *l2tpTitleLabel;
    SevenSwitch *l2tpSwitch;
    
    UILabel *pptpTitleLabel;
    SevenSwitch *pptpSwitch;
    
    UILabel *ipSecTitleLabel;
    SevenSwitch *ipSecSwitch;
    
    UIButton *okButton;
}
@end

@implementation UpnpSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"upnpStr",NULL,@"RouterUIStrings")];
    
    [self setupUIControls];
    
    [self getUPnPData];
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
    [self setUPnPData];
}

#pragma mark - get/set function

- (void)getUPnPData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestRouterUPnPData:^(id data, NSError *error) {
        if(data)
        {
            //
            upnpSwitch.on = ([[data objectForKey:RT_UPnP_Enable] isEqualToString:@"1"]) ? YES : NO;
            l2tpSwitch.on = ([[data objectForKey:RT_L2TP_Enable] isEqualToString:@"0"]) ? YES : NO;
            pptpSwitch.on = ([[data objectForKey:RT_PPTP_Enable] isEqualToString:@"0"]) ? YES : NO;
            ipSecSwitch.on = ([[data objectForKey:RT_IPSec_Enable] isEqualToString:@"0"]) ? YES : NO;
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setUPnPData
{
    NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                Config_Router_Basic,URL_CONFIG_ID,
                                [[NSNumber numberWithBool:upnpSwitch.on] stringValue],RT_UPnP_Enable,
                                [[NSNumber numberWithBool:!l2tpSwitch.on] stringValue],RT_L2TP_Enable,
                                [[NSNumber numberWithBool:!pptpSwitch.on] stringValue],RT_PPTP_Enable,
                                [[NSNumber numberWithBool:!ipSecSwitch.on] stringValue],RT_IPSec_Enable,nil];
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
    container = [[DataContainer alloc] initWithFrame:CGRectMake(DATA_CONTAINER_GAP, DATA_CONTAINER_GAP, sFrame.size.width-DATA_CONTAINER_GAP*2, 800) title:NSLocalizedStringFromTable(@"upnpStr",NULL,@"RouterUIStrings")];
    [self addSubview:container];
    
    CGFloat controlsWidth = container.frame.size.width - 2*DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsXDelta = DATA_CONTAINER_IN_X_GAP;
    CGFloat controlsYDelta = DATA_CONTAINER_IN_Y_GAP;
    
    // UPnP TitleLabel
    upnpTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"upnpStr",NULL,@"RouterUPnPUIStrings")];
    [container addSubview:upnpTitleLabel];
    
    // UPnP Switch
    upnpSwitch = [self switchControl:CGRectMake(controlsXDelta, upnpTitleLabel.frame.origin.y + upnpTitleLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    upnpSwitch.on = NO;
    [container addSubview:upnpSwitch];
    
    // L2TP TitleLabel
    l2tpTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, upnpSwitch.frame.origin.y + upnpSwitch.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"l2tpStr",NULL,@"RouterUPnPUIStrings")];
    [container addSubview:l2tpTitleLabel];
    
    // L2TP Switch
    l2tpSwitch = [self switchControl:CGRectMake(controlsXDelta, l2tpTitleLabel.frame.origin.y + l2tpTitleLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    l2tpSwitch.on = NO;
    [container addSubview:l2tpSwitch];

    // PPTP TitleLabel
    pptpTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, l2tpSwitch.frame.origin.y + l2tpSwitch.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"pptpStr",NULL,@"RouterUPnPUIStrings")];
    [container addSubview:pptpTitleLabel];
    
    // PPTP Switch
    pptpSwitch = [self switchControl:CGRectMake(controlsXDelta, pptpTitleLabel.frame.origin.y + pptpTitleLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    pptpSwitch.on = NO;
    [container addSubview:pptpSwitch];

    // IPSec TitleLabel
    ipSecTitleLabel = [self titleLabel:CGRectMake(controlsXDelta, pptpSwitch.frame.origin.y + pptpSwitch.frame.size.height + controlsYDelta, controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"ipSecStr",NULL,@"RouterUPnPUIStrings")];
    [container addSubview:ipSecTitleLabel];
    
    // IPSec Switch
    ipSecSwitch = [self switchControl:CGRectMake(controlsXDelta, ipSecTitleLabel.frame.origin.y + ipSecTitleLabel.frame.size.height, 75, INPUT_TEXTFIELD_HEIGHT) action:@selector(switchControlAction:) onTitle:NSLocalizedStringFromTable(@"enableStr",NULL,@"TipStrings") offTitle:NSLocalizedStringFromTable(@"disableStr",NULL,@"TipStrings")];
    ipSecSwitch.on = NO;
    [container addSubview:ipSecSwitch];

    //
    [container setHeight:ipSecSwitch.frame.origin.y + ipSecSwitch.frame.size.height + controlsYDelta*2];
    
    //
    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP, container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okCancelButtonAction:)];
    [self addSubview:okButton];
}


@end
