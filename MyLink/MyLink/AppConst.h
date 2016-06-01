//
//  AppConst.h
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#ifndef AppConst_h
#define AppConst_h

#define Debug_Mode  0
#define Need_Login  1

#define DATA_CONTAINER_GAP  10
#define DATA_CONTAINER_IN_X_GAP   10
#define DATA_CONTAINER_IN_Y_GAP   5

#define TITLE_LABEL_HEIGHT      20
#define SETTING_BUTTON_HEIGHT   26
#define INPUT_TEXTFIELD_HEIGHT  26

// --------------------------------------------------------------------------------------------------------------------
//
#define DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define PRIVATE_CONFIG          @"private.plist"
#define LOGIN_CONFIG            @"login.plist"
#define ADD_COMPONENT_CONFIG    @"addComponentConfig.plist"
#define HTTP_SHARE_CONFIG       @"httpShareConfig.plist"

#define WiFiMobleConfigFileName @"mylinkWiFi.mobileconfig"
#define WiFi_MobileConfig_Dict [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mylinkWiFi" ofType:@"mobileconfig"]]

// --------------------------------------------------------------------------------------------------------------------
//
typedef NS_ENUM(NSInteger, TOUCH_BUTTON_ID)
{
    TOUCH_BUTTON_NONE               =   0,
    TOUCH_BUTTON_LOGINOUT           =   1,
    TOUCH_BUTTON_STATUS             =   2,
    TOUCH_BUTTON_CONNECTION         =   3,
    TOUCH_BUTTON_WIFIDISK           =   4,
    TOUCH_BUTTON_SETTING            =   5,
    
    TOUCH_BUTTON_QUICKSETTING       =   6,
    TOUCH_BUTTON_ADVANCEDAETTING    =   7,
    TOUCH_BUTTON_MACFILTER_24G      =   8,
    TOUCH_BUTTON_MACFILTER_5G       =   9,
    TOUCH_BUTTON_PINSETTING         =   10,
    TOUCH_BUTTON_WPS                =   11,

    TOUCH_BUTTON_MYSMARTFREN        =   12,
    TOUCH_BUTTON_HTTPSHARE          =   13,
    TOUCH_BUTTON_LANCAMERA          =   14,
    TOUCH_BUTTON_WANCAMERA          =   15,
    TOUCH_BUTTON_WPSPBCBUTTON       =   16,
    TOUCH_BUTTON_WPSPBCBUTTON_5G    =   17,
    
    TOUCH_BUTTON_WIFIUSERS          =   18
};

typedef NS_ENUM(NSInteger, ADD_COMPONENT_INDEX)
{
    ADD_COMPONENT_INDEX_1   =   0,
    ADD_COMPONENT_INDEX_2   =   1,
    ADD_COMPONENT_INDEX_3   =   2,
    ADD_COMPONENT_INDEX_4   =   3
};

typedef NS_ENUM(NSInteger, POPVIEW_BUTTON_ID)
{
    POPVIEW_BUTTON_CANCEL   =   0,
    POPVIEW_BUTTON_ADD      =   1,
    POPVIEW_BUTTON_REMOVE   =   2,
    POPVIEW_BUTTON_MANAGE   =   3,
    POPVIEW_BUTTON_CONFIG   =   4
};

typedef NS_ENUM(NSInteger, BAND_TYPE)
{
    BAND_TYPE_24G   =   0,
    BAND_TYPE_5G    =   1
};

typedef NS_ENUM(NSInteger, INVALIDPASSWORD_TYPE)
{
    INVALID_TYPE_NONE   =   0,
    INVALID_TYPE_64B    =   1,
    INVALID_TYPE_128B   =   2,
    INVALID_TYPE_NOR    =   3
};

// SD Card
typedef enum
{
    SD_FILE_ALL,
    SD_FILE_IMAGE,
    SD_FILE_AUDIO,
    SD_FILE_VIDO,
    SD_FILE_DOCUMENT,
    SD_FILE_OTHERS
}SD_FILE_TYPE;

#define IMAGE_TYPE_LIST     @"png,bmp,jpg,jpeg,tiff"
#define AUDIO_TYPE_LIST     @"mp3,wav"
#define VIDEO_TYPE_LIST     @"mp4,mov,m4v,3gp"
#define DOCUMENT_TYPE_LIST  @"doc,docx,xls,xlsx,ppt,pptx,txt,rtf,pdf,htm,html,zip"

// --------------------------------------------------------------------------------------------------------------------
// Notification
#define ADDCOMPONENTNOTIFICATION @"ADDCOMPONENTNOTIFICATION"
#define ADDCOMPONENTSTAUSNOTIFICATION @"ADDCOMPONENTSTAUSNOTIFICATION"
#define SettingSheetDisappearNotification @"SettingSheetDisappearNotification"
#define HttpShareStatusNotification @"HttpShareStatusNotification"

#endif /* AppConst_h */
