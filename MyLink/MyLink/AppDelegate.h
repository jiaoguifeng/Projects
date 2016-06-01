//
//  AppDelegate.h
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoutingHTTPServer.h"

//UIBackgroundTaskIdentifier myBackgroundTask;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) RoutingHTTPServer *httpServer;

@end

