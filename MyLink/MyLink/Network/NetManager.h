//
//  NetManager.h
//  MyLink
//
//  Created by chen on 15/12/30.
//  Copyright © 2015年 tricheer. All rights reserved.
//
//
/*
  NetManager，网络状态监测、业务数据获取及配置
 
  回调结果:
  1.没有数据，返回nil和error
  2.有数据，直接返回data(如果有转换需求，则根据业务需求把data转换成model)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Net.h"

@interface NetManager : NSObject
{
}

@property (nonatomic, assign) BOOL willGotoBackground;

@property (nonatomic, assign) NSInteger currentNetworkStatus;

@property (nonatomic, strong) NSString *baseURLForSD;

+ (NetManager *)sharedNetManager;

// Network moniter
- (void)startMonitor;
- (void)stopMonitor;

// Data request/config base function
- (void)requestDataWithParam:(NSDictionary *)param command:(NSString *)command andBlock:(void (^)(id data, NSError *error))block;
- (void)configDataWithParam:(NSDictionary *)param andBlock:(void (^)(id data, NSError *error))block;

// Device connected/lost moniter
- (BOOL)isConnectedViaWiFi;
- (BOOL)hostServerConnected;

// MainUI
- (void)requesetMainUIData:(void (^)(id data, NSError *error))block;

// Status
- (void)requestStatusData:(void (^)(id data, NSError *error))block;

// Connection
- (void)requestConnectionData:(void (^)(id data, NSError *error))block;

// Setting->Wan
- (void)requestWanProfileManagementData:(void (^)(id data, NSError *error))block;
- (void)requestWanNetworkSettingData:(void (^)(id data, NSError *error))block;
- (void)requestWanMobileConnectionData:(void (^)(id data, NSError *error))block;
- (void)requesetWanPINStatusData:(void (^)(id data, NSError *error))block;

// Setting->WiFi
- (void)requestWiFiSettingDataFor2G:(void (^)(id data, NSError *error))block;
- (void)requestWiFiSettingDataFor5G:(void (^)(id data, NSError *error))block;
- (void)requestWiFiFilterDataFor2G:(void (^)(id data, NSError *error))block;
- (void)requestWiFiFilterDataFor5G:(void (^)(id data, NSError *error))block;
- (void)requestWiFiWPSDataFor2G:(void (^)(id data, NSError *error))block;
- (void)requestWiFiWPSDataFor5G:(void (^)(id data, NSError *error))block;
- (void)requestWiFiEnableStateFor2G:(void (^)(id data, NSError *error))block;
- (void)requestWiFiEnableStateFor5G:(void (^)(id data, NSError *error))block;

// Setting->Router
- (void)requestRouterUPnPData:(void (^)(id data, NSError *error))block;
- (void)requestRouterLanData:(void (^)(id data, NSError *error))block;
- (void)requestRouterStaticDHCPData:(void (^)(id data, NSError *error))block;
- (void)requestRouterDDNSData:(void (^)(id data, NSError *error))block;
- (void)requestRouterLanIPFilterData:(void (^)(id data, NSError *error))block;
- (void)requestRouterURLFilterData:(void (^)(id data, NSError *error))block;
- (void)requestRouterPortForwardingData:(void (^)(id data, NSError *error))block;
- (void)requestRouterDMZSettingData:(void (^)(id data, NSError *error))block;

// Setting->System
- (void)requestSystemUserNamePassworkData:(void (^)(id data, NSError *error))block;
- (void)requestSystemTimeData:(void (^)(id data, NSError *error))block;
- (void)requestSystemCurrentTime:(void (^)(id data, NSError *error))block;
- (void)requestSystemStorageData:(void (^)(id data, NSError *error))block;
- (void)requestSystemInternetStorageData:(void (^)(id data, NSError *error))block;

// Setting->About
- (void)requestAboutData:(void (^)(id data, NSError *error))block;

// PIN
- (NSString *)pinStatus;
- (NSDictionary *)retainTimeOfPinPuk;

// login/logout
- (BOOL)isLoginStatus;
- (void)loginWithName:(NSString *)userName password:(NSString *)password andBlock:(void (^)(id data, id error))block;
- (void)logout;
- (int)commitLoginSession;
- (void)resetAppTimer;
- (BOOL)isLoginSessionValid;
- (BOOL)isLoginTimeout;

// SD Card
- (NSDictionary *)querySDStatus;
- (NSDictionary *)querySDInfo;
- (void)queryFileList:(NSString *)directory andBlock:(void (^)(id data, id error))block;
- (void)queryFileListByType:(NSString *)type andBlock:(void (^)(id data, id error))block;
- (void)createNewFolder:(NSDictionary *)param andBlock:(void (^)(id data, id error))block;
- (void)rename:(NSDictionary *)param andBlock:(void (^)(id data, id error))block;
- (void)deleteFile:(NSString *)param andBlock:(void (^)(id data, id error))block;
- (void)deleteMoreFile:(NSArray *)param andBlock:(void (^)(id data, id error))block;
- (void)downloadFile:(NSString *)srcPath toPath:(NSString *)destPath andBlock:(void (^)(id data, NSError *error))block;
- (UIImage *)downloadThumbnailImage:(NSString *)imagePath;
- (void)uploadImageToDisk:(NSString *)dstFolderName srcFilePath:(NSString *)srcFilePath andBlock:(void (^)(id data, NSError *error))block;

//Get WPS Status
- (NSDictionary *)getWPSStatus;

//Get Current Modem Status
- (NSDictionary *)getCurrentModemStatus;

@end
