//
//  NetManager.m
//  MyLink
//
//  Created by chen on 15/12/30.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "NetManager.h"
#import "NetClient.h"
#import "SDNetClient.h"
#import "Utility.h"
#import "SBJson.h"

static NetManager *sharedNetManager = nil;

@interface NetManager()
{
    BOOL isMonitorFirstEnter;
    BOOL isDeviceConnected;
    
    NSUInteger appSessionID;
    BOOL isLoginStatus;
    
    //
    SDNetClient *sdNetClient;
    
    //
    AFHTTPRequestOperation *downloadOperation;
}
@end

@implementation NetManager

@synthesize willGotoBackground,currentNetworkStatus,baseURLForSD;

+ (NetManager *)sharedNetManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetManager = [[NetManager alloc] init];
    });
    
    return sharedNetManager;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        sharedNetManager = 0;
        currentNetworkStatus = AFNetworkReachabilityStatusNotReachable;
        isMonitorFirstEnter = YES;
        isDeviceConnected = NO;
        
        isLoginStatus = NO;
        
        //
        baseURLForSD = BASE_URL_STR;
        sdNetClient = nil;
        
        //
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(downloadFileCancelNotification:) name:@"downloadFileCancelNotification" object:nil];
        downloadOperation = nil;
    }
    
    return self;
}

#pragma mark - 网络状态监测

- (void)startMonitor
{
    willGotoBackground = NO;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch(status)
        {
            case AFNetworkReachabilityStatusNotReachable:
                currentNetworkStatus = AFNetworkReachabilityStatusNotReachable;
                NSLog(@"No Internet Connection");
                if(!isMonitorFirstEnter)
                    [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"networkChangedTipsStr",NULL,@"TipStrings")];
                isDeviceConnected = NO;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                currentNetworkStatus = AFNetworkReachabilityStatusReachableViaWiFi;
                NSLog(@"WiFi");
                if(!isMonitorFirstEnter)
                    [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"networkChangedTipsStr",NULL,@"TipStrings")];
                [NSThread detachNewThreadSelector:@selector(connectToHostServer:) toTarget:self withObject:nil];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                currentNetworkStatus = AFNetworkReachabilityStatusReachableViaWWAN;
                NSLog(@"WWAN");
                if(!isMonitorFirstEnter)
                    [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"networkChangedTipsStr",NULL,@"TipStrings")];
                isDeviceConnected = NO;
                break;
                
            default:
                currentNetworkStatus = AFNetworkReachabilityStatusUnknown;
                NSLog(@"Unknown Network");
                if(!isMonitorFirstEnter)
                    [[Utility defaultUtility] showHudTipStr:NSLocalizedStringFromTable(@"networkChangedTipsStr",NULL,@"TipStrings")];
                isDeviceConnected = NO;
                break;
        }
        
        if(isMonitorFirstEnter)
            isMonitorFirstEnter = NO;

        //userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:currentNetworkStatus],@"NetStatus",nil];
        //[[NSNotificationCenter defaultCenter] postNotificationName:NETWORKCHANGEDNOTIFICATION object: self userInfo:nil];
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)stopMonitor
{
    willGotoBackground = YES;
    isMonitorFirstEnter = YES;
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (NSInteger)currentNetworkStatus
{
    return currentNetworkStatus;
}

#pragma mark - 数据请求/设置基础接口

/*
 数据获取
 param   - 获取数据需要的参数，默认为nil。
 command - 获取数据的command(例如要获取电池状态，command设为BATTERT_STATUS)。多个command串联以逗号分隔可一次获取多个数据。
 block   - 返回获取结果。
 */
- (void)requestDataWithParam:(NSDictionary *)param command:(NSString *)command andBlock:(void (^)(id data, NSError *error))block;
{
    NSString *theURL = [NSString stringWithFormat:@"%@%@",URL_GET,command];
    [[NetClient sharedNetClient] requestDataWithPath:theURL withParams:param withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 数据设置
 param   - 设置数据所带的参数(JSON数据结构)
 block   - 设置数据返回值
 */
- (void)configDataWithParam:(NSDictionary *)param andBlock:(void (^)(id data, NSError *error))block
{
    [[NetClient sharedNetClient] requestDataWithPath:URL_CONFIG withParams:param withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

#pragma mark - 判断设备是否正确连接相关函数

- (BOOL)isConnectedViaWiFi
{
    if([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi)
        return YES;
    else
        return NO;
}

- (BOOL)hostServerConnected
{
    return isDeviceConnected;
}

- (void)connectToHostServer:(id)sender
{
    int tryCount = 0;
    
    while(tryCount < 5)
    {
        @autoreleasepool{
            
            NSString *gatewayStr = [[Utility defaultUtility] getRouterGateway];
            NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",gatewayStr,URL_GET,DEVICE_NAME]];
            NSURLRequest *request = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
            NSHTTPURLResponse *response = nil;
            NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
            if(response == nil)
            {
                isDeviceConnected = NO;
                NSLog(@"MyServer, connect failed ! tryCount: %d",tryCount);
            }
            else
            {
                NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:retData options:NSJSONReadingMutableLeaves error:nil];
                if(retDict)
                {
                    NSString *deviceNameStr = [retDict objectForKey:DEVICE_NAME];
                    if([deviceNameStr rangeOfString:MY_DEVICE_NAME].length > 0)
                    {
                        NSString *urlStr = [self getHostURLName:gatewayStr];
                        if(urlStr)
                        {
                            baseURLForSD = urlStr;
                            [[Utility defaultUtility] setBaseURL:urlStr];
                            
                            isDeviceConnected = YES;
                            NSLog(@"MyServer, connect success(%@) ! tryCount: %d, host name url:%@",deviceNameStr,tryCount,urlStr);
                            break;
                        }
                        else
                        {
                            isDeviceConnected = NO;
                            NSLog(@"MyServer, connect success(%@), tyrCount: %d, but host name url get failed!",deviceNameStr,tryCount);
                        }
                    }
                    else
                    {
                        isDeviceConnected = NO;
                        NSLog(@"MyServer, connect success(but not my device) ! tryCount: %d",tryCount);
                    }
                }
            }
            
            if(willGotoBackground)
            {
                NSLog(@"MyServer, exit and goto background!");
                break;
            }
            
            tryCount++;
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}

- (NSString *)getHostURLName:(NSString *)gatewayStr
{
    NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",gatewayStr,LC_URL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(retData)
    {
        NSString *urlStr = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
        if(urlStr)
            return [NSString stringWithFormat:@"http://%@/",urlStr];
    }

    return nil;
}

#pragma mark - 业务数据请求

/*
 获取主UI动态刷新数据
 block - 主UI数据获取结果
 */
- (void)requesetMainUIData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                     MODEM_STATUS,
                     ROAMING_STATUS,
                     OPERATOR_NAME,
                     NETWORK_TYPE,
                     SIGNAL_STRENGTH,
                     BATTERT_STATUS,
                     BATTERT_STATUS_PERCENT,
                     SDCARD_STATUS,
                     WIFI_USER_NUM,
                     WiFi_Enable_2G,
                     WiFi_Enable_5G,
                     NETWORK_CONNECT_STATUS,
                     Network_Connect_Time,
                     Network_Connect_Transmitted,
                     Network_Connect_Received];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取Status数据
 */
- (void)requestStatusData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@",
                     WiFi_Enable_2G,
                     WiFi_SSID_2G,
                     WiFi_Channel_2G,
                     WiFi_SecurityMode_2G,
                     WiFi_Enable_5G,
                     WiFi_SSID_5G,
                     WiFi_Channel_5G,
                     WiFi_SecurityMode_5G,
                     Get_Device_list];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取Connection数据
 */
- (void)requestConnectionData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@",
                     NETWORK_CONNECT_STATUS,
                     Network_Connect_StartDate,
                     Network_Connect_Time_All,
                     Network_Connect_Sent_All,
                     Network_Connect_Received_All,
                     Network_Connect_TotalData_All];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Wan->Profile Management 数据
 */
- (void)requestWanProfileManagementData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@",
                     Web_APN_List];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Wan->Network Setting 数据
 */
- (void)requestWanNetworkSettingData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@",
                     Net_Search_Mode];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Wan->Mobile Connection 数据
 */
- (void)requestWanMobileConnectionData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@",
                     Net_Connect_Mode,
                     Roaming_Switch];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Wan->PIN Mamagement 数据
 */

- (void)requesetWanPINStatusData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@",
                     MODEM_STATUS,
                     SIM_Status,
                     SIM_PIN_Remain_Num,
                     SIM_PUK_Remain_Num];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi 2G Setup 数据
 */
- (void)requestWiFiSettingDataFor2G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                     WiFi_Enable_2G,
                     WiFi_SSID_Broadcast_2G,
                     WiFi_SSID_2G,
                     WiFi_Interface_2G,
                     WiFi_Reg_Domain_2G,
                     WiFi_Channel_2G,
                     WiFi_Bintval_2G,
                     WiFi_Bandwidth_2G,
                     WiFi_MaxSta_2G,
                     WiFi_SecurityMode_2G,
                     WiFi_Wep_Password_2G,
                     WiFi_Wpa_Password_2G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi 5G Setup 数据
 */
- (void)requestWiFiSettingDataFor5G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                     WiFi_Enable_5G,
                     WiFi_SSID_Broadcast_5G,
                     WiFi_SSID_5G,
                     WiFi_Interface_5G,
                     WiFi_Reg_Domain_5G,
                     WiFi_Channel_5G,
                     WiFi_Bintval_5G,
                     WiFi_Bandwidth_5G,
                     WiFi_MaxSta_5G,
                     WiFi_SecurityMode_5G,
                     WiFi_Wep_Password_5G,
                     WiFi_Wpa_Password_5G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi 2G Enable 数据
 */
- (void)requestWiFiEnableStateFor2G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@",
                     WiFi_Enable_2G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi 5G Enable 数据
 */
- (void)requestWiFiEnableStateFor5G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@",
                     WiFi_Enable_5G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi Mac Fiter 2G Setup 数据
 */
- (void)requestWiFiFilterDataFor2G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@",
                     WiFi_MacFilter_Enable_2G,
                     Mac_Filter_Control_2G,
                     WiFi_MacFilter_Rule_String_2G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi Mac Filter 5G Setup 数据
 */
- (void)requestWiFiFilterDataFor5G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@",
                     WiFi_MacFilter_Enable_5G,
                     Mac_Filter_Control_5G,
                     WiFi_MacFilter_Rule_String_5G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi WPS 2G Setup 数据
 */
- (void)requestWiFiWPSDataFor2G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@",
                     WiFi_WPS_Enable_2G,
                     WiFi_WPS_Mode_2G,
                     WiFi_WPS_Client_Pin_2G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->WiFi WPS 5G Setup 数据
 */
- (void)requestWiFiWPSDataFor5G:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@",
                     WiFi_WPS_Enable_5G,
                     WiFi_WPS_Mode_5G,
                     WiFi_WPS_Client_Pin_5G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Router->UPnP 数据
 */
- (void)requestRouterUPnPData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@",
                     RT_UPnP_Enable,
                     RT_L2TP_Enable,
                     RT_PPTP_Enable,
                     RT_IPSec_Enable];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Router->Lan 数据
 */
- (void)requestRouterLanData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@",
                     RT_LanIP,
                     RT_NetMask,
                     RT_DHCPS_Enable,
                     RT_DHCPS_StartIP,
                     RT_DHCPS_EndIP,
                     RT_DHCPS_Lease,
                     RT_DNS_Mode,
                     RT_DNS_List,
                     RT_DNS_Relay_Enable];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

- (void)configRouterLanData:(NSDictionary *)param andBlock:(void (^)(id data, NSError *error))block
{
}

/*
 获取 Setting->Router->Static DHCP 数据
 */
- (void)requestRouterStaticDHCPData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@",RT_DHCP_Static];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Router->DDNS 数据
 */
- (void)requestRouterDDNSData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@",
                     RT_DDNS_Server,
                     RT_DDNS_UserName,
                     RT_DDNS_Password,
                     RT_DDNS_Domain];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Router->LAN IP Filter 数据
 */
- (void)requestRouterLanIPFilterData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@",
                     RT_IP_Filter_Control,
                     RT_IP_Filter_Rule];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Router->URL Filter 数据
 */
- (void)requestRouterURLFilterData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@",
                     RT_URL_Filter_Control,
                     RT_URL_Filter_Rule];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Router->Port Forwardiing 数据
 */
- (void)requestRouterPortForwardingData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@",
                     RT_Port_Forward_Enabled,
                     RT_Port_Forward_Rule,
                     RT_LanIP];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->Router->DMZ Setting 数据
 */
- (void)requestRouterDMZSettingData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@",
                     RT_DMZ_Enabled,
                     RT_DMZ_Host,
                     RT_DMZ_Src,
                     RT_LanIP];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->System->Modify Password 数据
 */
- (void)requestSystemUserNamePassworkData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@",
                     SYS_New_UserName,
                     SYS_New_Password];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->System->Time 数据
 */
- (void)requestSystemTimeData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@",
                     SYS_Current_Time,
                     SYS_Time_Mode,
                     SYS_NTP_Server,
                     SYS_Time_Zone];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->System->Time->Current Time 数据
 */
- (void)requestSystemCurrentTime:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@",
                     SYS_Current_Time];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->System->Storage 数据
 */
- (void)requestSystemStorageData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@",
                     Setting_Storage];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

- (void)requestSystemInternetStorageData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@",
                     Setting_Storage,
                     NETWORK_CONNECT_STATUS,
                     Wan_IP_Address_Ipv4];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

/*
 获取 Setting->About 数据
 */
- (void)requestAboutData:(void (^)(id data, NSError *error))block
{
    NSString *cmd = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@",
                     About_Modem_Version,
                     About_Software_Version,
                     About_Hardware_Version,
                     About_IMEI,
                     About_MacAddress,
                     About_MacAddress5G];
    [self requestDataWithParam:nil command:cmd andBlock:^(id data, NSError *error) {
        if(data)
        {
            block(data, nil);
        }
        else
        {
            block(nil, error);
        }
    }];
}

#pragma mark - PIN 判断相关函数

- (NSString *)pinStatus
{
    NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BASE_URL_STR,URL_GET,MODEM_STATUS]];
    NSURLRequest *request = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:retData options:NSJSONReadingMutableLeaves error:nil];
        if(retDict)
        {
            NSString *modemStatus = [retDict objectForKey:MODEM_STATUS];
            if(modemStatus && modemStatus.length > 0)
                return modemStatus;
        }
    }
    
    return @"";
}

- (NSDictionary *)retainTimeOfPinPuk
{
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@,%@",BASE_URL_STR,URL_GET,SIM_PIN_Remain_Num,SIM_PUK_Remain_Num]];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
        NSLog(@"My server can not be connected 1");
    }
    else
    {
        NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:retData options:NSJSONReadingMutableLeaves error:nil];
        if(retDict)
        {
            return retDict;
        }
    }
    
    return nil;
}

#pragma mark - Login/Logout

- (BOOL)isLoginStatus
{
    return isLoginStatus;
}

- (void)loginWithName:(NSString *)userName password:(NSString *)password andBlock:(void (^)(id data, id error))block
{
    long ramdomData = random()%10000;
    appSessionID = random()%1000000;

    NSString *authenticationUrl = [NSString stringWithFormat:URL_Authentication,password,userName,ramdomData];
    /*
    NSString *loginStr = [NSString stringWithFormat:@"%@%@",BASE_URL_STR,authenticationUrl];
    [[NetClient sharedNetClient] requestDataWithPath:loginStr withParams:nil withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int retCode = [tempStr intValue];
            tempStr = nil;
            
            if(retCode == 1)
            {
                // success
                block(tempStr,nil);
            }
            else if(retCode == 0)
            {
                // password failed
                block(nil,[NSNumber numberWithInt:retCode]);
            }
            else if(retCode == -1)
            {
                // userName failed
                block(nil,[NSNumber numberWithInt:retCode]);
            }
        }
        else
        {
            block(nil, nil);
        }
    }];*/

    
    NSURL *loginURL = [NSURL URLWithString:authenticationUrl relativeToURL:[NSURL URLWithString:BASE_URL_STR]];
    NSURLRequest *request = [NSURLRequest requestWithURL:loginURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
        block(nil,nil);
    }
    else
    {
        NSString *tempStr = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
        int retCode = [tempStr intValue];
        tempStr = nil;
        
        if(retCode == 1)
        {
            // success
            block([NSNumber numberWithInt:retCode],nil);
        }
        else if(retCode == 0)
        {
            // password failed
            block(nil,[NSNumber numberWithInt:retCode]);
        }
        else if(retCode == -1)
        {
            // userName failed
            block(nil,[NSNumber numberWithInt:retCode]);
        }
    }
}

- (void)logout
{
    NSURL *logoutURL = [NSURL URLWithString:URL_Logout relativeToURL:[NSURL URLWithString:BASE_URL_STR]];

    NSURLRequest *request = [NSURLRequest requestWithURL:logoutURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSString *tempStr = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
        //int retCode = [tempStr intValue];
        tempStr = nil;
    }
    
    appSessionID = random()%1000000;
    isLoginStatus = NO;
}

- (int)commitLoginSession
{
    int retCode = -1;
    
    NSString *loginSessionStr = [NSString stringWithFormat:URL_CommitLoginAppSessionID,(unsigned long)appSessionID];
    NSURL *loginSessionURL = [NSURL URLWithString:loginSessionStr relativeToURL:[NSURL URLWithString:BASE_URL_STR]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:loginSessionURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSString *tempStr = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
        retCode = [tempStr intValue];
        tempStr = nil;
        
        if(retCode == 2)    // already login
        {
        }
        else if(retCode == appSessionID)    // login success
        {
            retCode = 0;
            isLoginStatus = YES;
        }
        else if(retCode == -1)  // The session could not be created or the connection has been lost!
        {
        }
    }
    
    return retCode;
}

- (void)resetAppTimer
{
    NSString *authenticationUrl = [NSString stringWithFormat:URL_AppResetTimer];
    NSURL *resetTimerURL = [NSURL URLWithString:authenticationUrl relativeToURL:[NSURL URLWithString:BASE_URL_STR]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:resetTimerURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSString *tempStr = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
        //int retCode = [tempStr intValue];
        tempStr = nil;
    }
}

- (BOOL)isLoginSessionValid
{
    BOOL isLoginSessionValid = NO;
    NSString *loginSessionValidStr = [NSString stringWithFormat:URL_AppSessionIsValid,(unsigned long)appSessionID];
    NSURL *loginSessionValidURL = [NSURL URLWithString:loginSessionValidStr relativeToURL:[NSURL URLWithString:BASE_URL_STR]];

    NSURLRequest *request = [NSURLRequest requestWithURL:loginSessionValidURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSString *tempStr = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
        NSUInteger retCode = [tempStr integerValue];
        if(retCode == appSessionID)
        {
            isLoginSessionValid = YES;
        }
        
        tempStr = nil;
    }
    
    return isLoginSessionValid;
}

- (BOOL)isLoginTimeout
{
    BOOL isTimeOut = NO;
    NSString *loginTimeoutStr = [NSString stringWithFormat:URL_AppIsTimeOut];
    NSURL *loginTimeoutURL = [NSURL URLWithString:loginTimeoutStr relativeToURL:[NSURL URLWithString:BASE_URL_STR]];

    NSURLRequest *request = [NSURLRequest requestWithURL:loginTimeoutURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSString *tempStr = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
        if([tempStr rangeOfString:@"timeout"].length > 0)
        {
            isTimeOut = YES;
        }
        
        tempStr = nil;
    }
    
    return isTimeOut;
}

#pragma mark - SD Card

/*
  param:
  LAN:  BASE_URL_STR
  WWAN: baseURL
 */
- (void)setSDBaseURL:(NSString *)baseURL
{
    if(baseURL)
    {
        baseURLForSD = baseURL;
        if(sdNetClient)
            sdNetClient = nil;
        sdNetClient = [[SDNetClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLForSD]];
    }
    else
    {
        baseURLForSD = BASE_URL_STR;
        sdNetClient = nil;
    }
}

- (NSDictionary *)querySDStatus
{
    NSDictionary *sdDict = nil;
    
    NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",baseURLForSD,URL_GET,SD_Card_Status]];
    NSURLRequest *request = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:retData options:NSJSONReadingMutableLeaves error:nil];
        if(retDict)
        {
            sdDict = [NSDictionary dictionaryWithDictionary:retDict];
        }
    }
    
    return sdDict;
}

- (NSDictionary *)querySDInfo
{
    NSDictionary *sdDict = nil;
    
    NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseURLForSD,SD_Card_Info]];
    NSURLRequest *request = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
    }
    else
    {
        NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:retData options:NSJSONReadingMutableLeaves error:nil];
        if(retDict)
        {
            sdDict = [NSDictionary dictionaryWithDictionary:retDict];
        }
    }
    
    return sdDict;
}

- (void)queryFileList:(NSString *)directory andBlock:(void (^)(id data, id error))block
{
    NSString *tempPath = [NSString stringWithFormat:@"%@%@",URL_SD_GET_FILELIST,@""];
    if(directory)
        tempPath = [NSString stringWithFormat:@"%@%@",URL_SD_GET_FILELIST,directory];
    
    id netClient = [NetClient sharedNetClient];
    if(sdNetClient)
        netClient = sdNetClient;
    
    [netClient requestDataWithPath:tempPath withParams:nil withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            if([[data objectForKey:@"errorCode"] intValue] == 0)
            {
                block([data objectForKey:@"fileList"],nil);
            }
            else
                block(nil,error);
        }
        else
        {
            block(nil,error);
        }
    }];
}

- (void)queryFileListByType:(NSString *)type andBlock:(void (^)(id data, id error))block
{
    NSString *tempPath = [NSString stringWithFormat:@"%@%@",URL_SD_GET_FILELIST_BT_TYPE,type];
    
    id netClient = [NetClient sharedNetClient];
    if(sdNetClient)
        netClient = sdNetClient;

    [netClient requestDataWithPath:tempPath withParams:nil withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            if([[data objectForKey:@"errorCode"] intValue] == 0)
            {
                block([data objectForKey:@"fileList"],nil);
            }
            else
                block(nil,error);
        }
        else
        {
            block(nil,error);
        }
    }];
}

- (void)createNewFolder:(NSDictionary *)param andBlock:(void (^)(id data, id error))block
{
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [tempDict setObject:@"sdcard_create_folder" forKey:@"which_cgi"];
    [tempDict setObject:[param objectForKey:@"folderName"] forKey:@"folder_name"];
    [tempDict setObject:[param objectForKey:@"currentDir"] forKey:@"current_folder_dir"];
    
    id netClient = [NetClient sharedNetClient];
    if(sdNetClient)
        netClient = sdNetClient;

    [netClient requestDataWithPath:URL_SD_CONFIG withParams:tempDict withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            if([[data objectForKey:@"errorCode"] intValue] == 0)
            {
                block(data,nil);
            }
            else if([[data objectForKey:@"errorCode"] intValue] == 1)
            {
                if([[data objectForKey:@"errorDesc"] isEqualToString:@"error_f_exist"])
                    return block(data,nil);
                else
                    return block(nil,error);
            }
            else
                block(nil,error);
        }
        else
        {
            block(nil,error);
        }
    }];
}

- (void)rename:(NSDictionary *)param andBlock:(void (^)(id data, id error))block
{
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [tempDict setObject:@"sdcard_rename_file" forKey:@"which_cgi"];
    [tempDict setObject:[param objectForKey:@"srcPath"] forKey:@"from"];
    [tempDict setObject:[param objectForKey:@"destPath"] forKey:@"to"];

    id netClient = [NetClient sharedNetClient];
    if(sdNetClient)
        netClient = sdNetClient;

    [netClient requestDataWithPath:URL_SD_CONFIG withParams:tempDict withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            if([[data objectForKey:@"errorCode"] intValue] == 0)
            {
                block(data,nil);
            }
            else
                block(nil,error);
        }
        else
        {
            block(nil,error);
        }
    }];
}

- (void)deleteFile:(NSString *)param andBlock:(void (^)(id data, id error))block
{
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [tempDict setObject:@"sdcard_delete_file" forKey:@"which_cgi"];
    [tempDict setObject:param forKey:@"file_name"];

    id netClient = [NetClient sharedNetClient];
    if(sdNetClient)
        netClient = sdNetClient;

    [netClient requestDataWithPath:URL_SD_CONFIG withParams:tempDict withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            if([[data objectForKey:@"errorCode"] intValue] == 0)
            {
                block(data,nil);
            }
            else
                block(nil,error);
        }
        else
        {
            block(nil,error);
        }
    }];
}

- (void)deleteMoreFile:(NSArray *)param andBlock:(void (^)(id data, id error))block
{
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [tempDict setObject:@"sdcard_delete_more_file" forKey:@"which_cgi"];
    [tempDict setObject:[[NSNumber numberWithInteger:[param count]] stringValue] forKey:@"fileListSize"];
    
    NSMutableArray *tempFileList = [NSMutableArray arrayWithCapacity:0];
    for(int i = 0; i < [param count]; i++)
    {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[param objectAtIndex:i],@"path",nil];
        [tempFileList addObject:tempDict];
    }
    [tempDict setObject:tempFileList forKey:@"fileList"];

    id netClient = [NetClient sharedNetClient];
    if(sdNetClient)
        netClient = sdNetClient;

    [netClient requestDataWithPath:URL_SD_CONFIG withParams:tempDict withMethodType:Post andBlock:^(id data, NSError *error){
        if(data)
        {
            if([[data objectForKey:@"errorCode"] intValue] == 0)
            {
                block(data,nil);
            }
            else
                block(nil,error);
        }
        else
        {
            block(nil,error);
        }
    }];
}

- (void)downloadFile:(NSString *)srcPath toPath:(NSString *)destPath andBlock:(void (^)(id data, NSError *error))block
{
    if(downloadOperation)
        downloadOperation = nil;

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"share%@",[srcPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"]] relativeToURL:[NSURL URLWithString:baseURLForSD]];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/share%@",srcPath]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    downloadOperation.inputStream = [NSInputStream inputStreamWithURL:url];
    downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:destPath append:NO];
    
    [[Utility defaultUtility] hudShowWithProgress:@"Loading..." andCancel:@""];
    [downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = ((float)totalBytesRead)/totalBytesExpectedToRead * 100;
        //NSLog(@"Downloading: %.f%%",progress);
        [[Utility defaultUtility] setHudProgress:progress/100.0];
    }];
    
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        //NSLog(@"Download success, path: %@",srcPath);
        [[Utility defaultUtility] hudClose];
        block(destPath,nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        //NSLog(@"Download failed, path: %@",srcPath);
        [[Utility defaultUtility] hudClose];
        block(nil,error);
    }];
    
    [downloadOperation start];
}

- (void)downloadFileCancelNotification:(NSNotification *)notification
{
    if(downloadOperation)
        [downloadOperation cancel];
}

- (UIImage *)downloadThumbnailImage:(NSString *)imagePath
{
    //NSString *tempPath = [NSString stringWithFormat:@"/share%@?method=thumbnail&width=100&height=100",imagePath];
    NSString *tempPath = [NSString stringWithFormat:@"/share%@",imagePath];
    NSString *tempPath1 = [tempPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:tempPath1 relativeToURL:[NSURL URLWithString:baseURLForSD]];
    
    //
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:2];
    NSHTTPURLResponse *response = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
    if(response == nil)
    {
        return nil;
    }
    else
    {
        UIImage *resImage = [UIImage imageWithData:retData];
        return resImage;
    }

    return NULL;
}

- (void)uploadImageToDisk:(NSString *)dstFolderName srcFilePath:(NSString *)srcFilePath andBlock:(void (^)(id data, NSError *error))block
{
    NSString *uploadURLString = [NSString stringWithFormat:@"%@%@",baseURLForSD,URL_SD_FILE_UPLOAD];
    NSString *paramStr = [NSString stringWithFormat:@"longcheer_w>/%@>",dstFolderName];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:paramStr,@"current_folder_dir", nil];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST"
                                                                    URLString:uploadURLString
                                                                   parameters:param
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:srcFilePath]
                                                                                   name:@"lc_upfile"
                                                                               fileName:[srcFilePath lastPathComponent]
                                                                               mimeType:@"image/png"
                                                                                  error:nil];}
                                                                        error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    AFHTTPRequestOperation *uploadOperation = nil;
    [[Utility defaultUtility] hudShowWithProgress:@"Uploading..."];
    uploadOperation = [manager HTTPRequestOperationWithRequest:request
                                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                           [[Utility defaultUtility] hudClose];
                                                           block(srcFilePath,nil);
                                                       }
                                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                           [[Utility defaultUtility] hudClose];
                                                           block(nil,error);
                                                       }];
    
    [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float progress = ((float)totalBytesWritten)/totalBytesExpectedToWrite * 100;
        [[Utility defaultUtility] setHudProgress:progress/100.0];
    }];
    
    [uploadOperation start];
}

#pragma mark - Get WPS Status
- (NSDictionary *)getWPSStatus
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BASE_URL_STR,URL_GET,Get_WPS_Status]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    return dict;
}

#pragma mark - Get Current Modem Status
- (NSDictionary *)getCurrentModemStatus
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BASE_URL_STR,URL_GET,MODEM_STATUS]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    return dict;
}

@end
