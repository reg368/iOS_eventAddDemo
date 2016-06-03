//
//  ViewController.h
//  eventAddDemo
//
//  Created by t00javateam@gmail.com on 2016/5/31.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/* EditSettingViewController 實作 : 當 PopView 彈跳出來後再產生 EditSettingViewController 的內容畫面 */
@protocol ViewControllerPopOverDelegate;

@interface ViewController : UITableViewController

@property (nonatomic) id<ViewControllerPopOverDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *alarmControllerButton;

@end

@protocol ViewControllerPopOverDelegate <NSObject>

@optional
-(void)initView;

@end
