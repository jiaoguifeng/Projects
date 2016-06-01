//
//  Utility.m
//  MyLink
//
//  Created by chen on 15/12/30.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "Utility.h"
#import "MBProgressHUD.h"
#import "Net.h"
#import "NetManager.h"
#import "PopView.h"
#import "AppDelegate.h"

//for ifaddrs
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "getgateway.h"

static Utility *defaultUtility = nil;

@interface Utility()<MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    UIButton *cancelButton;
    
    NSThread      *refreshWPSStatusThd;
    PopView       *popView;
    NSDictionary  *userInfo;
    
    NSMutableString *baseURL;
}
@end

@implementation Utility

+ (Utility *)defaultUtility
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultUtility = [[Utility alloc] init];
    });

    return defaultUtility;
}

#pragma mark -

- (void)setBaseURL:(NSString *)urlStr
{
    if(baseURL)
        baseURL = nil;

    baseURL = [[NSMutableString alloc] initWithCapacity:0];
    if(urlStr)
        [baseURL setString:urlStr];
}

- (NSString *)baseURL
{
    return baseURL;
}

- (NSString *)getRouterGateway
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL)
        /*/
         int i=255;
         while((i--)>0)
         //*/
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                //NSLog(@"----------------");
                //NSLog(@"the name: %@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                    //routerIP----192.168.1.255 广播地址
                    //NSLog(@"broadcast address--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    //--192.168.1.106 本机地址
                    //NSLog(@"local device ip--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                    //--255.255.255.0 子网掩码地址
                    //NSLog(@"netmask--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    //--en0 端口地址
                    //NSLog(@"interface--%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                    
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    in_addr_t i = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t *x = &i;
    
    unsigned char *s = getdefaultgateway(x);
    NSString *ip = @"192.168.0.1";
    if(s)
    {
        ip = [NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
        free(s);
    }
    //return ip;
    return [NSString stringWithFormat:@"http://%@/",ip];
}


#pragma mark - private plist
- (NSDictionary *)privateConfigData
{
    NSDictionary *privateDict = nil;
    NSString *privateConfigPath = [DOCUMENT stringByAppendingPathComponent:PRIVATE_CONFIG];
    if([[NSFileManager defaultManager] fileExistsAtPath:privateConfigPath])
        privateDict = [NSDictionary dictionaryWithContentsOfFile:privateConfigPath];
    
    return privateDict;
}

- (void)setPrivateConfigData:(NSDictionary *)dict
{
    NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:dict];
    NSString *privateConfigPath = [DOCUMENT stringByAppendingPathComponent:PRIVATE_CONFIG];
    [tempDict writeToFile:privateConfigPath atomically:YES];
}

- (BOOL)isPrivateKeyOpenedAtIndex:(NSInteger)keyIndex
{
    NSString *keyValue = [NSString stringWithFormat:@"addr%@",[[NSNumber numberWithInteger:keyIndex] stringValue]];
    return [[[[Utility defaultUtility] privateConfigData] objectForKey:keyValue] isEqualToString:@"1"];
}

#pragma mark - custom 4 plus button plist

- (NSArray *)addComponentConfigList
{
    NSArray *dictList = nil;
    
    NSString *addComponentConfig = [DOCUMENT stringByAppendingPathComponent:ADD_COMPONENT_CONFIG];
    if([[NSFileManager defaultManager] fileExistsAtPath:addComponentConfig])
        dictList = [NSArray arrayWithContentsOfFile:addComponentConfig];
    
    return dictList;
}

- (void)setAddComponentConfigDict:(NSArray *)dictList
{
    NSString *addComponentConfig = [DOCUMENT stringByAppendingPathComponent:ADD_COMPONENT_CONFIG];
    if(dictList)
    {
        [dictList writeToFile:addComponentConfig atomically:YES];
    }
}

- (void)setAddComponentConfigDictWithIndex:(NSInteger)index dict:(NSDictionary *)dict
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:[self addComponentConfigList]];
    [list replaceObjectAtIndex:index withObject:dict];
    [self setAddComponentConfigDict:list];
}

#pragma mark - login plist

- (NSDictionary *)loginConfigData
{
    NSDictionary *loginDict = nil;
    NSString *loginConfigPath = [DOCUMENT stringByAppendingPathComponent:LOGIN_CONFIG];
    if([[NSFileManager defaultManager] fileExistsAtPath:loginConfigPath])
        loginDict = [NSDictionary dictionaryWithContentsOfFile:loginConfigPath];
    
    return loginDict;
}

- (void)setLoginConfigData:(NSDictionary *)dict
{
    NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:dict];
    NSString *loginConfigPath = [DOCUMENT stringByAppendingPathComponent:LOGIN_CONFIG];
    [tempDict writeToFile:loginConfigPath atomically:YES];
}

#pragma mark - http share plist

- (NSDictionary *)httpShareConfigData
{
    NSDictionary *httpShareDict = nil;
    NSString *httpShareConfigPath = [DOCUMENT stringByAppendingPathComponent:HTTP_SHARE_CONFIG];
    if([[NSFileManager defaultManager] fileExistsAtPath:httpShareConfigPath])
        httpShareDict = [NSDictionary dictionaryWithContentsOfFile:httpShareConfigPath];
    
    return httpShareDict;
}

- (void)setHttpShareConfigData:(NSDictionary *)dict
{
    NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:dict];
    NSString *httpShareConfigPath = [DOCUMENT stringByAppendingPathComponent:HTTP_SHARE_CONFIG];
    [tempDict writeToFile:httpShareConfigPath atomically:YES];
}

#pragma mark - image capture cache plist

- (void)setupImageCaptureDirectory
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *captureTempPath = [NSString stringWithFormat:@"%@/Caches/ImageCaptureTemp/WIFIPhotos/",documentsPath];
    NSString *wifiPhtotoConfigFile = [NSString stringWithFormat:@"%@/WIFIPhotos.plist",captureTempPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:captureTempPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:captureTempPath withIntermediateDirectories:YES attributes:NULL error:NULL];
        if(![[NSFileManager defaultManager] fileExistsAtPath:wifiPhtotoConfigFile])
        {
            NSMutableArray *wifiPhotosList = [NSMutableArray arrayWithCapacity:0];
            [wifiPhotosList writeToFile:wifiPhtotoConfigFile atomically:YES];
        }
    }
}

- (NSArray *)wifiPhotosList
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *captureTempPath = [NSString stringWithFormat:@"%@/Caches/ImageCaptureTemp/WIFIPhotos/",documentsPath];
    NSString *wifiPhtotoConfigFile = [NSString stringWithFormat:@"%@/WIFIPhotos.plist",captureTempPath];

    return [NSArray arrayWithContentsOfFile:wifiPhtotoConfigFile];
}

- (void)setWifiPhotosList:(NSArray *)photoList
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *captureTempPath = [NSString stringWithFormat:@"%@/Caches/ImageCaptureTemp/WIFIPhotos/",documentsPath];
    NSString *wifiPhtotoConfigFile = [NSString stringWithFormat:@"%@/WIFIPhotos.plist",captureTempPath];

    NSMutableArray *wifiPhotosList = [NSMutableArray arrayWithArray:photoList];
    [wifiPhotosList writeToFile:wifiPhtotoConfigFile atomically:YES];
}

- (void)addToWifiPhotosList:(NSDictionary *)fileDict
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *captureTempPath = [NSString stringWithFormat:@"%@/Caches/ImageCaptureTemp/WIFIPhotos/",documentsPath];
    NSString *wifiPhtotoConfigFile = [NSString stringWithFormat:@"%@/WIFIPhotos.plist",captureTempPath];

    NSMutableArray *fileList = [NSMutableArray arrayWithContentsOfFile:wifiPhtotoConfigFile];
    [fileList addObject:fileDict];
    [fileList writeToFile:wifiPhtotoConfigFile atomically:YES];
}

- (NSString *)wifiPhotosPath
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *captureTempPath = [NSString stringWithFormat:@"%@/Caches/ImageCaptureTemp/WIFIPhotos/",documentsPath];

    return captureTempPath;
}

- (NSString *)currentDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    dateFormatter = nil;
    
    return currentDateStr;
}

- (NSString *)currentDateAndTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    dateFormatter = nil;
    
    return currentDateStr;
}

#pragma mark -

- (void)prepareConfigFiles
{
    if(![self privateConfigData])
    {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"0",@"addr0",
                                  @"0",@"addr1",
                                  @"0",@"addr2",
                                  @"0",@"addr3",
                                  @"0",@"addr4",
                                  @"0",@"addr5",
                                  @"0",@"addr6",
                                  @"0",@"addr7",
                                  @"0",@"addr8",
                                  @"0",@"addr9",nil];
        
        [self setPrivateConfigData:tempDict];
    }
    
    if(![self loginConfigData])
    {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"",@"userName",
                                  @"",@"password",
                                  [NSNumber numberWithBool:NO],@"isRemember",nil];
        [self setLoginConfigData:tempDict];
    }
    
    if(![self addComponentConfigList])
    {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:@"plus",@"buttonImage",NSLocalizedStringFromTable(@"clickAddComponentsStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:TOUCH_BUTTON_NONE],@"buttonID",@"",@"buttonDescription", nil];
        NSArray *tempList = [NSArray arrayWithObjects:tempDict,tempDict,tempDict,tempDict, nil];
        [self setAddComponentConfigDict:tempList];
    }
    
    if(![self httpShareConfigData])
    {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"http://",@"httpShareURL",
                                  @"",@"httpShareUsername",
                                  @"",@"httpSharePassword",nil];
        [self setHttpShareConfigData:tempDict];
    }
    
    [self setupImageCaptureDirectory];
}

#pragma mark - File type

- (NSString *)fileTypeName:(NSString *)extensionStr
{
    if(extensionStr)
    {
        NSString *tempStr = [extensionStr lowercaseString];
        
        if([IMAGE_TYPE_LIST rangeOfString:tempStr].length > 0)
            return @"icon_list_image.png";
        else if([AUDIO_TYPE_LIST rangeOfString:tempStr].length > 0)
            return @"icon_list_audiofile.png";
        else if([VIDEO_TYPE_LIST rangeOfString:tempStr].length > 0)
            return @"icon_list_videofile.png";
        else if([DOCUMENT_TYPE_LIST rangeOfString:tempStr].length > 0)
        {
            if([tempStr rangeOfString:@"doc"].length > 0 || [tempStr rangeOfString:@"rtf"].length > 0)
                return @"icon_list_doc.png";
            else if([tempStr rangeOfString:@"xls"].length > 0 || [tempStr rangeOfString:@"xlsx"].length > 0)
                return @"icon_list_excel.png";
            else if([tempStr rangeOfString:@"ppt"].length > 0 || [tempStr rangeOfString:@"pptx"].length > 0)
                return @"icon_list_ppt.png";
            else if([tempStr rangeOfString:@"txt"].length > 0)
                return @"icon_list_txtfile.png";
            else if([tempStr rangeOfString:@"pdf"].length > 0)
                return @"icon_list_pdf.png";
            else if([tempStr rangeOfString:@"html"].length > 0 || [tempStr rangeOfString:@"htm"].length > 0)
                return @"icon_list_html.png";
            else if([tempStr rangeOfString:@"zip"].length > 0)
                return @"icon_list_compressfile.png";
            else
                return @"icon_list_file.png";
        }
        else
            return @"icon_list_file.png";
    }
    
    return @"icon_list_file.png";
}

// 0-image 1-audio 2-video 3-document
- (SD_FILE_TYPE)fileType:(NSString *)extensionStr
{
    NSString *tempStr = [extensionStr lowercaseString];
    
    if([IMAGE_TYPE_LIST rangeOfString:tempStr].length > 0)
        return SD_FILE_IMAGE;
    else if([AUDIO_TYPE_LIST rangeOfString:tempStr].length > 0)
        return SD_FILE_AUDIO;
    else if([VIDEO_TYPE_LIST rangeOfString:tempStr].length > 0)
        return SD_FILE_VIDO;
    else if([DOCUMENT_TYPE_LIST rangeOfString:tempStr].length > 0)
        return SD_FILE_DOCUMENT;
    else
        return SD_FILE_OTHERS;
}

#pragma mark - image utility

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

#pragma mark - HUD

- (void)showHudTipStr:(NSString *)tipStr
{
    if (tipStr && tipStr.length > 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelFont = [UIFont boldSystemFontOfSize:15.0];
        hud.detailsLabelText = tipStr;
        hud.margin = 10.f;
        hud.cornerRadius = 5.0f;
        hud.removeFromSuperViewOnHide = YES;
        float screenHeight = [[UIScreen mainScreen] bounds].size.height;
        hud.yOffset = screenHeight/2 - 40;
        [hud hide:YES afterDelay:1.0];
    }
}

- (void)showHudTipStr:(NSString *)tipStr withTimeInterval:(NSTimeInterval)timeInterval
{
    if (tipStr && tipStr.length > 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelFont = [UIFont boldSystemFontOfSize:15.0];
        hud.detailsLabelText = tipStr;
        hud.margin = 10.f;
        hud.cornerRadius = 5.0f;
        hud.removeFromSuperViewOnHide = YES;
        float screenHeight = [[UIScreen mainScreen] bounds].size.height;
        hud.yOffset = screenHeight/2 - 40;
        [hud hide:YES afterDelay:timeInterval];
    }
}

- (void)hudShowWithTitle:(NSString *)strTitle
{
    [self hudClose];
    
    HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:HUD];
    HUD.delegate = self;
    HUD.labelText = strTitle;
    [HUD show:YES];
}

- (void)hudShowWithTitle:(NSString *)strTitle forView:(UIView *)forView
{
    [self hudClose];
    
    HUD = [[MBProgressHUD alloc] initWithView:forView];
    [forView addSubview:HUD];
    [forView bringSubviewToFront:HUD];
    HUD.delegate = self;
    HUD.labelText = strTitle;
    [HUD show:YES];
}

- (void)hudShowWithProgress:(NSString *)strTitle
{
    [self hudClose];
    
    HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:HUD];
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    HUD.progress = 0.0;
    HUD.labelText = strTitle;
    [HUD show:YES];
}

- (void)hudShowWithProgress:(NSString *)strTitle andCancel:(NSString *)cancelStr
{
    [self hudClose];
    
    HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:HUD];
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    HUD.progress = 0.0;
    HUD.labelText = strTitle;
    [HUD show:YES];
    
    CGRect buttonRect = HUD.indicatorFrame;
    buttonRect.origin.x -= 20;
    buttonRect.origin.y -= (20 + 15 + 1);
    buttonRect.size.width = 15;
    buttonRect.size.height = 15;
    cancelButton = [[UIButton alloc] initWithFrame:buttonRect];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:cancelButton];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:cancelButton];
}

- (void)cancelAction:(id)sender
{
    [self hudClose];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFileCancelNotification" object: self userInfo:nil];
}

- (void)setHudProgress:(float)progress
{
    if(HUD)
        HUD.progress = progress;
}

- (void)hudClose
{
    if(HUD)
    {
        [HUD removeFromSuperview];
        HUD = nil;
    }
    
    if(cancelButton)
    {
        [cancelButton removeTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton removeFromSuperview];
        cancelButton = nil;
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    NSLog(@"Hud: %@", hud);
    // Remove HUD from screen when the HUD was hidded
    if(HUD)
    {
        [HUD removeFromSuperview];
        HUD = nil;
    }
}


#pragma mark - Restart System, Restart WiFi
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

#pragma mark - wps Connection Mode Setting
- (void)quickSettingForWPSMode:(BAND_TYPE)type
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (type == BAND_TYPE_24G)
    {
        [[NetManager sharedNetManager] requestWiFiEnableStateFor2G:^(id data, NSError *error) {
            if (data)
            {
                NSDictionary *dict = (NSDictionary *)data;
                if ([[dict objectForKey:WiFi_Enable_2G] isEqualToString:@"1"])
                {
                    [[NetManager sharedNetManager] requestWiFiWPSDataFor2G:^(id data, NSError *error) {
                        if (data)
                        {
                            NSDictionary *tmpDic = (NSDictionary *)data;
                            
                            if ([[tmpDic objectForKey:WiFi_WPS_Enable_2G] isEqualToString:@"1"])
                            {
                                [dictionary setObject:WiFi_WPS_Set_Name forKey:URL_CONFIG_ID];
                                [dictionary setObject:[NSString stringWithFormat:@"%ld",(long)type] forKey:WiFi_Type];
                                [dictionary setObject:[tmpDic objectForKey:WiFi_WPS_Enable_2G] forKey:WiFi_WPS_Set_Enable];
                                [dictionary setObject:[WiFi_WPS_Mode_Key objectForKey:@"PBC Mode"] forKey:WiFi_WPS_Set_Mode];
                                [dictionary setObject:[tmpDic objectForKey:WiFi_WPS_Client_Pin_2G] forKey:WiFi_WPS_Set_Client_Pin];
                                
                                [[NetManager sharedNetManager] configDataWithParam:dictionary andBlock:^(id data, NSError *error) {
                                    if(data)
                                    {
                                        [[Utility defaultUtility] refreshWpsModeStatus:type];
                                    }
                                }];
                            }
                            else if ([[tmpDic objectForKey:WiFi_WPS_Enable_2G] isEqualToString:@"0"])
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"WiFiWPSSwitchDisable2GStr",NULL,@"TipStrings")
                                                                                message:@""
                                                                               delegate:self
                                                                      cancelButtonTitle:nil
                                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                                [alert show];
                            }
                        }
                        else
                        {
                            NSLog(@"error occurs");
                        }
                    }];
                }
                else if ([[dict objectForKey:WiFi_Enable_2G] isEqualToString:@"0"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"WiFiSwitchDisable2GStr",NULL,@"TipStrings")
                                                                    message:@""
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                    [alert show];
                }
            }
            else
            {
                
            }
            
        }];
    }
    else if (type == BAND_TYPE_5G)
    {
        [[NetManager sharedNetManager] requestWiFiEnableStateFor5G:^(id data, NSError *error) {
            if (data)
            {
                NSDictionary *dict = (NSDictionary *)data;
                if ([[dict objectForKey:WiFi_Enable_5G] isEqualToString:@"1"])
                {
                    [[NetManager sharedNetManager] requestWiFiWPSDataFor5G:^(id data, NSError *error) {
                        if (data)
                        {
                            NSDictionary *tmpDic = (NSDictionary *)data;
                            
                            if ([[tmpDic objectForKey:WiFi_WPS_Enable_5G] isEqualToString:@"1"])
                            {
                                
                                [dictionary setObject:WiFi_WPS_Set_Name forKey:URL_CONFIG_ID];
                                [dictionary setObject:[NSString stringWithFormat:@"%ld",(long)type] forKey:WiFi_Type];
                                [dictionary setObject:[tmpDic objectForKey:WiFi_WPS_Enable_5G] forKey:WiFi_WPS_Set_Enable];
                                [dictionary setObject:[WiFi_WPS_Mode_Key objectForKey:@"PBC Mode"] forKey:WiFi_WPS_Set_Mode];
                                [dictionary setObject:[tmpDic objectForKey:WiFi_WPS_Client_Pin_5G] forKey:WiFi_WPS_Set_Client_Pin];
                                
                                [[NetManager sharedNetManager] configDataWithParam:dictionary andBlock:^(id data, NSError *error) {
                                    if(data)
                                    {
                                        [[Utility defaultUtility] refreshWpsModeStatus:type];
                                    }
                                }];
                            }
                            else if ([[tmpDic objectForKey:WiFi_WPS_Enable_5G] isEqualToString:@"0"])
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"WiFiWPSSwitchDisable5GStr",NULL,@"TipStrings")
                                                                                message:@""
                                                                               delegate:self
                                                                      cancelButtonTitle:nil
                                                                      otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                                [alert show];
                            }
                        }
                        else
                        {
                            NSLog(@"error occurs");
                        }
                    }];
                }
                else if ([[dict objectForKey:WiFi_Enable_5G] isEqualToString:@"0"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"WiFiSwitchDisable5GStr",NULL,@"TipStrings")
                                                                    message:@""
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
                    [alert show];
                }
            }
            else
            {
                
            }
        }];
    }
}

- (void)refreshWpsModeStatus:(BAND_TYPE)type
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:WiFi_WPS_Opt_Name forKey:URL_CONFIG_ID];
    if (type == BAND_TYPE_24G)
    {
        [info setObject:[NSString stringWithFormat:@"%ld",(long)type] forKey:WiFi_Type];
    }
    else
    {
        [info setObject:[NSString stringWithFormat:@"%ld",(long)type] forKey:WiFi_Type];
    }
    [info setObject:@"5" forKey:WiFi_WPS_Set_Mode];
    
    userInfo = info;
    
    if (refreshWPSStatusThd)
    {
        refreshWPSStatusThd = nil;
    }
    refreshWPSStatusThd = [[NSThread alloc] initWithTarget:self selector:@selector(refreshWPSStatus) object:nil];
    [refreshWPSStatusThd start];
}

- (void)refreshWPSStatus
{
    for (NSInteger i = 120; i >= 1; i--)
    {
        if ([[NSThread currentThread] isCancelled])
        {
            [NSThread exit];
        }
        
        NSDictionary *dict = [[NetManager sharedNetManager] getWPSStatus];
        if ([[dict objectForKey:Get_WPS_Status] isEqualToString:@"TIMEOUT"] || [[dict objectForKey:Get_WPS_Status] isEqualToString:@"SUCCESS"] || [[dict objectForKey:Get_WPS_Status] isEqualToString:@"CROSS"] || [[dict objectForKey:Get_WPS_Status] isEqualToString:@"ERROR"])
        {
            break;
        }
        
        NSString *newTitle = [NSString stringWithFormat:@"Remain : %ld",(long)i];
        [self performSelectorOnMainThread:@selector(refreshPopViewTitle:) withObject:newTitle waitUntilDone:YES];
        
        sleep(1);
    }
    
    [self performSelectorOnMainThread:@selector(terminateWPSStatus) withObject:nil waitUntilDone:YES];
    [NSThread exit];
}

- (void)refreshPopViewTitle:(NSString *)newTitle
{
    if (popView == nil)
    {
        NSArray *btnList = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"cancelStr",NULL,@"ButtonStrings"),@"buttonTitle",[NSNumber numberWithInteger:POPVIEW_BUTTON_CANCEL],@"buttonID", nil],nil];
        
        popView = [[PopView alloc] initWithTitle:@"" buttonList:btnList];
        [popView showWithcompletion:^(id data, NSError *error) {
            
            [refreshWPSStatusThd cancel];
            popView = nil;
            
            if (data == nil)
            {
                [[NetManager sharedNetManager] configDataWithParam:userInfo andBlock:^(id data, NSError *error) {
                    
                    NSString *result = [data objectForKey:@"result"];
                    if([result isEqualToString:@"success"])
                        ;
                }];
            }
            
        }];
    }
    
    [popView changePopViewTitle:newTitle];
}

- (void)terminateWPSStatus
{
    [popView dismiss];
}

#pragma mark - Modem Status
- (BOOL)currentModemStatus
{
    NSDictionary *modemStatus = [[NetManager sharedNetManager] getCurrentModemStatus];
    
    if ([[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"sim_ready"] ||
        [[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"pin_enable"] ||
        [[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"need_pin"] ||
        [[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"need_puk"] ||
        [[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"puk_lock"] ||
        [[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"sim_lock"])
    {
        return YES;
    }
    else
    {
        if ([[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"not_invalid"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"InvalidSIMCardStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
            
        }
        else if ([[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"no_simcard"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"NoSIMCardStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
        }
        else if ([[modemStatus objectForKey:MODEM_STATUS] isEqualToString:@"not_ready"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"NotReadySIMCardStr",NULL,@"TipStrings")
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedStringFromTable(@"okStr",NULL,@"ButtonStrings"),nil];
            [alert show];
        }
    }
    return NO;
}

#pragma mark -

//获取屏幕截屏方法
- (UIImage *)captureImageInView:(UIView *)inView
{
    // 创建一个context
    UIGraphicsBeginImageContextWithOptions(inView.bounds.size, inView.opaque, 0.0);
    
    //把当前的全部画面导入到栈顶context中并进行渲染
    [inView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // 从当前context中创建一个新图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark -

- (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *uuidStr = [NSString stringWithString:(__bridge NSString *)string];
    CFRelease(string);
    return uuidStr;
}

- (void)setWiFiMobleConfigFile:(NSString *)ssid password:(NSString *)password
{
    NSMutableDictionary *configRootDict = [NSMutableDictionary dictionaryWithDictionary:WiFi_MobileConfig_Dict];
   
    // PayloadContent(NSArray)
    NSMutableArray *rootContentList = [configRootDict objectForKey:@"PayloadContent"];
    
    // get item0 at rootContentList
    NSMutableDictionary *itemDict = [rootContentList objectAtIndex:0];
    
    // set item0 contents
    [itemDict setObject:ssid forKey:@"SSID_STR"];
    [itemDict setObject:password forKey:@"Password"];
    [itemDict setObject:[self getUUID] forKey:@"PayloadUUID"];
    
    // replace item0 for rootContentList
    [rootContentList replaceObjectAtIndex:0 withObject:itemDict];
    
    // set PayloadContent(NSArray)
    [configRootDict setObject:rootContentList forKey:@"PayloadContent"];
    // set PayloadUUID
    [configRootDict setObject:[self getUUID] forKey:@"PayloadUUID"];
    
    //
    NSString *configFilePath = [DOCUMENT stringByAppendingPathComponent:WiFiMobleConfigFileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:configFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:configFilePath error:nil];
    BOOL success = [configRootDict writeToFile:configFilePath atomically:YES];
    
    //
    __weak AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UInt16 port = appDelegate.httpServer.port;
    NSLog(@"%u", port);
    if(success)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%u/%@", port,WiFiMobleConfigFileName]]];
    else
        NSLog(@"Error generating profile");
}

@end
