//
//  AppDelegate.m
//  eventAddDemo
//
//  Created by t00javateam@gmail.com on 2016/5/31.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import "AppDelegate.h"
/* 本機端儲存的import */
#import <MagicalRecord/MagicalRecord.h>
@interface AppDelegate ()

@end

@implementation AppDelegate{
     UIBackgroundTaskIdentifier bgTask;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MagicalRecord setupAutoMigratingCoreDataStack];
     [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /* 額外爭取3分鐘背景執行時間 */
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        UIApplication *application = [UIApplication sharedApplication];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
   
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if([_delegate respondsToSelector:@selector(refreshLocalEvent)]){
        [_delegate refreshLocalEvent];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
