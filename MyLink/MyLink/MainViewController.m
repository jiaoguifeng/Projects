//
//  MainViewController.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "MainViewController.h"
#import "LBHamburgerButton.h"
#import "VWWWaterView.h"
#import "SettingContainer.h"
#import "TouchButton.h"
#import "BadgeButton.h"

#import "StatusViewController.h"
#import "ConnectionViewController.h"
#import "WiFiDiskViewController.h"
#import "SettingViewController.h"

#import "HttpShareViewController.h"
#import "WiFiCacheViewController.h"
#import "AddComponentsViewController.h"

#import "QuickSetupViewController.h"
#import "MACFilterViewController.h"
#import "WPSViewController.h"
#import "PINMgrViewController.h"

#import "PopView.h"

#import "LoginView.h"
#import "KVNProgress.h"
#import "Utility.h"

#import "NetManager.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MainViewController ()<VWWWaterViewDelegate,TouchButtonDelegate,SettingContainerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    // Setting On/Off
    LBHamburgerButton *settingButton;
    SettingContainer *settintContainer;
    
    // Device status controls
    BadgeButton *wifiUserButton;
    UIImageView *smartfren4GLogo;
    UILabel *operatorNameLabel;
    UIImageView *batteryImageView;
    UIImageView *batteryPercentImageView;
    UILabel *batteryInfoLabel;
    UIImageView *singleImageView;
    UIImageView *wifiStatusImageView;
    UIImageView *wifiStatusImageView5G;
    
    // Connection status control
    VWWWaterView *waterView;
    UILabel *connectionTimeLabel;
    UILabel *connectionVolumeLabel;

    // Four custom TouchButton
    TouchButton *btn1;
    TouchButton *btn2;
    TouchButton *btn3;
    TouchButton *btn4;
    ADD_COMPONENT_INDEX clickedButtonIndex;
    NSMutableArray *fourBtnList;
    
    //
    PopView *popView;
    
    // ViewControllers
    StatusViewController *statusVC;
    ConnectionViewController *connectionVC;
    WiFiDiskViewController *wifiDiskVC;
    SettingViewController *settingVC;
    
    HttpShareViewController *httpShareVC;
    WiFiCacheViewController *wifiCacheVC;
    AddComponentsViewController *addComponentsVC;
    
    QuickSetupViewController *quickSetupVC;
    MACFilterViewController *macFilterVC;
    WPSViewController *wpsVC;
    PINMgrViewController *pinMgrVC;
    
    // mainUI refresh flags
    BOOL refreshOneLoopFinished;
    BOOL isDeviceConnected;
    NSInteger timeOutCount;
    
    //
    BOOL isPINValidateProcessing;
    UIAlertView *pinInputDialog;
    UIAlertView *pukInputDialog;
    UIAlertView *pukLockedDialog;
    
    //
    BOOL isMainVCStatus;
    BOOL isAddComponentStatus;
    BOOL isHttpShareStatus;
    
    //
    NSInteger batteryChargeLevel;
    
    //
    UIImagePickerController *imagePickerController;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[Utility defaultUtility] prepareConfigFiles];
    
    [self initData];
    
    [self setupMainUIControls];
    
    [self addNotifications];
    
    [self initMainUITask];
    
    [self initImageCapture];    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    isMainVCStatus = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    isMainVCStatus = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setting UI On/Off

- (void)settingButtonPressed:(id)sender
{
    [settingButton switchState];
    
    if(settintContainer.isShown)
        [settintContainer hide];
    else
        [settintContainer show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TouchButtonDelegate (TouchButton单击和长按事件处理)

- (void)buttonSinglePressed:(TOUCH_BUTTON_ID)buttonID buttonTag:(ADD_COMPONENT_INDEX)buttonTag
{
    if(TOUCH_BUTTON_NONE == buttonID)
    {
        clickedButtonIndex = buttonTag;
        
        if(addComponentsVC)
            addComponentsVC = nil;
        addComponentsVC = [[AddComponentsViewController alloc] init];
        [self.navigationController pushViewController:addComponentsVC animated:YES];
    }
    else if(buttonID >= TOUCH_BUTTON_LOGINOUT && buttonID <= TOUCH_BUTTON_WPS)  // setting & advancedSetting
    {
        [self handleActionWithButton:buttonID];
    }
    else if(buttonID == TOUCH_BUTTON_MYSMARTFREN)
    {
        //[[Utility defaultUtility] setWiFiMobleConfigFile:@"9303_ap0011" password:@"00000000"];
        
    }
    else if(buttonID == TOUCH_BUTTON_HTTPSHARE)
    {
        if(httpShareVC)
            httpShareVC = nil;
        httpShareVC = [[HttpShareViewController alloc] initWithType:1];
        [self.navigationController pushViewController:httpShareVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_LANCAMERA || buttonID == TOUCH_BUTTON_WANCAMERA)
    {
        [self selectImageFromCamera];
    }
    else if(buttonID == TOUCH_BUTTON_WPSPBCBUTTON || buttonID == TOUCH_BUTTON_WPSPBCBUTTON_5G)
    {
        BAND_TYPE wifiType = BAND_TYPE_24G;
        if(buttonID == TOUCH_BUTTON_WPSPBCBUTTON_5G)
            wifiType = BAND_TYPE_5G;
        
        [[Utility defaultUtility] quickSettingForWPSMode:wifiType];
    }
}

- (void)buttonLongPressed:(TOUCH_BUTTON_ID)buttonID buttonTag:(ADD_COMPONENT_INDEX)buttonTag
{
    if(buttonID != TOUCH_BUTTON_NONE)
    {
        clickedButtonIndex = buttonTag;
        NSDictionary *theDict = [fourBtnList objectAtIndex:clickedButtonIndex];
        
        if(popView)
            popView = nil;
        
        NSArray *buttonList = nil;
        if(buttonID == TOUCH_BUTTON_LANCAMERA)
        {
            buttonList = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"managePhotoCachesStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_MANAGE],@"buttonID", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Remove this component",@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_REMOVE],@"buttonID", nil],[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_CANCEL],@"buttonID", nil],nil];
        }
        else if(buttonID == TOUCH_BUTTON_WANCAMERA)
        {
            buttonList = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"configComponent",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_CONFIG],@"buttonID", nil],[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"managePhotoCachesStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_MANAGE],@"buttonID", nil],[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"removeComponentStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_REMOVE],@"buttonID", nil],[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_CANCEL],@"buttonID", nil],nil];
        }
        else
        {
            buttonList = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"removeComponentStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_REMOVE],@"buttonID", nil],[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_CANCEL],@"buttonID", nil],nil];
        }
        
        NSString *descriptionStr = [theDict objectForKey:@"itemDescription"];
        if(!descriptionStr)
            descriptionStr = [[[[Utility defaultUtility] addComponentConfigList] objectAtIndex:clickedButtonIndex] objectForKey:@"buttonDescription"];
        popView = [[PopView alloc] initWithTitle:descriptionStr buttonList:buttonList];
        [popView showWithcompletion:^(id data, NSError *error) {
            if(data)
            {
                POPVIEW_BUTTON_ID thePopViewButtonID = [[data objectForKey:@"buttonID"] integerValue];
                if(POPVIEW_BUTTON_REMOVE == thePopViewButtonID)
                {
                    switch(clickedButtonIndex)
                    {
                        case ADD_COMPONENT_INDEX_1:
                            btn1.buttonImage = @"plus";
                            btn1.buttonTitle = NSLocalizedStringFromTable(@"clickAddComponentsStr",NULL,@"ButtonStrings");
                            btn1.buttonID = TOUCH_BUTTON_NONE;
                            break;
                        case ADD_COMPONENT_INDEX_2:
                            btn2.buttonImage = @"plus";
                            btn2.buttonTitle = NSLocalizedStringFromTable(@"clickAddComponentsStr",NULL,@"ButtonStrings");
                            btn2.buttonID = TOUCH_BUTTON_NONE;
                            break;
                        case ADD_COMPONENT_INDEX_3:
                            btn3.buttonImage = @"plus";
                            btn3.buttonTitle = NSLocalizedStringFromTable(@"clickAddComponentsStr",NULL,@"ButtonStrings");
                            btn3.buttonID = TOUCH_BUTTON_NONE;
                            break;
                        case ADD_COMPONENT_INDEX_4:
                            btn4.buttonImage = @"plus";
                            btn4.buttonTitle = NSLocalizedStringFromTable(@"clickAddComponentsStr",NULL,@"ButtonStrings");
                            btn4.buttonID = TOUCH_BUTTON_NONE;
                            break;
                        default:
                            break;
                    }
                    
                    //
                    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:@"plus",@"buttonImage",NSLocalizedStringFromTable(@"clickAddComponentsStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:TOUCH_BUTTON_NONE],@"buttonID",[theDict objectForKey:@"itemDescription"],@"buttonDescription", nil];
                    [fourBtnList replaceObjectAtIndex:clickedButtonIndex withObject:tempDict];
                    [[Utility defaultUtility] setAddComponentConfigDictWithIndex:clickedButtonIndex dict:tempDict];
                }
                else if(POPVIEW_BUTTON_MANAGE == thePopViewButtonID)
                {
                    if(!isDeviceConnected)
                    {
                        [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"noDeviceTipsStr",NULL,@"TipStrings")];
                        if(!Debug_Mode)
                            return;
                    }

                    // Manage photo caches
                    if(buttonID == TOUCH_BUTTON_LANCAMERA || buttonID == TOUCH_BUTTON_WANCAMERA)
                    {
                        if(wifiCacheVC)
                            wifiCacheVC = nil;
                        wifiCacheVC = [[WiFiCacheViewController alloc] init];
                        [self.navigationController pushViewController:wifiCacheVC animated:YES];
                    }
                }
                else if(POPVIEW_BUTTON_CONFIG == thePopViewButtonID)
                {
                    // Config this component
                    if(buttonID == TOUCH_BUTTON_WANCAMERA)
                    {
                        if(httpShareVC)
                            httpShareVC = nil;
                        httpShareVC = [[HttpShareViewController alloc] initWithType:0];
                        [self.navigationController pushViewController:httpShareVC animated:YES];
                    }
                }
            }
        }];
    }
}

#pragma mark - Notification (TouchButton添加定制按钮事件处理)

- (void)addComponentNotification:(NSNotification *)notification
{
    [self.navigationController popToViewController:self animated:YES];
    if(addComponentsVC)
        addComponentsVC = nil;
    
    NSDictionary *theDict = [notification userInfo];
    NSInteger touchButtonID = [[theDict objectForKey:@"itemButtonID"] integerValue];
    NSString *touchButtonImage = [theDict objectForKey:@"itemButtonImage"];
    NSString *touchButtonTitle = [theDict objectForKey:@"itemTitle"];
    NSString *touchButtonDescription = [theDict objectForKey:@"itemDescription"];
    
    if(clickedButtonIndex == ADD_COMPONENT_INDEX_1)
    {
        btn1.buttonImage = touchButtonImage;
        btn1.buttonID = touchButtonID;
        btn1.buttonTitle = touchButtonTitle;
    }
    else if(clickedButtonIndex == ADD_COMPONENT_INDEX_2)
    {
        btn2.buttonImage = touchButtonImage;
        btn2.buttonID = touchButtonID;
        btn2.buttonTitle = touchButtonTitle;
    }
    else if(clickedButtonIndex == ADD_COMPONENT_INDEX_3)
    {
        btn3.buttonImage = touchButtonImage;
        btn3.buttonID = touchButtonID;
        btn3.buttonTitle = touchButtonTitle;
    }
    else if(clickedButtonIndex == ADD_COMPONENT_INDEX_4)
    {
        btn4.buttonImage = touchButtonImage;
        btn4.buttonID = touchButtonID;
        btn4.buttonTitle = touchButtonTitle;
    }
    
    //
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:touchButtonImage,@"buttonImage",touchButtonTitle,@"buttonTitle",[NSNumber numberWithInteger:touchButtonID],@"buttonID",touchButtonDescription,@"buttonDescription", nil];
    [fourBtnList replaceObjectAtIndex:clickedButtonIndex withObject:tempDict];
    [[Utility defaultUtility] setAddComponentConfigDictWithIndex:clickedButtonIndex dict:tempDict];
}

- (void)addComponentStatusNotification:(NSNotification *)notification
{
    NSDictionary *infoDict = [notification userInfo];
    if([[infoDict objectForKey:@"addComponentStatus"] boolValue])
        isAddComponentStatus = YES;
    else
        isAddComponentStatus = NO;
}

- (void)settingSheetDisappearNotification:(NSNotification *)notification
{
    [self settingButtonPressed:nil];
}

- (void)httpShareStatusNotification:(NSNotification *)notification
{
    NSDictionary *infoDict = [notification userInfo];
    if([[infoDict objectForKey:@"httpShareStatus"] boolValue])
        isHttpShareStatus = YES;
    else
        isHttpShareStatus = NO;
}

#pragma mark - SettingContainerDelegate (Setting进入子界面按钮点击按钮事件处理)

- (void)settingContainerAction:(TOUCH_BUTTON_ID)buttonID
{
    if(settintContainer.isShown)
    {
        [settintContainer hide];
        [settingButton switchState];
    }

    [self handleActionWithButton:buttonID];
}

#pragma mark - VWWWaterViewDelegate (Goto Connection)

- (void)waterViewClicked
{
    [self handleActionWithButton:TOUCH_BUTTON_CONNECTION];
}

#pragma mark - WiFi User button action (Goto UserList)

- (void)wifiUserListClicked:(id)sender
{
    [self handleActionWithButton:TOUCH_BUTTON_WIFIUSERS];
}

#pragma mark - ViewController switch function

- (void)handleActionWithButton:(TOUCH_BUTTON_ID)buttonID
{
    if(!isDeviceConnected)
    {
        [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"noDeviceTipsStr",NULL,@"TipStrings")];
        if(!Debug_Mode)
            return;
    }
    
    if(buttonID == TOUCH_BUTTON_LOGINOUT)
    {
        BOOL loginStatus = [[NetManager sharedNetManager] isLoginStatus];
        if(loginStatus)
        {
            [[NetManager sharedNetManager] logout];
        }
        else
        {
            LoginView *logView = [[LoginView alloc] init];
            [logView showWithcompletion:^(id data, NSError *error) {
                NSDictionary *shareDict = data;
                if(shareDict)
                {
                }
            }];
        }
    }
    else
    {
        if(Need_Login)
        {
            if(![[NetManager sharedNetManager] isLoginStatus])
            {
                LoginView *logView = [[LoginView alloc] init];
                [logView showWithcompletion:^(id data, NSError *error) {
                    NSDictionary *shareDict = data;
                    if(shareDict)
                    {
                        [self hadLoginAndHandleAction:buttonID];
                    }
                }];
            }
            else
            {
                [self hadLoginAndHandleAction:buttonID];
            }
        }
        else
            [self hadLoginAndHandleAction:buttonID];
    }
}

- (void)hadLoginAndHandleAction:(TOUCH_BUTTON_ID)buttonID
{
    if(buttonID == TOUCH_BUTTON_STATUS)
    {
        if(statusVC)
            statusVC = nil;
        statusVC = [[StatusViewController alloc] init];
        [self.navigationController pushViewController:statusVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_CONNECTION)
    {
        if ([[Utility defaultUtility] currentModemStatus] == NO)
        {
            return;
        }

        if(connectionVC)
            connectionVC = nil;
        connectionVC = [[ConnectionViewController alloc] init];
        [self.navigationController pushViewController:connectionVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_WIFIDISK)
    {
        if(wifiDiskVC)
            wifiDiskVC = nil;
        wifiDiskVC = [[WiFiDiskViewController alloc] init];
        [self.navigationController pushViewController:wifiDiskVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_SETTING)
    {
        if(settingVC)
            settingVC = nil;
        settingVC = [[SettingViewController alloc] init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_QUICKSETTING)
    {
        if(quickSetupVC)
            quickSetupVC = nil;
        quickSetupVC = [[QuickSetupViewController alloc] init];
        [self.navigationController pushViewController:quickSetupVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_ADVANCEDAETTING)
    {
    }
    else if(buttonID == TOUCH_BUTTON_MACFILTER_24G)
    {
        if(macFilterVC)
            macFilterVC = nil;
        macFilterVC = [[MACFilterViewController alloc] initWithType:BAND_TYPE_24G];
        [self.navigationController pushViewController:macFilterVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_MACFILTER_5G)
    {
        if(macFilterVC)
            macFilterVC = nil;
        macFilterVC = [[MACFilterViewController alloc] initWithType:BAND_TYPE_5G];
        [self.navigationController pushViewController:macFilterVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_PINSETTING)
    {
        if(pinMgrVC)
            pinMgrVC = nil;
        pinMgrVC = [[PINMgrViewController alloc] init];
        [self.navigationController pushViewController:pinMgrVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_WPS)
    {
        if(wpsVC)
            wpsVC = nil;
        wpsVC = [[WPSViewController alloc] initWithType:BAND_TYPE_24G];
        [wpsVC setTitleText:NSLocalizedStringFromTable(@"24GWPSStr",NULL,@"WiFiUIStrings")];
        [self.navigationController pushViewController:wpsVC animated:YES];
    }
    else if(buttonID == TOUCH_BUTTON_WIFIUSERS)
    {
        if(statusVC)
            statusVC = nil;
        statusVC = [[StatusViewController alloc] init];
        [self.navigationController pushViewController:statusVC animated:YES];
    }
}

#pragma mark - MainUI Refresh Task

- (void)initMainUITask
{
    /*
     确保只有一个PIN码输入验证过程
     */
    isPINValidateProcessing = NO;
    
    /*
     mainUI刷新线程数据请求锁(当次数据请求没有完成时，忽略下次数据请求)
     */
    refreshOneLoopFinished = YES;
    
    /*
     mainUI刷新线程设置isDeviceConnected，后续mainUI状态刷新判断有无设备时用此变量(无需再次向服务器请求数据)
     */
    isDeviceConnected = NO;
    
    /*
     启动mainUI刷新线程
     */
    if(!Debug_Mode)
        [NSThread detachNewThreadSelector:@selector(mainUIRefresh:) toTarget:self withObject:nil];
}

/*
 主UI刷新线程,刷新条件:
 1.iOS设备通过WiFi连接网络
 2.连接到到的设备是我们的设备
 3.上次刷新已经结束
 */
- (void)mainUIRefresh:(id)sender
{
    timeOutCount = 0;
    
    while(YES)
    {
        @autoreleasepool
        {
            NSLog(@"====================================================");
            NSLog(@"Refresh-Loop: loop begin");
            
            if([[NetManager sharedNetManager] isConnectedViaWiFi])    // 1
            {
                NSLog(@"Refresh-Loop: WiFi connection ok");
                
                if([[NetManager sharedNetManager] hostServerConnected]) // 2
                {
                    NSLog(@"Refresh-Loop: host server connected");
                    isDeviceConnected = YES;
                    
                    NSString *pinStatus = [[NetManager sharedNetManager] pinStatus];
                    
                    if([pinStatus isEqualToString:@"need_pin"] || [pinStatus isEqualToString:@"need_puk"] || [pinStatus isEqualToString:@"puk_lock"])
                    {
                        if(!isMainVCStatus)
                            [self performSelectorOnMainThread:@selector(switchToMainUI:) withObject:nil waitUntilDone:YES];
                        
                        NSLog(@"Refresh-Loop: need input PIN");
                        if(isPINValidateProcessing == NO)
                        {
                            isPINValidateProcessing = YES;
                            if([pinStatus isEqualToString:@"puk_lock"])
                            {
                                NSLog(@"Refresh-Loop: puk locked");
                                [self performSelectorOnMainThread:@selector(pukLockedAlert:) withObject:nil waitUntilDone:YES];
                            }
                            else if([pinStatus isEqualToString:@"need_puk"])
                            {
                                NSLog(@"Refresh-Loop: enter PUK validate process");
                                [self performSelectorOnMainThread:@selector(pukValidateDialog:) withObject:nil waitUntilDone:YES];
                            }
                            else if([pinStatus isEqualToString:@"need_pin"])
                            {
                                NSLog(@"Refresh-Loop: enter PIN validate process");
                                [self performSelectorOnMainThread:@selector(pinValidateDialog:) withObject:nil waitUntilDone:YES];
                            }
                        }
                        else
                        {
                            NSLog(@"Refresh-Loop: PIN validate is processing, skip this loop");
                        }
                    }
                    else
                    {
                        [self logInOutStatus];
                        
                        if(refreshOneLoopFinished)  // 3
                        {
                            refreshOneLoopFinished = NO;
                            
                            NSLog(@"Refresh-Loop: request start");
                            [[NetManager sharedNetManager] requesetMainUIData:^(id data, NSError *error) {
                                [self performSelectorOnMainThread:@selector(updateMainUIStatus:) withObject:data waitUntilDone:YES];
                            }];
                        }
                        else
                        {
                            NSLog(@"Refresh-Loop: last loop processing is not finished, do nothing and skip");
                        }
                    }
                }
                else
                {
                    NSLog(@"Refresh-Loop: host server cannot be connected");
                    
                    isDeviceConnected = NO;
                    [self performSelectorOnMainThread:@selector(updateMainUIStatus:) withObject:nil waitUntilDone:YES];
                }
            }
            else
            {
                NSLog(@"Refresh-Loop: WiFi connection lost");
                
                // device lost, reset login status
                [[NetManager sharedNetManager] logout];
                [self logInOutStatus];
                
                refreshOneLoopFinished = YES;
                isDeviceConnected = NO;
                [self performSelectorOnMainThread:@selector(updateMainUIStatus:) withObject:nil waitUntilDone:YES];
            }
            
            if(NO == isDeviceConnected && NO == isMainVCStatus && NO == isAddComponentStatus && NO == isHttpShareStatus)
            {
                NSLog(@"Refresh-Loop: device lost and current UI is not MainViewController, switch to it");
                [self performSelectorOnMainThread:@selector(switchToMainUI:) withObject:nil waitUntilDone:YES];
            }
            
            NSLog(@"Refresh-Loop: loop end");
            
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}

- (void)updateMainUIStatus:(id)data
{
    NSLog(@"Refresh-Loop: update mainUI start");
    
    if(data)
    {
        NSLog(@"Refresh-Loop: data returned from server");
        NSDictionary *dataDict = (NSDictionary *)data;
        [self setControlValues:dataDict];
    }
    else
    {
        // set empty values
        [self setControlValues:nil];
    }
    
    NSLog(@"Refresh-Loop: update mainUI end");
    refreshOneLoopFinished = YES;
}

- (void)setControlValues:(NSDictionary *)dict
{
    BOOL toHideControls = YES;
    if(dict)
    {
        toHideControls = NO;
        
        // wifi user number
        [wifiUserButton setBadgeNumber:[[dict objectForKey:WIFI_USER_NUM] integerValue]];
        
        // 2.4G wifi switch
        wifiStatusImageView.image = [UIImage imageNamed:@"wifiStatus"];
        BOOL is24GWiFiEnable = [[dict objectForKey:WiFi_Enable_2G] isEqualToString:@"1"] ? YES : NO;
        if(!is24GWiFiEnable)
            wifiStatusImageView.image = [UIImage imageNamed:@"wifiStatusDisable"];;

        // 5G wifi switch
        wifiStatusImageView5G.image = [UIImage imageNamed:@"wifiStatus5"];
        BOOL is5GWiFiEnable = [[dict objectForKey:WiFi_Enable_5G] isEqualToString:@"1"] ? YES : NO;
        if(!is5GWiFiEnable)
            wifiStatusImageView5G.image = [UIImage imageNamed:@"wifiStatus5Disable"];
        
        // battery
        NSString *batteryStatusStr = [dict objectForKey:BATTERT_STATUS];
        NSString *batteryStatusPercentStr = [dict objectForKey:BATTERT_STATUS_PERCENT];
        if([batteryStatusStr isEqualToString:@"ac"] || [batteryStatusStr isEqualToString:@"usb"])
        {
            batteryPercentImageView.image = nil;
            
            // battery image
            if(batteryChargeLevel == 4)
                batteryChargeLevel = 0;
            
            if(batteryChargeLevel == 0)
                batteryImageView.image = [UIImage imageNamed:@"battery0"];
            else if(batteryChargeLevel == 1)
                batteryImageView.image = [UIImage imageNamed:@"battery30"];
            else if(batteryChargeLevel == 2)
                batteryImageView.image = [UIImage imageNamed:@"battery60"];
            else if(batteryChargeLevel == 3)
                batteryImageView.image = [UIImage imageNamed:@"battery"];
            
            batteryChargeLevel++;
            
            // battery percent
            batteryInfoLabel.text = [NSString stringWithFormat:@"%@%%",batteryStatusPercentStr];
        }
        else if([batteryStatusStr isEqualToString:@"err"])
        {
            batteryInfoLabel.text = @"";
            batteryImageView.image = [UIImage imageNamed:@"battery0"];
            batteryPercentImageView.image = nil;
        }
        else
        {
            // battery percent
            batteryInfoLabel.text = @"";
            
            // battery image
            batteryChargeLevel = 0;
            batteryImageView.image = [UIImage imageNamed:@"battery0"];
            batteryPercentImageView.image = [UIImage imageNamed:@"batteryPercent"];

            batteryPercentImageView.frame = batteryImageView.frame;
            if(![batteryStatusStr isEqualToString:@"full"])
            {
                CGRect thePercentRect = batteryImageView.frame;
                thePercentRect.size.width = (thePercentRect.size.width-1)*([batteryStatusPercentStr intValue]/100.0);
                batteryPercentImageView.frame = thePercentRect;
            }
            else
            {
                batteryInfoLabel.text = @"100%";
                batteryImageView.image = [UIImage imageNamed:@"battery"];
                batteryPercentImageView.image = nil;
            }
        }
        
        // sim card status
        BOOL hasSIMCard = ([[dict objectForKey:MODEM_STATUS] isEqualToString:@"no_simcard"] ? NO : YES);
        if(!hasSIMCard)
            singleImageView.image = [UIImage imageNamed:@"noUSIM"];
        else
        {
            // signal strength
            // operator name
            if([[dict objectForKey:MODEM_STATUS] isEqualToString:@"sim_ready"] && ![[dict objectForKey:NETWORK_TYPE] isEqualToString:@"no_service"])
            {
                NSString *signalImageName = [NSString stringWithFormat:@"signalStrength%@",[dict objectForKey:SIGNAL_STRENGTH]];
                singleImageView.image = [UIImage imageNamed:signalImageName];
                operatorNameLabel.text = [dict objectForKey:OPERATOR_NAME];
            }
            else
            {
                singleImageView.image = [UIImage imageNamed:@"signalStrength0"];
                operatorNameLabel.text = @"";
            }
        }
        
        // connection time
        int connectTimes = [[dict objectForKey:Network_Connect_Time] intValue];
        //connectionTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",connectTimes/3600,(connectTimes%3600)/60, connectTimes%60];

        // network connection status
        NSString *networkConnectionStatus = [dict objectForKey:NETWORK_CONNECT_STATUS];
        if([networkConnectionStatus isEqualToString:NETWORK_CONNECTED])
        {
            waterView.isNeedAnimation = YES;
            connectionTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",connectTimes/3600,(connectTimes%3600)/60, connectTimes%60];
        }
        else
        {
            waterView.isNeedAnimation = NO;
            connectionTimeLabel.text = @"00:00:00";
        }

        // connection volume
        NSString *transmitStr = [[[dict objectForKey:Network_Connect_Transmitted] componentsSeparatedByString:@","] objectAtIndex:0];
        NSString *receivedStr = [[[dict objectForKey:Network_Connect_Received] componentsSeparatedByString:@","] objectAtIndex:0];
        long long sizeNum = [transmitStr longLongValue] + [receivedStr longLongValue];
        connectionVolumeLabel.text = [NSByteCountFormatter stringFromByteCount:sizeNum countStyle:NSByteCountFormatterCountStyleFile];
    }
    else
    {
        [wifiUserButton setBadgeNumber:0];
        
        connectionVolumeLabel.text = NSLocalizedStringFromTable(@"mainUINoDeviceStr",NULL,@"MainUIStrings");
        
        waterView.isNeedAnimation = NO;
    }
    
    smartfren4GLogo.hidden = toHideControls;
    operatorNameLabel.hidden = toHideControls;
    batteryImageView.hidden = toHideControls;
    batteryPercentImageView.hidden = toHideControls;
    batteryInfoLabel.hidden = toHideControls;
    singleImageView.hidden = toHideControls;
    wifiStatusImageView.hidden = toHideControls;
    wifiStatusImageView5G.hidden = toHideControls;
    connectionTimeLabel.hidden = toHideControls;
}

- (void)switchToMainUI:(id)sender
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)logInOutStatus
{
    timeOutCount++;
    BOOL loginStatus = [[NetManager sharedNetManager] isLoginStatus];
    if(loginStatus)
    {
        [[NetManager sharedNetManager] resetAppTimer];
        
        if((timeOutCount%5 == 2)) // if app is timeout
        {
            BOOL isTimeOut = [[NetManager sharedNetManager] isLoginTimeout];
            if(YES == isTimeOut)
            {
                //logout
                [[NetManager sharedNetManager] logout];
            }
        }
        if((timeOutCount%3 == 1)) //app session is viald
        {
            BOOL isAppSessionIsValid = [[NetManager sharedNetManager] isLoginSessionValid];
            if(NO == isAppSessionIsValid)
            {
                //logout
                [[NetManager sharedNetManager] logout];
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(updateSettingLoginStatus:) withObject:[NSNumber numberWithBool:loginStatus] waitUntilDone:YES];
}

- (void)updateSettingLoginStatus:(id)sender
{
    BOOL loginStatus = [sender boolValue];
    
    //
    [settintContainer setLoginButtonStatus:loginStatus];
    
    //
    NSDictionary *tempDict = nil;
    int i = 0;
    NSString *btnStr = @"";
    for(i = 0; i < [fourBtnList count]; i++)
    {
        tempDict = [fourBtnList objectAtIndex:i];
        NSNumber *buttonIDNumber = [tempDict objectForKey:@"buttonID"];
        if(buttonIDNumber && [buttonIDNumber integerValue] == TOUCH_BUTTON_LOGINOUT)
        {
            btnStr = NSLocalizedStringFromTable(@"loginStr",NULL,@"SettingMainUIStrings");
            if(loginStatus)
                btnStr = NSLocalizedStringFromTable(@"logoutStr",NULL,@"SettingMainUIStrings");
            break;
        }
    }
    
    switch(i)
    {
        case ADD_COMPONENT_INDEX_1:
            btn1.buttonTitle = btnStr;
            break;
        case ADD_COMPONENT_INDEX_2:
            btn2.buttonTitle = btnStr;
            break;
        case ADD_COMPONENT_INDEX_3:
            btn3.buttonTitle = btnStr;
            break;
        case ADD_COMPONENT_INDEX_4:
            btn4.buttonTitle = btnStr;
            break;
        default:
            break;
    }
}

#pragma mark - PIN/PUK Validate functions

- (void)pinValidateDialog:(id)sender
{
    int retainTimes = [[[[NetManager sharedNetManager] retainTimeOfPinPuk] objectForKey:SIM_PIN_Remain_Num] intValue];
    NSString *retainStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"pinInputSubStr",NULL,@"PINInputStrings"),retainTimes];
    pinInputDialog = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"pinInputStr",NULL,@"PINInputStrings")
                                                message:retainStr
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    pinInputDialog.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [pinInputDialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [pinInputDialog textFieldAtIndex:0].placeholder = NSLocalizedStringFromTable(@"pinInputFieldTipStr",NULL,@"PINInputStrings");
    pukInputDialog.tag = 0;
    [pinInputDialog show];
}

- (void)pukValidateDialog:(id)sender
{
    int retainTimes = [[[[NetManager sharedNetManager] retainTimeOfPinPuk] objectForKey:SIM_PUK_Remain_Num] intValue];
    NSString *retainStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"pinInputSubStr",NULL,@"PINInputStrings"),retainTimes];
    pukInputDialog = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"pukInputStr",NULL,@"PINInputStrings")
                                                message:retainStr
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings")
                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    pukInputDialog.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [pukInputDialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [pukInputDialog textFieldAtIndex:0].placeholder = NSLocalizedStringFromTable(@"pukInputFieldTipStr",NULL,@"PINInputStrings");
    pukInputDialog.tag = 1;
    [pukInputDialog show];
}

- (void)pukLockedAlert:(id)sender
{
    pukLockedDialog = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"pukLockedStr",NULL,@"TipStrings")
                                                message:@""
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
    pukLockedDialog.tag = 2;
    [pukLockedDialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 1) //OK
    {
        NSString *pinStr = [[alertView textFieldAtIndex:0] text];
        //[[Utility defaultUtility] hudShowWithTitle:NSLocalizedStringFromTable(@"processingStr",NULL,@"TipStrings")];
        
        if(alertView.tag == 0) // unlock pin
            [self performSelectorOnMainThread:@selector(unlockPIN:) withObject:pinStr waitUntilDone:YES];
        else if(alertView.tag == 1)
            [self performSelectorOnMainThread:@selector(unlockPUK:) withObject:pinStr waitUntilDone:YES];
        else if(alertView.tag == 2)
            ;
    }
    else
    {
        isPINValidateProcessing = NO;
    }
}

- (void)unlockPIN:(id)sender
{
    NSString *pinStr = sender;
    if(pinStr.length < 4 || pinStr.length > 8)
    {
        isPINValidateProcessing = NO;
        return;
    }

    // current pin is locked, unlock it
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_PIN_Unlock,URL_CONFIG_ID,
                                 pinStr,SIM_PIN_Num,nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@"" forView:self.view];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            BOOL unlockSuccess = NO;
            if(unlockSuccess)
                isPINValidateProcessing = YES;
            else
            {
                isPINValidateProcessing = NO;
            }
        }
        
        [[Utility defaultUtility] hudClose];
    }];
}

- (void)unlockPUK:(id)sender
{
    NSString *pukStr = sender;
    if(pukStr.length != 8)
    {
        isPINValidateProcessing = NO;
        return;
    }

    // current puk is locked, unlock it
    NSDictionary *configDict =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 Config_PUK_Unlock,URL_CONFIG_ID,
                                 @"1234",SIM_PIN_Num,
                                 pukStr,SIM_PUK_Num,nil];
    
    [[Utility defaultUtility] hudShowWithTitle:@"" forView:self.view];
    [[NetManager sharedNetManager] configDataWithParam:configDict andBlock:^(id data, NSError *error) {
        if(data)
        {
            [[Utility defaultUtility] hudClose];

            NSString *result = [data objectForKey:@"result"];
            if([result isEqualToString:@"success"])
            {
                isPINValidateProcessing = YES;
                
                UIAlertView *defaultPINAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"defaultPINSetStr",NULL,@"TipStrings")
                                                                          message:@""
                                                                         delegate:self
                                                                cancelButtonTitle:nil
                                                                otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                [defaultPINAlert show];

            }
            else
            {
                isPINValidateProcessing = NO;
            }
        }
    }];
}

#pragma mark - Image Capture & Upload & Cache

- (void)initImageCapture
{
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePickerController.allowsEditing = NO;
}

- (void)selectImageFromCamera
{
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    int pickerType = [[Utility defaultUtility] isPrivateKeyOpenedAtIndex:0] ? 1 : 0;  // 0:image 1:image/movie
    if(pickerType == 0)
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    else
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
    
    //视频上传质量
    //medium quality, suitable for transmission via Wi-Fi
    imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    
    //设置摄像头模式（拍照，录制视频）
    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        NSData *fileData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 1.0);
        
        [self uploadFileToWiFiDisk:fileData fileType:@"image"];
    }
    else if([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSData *fileData = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        
        [self uploadFileToWiFiDisk:fileData fileType:@"movie"];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadFileToWiFiDisk:(NSData *)fileData fileType:(NSString *)fileType
{
    if(fileData)
    {
        // Save image to cache directory
        NSString *fileCachePath = @"";
        if([fileType isEqualToString:@"image"])
            fileCachePath = [NSString stringWithFormat:@"%@%@.JPG",[[Utility defaultUtility] wifiPhotosPath],[[Utility defaultUtility] currentDateAndTime]];
        else
            fileCachePath = [NSString stringWithFormat:@"%@%@.MOV",[[Utility defaultUtility] wifiPhotosPath],[[Utility defaultUtility] currentDateAndTime]];
        
        if([fileData writeToFile:fileCachePath atomically:YES])
        {
            if(!isDeviceConnected)
            {
                // no device, keep cache file
                [self storeFileToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length fileType:fileType];
            }
            else
            {
                NSDictionary *sdInfo = [[NetManager sharedNetManager] querySDStatus];
                if(sdInfo)
                {
                    NSString *sdInfoStr = [sdInfo objectForKey:SD_Card_Status];
                    if([sdInfoStr isEqualToString:@"s_s_enabled"])
                    {
                        // Upload image to WiFi disk when sd card is avaiable
                        NSString *folderName = @"WIFIPhotos";
                        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:folderName,@"folderName",@"/",@"currentDir",nil];
                        [[NetManager sharedNetManager] createNewFolder:tempDict andBlock:^(id data, id error) {
                            if(data)
                            {
                                [[NetManager sharedNetManager] uploadImageToDisk:folderName srcFilePath:fileCachePath andBlock:^(id data, NSError *error) {
                                    if(data)
                                    {
                                        // upload success, remove cache file
                                        if([[NSFileManager defaultManager] fileExistsAtPath:fileCachePath])
                                            [[NSFileManager defaultManager] removeItemAtPath:fileCachePath error:nil];
                                        
                                        [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"wifiPhotoUploadSuccess",NULL,@"TipStrings")];
                                    }
                                    else
                                    {
                                        // upload failed, keep cache file
                                        [self storeFileToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length fileType:fileType];
                                    }
                                }];
                            }
                            else
                            {
                                // "WiFiPhotos" folder create failed, keep cache file
                                [self storeFileToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length fileType:fileType];
                            }
                        }];
                    }
                    else
                    {
                        // sd card is not ready, keep cache file
                        [self storeFileToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length fileType:fileType];
                    }
                }
                else
                {
                    // sd card is not ready, keep cache file
                    [self storeFileToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length fileType:fileType];
                }
            }
        }
    }
}

- (void)storeFileToWiFiPhotoCache:(NSString *)fileName fileSize:(NSInteger)fileSize fileType:(NSString *)fileType
{
    NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              fileName,@"fileName",
                              [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile],@"fileSize",
                              [NSNumber numberWithBool:NO],@"isSelected",
                              [NSNumber numberWithBool:NO],@"isProcessing",
                              [NSNumber numberWithBool:NO],@"isUploadFinished",nil];
    [[Utility defaultUtility] addToWifiPhotosList:fileDict];
    
    if([fileType isEqualToString:@"image"])
        [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"wifiPhotoUploadFailed",NULL,@"TipStrings") withTimeInterval:3.0];
    else
        [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"wifiMovieUploadFailed",NULL,@"TipStrings") withTimeInterval:3.0];
}
/*
- (void)uploadImageToWiFiDisk:(NSData *)fileData
{
    if(fileData)
    {
        // Save image to cache directory
        NSString *fileCachePath = [NSString stringWithFormat:@"%@%@.JPG",[[Utility defaultUtility] wifiPhotosPath],[[Utility defaultUtility] currentDateAndTime]];
        if([fileData writeToFile:fileCachePath atomically:YES])
        {
            if(!isDeviceConnected)
            {
                // no device, keep cache file
                [self storeImageToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length];
            }
            else
            {
                NSDictionary *sdInfo = [[NetManager sharedNetManager] querySDStatus];
                if(sdInfo)
                {
                    NSString *sdInfoStr = [sdInfo objectForKey:SD_Card_Status];
                    if([sdInfoStr isEqualToString:@"s_s_enabled"])
                    {
                        // Upload image to WiFi disk when sd card is avaiable
                        NSString *folderName = @"WIFIPhotos";
                        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:folderName,@"folderName",@"/",@"currentDir",nil];
                        [[NetManager sharedNetManager] createNewFolder:tempDict andBlock:^(id data, id error) {
                            if(data)
                            {
                                [[NetManager sharedNetManager] uploadImageToDisk:folderName srcFilePath:fileCachePath andBlock:^(id data, NSError *error) {
                                    if(data)
                                    {
                                        // upload success, remove cache file
                                        if([[NSFileManager defaultManager] fileExistsAtPath:fileCachePath])
                                            [[NSFileManager defaultManager] removeItemAtPath:fileCachePath error:nil];

                                        [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"wifiPhotoUploadSuccess",NULL,@"TipStrings")];
                                    }
                                    else
                                    {
                                        // upload failed, keep cache file
                                        [self storeImageToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length];
                                    }
                                }];
                            }
                            else
                            {
                                // "WiFiPhotos" folder create failed, keep cache file
                                [self storeImageToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length];
                            }
                        }];
                    }
                    else
                    {
                        // sd card is not ready, keep cache file
                        [self storeImageToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length];
                    }
                }
                else
                {
                    // sd card is not ready, keep cache file
                    [self storeImageToWiFiPhotoCache:[fileCachePath lastPathComponent] fileSize:fileData.length];
                }
            }
        }
    }
}

- (void)storeImageToWiFiPhotoCache:(NSString *)fileName fileSize:(NSInteger)fileSize
{
    NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              fileName,@"fileName",
                              [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile],@"fileSize",
                              [NSNumber numberWithBool:NO],@"isSelected",
                              [NSNumber numberWithBool:NO],@"isProcessing",
                              [NSNumber numberWithBool:NO],@"isUploadFinished",nil];
    [[Utility defaultUtility] addToWifiPhotosList:fileDict];
    [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"wifiPhotoUploadFailed",NULL,@"TipStrings") withTimeInterval:3.0];
}
*/
#pragma mark - UI setup function

- (void)setupMainUIControls
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //
    BOOL is35Screen = NO;
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    // 5.5-inch:414*736; 4.7-inch:375*667; 4-inch:320*568; 3.5-inch:320*480
    // iPad:768*1024
    if(screenWidth == 320 && screenHeight == 480)
        is35Screen = YES;
    
    // ----------------------------------------------------------------------------------------
    // debug flag
    BOOL needControlBGColor = NO;
    
    // ----------------------------------------------------------------------------------------
    // setup background image
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backImageView.contentMode = UIViewContentModeScaleAspectFill;
    backImageView.image = [UIImage imageNamed:@"MainViewBG"];
    [self.view addSubview:backImageView];
    
    // ----------------------------------------------------------------------------------------
    // setup setting button
    settingButton = [[LBHamburgerButton alloc] initWithFrame:CGRectMake(5, 20, 50, 50)
                                           withHamburgerType:LBHamburgerButtonTypeBackButton
                                                   lineWidth:20
                                                  lineHeight:20/6
                                                 lineSpacing:2
                                                  lineCenter:CGPointMake(15, 25)
                                                       color:[UIColor whiteColor]];
    //[settingButton setCenter:CGPointMake(settingButton.center.x, settingButton.center.y + 120)];
    //[settingButton setBackgroundColor:[UIColor blackColor]];
    [settingButton addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingButton];
    
    // ----------------------------------------------------------------------------------------
    // setup main title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, 20, 200, 50)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if(needControlBGColor)
        titleLabel.backgroundColor = [UIColor grayColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedStringFromTable(@"mainUITitleStr",NULL,@"MainUIStrings");
    titleLabel.font = [UIFont boldSystemFontOfSize:26];
    [self.view addSubview:titleLabel];
    
    // ----------------------------------------------------------------------------------------
    // WiFi User button
    wifiUserButton = [[BadgeButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 40 - 5, 25, 40, 40)];
    [wifiUserButton setImage:[UIImage imageNamed:@"usrs"] forState:UIControlStateNormal];
    [wifiUserButton addTarget:self action:@selector(wifiUserListClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wifiUserButton];
    
    // ----------------------------------------------------------------------------------------
    // Device status control y
    float startY = titleLabel.frame.origin.y + titleLabel.frame.size.height + 5;
    float gapX = 5;
    
    // ----------------------------------------------------------------------------------------
    // smartfren 4G LTE logo
    smartfren4GLogo = [[UIImageView alloc] initWithFrame:CGRectMake(gapX, startY, 100, 15)];
    smartfren4GLogo.contentMode = UIViewContentModeScaleAspectFit;
    if(needControlBGColor)
        smartfren4GLogo.backgroundColor = [UIColor grayColor];
    smartfren4GLogo.image = [UIImage imageNamed:@"smartfren4gLTE"];
    [self.view addSubview:smartfren4GLogo];

    // ----------------------------------------------------------------------------------------
    // wifi status imageView
    float wifiStatusWidth = 31;
    wifiStatusImageView5G = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - wifiStatusWidth, startY-5, wifiStatusWidth, 20)];
    wifiStatusImageView5G.contentMode = UIViewContentModeScaleAspectFit;
    if(needControlBGColor)
        wifiStatusImageView5G.backgroundColor = [UIColor grayColor];
    wifiStatusImageView5G.image = [UIImage imageNamed:@"wifiStatus"];
    [self.view addSubview:wifiStatusImageView5G];

    wifiStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(wifiStatusImageView5G.frame.origin.x - wifiStatusWidth, startY-5, wifiStatusWidth, 20)];
    wifiStatusImageView.contentMode = UIViewContentModeScaleAspectFit;
    if(needControlBGColor)
        wifiStatusImageView.backgroundColor = [UIColor grayColor];
    wifiStatusImageView.image = [UIImage imageNamed:@"wifiStatus"];
    [self.view addSubview:wifiStatusImageView];

    // ----------------------------------------------------------------------------------------
    // signal imageView
    float singleWidth = 30;
    singleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(wifiStatusImageView.frame.origin.x - singleWidth - gapX, startY, singleWidth, 15)];
    singleImageView.contentMode = UIViewContentModeScaleAspectFit;
    if(needControlBGColor)
        singleImageView.backgroundColor = [UIColor grayColor];
    singleImageView.image = [UIImage imageNamed:@"signalStrength5"];
    [self.view addSubview:singleImageView];

    // ----------------------------------------------------------------------------------------
    // battery imageView
    float batteryWidth = 30;
    batteryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(singleImageView.frame.origin.x - batteryWidth - gapX, startY, batteryWidth, 15)];
    batteryImageView.contentMode = UIViewContentModeScaleAspectFit;
    if(needControlBGColor)
        batteryImageView.backgroundColor = [UIColor grayColor];
    batteryImageView.image = [UIImage imageNamed:@"battery0"];
    [self.view addSubview:batteryImageView];
    
    // ----------------------------------------------------------------------------------------
    // battery precent imageView
    batteryPercentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(singleImageView.frame.origin.x - batteryWidth - gapX, startY, batteryWidth, 15)];
    batteryPercentImageView.contentMode = UIViewContentModeScaleToFill;
    if(needControlBGColor)
        batteryPercentImageView.backgroundColor = [UIColor grayColor];
    batteryPercentImageView.image = [UIImage imageNamed:@"battery"];
    [self.view addSubview:batteryPercentImageView];
    
    // ----------------------------------------------------------------------------------------
    // battery info label button
    batteryInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, batteryWidth, 15)];
    batteryInfoLabel.textColor = [UIColor orangeColor];
    batteryInfoLabel.font = [UIFont boldSystemFontOfSize:10.0];
    batteryInfoLabel.textAlignment = NSTextAlignmentCenter;
    batteryInfoLabel.text = @"";
    [batteryPercentImageView addSubview:batteryInfoLabel];

    // ----------------------------------------------------------------------------------------
    // operator name label
    float operatorWidth = 100;
    operatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(batteryImageView.frame.origin.x - operatorWidth - gapX, startY, operatorWidth, 15)];
    operatorNameLabel.textColor = [UIColor whiteColor];
    if(needControlBGColor)
        operatorNameLabel.backgroundColor = [UIColor grayColor];
    operatorNameLabel.font = [UIFont boldSystemFontOfSize:12];
    operatorNameLabel.textAlignment = NSTextAlignmentRight;
    operatorNameLabel.text = @"";
    [self.view addSubview:operatorNameLabel];

    // ----------------------------------------------------------------------------------------
    // Touch button init
    
    NSArray *touchButtonList = [[Utility defaultUtility] addComponentConfigList];
    
    [fourBtnList setArray:touchButtonList];
    
    CGRect sFrame = self.view.frame;
    CGFloat buttonHeight = 110;
    if(is35Screen)
        buttonHeight = 80;
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType rangeOfString:@"iPad"].length > 0)
        buttonHeight = 200;
    CGFloat buttonGap = 5;
    
    btn1 = [[TouchButton alloc] initWithFrame:CGRectMake(5, sFrame.size.height - buttonHeight*2 - buttonGap*2,
                                                                      (sFrame.size.width - buttonGap*3)/2, buttonHeight)];
    btn1.delegate = self;
    btn1.bgColor = [UIColor colorWithRed:151/255.0 green:25/255.0 blue:35/255.0 alpha:0.7];
    btn1.buttonImage = [[touchButtonList objectAtIndex:0] objectForKey:@"buttonImage"];
    btn1.buttonTitle = [[touchButtonList objectAtIndex:0] objectForKey:@"buttonTitle"];
    btn1.buttonID = [[[touchButtonList objectAtIndex:0] objectForKey:@"buttonID"] integerValue];
    btn1.buttonTag = ADD_COMPONENT_INDEX_1;
    [self.view addSubview:btn1];
    
    btn2 = [[TouchButton alloc] initWithFrame:CGRectMake(btn1.frame.origin.x + btn1.frame.size.width + buttonGap,
                                                                      sFrame.size.height - buttonHeight*2 - buttonGap*2,
                                                                      (sFrame.size.width - buttonGap*3)/2, buttonHeight)];
    btn2.delegate = self;
    btn2.bgColor = [UIColor colorWithRed:234/255.0 green:96/255.0 blue:53/255.0 alpha:0.7];
    btn2.buttonImage = [[touchButtonList objectAtIndex:1] objectForKey:@"buttonImage"];
    btn2.buttonTitle = [[touchButtonList objectAtIndex:1] objectForKey:@"buttonTitle"];
    btn2.buttonID = [[[touchButtonList objectAtIndex:1] objectForKey:@"buttonID"] integerValue];
    btn2.buttonTag = ADD_COMPONENT_INDEX_2;
    [self.view addSubview:btn2];
    
    btn3 = [[TouchButton alloc] initWithFrame:CGRectMake(5, sFrame.size.height - buttonHeight - buttonGap,
                                                                      (sFrame.size.width - buttonGap*3)/2, buttonHeight)];
    btn3.delegate = self;
    btn3.bgColor = [UIColor colorWithRed:86/255.0 green:86/255.0 blue:88/255.0 alpha:0.7];
    btn3.buttonImage = [[touchButtonList objectAtIndex:2] objectForKey:@"buttonImage"];
    btn3.buttonTitle = [[touchButtonList objectAtIndex:2] objectForKey:@"buttonTitle"];
    btn3.buttonID = [[[touchButtonList objectAtIndex:2] objectForKey:@"buttonID"] integerValue];
    btn3.buttonTag = ADD_COMPONENT_INDEX_3;
    [self.view addSubview:btn3];
    
    btn4 = [[TouchButton alloc] initWithFrame:CGRectMake(btn1.frame.origin.x + btn1.frame.size.width + buttonGap,
                                                                      sFrame.size.height - buttonHeight - buttonGap,
                                                                      (sFrame.size.width - buttonGap*3)/2, buttonHeight)];
    btn4.delegate = self;
    btn4.bgColor = [UIColor colorWithRed:151/255.0 green:25/255.0 blue:35/255.0 alpha:0.7];
    btn4.buttonImage = [[touchButtonList objectAtIndex:3] objectForKey:@"buttonImage"];
    btn4.buttonTitle = [[touchButtonList objectAtIndex:3] objectForKey:@"buttonTitle"];
    btn4.buttonID = [[[touchButtonList objectAtIndex:3] objectForKey:@"buttonID"] integerValue];
    btn4.buttonTag = ADD_COMPONENT_INDEX_4;
    [self.view addSubview:btn4];
    
    // ----------------------------------------------------------------------------------------
    // setup connection control
    float waterViewHeight = sFrame.size.width/2;
    CGRect theRect = self.view.bounds;
    theRect.origin.x = (self.view.frame.size.width - waterViewHeight)/2;
    theRect.origin.y = sFrame.size.height - buttonHeight*2 - buttonGap*3 - 20 - waterViewHeight;
    theRect.size.width = waterViewHeight;
    theRect.size.height = waterViewHeight;
    waterView = [[VWWWaterView alloc] initWithFrame:theRect];
    waterView.delegate = self;
    [self.view addSubview:waterView];
    
    // ----------------------------------------------------------------------------------------
    // setup connectionVolumeLabel control
    connectionVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,(waterView.frame.size.height - 30)/2, waterView.frame.size.width, 30)];
    if(needControlBGColor)
        connectionVolumeLabel.backgroundColor = [UIColor grayColor];
    else
        connectionVolumeLabel.backgroundColor = [UIColor clearColor];
    connectionVolumeLabel.textAlignment = NSTextAlignmentCenter;
    connectionVolumeLabel.textColor = [UIColor whiteColor];
    connectionVolumeLabel.font = [UIFont boldSystemFontOfSize:23.0];
    connectionVolumeLabel.text = @"0 Bytes";
    [waterView addSubview:connectionVolumeLabel];

    // ----------------------------------------------------------------------------------------
    // setup connectionTimeLabel control
    connectionTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, connectionVolumeLabel.frame.origin.y - 20 - 1, waterView.frame.size.width, 20)];
    if(needControlBGColor)
        connectionTimeLabel.backgroundColor = [UIColor grayColor];
    else
        connectionTimeLabel.backgroundColor = [UIColor clearColor];
    connectionTimeLabel.textAlignment = NSTextAlignmentCenter;
    connectionTimeLabel.textColor = [UIColor whiteColor];
    connectionTimeLabel.font = [UIFont boldSystemFontOfSize:20.0];
    connectionTimeLabel.text = @"00:00:00";
    [waterView addSubview:connectionTimeLabel];
    
    // ----------------------------------------------------------------------------------------
    // setting sheet init
    settintContainer = [[SettingContainer alloc] init];
    settintContainer.delegate = self;
    [self.view addSubview:settintContainer];
    
    // ----------------------------------------------------------------------------------------
    // set KVNProgressUI appearence
    [self setCustomKVNProgressUIConfiguration];
    
    [self updateMainUIStatus:nil];
}

- (void)initData
{
    //
    fourBtnList = [[NSMutableArray alloc] initWithCapacity:4];
    for(int i = 0; i < 4; i++)
        [fourBtnList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"empty", nil]];
    
    isMainVCStatus = YES;
    isAddComponentStatus = NO;
    
    batteryChargeLevel = 0;
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(addComponentNotification:) name:ADDCOMPONENTNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(addComponentStatusNotification:) name:ADDCOMPONENTSTAUSNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(settingSheetDisappearNotification:) name:SettingSheetDisappearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(httpShareStatusNotification:) name:HttpShareStatusNotification object:nil];
}

#pragma mark -

- (void)setCustomKVNProgressUIConfiguration
{
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    
    //configuration.statusColor = [UIColor whiteColor];
    configuration.statusFont = [UIFont boldSystemFontOfSize:15.0];
    //configuration.circleStrokeForegroundColor = [UIColor whiteColor];
    //configuration.circleStrokeBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    //configuration.circleFillBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    //configuration.backgroundFillColor = [UIColor colorWithRed:0.173f green:0.263f blue:0.856f alpha:0.9f];
    //configuration.backgroundTintColor = [UIColor colorWithRed:0.173f green:0.263f blue:0.856f alpha:1.0f];
    //configuration.successColor = [UIColor whiteColor];
    //configuration.errorColor = [UIColor whiteColor];
    configuration.circleSize = 40.0f;
    //configuration.lineWidth = 1.0f;
    //configuration.fullScreen = NO;
    
    [KVNProgress setConfiguration:configuration];
}


@end
