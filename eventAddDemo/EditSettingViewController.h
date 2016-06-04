//
//  EditSettingViewController.h
//  eventAddDemo
//
//  Created by t00javateam@gmail.com on 2016/5/31.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

/* ViewController 實作 : 按下 save 按鈕後 , view controller 實作儲存的細節動作 */
@protocol EditSettingDelegate;

@interface EditSettingViewController : UIViewController <ViewControllerPopOverDelegate>
@property (nonatomic,weak) id<EditSettingDelegate> delegate;

/* ViewController 在生成 EditSettingViewController 時需把自己 (ViewController) 指派給 EditSettingViewController ,
   進而讓在 EditSettingViewController 實作的代理 "ViewControllerPopOverDelegate" 成為自己 (ViewController)  */
@property ViewController *mainPopController;

@end

@protocol EditSettingDelegate <NSObject>
@optional
-(void)viewController:(UIViewController*)vc saveEventByTitle:(NSString*)title andYear:(NSNumber*)year andMonth:(NSNumber*)month andDay:(NSNumber*)day andHour:(NSNumber*)hour andMinute:(NSNumber*)minute;

@end

