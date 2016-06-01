//
//  StorageViewController.m
//  MyLink
//
//  Created by chen on 16/1/20.
//  Copyright © 2016年 tricheer. All rights reserved.
//

#import "StorageViewController.h"

#define Storage_Menu @[NSLocalizedStringFromTable(@"storageWiFi",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"storageInternetStr",NULL,@"TipStrings"),NSLocalizedStringFromTable(@"storageLocal",NULL,@"TipStrings")]

@interface StorageViewController ()
{
    DataContainer *container;
    
    UILabel *storageLabel;
    SelectionButton *storageSelectionButton;
    
    UILabel *ipAddressLbl;
    
    CGFloat heightLevel1;
    CGFloat heightLevel2;
    
    UIButton *okButton;
}
@end

@implementation StorageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitleText:NSLocalizedStringFromTable(@"storageStr",NULL,@"SystemUIStrings")];
    
    [self setupUIControls];
    
    [self getStorageData];
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

#pragma mark - Selection Button action

- (void)selectionButtonAction:(id)sender
{
    __weak SelectionButton *selButton = sender;
    PopSelectView *selectView = [[PopSelectView alloc] initWithContentList:Storage_Menu];
    [selectView showWithcompletion:^(id data, NSError *error) {
        if(data)
        {
            NSInteger selectedIndex = [data integerValue];
            [selButton setButtonTitle:[Storage_Menu objectAtIndex:selectedIndex]];
            selButton.tag = selectedIndex;
            
            [self refreshUIControl];
        }
    }];
}

#pragma mark - OK button actions

- (void)okButtonAction:(id)sender
{
    NSString *alertStr = @"";
    NSInteger theTag = 0;
    if(storageSelectionButton.tag == 2)
    {
        alertStr = NSLocalizedStringFromTable(@"setLanRebootStr",NULL,@"TipStrings");
        theTag = 1;
    }
    else
    {
        alertStr = NSLocalizedStringFromTable(@"storageRestartWiFiStr",NULL,@"TipStrings");
        theTag = 2;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:alertStr
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                          otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    alert.tag = theTag;
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self setStorageData];
    }
}

#pragma mark - set/get data

- (void)getStorageData
{
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] requestSystemStorageData:^(id data, NSError *error) {
        if(data)
        {
            // WiFi:3 Internet:4 Local:5
            NSString *storageIndex = [data objectForKey:Setting_Storage];
            if(storageIndex)
                [storageSelectionButton setButtonTitle:[Storage_Menu objectAtIndex:[storageIndex integerValue]-3]];
            
            [self refreshUIControl];
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)setStorageData
{
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_Setting_Storage,URL_CONFIG_ID,
                                 [NSNumber numberWithInteger:storageSelectionButton.tag+3],Setting_Storage_Mode,nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                if(storageSelectionButton.tag == 2)
                    [self rebootSystem];
                else
                    [self restarttWiFi];
            }
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)rebootSystem
{
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_System_Reboot,URL_CONFIG_ID,
                                 SYS_Reboot,SYS_Param,nil];
    [[Utility defaultUtility] hudShowWithTitle:@""];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)restarttWiFi
{
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_WiFi_Restart,URL_CONFIG_ID,
                                 WiFi_Type_Param,WiFi_Type,nil];
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
    
    // Storage TitleLabel
    storageLabel = [self titleLabel:CGRectMake(controlsXDelta, DATA_CONTAINER_IN_Y_GAP + [container headerHeight], controlsWidth, TITLE_LABEL_HEIGHT) withTitle:NSLocalizedStringFromTable(@"storageStorageStr",NULL,@"StorageUIStrings")];
    [container addSubview:storageLabel];

    // Storage Selection Button
    storageSelectionButton = [self selectionButton:CGRectMake(controlsXDelta, storageLabel.frame.origin.y + storageLabel.frame.size.height, controlsWidth, INPUT_TEXTFIELD_HEIGHT) title:@"Selection Button Item" action:@selector(selectionButtonAction:)];
    storageSelectionButton.tag = 0;
    [storageSelectionButton setButtonTitle:NSLocalizedStringFromTable(@"storageWiFi",NULL,@"TipStrings")];
    [container addSubview:storageSelectionButton];
    
    heightLevel1 = storageSelectionButton.frame.origin.y + storageSelectionButton.frame.size.height + controlsYDelta*2;
    
    ipAddressLbl = [self titleLabel:CGRectMake(controlsXDelta, storageSelectionButton.frame.origin.y + storageSelectionButton.frame.size.height + controlsYDelta, controlsWidth, INPUT_TEXTFIELD_HEIGHT) withTitle:[NSString stringWithFormat:@"%@ : %@",NSLocalizedStringFromTable(@"StorageAddressStr",NULL,@"WiFiDiskUIStrings"),NSLocalizedStringFromTable(@"NetWorkDisconnectedStr",NULL,@"WiFiDiskUIStrings")]];
    [container addSubview:ipAddressLbl];

    heightLevel2 = ipAddressLbl.frame.origin.y + ipAddressLbl.frame.size.height + controlsYDelta*2;

    [container setHeight:heightLevel2];

    [self refreshUIControl];

    okButton = [self baseButton:CGRectMake(DATA_CONTAINER_GAP , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30) title:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings") action:@selector(okButtonAction:)];
    [self addSubview:okButton];
}

- (void)refreshUIControl
{
    if ([storageSelectionButton.titleLabel.text isEqualToString:NSLocalizedStringFromTable(@"storageInternetStr",NULL,@"TipStrings")])
    {
        ipAddressLbl.hidden = NO;
        [container setHeight:heightLevel2];
        
        [[NetManager sharedNetManager] requestSystemInternetStorageData:^(id data, NSError *error) {
            
            if ([[data objectForKey:NETWORK_CONNECT_STATUS] isEqualToString:NETWORK_CONNECTED])
            {
                ipAddressLbl.text = [NSString stringWithFormat:@"%@ : %@",NSLocalizedStringFromTable(@"StorageAddressStr",NULL,@"WiFiDiskUIStrings"),[data objectForKey:Wan_IP_Address_Ipv4]];
            }
            else
            {
                ipAddressLbl.text = [NSString stringWithFormat:@"%@ : %@",NSLocalizedStringFromTable(@"StorageAddressStr",NULL,@"WiFiDiskUIStrings"),NSLocalizedStringFromTable(@"NetWorkDisconnectedStr",NULL,@"WiFiDiskUIStrings")];
            }
            
        }];
    }
    else
    {
        ipAddressLbl.hidden = YES;
        [container setHeight:heightLevel1];
    }
    
    okButton.frame = CGRectMake(DATA_CONTAINER_GAP , container.frame.origin.y + container.frame.size.height + DATA_CONTAINER_GAP, container.frame.size.width, 30);
}
@end
