//
//  AppDelegate.h
//  eventAddDemo
//
//  Created by t00javateam@gmail.com on 2016/5/31.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventAppDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) id<EventAppDelegate> delegate;

@end

@protocol EventAppDelegate <NSObject>

@optional
-(void)appDelegatedoRefreshLocalEvent:(AppDelegate*)appDelegate;
@end