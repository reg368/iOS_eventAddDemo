//
//  EditSettingViewController.m
//  eventAddDemo
//
//  Created by t00javateam@gmail.com on 2016/5/31.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import "EditSettingViewController.h"
#import "EventKit/EventKit.h"

@interface EditSettingViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
/* self view component */
@property (nonatomic) UINavigationBar *navigationBar;
@property (nonatomic) UILabel *titlelabel;
@property (nonatomic) UITextField *textfield;
@property (nonatomic) UILabel *datePickerTitleLabel;

/* custom data picker */
@property (nonatomic) UIPickerView *picker;
@property (nonatomic) UIPickerView *pickerTime;
@property (nonatomic) NSArray *years;
@property (nonatomic) NSMutableArray *months;
@property (nonatomic) NSMutableArray *days;
@property (nonatomic) NSMutableArray *hours;
@property (nonatomic) NSMutableArray *minutes;
@end

@implementation EditSettingViewController{
    NSDateComponents *components;
    NSNumber *selectedYear;
    NSNumber *selectedMonth;
    NSNumber *selectedDay;
    NSNumber *selectedHour;
    NSNumber *selectedMinute;
}

const int PICKER_TAG = 0;
const int PICKERTIME_TAG = 1;
const int PADDING_LEFT = 5;
const int PADDING_TOP = 5;
const int LABEL_HEIGHT = 10;


-(UINavigationBar*)navigationBar{
    if(!_navigationBar){
        
        _navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Add Event"];
        
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(leftBtnClick:)];
        
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(rightBtnClick:)];
        
        
        navItem.leftBarButtonItem = leftBtn;
        navItem.rightBarButtonItem = rightBtn;
        
        _navigationBar.items = @[navItem];

    }
    return _navigationBar;
}

-(UILabel*)titlelabel{
    if(!_titlelabel){
        _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT, CGRectGetMaxY(self.navigationBar.frame)+PADDING_TOP, self.view.bounds.size.width-10, 30)];
        _titlelabel.text = @"請輸入事件標題 : ";
        [_titlelabel setTextColor:[UIColor blackColor]];
        [_titlelabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    }
    return _titlelabel;
}

-(UITextField*)textfield{
    if(!_textfield){
        _textfield = [[UITextField alloc] initWithFrame:CGRectMake(PADDING_LEFT, CGRectGetMaxY(self.titlelabel.frame)+PADDING_TOP, self.view.frame.size.width-10, 50)];
        [_textfield becomeFirstResponder];
        _textfield.placeholder = @"標題";
        [_textfield setBorderStyle:UITextBorderStyleRoundedRect];
    }
    return _textfield;
}

-(UILabel*)datePickerTitleLabel{
    if(!_datePickerTitleLabel){
        _datePickerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT, CGRectGetMaxY(self.textfield.frame) + PADDING_TOP, self.view.frame.size.width - 10, 30)];
        _datePickerTitleLabel.text = @"請選擇提醒日期和時間";
        [_datePickerTitleLabel setTextColor:[UIColor blackColor]];
        [_datePickerTitleLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    }
    return _datePickerTitleLabel;
}


-(UIPickerView*)picker{
    if(!_picker){
        _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(PADDING_LEFT, CGRectGetMaxY(self.datePickerTitleLabel.frame)+5, self.view.frame.size.width-10, self.view.frame.size.height / 4)];
        _picker.dataSource = self;
        _picker.delegate = self;
        _picker.tag = PICKER_TAG;
    }
    return _picker;
}

-(UIPickerView*)pickerTime{
    if(!_pickerTime){
        _pickerTime = [[UIPickerView alloc] initWithFrame:CGRectMake(PADDING_LEFT, CGRectGetMaxY(self.picker.frame), self.view.frame.size.width-10, self.view.frame.size.height / 4)];
        _pickerTime.dataSource = self;
        _pickerTime.delegate = self;
        _pickerTime.tag = PICKERTIME_TAG;
    }
    return _pickerTime;
}

-(NSArray*)years{
    if(!_years){
        _years = @[[NSNumber numberWithInt:2013],[NSNumber numberWithInt:2014],[NSNumber numberWithInt:2015],[NSNumber numberWithInt:2016],[NSNumber numberWithInt:2017],[NSNumber numberWithInt:2018]];
    }
    return _years;
}

-(NSMutableArray*)months{
    if(!_months){
        _months = [[NSMutableArray alloc] init];
        for(int i = 0 ; i < 12 ; i ++){
            [_months addObject:[NSNumber numberWithInt:i+1]];
        }
    }
    return _months;
}

-(NSMutableArray*)days{
    if(!_days){
        _days = [[NSMutableArray alloc] init];
        for(int i = 0 ; i < 31 ; i ++){
            [_days addObject:[NSNumber numberWithInt:i+1]];
        }
    }
    return _days;
}

-(NSMutableArray*)hours{
    if(!_hours){
        _hours = [[NSMutableArray alloc] init];
        for(int i = 0 ; i < 24 ; i ++){
            [_hours addObject:[NSNumber numberWithInt:i]];
        }
    }
    return _hours;
}

-(NSMutableArray*)minutes{
    if(!_minutes){
        _minutes = [[NSMutableArray alloc] init];
        for(int i = 0 ; i < 60 ; i ++){
            [_minutes addObject:[NSNumber numberWithInt:i]];
        }
    }
    return _minutes;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)rightBtnClick:(UIBarButtonItem*)sender{
    if([_delegate respondsToSelector:@selector(setEventByTitle:andYear:andMonth:andDay:andHour:andMinute:)]){
        [_delegate setEventByTitle:self.textfield.text andYear:selectedYear andMonth:selectedMonth andDay:selectedDay andHour:selectedHour andMinute:selectedMinute];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });

}

-(void)leftBtnClick:(UIBarButtonItem*)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if(pickerView.tag == PICKER_TAG)
        return 3;
    else if(pickerView.tag == PICKERTIME_TAG)
        return 2;
    else
        return 0;
        
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if(pickerView.tag == PICKER_TAG){
        if(component == 0){
            return self.years.count;
        }else if(component == 1){
            return self.months.count;
            
        }else if (component == 2){
            //二月處理
            if([selectedMonth intValue] == 2){
                if([selectedYear intValue] % 4 == 0)
                    return 29;
                else
                    return 28;
            }
            //7月之前的小月 雙數
            if([selectedMonth intValue] <= 7 && [selectedMonth intValue] % 2 == 0)
                return 30;
            //7月之前的大月 單數
            else if ([selectedMonth intValue] <= 7 && [selectedMonth intValue] % 2 != 0)
                return 31;
            //8月之後的大月 雙數
            else if ([selectedMonth intValue] >= 8 && [selectedMonth intValue] % 2 == 0)
                return 31;
            //8月之後的小月 單數
            else if ([selectedMonth intValue] >= 8 && [selectedMonth intValue] % 2 != 0)
                return 30;
        }
    }else if(pickerView.tag == PICKERTIME_TAG){
        if(component == 0)
            return self.hours.count;
        else if(component == 1)
            return self.minutes.count;
    }

    return 0;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(pickerView.tag == PICKER_TAG){
    
        if(component == 0)
            return [NSString stringWithFormat:@"%d年",[[self.years objectAtIndex:row] intValue]];
        else if(component == 1)
            return [NSString stringWithFormat:@"%d月",[[self.months objectAtIndex:row] intValue]];
        else if(component == 2)
            return [NSString stringWithFormat:@"%d日",[[self.days objectAtIndex:row] intValue]];
    
    }else if(pickerView.tag == PICKERTIME_TAG){
        if(component == 0){
                return [NSString stringWithFormat:@"%d時",[[self.hours objectAtIndex:row] intValue]];
        }
        else if(component == 1){
            if([[self.minutes objectAtIndex:row] intValue] >= 10)
                return [NSString stringWithFormat:@"%d分",[[self.minutes objectAtIndex:row] intValue]];
            else
                return [NSString stringWithFormat:@"0%d分",[[self.minutes objectAtIndex:row] intValue]];
        }
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == PICKER_TAG){
        if(component == 0){
            selectedYear = [self.years objectAtIndex:row];
            [self.picker reloadComponent:2];
        }else if(component == 1){
            selectedMonth = [self.months objectAtIndex:row];
            [self.picker reloadComponent:2];
            [self.picker rowSizeForComponent:2];
        }else if(component == 2){
            selectedDay = [self.days objectAtIndex:row];
        }
        
        /*
            當日期目前顯示是只有30天 而使用者選到第31天 , (要儲存的)選擇的日期就自動變成為當下月份最後一天的日期
            此情況會發生在使用者滑動月份而沒滑動日的狀況下
         */
        
        if([self.picker numberOfRowsInComponent:2]  < [selectedDay intValue]){
            selectedDay = [self.days objectAtIndex:([self.picker numberOfRowsInComponent:2] - 1 )];
        }

    }else if(pickerView.tag == PICKERTIME_TAG){
        if(component == 0)
            selectedHour = [self.hours objectAtIndex:row];
        else if(component == 1)
            selectedMinute = [self.minutes objectAtIndex:row];
    }
    
    
    //NSLog(@"SELECTED : %d / %d / %d %d : %d",[selectedYear intValue],[selectedMonth intValue],[selectedDay intValue],[selectedHour intValue],[selectedMinute intValue]);
    
}

-(void)initView{
    
    //NSLog(@"EditSettingViewController view width : %f , height : %f",self.view.frame.size.width,self.view.frame.size.height);
  
   dispatch_async(dispatch_get_main_queue(), ^{
   self.view.backgroundColor = [UIColor whiteColor];
   [self.view addSubview:self.navigationBar];
   [self.view addSubview:self.titlelabel];
   [self.view addSubview:self.textfield];
   [self.view addSubview:self.datePickerTitleLabel];
   [self.view addSubview:self.picker];
   [self.view addSubview:self.pickerTime];
   });
   
   
   components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
   selectedYear = [NSNumber numberWithInteger:[components year]];
   selectedMonth = [NSNumber numberWithInteger:[components month]];
   selectedDay = [NSNumber numberWithInteger:[components day]];
   selectedHour = [NSNumber numberWithInteger:[components hour]];
   selectedMinute = [NSNumber numberWithInteger:[components minute]];
   
   
   for(int  i = 0 ; i < self.years.count ; i++){
   if([self.years[i] intValue] == [selectedYear intValue])
   [self.picker selectRow:i  inComponent:0 animated:YES];
   }
   
   [self.picker selectRow:([selectedMonth intValue] - 1)  inComponent:1 animated:YES];
   [self.picker selectRow:([selectedDay intValue] - 1)  inComponent:2 animated:YES];
   [self.pickerTime selectRow:([selectedHour intValue])  inComponent:0 animated:YES];
   [self.pickerTime selectRow:([selectedMinute intValue])  inComponent:1 animated:YES];
   
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
