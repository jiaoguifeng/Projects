//
//  AppDelegate.m
//  MyLink
//
//  Created by chen on 15/12/28.
//  Copyright © 2015年 tricheer. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "NetManager.h"

@interface AppDelegate ()
{
    UIInterfaceOrientationMask rotationMask;
}

- (void)startServer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // For Video Play Rotation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateChanged:) name:@"CMPMoviePlayerViewRotateChanged" object:nil];
    rotationMask = UIInterfaceOrientationMaskPortrait;

    //
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    //
    [self startServer];
    
    // Window init
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    // 网络初始化
    [[NetManager sharedNetManager] startMonitor];

    //
    MainViewController *mainVC = [[MainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [mainVC.navigationController setNavigationBarHidden:YES];
    
    //
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [NSThread sleepForTimeInterval:1.0];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NetManager sharedNetManager] logout];
    [[NetManager sharedNetManager] stopMonitor];
    
    /*backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NetManager sharedNetManager] startMonitor];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    //UIInterfaceOrientationMaskPortrait
    //UIInterfaceOrientationMaskAllButUpsideDown;
    return rotationMask;
}

- (void)didRotateChanged:(NSNotification *)notification
{
    NSDictionary *theInfo = [notification userInfo];
    NSString *curView = [theInfo objectForKey:@"currentView"];
    if([curView isEqualToString:@"CMP_YES"])
        rotationMask = UIInterfaceOrientationMaskAllButUpsideDown;
    else
        rotationMask = UIInterfaceOrientationMaskPortrait;
}

- (void)startServer
{
    // Create server using our custom MyHTTPServer class
    _httpServer = [[RoutingHTTPServer alloc] init];
    
    // 设置文件格式为 Apple.mobileconfig
    [_httpServer setDefaultHeader:@"Content-Type" value:@"application/x-apple-aspen-config"];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [_httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [_httpServer setPort:8000];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [_httpServer setDocumentRoot:documentsDirectory];
    
    if(_httpServer.isRunning)
        [_httpServer stop];
    
    NSError *error;
    if([_httpServer start:&error])
    {
        NSLog(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
    }
    else
    {
        NSLog(@"Error starting HTTP Server: %@", error);
        // Probably should add an escape - but in practice never loops more than twice (bug filed on GitHub https://github.com/robbiehanson/CocoaHTTPServer/issues/88)
        [self startServer];
    }
}

@end
