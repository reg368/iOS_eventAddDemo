//
//  ViewController.m
//  eventAddDemo
//
//  Created by t00javateam@gmail.com on 2016/5/31.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "EditSettingViewController.h"
#import "EventKit/EventKit.h"
#import "EventVO.h"
#import "AppDelegate.h"
/* 本機端儲存的import */
#import <MagicalRecord/MagicalRecord.h>

@interface ViewController ()<EditSettingDelegate,EventAppDelegate>

// The database with calendar events and reminders
@property (strong, nonatomic) EKEventStore *eventStore;

// The data source for the table view
@property (strong, nonatomic) NSMutableArray<EKEvent*> *eventItems;

@property (nonatomic)  EditSettingViewController *editView;
@property (strong, nonatomic) EKCalendar *calendar;

//date setting
@property (nonatomic) NSCalendar *nscalendar;
@property (nonatomic) NSDateComponents *dateComponents;

@end

@implementation ViewController{
    dispatch_queue_t updateEventIndexQueue;
}

-(EKEventStore*)eventStore{
    if(!_eventStore){
        _eventStore = [[EKEventStore alloc]init];
    }
    return _eventStore;
}

-(EditSettingViewController*)editView{
    if(!_editView){
        _editView = [[EditSettingViewController alloc] init];
        _editView.delegate = self;
    }
    return _editView;
}

-(NSCalendar*)nscalendar{
    if(!_nscalendar){
        _nscalendar = [NSCalendar currentCalendar];
    }
    return _nscalendar;
}

-(NSDateComponents*)dateComponents{
    if(!_dateComponents){
        _dateComponents = [self.nscalendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    }
    return _dateComponents;
}

-(NSMutableArray<EKEvent*>*)eventItems{
    if(!_eventItems){
        _eventItems = [[NSMutableArray alloc] init];
    }
    return _eventItems;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.delegate = self;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self fetchStoreEvent];
    
    updateEventIndexQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"viewWillAppear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // NSLog(@"viewDidDisappear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // NSLog(@"viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.eventItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.eventItems[indexPath.row].title;
    
    NSDateComponents *components = [self.nscalendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.eventItems[indexPath.row].startDate];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld年%ld月%ld日  時間： %ld時%ld分",(long)components.year,(long)components.month , (long)components.day, (long)components.hour , (long)components.minute];
    
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height-1, self.view.bounds.size.width, 1)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:bottomLineView];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        EKEvent *event = self.eventItems[indexPath.row];
        [self.eventStore removeEvent:event span:EKSpanThisEvent error:nil];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventVO"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@",event.eventIdentifier];
        [fetchRequest setPredicate:predicate];
        NSArray  *datas = [EventVO MR_executeFetchRequest:fetchRequest];
        if(datas != nil && datas.count > 0){
            EventVO *vo = datas[0];
            NSManagedObjectContext *context = [vo managedObjectContext];
            [vo MR_deleteEntityInContext:context];
            [context MR_saveToPersistentStoreAndWait];
        }
        [self.eventItems removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

/* 手指觸控長按點擊 */
- (IBAction)longPressGestureRecognized:(id)sender {
    
        UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer*)sender;
        UIGestureRecognizerState state = longPress.state;
        
        CGPoint location = [longPress locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        static UIView *snapshot = nil; ///< A snapshot of the row user is moving.
        static NSIndexPath *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
        
        switch (state) {
            case UIGestureRecognizerStateBegan:{
                if(indexPath){
                    sourceIndexPath = indexPath;
                    
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    snapshot = [self customSnapshotFromView:cell];
                    
                    // Add the snapshot as subview, centered at cell's center...
                    // 宣告 _block 是為了要讓下方的 animations:^{} block 可以更改此變數的值
                    __block CGPoint center = cell.center;
                    snapshot.center = center;
                    //透明度 0 ~ 1.0 ,預設是1.0(不透明)
                    snapshot.alpha = 0.0;
                    [self.tableView addSubview:snapshot];
                    
                    //row 彈跳出來的動畫
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        // Offset for gesture location.
                        center.y = location.y;
                        snapshot.center = center;
                        snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                        snapshot.alpha = 0.98;
                        
                        // Black out.
                        cell.backgroundColor = [UIColor blackColor];
                    } completion:nil];
                }
                break;
            }
                
            case UIGestureRecognizerStateChanged: {
                // NSLog(@"UIGestureRecognizerStateChanged");
                CGPoint center = snapshot.center;
                center.y = location.y;
                snapshot.center = center;
                
                // Is destination valid and is it different from source?
                if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                    
                    // ... update data source.
                    [self.eventItems exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                    
                    // ... move the rows.
                    [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                    
                    
                    // ... and update source so it is in sync with UI changes.
                    sourceIndexPath = indexPath;
                }
                break;
            }
            default: {
                // Clean up.
                //  NSLog(@"default");
                // ... delete all event in core data
                dispatch_sync(updateEventIndexQueue, ^{
                    NSLog(@"event delete");
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventVO"];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@",[NSDate date]];
                    [fetchRequest setPredicate:predicate];
                    
                    NSArray  *datas = [EventVO MR_executeFetchRequest:fetchRequest];
                    
                    for(EventVO *vo in datas){
                        NSManagedObjectContext *context = [vo managedObjectContext];
                        [vo MR_deleteEntityInContext:context];
                        [context MR_saveToPersistentStoreAndWait];
                    }
                    
                });
                
                // ... insert new event in core data
                dispatch_sync(updateEventIndexQueue, ^{
                    NSLog(@"event save");
                    for(EKEvent *event in self.eventItems){
                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                            
                            EventVO *eventvo = [EventVO MR_createEntityInContext:localContext];
                            eventvo.identifier = event.eventIdentifier;
                            eventvo.date = event.startDate;
                            
                        }completion:^(BOOL success, NSError *error) {
                            
                        }];
                    }
                    
                });
                

                
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    snapshot.center = cell.center;
                    /* 初始化UIView的矩陣位置 */
                    snapshot.transform = CGAffineTransformIdentity;
                    //透明度 0 ~ 1.0 ,預設是1.0(不透明)
                    snapshot.alpha = 0.0;
                    
                    // Undo the black-out effect we did.
                    cell.backgroundColor = [UIColor whiteColor];
                    
                } completion:^(BOOL finished) {
                    
                    [snapshot removeFromSuperview];
                    snapshot = nil;
                    
                }];
                sourceIndexPath = nil;
                break;
            }
                
        }
}

- (IBAction)onRightButtonAdd:(id)sender {
    //要求空至行事曆
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL allowed, NSError *error) {
        //使用者點選確定
        if (allowed) {
            
            /*  
                UIModalPresentationFormSheet 為彈跳視窗樣式,在iPad上是呈現子母2層畫面,而在iPhone呈現都是全螢幕樣式
                此處需要在completion實作一block的目的是因為 : 
             
                    在iPad的呈現上彈跳出來的畫面視窗,是要等到該視窗彈跳出來後才會取得該視窗的大小 , 所以若視窗內的內容畫面
                  (此例:EditSettingViewController) ,在此之前生成,會取不到該彈跳視窗的大小,造成內容畫面的大小不能fit
                  彈跳出來的視窗.
                   所以必須延後彈跳視窗內的內容畫面的生成時間,依照生命週期 viewDidLoad/viewWillAppear 皆會在視窗
                  彈跳出來之前執行.為了延後,必須把內容畫面生成的程式寫在 presentViewController 方法所提供的 completion
                  的 block 內.(這邊使用delegate實作,以確保presentViewController執行完畢後,EditSettingViewController能
                  及時實行產生畫面的程式碼).
             */
            
            self.editView.modalPresentationStyle = UIModalPresentationFormSheet;
            self.editView.mainPopController = self;
            self.editView.mainPopController.delegate = self.editView;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:self.editView animated:YES completion:^{
                    
                    if([_delegate respondsToSelector:@selector(initView)]){
                        [_delegate initView];
                    }
                
                }];
            });
        
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // UI Updating code here.
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"錯誤"
                                              message:@"拒絕存取日曆資料,新增事件失敗"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* confirmButton = [UIAlertAction
                                                actionWithTitle:@"確定"
                                                style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * action){
                                                    //[self dismissViewControllerAnimated:YES completion:nil];
                                                }];
                
                [alert addAction:confirmButton];
                [self presentViewController:alert animated:YES completion:nil];
            });
            
        }
    }];
}

-(void)setEventByTitle:(NSString*)title andYear:(NSNumber*)year andMonth:(NSNumber*)month andDay:(NSNumber*)day andHour:(NSNumber *)hour andMinute:(NSNumber *)minute{
    
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore ];
    if(title.length == 0){
        event.title = [NSString stringWithFormat:@"NewEvent%u",self.eventItems.count+1];
    }else
        event.title = title;

    //set date components
    [self.dateComponents setDay:[day intValue]];
    [self.dateComponents setMonth:[month intValue]];
    [self.dateComponents setYear:[year intValue]];
    [self.dateComponents setHour:[hour intValue]];
    [self.dateComponents setMinute:[minute intValue]];
    [self.dateComponents setSecond:0];
    
    //save date relative from date
    NSDate *date = [self.nscalendar dateFromComponents:self.dateComponents];
    event.startDate = date;
    event.endDate = date;
    
    [event setCalendar:[self.eventStore  defaultCalendarForNewEvents]];
    [event addAlarm:[EKAlarm alarmWithAbsoluteDate:date]];
   
    [self.eventStore  saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
            EventVO *eventvo = [EventVO MR_createEntityInContext:localContext];
            eventvo.identifier = event.eventIdentifier;
            eventvo.date = event.startDate;
       
    }completion:^(BOOL success, NSError *error) {
        [self.eventItems addObject:event];
        [self.tableView reloadData];
    }];
}

-(void)refreshLocalEvent{
    [self.eventItems removeAllObjects];
    [self fetchStoreEvent];
}


/*  view 畫面呈現前 呼叫
    把custom app資料庫儲存的event identifier 取出然後從 calender store 裡面找 ,找的到就顯示,找不到就刪除（從custom app資料庫內)
 */
-(void)fetchStoreEvent{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventVO"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@",[NSDate date]];
    [fetchRequest setPredicate:predicate];
    NSArray  *datas = [EventVO MR_executeFetchRequest:fetchRequest];
    
    if(datas != nil && datas.count > 0){
        for(EventVO *vo in datas){
            EKEvent *event = [self.eventStore eventWithIdentifier:vo.identifier];
            if(event == nil){
                NSManagedObjectContext *context = [vo managedObjectContext];
                [vo MR_deleteEntityInContext:context];
                [context MR_saveToPersistentStoreAndWait];
            }else{
                [self.eventItems addObject:event];
            }
        }
    }
    [self.tableView reloadData];
}


/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

/*
 //建立新活動
 EKEvent *Event = [EKEvent eventWithEventStore:self.eventStore ];
 //設定活動內容說明
 Event.title = @"This is Message";
 //設定活動開始時間，範例是目前時間
 Event.startDate = [NSDate date];
 //設定活動結束時間，範例是目前時間加3600秒，也就是1小時
 Event.endDate = [[NSDate date] dateByAddingTimeInterval:10];
 //設定活動為行事曆的新活動
 [Event setCalendar:[self.eventStore  defaultCalendarForNewEvents]];
 //增加提醒，範例是設定600秒前提醒
 [Event addAlarm:[EKAlarm alarmWithRelativeOffset:10]];
 //將活動儲存至行事曆
 [self.eventStore  saveEvent:Event span:EKSpanThisEvent commit:YES error:nil];
 */

@end
