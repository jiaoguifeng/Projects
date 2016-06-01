//
//  Utility.h
//  MyLink
//
//  Created by chen on 15/12/30.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppConst.h"

@interface Utility : NSObject

+ (Utility *)defaultUtility;

//
- (NSString *)baseURL;
- (void)setBaseURL:(NSString *)urlStr;
- (NSString *)getRouterGateway;

//
- (void)prepareConfigFiles;

//
- (NSDictionary *)privateConfigData;
- (void)setPrivateConfigData:(NSDictionary *)dict;
- (BOOL)isPrivateKeyOpenedAtIndex:(NSInteger)keyIndex;

//
- (NSArray *)addComponentConfigList;
- (void)setAddComponentConfigDict:(NSArray *)dictList;
- (void)setAddComponentConfigDictWithIndex:(NSInteger)index dict:(NSDictionary *)dict;

//
- (NSDictionary *)loginConfigData;
- (void)setLoginConfigData:(NSDictionary *)dict;

//
- (NSDictionary *)httpShareConfigData;
- (void)setHttpShareConfigData:(NSDictionary *)dict;

//
- (NSArray *)wifiPhotosList;
- (void)setWifiPhotosList:(NSArray *)photoList;
- (void)addToWifiPhotosList:(NSDictionary *)fileDict;
- (NSString *)wifiPhotosPath;
- (NSString *)currentDate;
- (NSString *)currentDateAndTime;

//
- (NSString *)fileTypeName:(NSString *)extensionStr;
- (SD_FILE_TYPE)fileType:(NSString *)extensionStr;

//
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//
- (void)showHudTipStr:(NSString *)tipStr;
- (void)showHudTipStr:(NSString *)tipStr withTimeInterval:(NSTimeInterval)timeInterval;
- (void)hudShowWithTitle:(NSString *)strTitle;
- (void)hudShowWithTitle:(NSString *)strTitle forView:(UIView *)forView;
- (void)hudShowWithProgress:(NSString *)strTitle;
- (void)hudShowWithProgress:(NSString *)strTitle andCancel:(NSString *)cancelStr;
- (void)setHudProgress:(float)progress;
- (void)hudClose;

//
- (void)rebootSystem;
- (void)restarttWiFi;

//
- (void)quickSettingForWPSMode:(BAND_TYPE)type;
- (void)refreshWpsModeStatus:(BAND_TYPE)type;

//
- (BOOL)currentModemStatus;

//
- (UIImage *)captureImageInView:(UIView *)inView;

//
- (void)setWiFiMobleConfigFile:(NSString *)ssid password:(NSString *)password;

@end
