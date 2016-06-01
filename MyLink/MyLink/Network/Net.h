//
//  Net.h
//  MyLink
//
//  Created by chen on 15/12/30.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#ifndef Net_h
#define Net_h

typedef enum
{
    Get = 0,
    Post,
    Put,
    Delete
}NetworkRequestMethod;

#define BASE_URL_STR    [[Utility defaultUtility] baseURL]
//#define BASE_URL_STR    @"http://192.168.1.1/"
//#define BASE_URL_STR    @"http://192.168.0.1/"

#define MY_DEVICE_NAME  @"longcheermifi"
#define LC_URL @"get_lc_request_url"

// ----------------------------------------------------------------------------------------------------
//
#define NETWORK_CONNECTED       @"connected"
#define NETWORK_DISCONNECTED    @"disconnected"
#define NETWORK_CONNECTING      @"connecting"
#define NETWORK_DISCONNECTING   @"disconnecting"

// ----------------------------------------------------------------------------------------------------
// Login/Logout
#define URL_Authentication          @"cgi-bin/ajax_get.cgi?which_ajax=check_password&pram=%@&username=%@&sids=%ld"
#define URL_Authentication_PASS     @"cgi-bin/ajax_get.cgi?which_ajax=check_password&pram=%@&sids=%ld"

#define URL_Logout                  @"ajax_session?sid=logout"
#define URL_CommitLoginAppSessionID @"ajax_session?sid=%ld"

#define URL_AppIsTimeOut            @"ajax_timmer"
#define URL_AppSessionIsValid       @"remember_timmer?sid=%ld"
#define URL_AppResetTimer           @"reset_timmer"

// ----------------------------------------------------------------------------------------------------
// Get and Set

#define URL_GET                 @"cgi-bin/iapp_get_full.cgi?cmd="
#define URL_CONFIG              @"cgi-bin/iapp_set_full.cgi"
#define URL_CONFIG_ID           @"goformId"

// Device Name
#define DEVICE_NAME             @"get_device_name"

// Main UI
#define MODEM_STATUS            @"modem_status"
#define ROAMING_STATUS          @"roaming_status"
#define OPERATOR_NAME           @"operator_name"
#define NETWORK_TYPE            @"network_type"
#define SIGNAL_STRENGTH         @"signal_strength"
#define BATTERT_STATUS          @"battery_status"
#define BATTERT_STATUS_PERCENT  @"battery_status_percent"
#define SDCARD_STATUS           @"sdcard_status"
#define WIFI_USER_NUM           @"wifi_user_num"
#define NETWORK_CONNECT_STATUS  @"network_connect_status"

// Connection
#define Network_Connect_Time        @"real_time"
#define Network_Connect_Transmitted @"sent_bytes"
#define Network_Connect_Received    @"receive_bytes"

#define Network_Connect_StartDate       @"traffic_start_time"
#define Network_Connect_Time_All        @"device_live_time"
#define Network_Connect_Sent_All        @"device_sent_bytes"
#define Network_Connect_Received_All    @"device_recv_bytes"
#define Network_Connect_TotalData_All   @"device_total_bytes"

#define Config_Traffic_Reset        @"net_traffic_restart"

#define Network_Connect             @"connectNetwork"
#define Config_Network_Connect      @"opt_dial"

// Status
#define Get_Device_list         @"get_device_list"
#define Device_List_Clients     @"clients"
#define Device_Connect_Duration @"connectionDuration"
#define Device_HostName         @"hostname"
#define Device_IP               @"ip"
#define Device_MacAddress       @"macAddress"
#define Device_Mode             @"mode"

// Setting->Quick Setup
#define WiFi_Setting_Name       @"wifi_settings"
#define WiFi_Type               @"wifi_type"
#define WiFi_Wep_Password       @"wifi_wep_password"
#define WiFi_Enable             @"wifi_enable"
#define WiFi_Interface          @"wifi_interface"
#define WiFi_Reg_Domain         @"wifi_reg_domain"
#define WiFi_Channel            @"wifi_channel"
#define WiFi_Bintval            @"wifi_bintval"
#define WiFi_BandWidth          @"wifi_bandwidth"
#define WiFi_SSID_Name          @"wifi_ssid"
#define WiFi_SSID_Broadcast     @"wifi_ssidbroadcast"
#define WiFi_Max_Sta            @"wifi_max_sta"
#define WiFi_Security_Mode      @"wifi_securitymode"
#define WiFi_Password           @"wifi_password"

// Setting->Wan
#define Web_APN_List        @"web_apn_list"
#define APN_ApnListSize     @"apnListSize"
#define APN_OldDefaultIndex @"oldDefaultIndex"
#define APN_OldNetMode      @"oldNetMode"
#define APN_SendMsg         @"sendMsg"
#define APN_ApnList         @"apnList"
#define APN_Index           @"index"
#define APN_WhetherDefault  @"wetherDefault"
#define APN_ProfileName     @"proFilename"
#define APN_UserName        @"userName"
#define APN_Password        @"password"
#define APN_Apn             @"apn"
#define APN_DialNum         @"telNumber"
#define APN_AuthType        @"auth"
#define APN_NetMode         @"netMode"
#define APN_IPMode          @"ipMode"
#define Config_APN_List     @"net_set_apn"

#define Net_Search_Mode             @"net_work_select"
#define Net_Search_List             @"net_search_list"
#define Operator_Name               @"operatorname"
#define Operator_Network_Type       @"networktype"
#define Operator_Currrent_Status    @"currentstatus"
#define Operator_Identity           @"identity"
#define Operator_Rrat               @"rrat"

#define Net_Search_Select_Changed   @"net_search_select_changed"
#define Net_Search_Select_ID1       @"net_search_selected_id_1"
#define Net_Search_Select_ID2       @"net_search_selected_id_2"
#define Net_Search_Select_Type      @"net_search_selected_type"
#define Config_Net_Search_List      @"net_search_list"
#define Config_Net_Search_Setting   @"net_search_setting"

#define Roaming_Status          @"roaming_status"
#define Roaming_Switch          @"net_roaming_switch"
#define Net_Connect_Mode        @"net_connect_mode"
#define Net_Work_Mode           @"net_work_mode"
#define Config_Net_Set_Mode     @"net_set_mode"

#define SIM_Status              @"sim_status_status"
#define SIM_PIN_Remain_Num      @"remain_pin_num"
#define SIM_PUK_Remain_Num      @"remain_puk_num"

#define SIM_Old_PIN_Num         @"OldPinNumber"
#define SIM_New_PIN_Num         @"NewPinNumber"
#define SIM_PIN_Num             @"PinNumber"
#define SIM_PUK_Num             @"PUKNumber"

#define Config_PIN_Enable       @"net_enable_pin"
#define Config_PIN_Disable      @"net_disable_pin"
#define Config_PIN_Change       @"net_change_pin"
#define Config_PIN_Unlock       @"net_unlock_pin"
#define Config_PUK_Unlock       @"net_unlock_puk"

// Setting->Wi-Fi
#define WiFi_Enable_2G                  @"wifi_enable_2G"
#define WiFi_SSID_Broadcast_2G          @"wifi_ssidbroadcast_2G"
#define WiFi_SSID_2G                    @"wifi_ssid_2G"
#define WiFi_Interface_2G               @"wifi_interface_2G"
#define WiFi_Channel_2G                 @"wifi_channel_2G"
#define WiFi_Bintval_2G                 @"wifi_bintval_2G"
#define WiFi_Bandwidth_2G               @"wifi_bandwidth_2G"
#define WiFi_MaxSta_2G                  @"wifi_max_sta_2G"
#define WiFi_SecurityMode_2G            @"wifi_securitymode_2G"
#define WiFi_Wep_Password_2G            @"wifi_wep_password_2G"
#define WiFi_Wpa_Password_2G            @"wifi_wpa_password_2G"
#define WiFi_MacFilter_Enable_2G        @"wifi_macfilter_enable_2G"
#define Mac_Filter_Control_2G           @"mac_filter_control_2G"
#define WiFi_MacFilter_Rule_String_2G   @"wifi_macfilter_rule_string_2G"
#define WiFi_WPS_Enable_2G              @"wifi_wps_enable_2G"
#define WiFi_WPS_Mode_2G                @"wifi_wps_mode_2G"
#define WiFi_WPS_Client_Pin_2G          @"wifi_wps_client_pin_2G"
#define WiFi_Reg_Domain_2G              @"wifi_reg_domain_2G"

#define WiFi_Enable_5G                  @"wifi_enable_5G"
#define WiFi_SSID_Broadcast_5G          @"wifi_ssidbroadcast_5G"
#define WiFi_SSID_5G                    @"wifi_ssid_5G"
#define WiFi_Interface_5G               @"wifi_interface_5G"
#define WiFi_Channel_5G                 @"wifi_channel_5G"
#define WiFi_Bintval_5G                 @"wifi_bintval_5G"
#define WiFi_Bandwidth_5G               @"wifi_bandwidth_5G"
#define WiFi_MaxSta_5G                  @"wifi_max_sta_5G"
#define WiFi_SecurityMode_5G            @"wifi_securitymode_5G"
#define WiFi_Wep_Password_5G            @"wifi_wep_password_5G"
#define WiFi_Wpa_Password_5G            @"wifi_wpa_password_5G"
#define WiFi_MacFilter_Enable_5G        @"wifi_macfilter_enable_5G"
#define WiFi_MacFilter_Rule_String_5G   @"wifi_macfilter_rule_string_5G"
#define Mac_Filter_Control_5G           @"mac_filter_control_5G"
#define WiFi_WPS_Enable_5G              @"wifi_wps_enable_5G"
#define WiFi_WPS_Mode_5G                @"wifi_wps_mode_5G"
#define WiFi_WPS_Client_Pin_5G          @"wifi_wps_client_pin_5G"
#define WiFi_Reg_Domain_5G              @"wifi_reg_domain_5G"

#define Config_WiFi_Restart @"wifi_restart"
#define WiFi_Type           @"wifi_type"
#define WiFi_Type_Param     @"apall"

#define WiFi_Mac_Filter_Name            @"wifi_mac_filter"
#define WiFi_Mac_Filter_Enable          @"wifi_macfilter_enable"
#define WiFi_Mac_Filter_Control         @"mac_filter_control"
#define WiFi_Mac_Filter_Rule_String     @"wifi_macfilter_rule_string"

#define Get_WPS_Status                  @"get_wps_status"
#define WiFi_WPS_Set_Name               @"wifi_wps_set"
#define WiFi_WPS_Opt_Name               @"wifi_wps_opt"
#define WiFi_WPS_Set_Enable             @"wifi_wps_enable"
#define WiFi_WPS_Set_Mode               @"wifi_wps_mode"
#define WiFi_WPS_Set_Client_Pin         @"wifi_wps_client_pin"

// Setting->Router
#define RT_UPnP_Enable      @"rt_upnp_enabled"
#define RT_L2TP_Enable      @"rt_l2tp_pass_enable"
#define RT_PPTP_Enable      @"rt_pptp_pass_enable"
#define RT_IPSec_Enable     @"rt_ipsec_pass_enable"
#define Config_Router_Basic @"router_basic"

#define RT_LanIP            @"rt_lanip"
#define RT_NetMask          @"rt_netmask"
#define RT_HostName         @"rt_hostname"
#define RT_DHCPS_Enable     @"rt_dhcps_enabled"
#define RT_DHCPS_StartIP    @"rt_dhcps_startip"
#define RT_DHCPS_EndIP      @"rt_dhcps_endip"
#define RT_DHCPS_Lease      @"rt_dhcps_lease"
#define RT_DHCPS_MaxClient  @"rt_dhcps_macclient"
#define RT_DNS_Mode         @"rt_dns_mode"
#define RT_DNS_List         @"rt_dns_list"
#define RT_DNS_Relay_Enable @"rt_dnsrelay_enabled"
#define Config_Router_DHCP  @"router_dhcp"

#define RT_DHCP_Static              @"rt_dhcps_static"
#define Config_Router_Static_Dhcp   @"router_static_dhcp"

#define RT_DDNS_Server      @"rt_ddns_server"
#define RT_DDNS_UserName    @"rt_ddns_username"
#define RT_DDNS_Password    @"rt_ddns_pwd"
#define RT_DDNS_Domain      @"rt_ddns_domain"
#define Config_Router_DDNS  @"router_ddns"

#define RT_IP_Filter_Control    @"rt_ip_filter_control"
#define RT_IP_Filter_Rule       @"rt_ip_filter_rule"
#define Config_IP_Filter        @"router_ipfilter"

#define RT_URL_Filter_Control   @"rt_url_filter_control"
#define RT_URL_Filter_Rule      @"rt_url_filter_rule"
#define Config_URL_Filter       @"router_urlfilter"

#define RT_Port_Forward_Enabled @"rt_portfwd_enabled"
#define RT_Port_Forward_Rule    @"rt_portfwd_rule"
#define Config_Port_Forward     @"router_portforward"

#define RT_DMZ_Enabled  @"rt_dmz_enabled"
#define RT_DMZ_Host     @"rt_dmz_host"
#define RT_DMZ_Src      @"rt_dmz_src"
#define Config_DMZ      @"router_dmz"

// Setting->System
#define SYS_New_UserName        @"sys_new_username"
#define SYS_New_Password        @"sys_new_pass"
#define Config_System_Setting   @"system_setting"

#define Config_System_Restore   @"system_restore"

#define SYS_Param               @"pram"
#define SYS_Reboot              @"reboot"
#define SYS_Shutdown            @"shutdown"
#define Config_System_Reboot    @"reboot_system"

#define SYS_Current_Time    @"device_current_time"
#define SYS_Time_Mode       @"sys_time_mode"
#define SYS_NTP_Server      @"sys_ntp_server"
#define SYS_Time_Zone       @"sys_time_zone"
#define SYS_Year            @"sys_year"
#define SYS_Month           @"sys_month"
#define SYS_Day             @"sys_day"
#define SYS_Hour            @"sys_hour"
#define SYS_Minute          @"sys_minute"
#define Config_System_Time  @"system_time"

#define Setting_Storage         @"system_sdcard_share_mode"
#define Setting_Storage_Mode    @"sdcard_share_mode"
#define Config_Setting_Storage  @"system_sdcard_share_mode"

// Setting->About
#define About_Modem_Version         @"modem_version"
#define About_Software_Version      @"software_version"
#define About_Hardware_Version      @"hardware_version"
#define About_IMEI                  @"sim_imei"
#define About_MacAddress            @"about_mac_address"
#define About_MacAddress5G          @"about_mac_address_5G"

// SD Card
#define SD_Card_Status              @"sdcard_status"
#define Wan_IP_Address_Ipv4         @"wan_ip_addr_ipv4"
#define Wan_IP_Address_Ipv6         @"wan_ip_addr_ipv6"     //中国未使用IPV6
#define SD_Card_Info                @"cgi-bin/iapp_sdcard.cgi?which_cgi=sdcard_info"
#define URL_SD_GET_FILELIST         @"cgi-bin/iapp_sdcard.cgi?which_cgi=sdcard_file_list&current_folder_dir="
#define URL_SD_GET_FILELIST_BT_TYPE @"cgi-bin/iapp_sdcard.cgi?which_cgi=sdcard_file_list_by_type&type="
#define URL_SD_CONFIG               @"cgi-bin/iapp_sdcard.cgi"
#define URL_SD_FILE_UPLOAD          @"cgi-bin/iapp_upfile.cgi"

// ----------------------------------------------------------------------------------------------------
// Key-Value

// WiFi_Security_Mode
#define WiFi_SecurityMode_Value [NSDictionary dictionaryWithObjectsAndKeys:@"None",@"0100,1",@"WEP 64 Bit - Shared",@"0201,2",@"WEP 128 Bit - Shared",@"0201,3",@"WEP 64 Bit - Open",@"0200,4",@"WEP 128 Bit - Open",@"0200,5",@"WPA-Personal TKIP",@"0804,6",@"WPA-Personal TKIP/AES",@"0812,7",@"WPA2-Personal AES",@"3208,8",@"WPA2-Personal TKIP/AES",@"3212,9",@"WPA/WPA2 Personal",@"4012,10", nil]

#define WiFi_SecurityMode_Key [NSDictionary dictionaryWithObjectsAndKeys:@"0100,1",@"0",@"0201,2",@"1",@"0201,3",@"2",@"0200,4",@"3",@"0200,5",@"4",@"0804,6",@"5",@"0812,7",@"6",@"3208,8",@"7",@"3212,9",@"8",@"4012,10",@"9", nil]

#define WiFi_Security_Mode_Menu @[@"None",@"WEP 64 Bit - Shared",@"WEP 128 Bit - Shared",@"WEP 64 Bit - Open",@"WEP 128 Bit - Open",@"WPA-Personal TKIP",@"WPA-Personal TKIP/AES",@"WPA2-Personal AES",@"WPA2-Personal TKIP/AES",@"WPA/WPA2 Personal"]

// WiFi_Interface
//#define WiFi_Interface_Menu @[@"bgn",@"n",@"b",@"bg"]
#define WiFi_Interface_Menu_2G  @[@"802.11n Only",@"802.11b Only",@"802.11b/g Compatible",@"802.11b/g/n Compatible"]
#define WiFi_Interface_Value_2G [NSDictionary dictionaryWithObjectsAndKeys:@"802.11n Only",@"n",@"802.11b Only",@"b",@"802.11b/g Compatible",@"bg",@"802.11b/g/n Compatible",@"bgn",nil]
#define WiFi_Interface_Key_2G   [NSDictionary dictionaryWithObjectsAndKeys:@"n",@"802.11n Only",@"b",@"802.11b Only",@"bg",@"802.11b/g Compatible",@"bgn",@"802.11b/g/n Compatible",nil]

#define WiFi_Interface_Menu_5G  @[@"802.11a/n/ac Compatible"]
#define WiFi_Interface_Value_5G [NSDictionary dictionaryWithObjectsAndKeys:@"802.11a/n/ac Compatible",@"anc",nil]
#define WiFi_Interface_Key_5G   [NSDictionary dictionaryWithObjectsAndKeys:@"anc",@"802.11a/n/ac Compatible",nil]


// WiFi_Channle
#define Change_Auto_To_Zero      [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"Auto",nil]
#define Change_Zero_To_Auto      [NSDictionary dictionaryWithObjectsAndKeys:@"Auto",@"0",nil]
#define WiFi_Channel_Menu_2G_1   @[@"Auto",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13"]
#define WiFi_Channel_Menu_2G_2   @[@"Auto",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11"]
#define WiFi_Reg_Domain_List_2G  @[@"CA",@"CO",@"DO",@"GT",@"MX",@"PA",@"PR",@"TW",@"US",@"UZ"]

#define WiFi_Reg_Domain_List_5G_1  @[@"CA",@"US"]
#define WiFi_Channel_Menu_5G_1     @[@"Auto",@"36",@"40",@"44",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"132",@"136",@"140",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_2  @[@"CH"]
#define WiFi_Channel_Menu_5G_2     @[@"Auto",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"132",@"136",@"140"]

#define WiFi_Reg_Domain_List_5G_3  @[@"JP"]
#define WiFi_Channel_Menu_5G_3     @[@"Auto",@"7",@"8",@"9",@"11",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"132",@"136",@"140",@"149",@"153",@"157",@"161",@"165",@"183",@"184",@"185",@"187",@"188",@"189",@"192",@"196"]

#define WiFi_Reg_Domain_List_5G_4  @[@"SG"]
#define WiFi_Channel_Menu_5G_4     @[@"Auto",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_5  @[@"CN"]
#define WiFi_Channel_Menu_5G_5     @[@"Auto",@"36",@"40",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_6  @[@"IL"]
#define WiFi_Channel_Menu_5G_6     @[@"Auto",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"64"]

#define WiFi_Reg_Domain_List_5G_7  @[@"KP",@"KR"]
#define WiFi_Channel_Menu_5G_7     @[@"Auto",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_8  @[@"TR"]
#define WiFi_Channel_Menu_5G_8     @[@"Auto",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"132",@"136",@"140"]

#define WiFi_Reg_Domain_List_5G_9  @[@"AU"]
#define WiFi_Channel_Menu_5G_9     @[@"Auto",@"36",@"40",@"44",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"132",@"136",@"140",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_10  @[@"BR"]
#define WiFi_Channel_Menu_5G_10     @[@"Auto",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"132",@"136",@"140",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_11  @[@"TW"]
#define WiFi_Channel_Menu_5G_11     @[@"Auto",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"132",@"136",@"140",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_12  @[@"NZ"]
#define WiFi_Channel_Menu_5G_12     @[@"Auto",@"34",@"36",@"38",@"40",@"42",@"44",@"46",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"132",@"136",@"140",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Reg_Domain_List_5G_13  @[@"IN"]
#define WiFi_Channel_Menu_5G_13     @[@"Auto",@"36",@"40",@"44",@"48",@"52",@"56",@"60",@"64",@"149",@"153",@"157",@"161",@"165"]

#define WiFi_Channel_Menu_5G_14     @[@"Auto",@"36",@"40",@"44",@"48",@"52",@"56",@"60",@"64",@"100",@"104",@"108",@"112",@"116",@"120",@"124",@"128",@"132",@"136",@"140"]

// WiFi_regulatory_Domain
#define WiFi_regulatory_Domain_Menu [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RegDomain" ofType:@"plist"]]

// WiFi_Band_Width
//#define WiFi_Band_Width_Menu @[@"0",@"2",@"1"]
#define WiFi_Band_Width_Menu_2G  @[@"HT20",@"HT40",@"HT20/40mixed"]
#define WiFi_Band_Width_Value_2G [NSDictionary dictionaryWithObjectsAndKeys:@"HT20",@"0",@"HT40",@"2",@"HT20/40mixed",@"1",nil]
#define WiFi_Band_Width_Key_2G   [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"HT20",@"2",@"HT40",@"1",@"HT20/40mixed",nil]

#define WiFi_Band_Width_Menu_5G  @[@"HT20",@"HT40",@"HT80"]
#define WiFi_Band_Width_Value_5G [NSDictionary dictionaryWithObjectsAndKeys:@"HT20",@"0",@"HT40",@"2",@"HT80",@"3",nil]
#define WiFi_Band_Width_Key_5G   [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"HT20",@"2",@"HT40",@"3",@"HT80",nil]

// WiFi_Max_Number_Users
#define WiFi_Max_Number_Users_Menu @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"]

// WiFi_WPS_Mode
#define WiFi_WPS_Mode_Value [NSDictionary dictionaryWithObjectsAndKeys:@"Client PIN Mode",@"2",@"PBC Mode",@"1",@"No Connection",@"0",nil]
#define WiFi_WPS_Mode_Menu @[@"Client PIN Mode",@"PBC Mode",@"No Connection"]
#define WiFi_WPS_Mode_Key [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"Client PIN Mode",@"1",@"PBC Mode",@"0",@"No Connection",nil]

// WiFi_Connect_Mode
#define WiFi_Connect_Mode_Value [NSDictionary dictionaryWithObjectsAndKeys:@"WiFi",@"0",@"USB",@"1",nil]

// Lan_Lease_Time
#define Lan_Lease_Time_Value [NSDictionary dictionaryWithObjectsAndKeys:@"Half Hour",@"30",@"One Hour",@"60",@"Tow Hour",@"120",@"Half Day",@"720",@"One Day",@"1440",@"Tow Days",@"2880",@"One Week",@"10080",@"Two Weeks",@"20160",nil]

#define Lan_Lease_Time_Key [NSDictionary dictionaryWithObjectsAndKeys:@"30",@"0",@"60",@"1",@"120",@"2",@"720",@"3",@"1440",@"4",@"2880",@"5",@"10080",@"6",@"20160",@"7",nil]

#define Lan_Lease_Time_Menu @[@"Half Hour",@"One Hour",@"Tow Hour",@"Half Day",@"One Day",@"Tow Days",@"One Week",@"Two Weeks"]

// System_Time_Zone
#define System_Time_Zone_Value [NSDictionary dictionaryWithObjectsAndKeys:@"(GMT-12) Eniwetok",@"-120001",@"(GMT-11) Samoa",@"-110001",@"(GMT-10) Hawaii",@"-100001",@"(GMT-9) Alaska",@"-090001",@"(GMT-8) Pacific Time",@"-080001",@"(GMT-7) Mountain Time",@"-070001",@"(GMT-6) Central Time",@"-060001",@"(GMT-5) Eastern Time",@"-050001",@"(GMT-4) Atlantic Time",@"-040001",@"(GMT-3) Brazilia",@"-030001",@"(GMT-2) Mid-Atlantic",@"-020001",@"(GMT-1) Azores",@"-010001",@"(GMT) Greenwich Mean Time",@"-000001",@"(GMT+1) Rome",@"+010001",@"(GMT+2) Israel",@"+020001",@"(GMT+3) Moscow",@"+030001",@"(GMT+4) Baghdad, Iraq",@"+040001",@"(GMT+5) New Delhi",@"+050001",@"(GMT+6) Dhakar",@"+060001",@"(GMT+7) Jakarta",@"+070001",@"(GMT+8) Hong Kong, Bei Jing",@"+080001",@"(GMT+9) Tokyo",@"+090001",@"(GMT+10) Sydney",@"+100001",@"(GMT+11) Magadan",@"+110001",@"(GMT+12) Welington",@"+120001",@"(GMT+13) NW Atlantic",@"+130001",nil]

#define System_Time_Zone_Key [NSDictionary dictionaryWithObjectsAndKeys:@"-120001",@"0",@"-110001",@"1",@"-100001",@"2",@"-090001",@"3",@"-080001",@"4",@"-070001",@"5",@"-060001",@"6",@"-050001",@"7",@"-040001",@"8",@"-030001",@"9",@"-020001",@"10",@"-010001",@"11",@"-000001",@"12",@"+010001",@"13",@"+020001",@"14",@"+030001",@"15",@"+040001",@"16",@"+050001",@"17",@"+060001",@"18",@"+070001",@"19",@"+080001",@"20",@"+090001",@"21",@"+100001",@"22",@"+110001",@"23",@"+120001",@"24",@"+130001",@"25",nil]

#define System_Time_Zone_Menu @[@"(GMT-12) Eniwetok",@"(GMT-11) Samoa",@"(GMT-10) Hawaii",@"(GMT-9) Alaska",@"(GMT-8) Pacific Time",@"(GMT-7) Mountain Time",@"(GMT-6) Central Time",@"(GMT-5) Eastern Time",@"(GMT-4) Atlantic Time",@"(GMT-3) Brazilia",@"(GMT-2) Mid-Atlantic",@"(GMT-1) Azores",@"(GMT) Greenwich Mean Time",@"(GMT+1) Rome",@"(GMT+2) Israel",@"(GMT+3) Moscow",@"(GMT+4) Baghdad, Iraq",@"(GMT+5) New Delhi",@"(GMT+6) Dhakar",@"(GMT+7) Jakarta",@"(GMT+8) Hong Kong, Bei Jing",@"(GMT+9) Tokyo",@"(GMT+10) Sydney",@"(GMT+11) Magadan",@"(GMT+12) Welington",@"(GMT+13) NW Atlantic"]

#define Protocol_Menu_Index [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"TCP",@"1",@"UDP",@"2",@"Both",nil]

#endif /* Net_h */

