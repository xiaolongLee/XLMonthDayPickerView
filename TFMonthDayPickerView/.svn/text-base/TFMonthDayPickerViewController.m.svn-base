//
//  TFMonthDayPickerViewController.m
//  MZSJ
//
//  Created by sqy on 16/8/18.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import "TFMonthDayPickerViewController.h"
#import "TFMonthDayPickerView.h"
#import "Time.h"

@interface TFMonthDayPickerViewController ()

@end

@implementation TFMonthDayPickerViewController

#pragma mark - ui events

- (IBAction)clickBlanket:(UITapGestureRecognizer *)sender {
    _confirmBlock(_monthDayPickerView.currentDate);
}

#pragma mark - public methods

- (void)configDateStartDate:(NSDate *)startDate selectedDate:(NSDate *)selectedDate endDate:(NSDate *)endDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    NSDate *today = [df dateFromString:[[Time getFutureTime] substringToIndex:10]];
    
    if (startDate) {
        _monthDayPickerView.startDate = startDate;
    } else {
        //开始日期：当天
        _monthDayPickerView.startDate = today;
    }
    
    //下个月月末
    df.dateFormat = @"y";
    NSString *year = [df stringFromDate:today];
    df.dateFormat = @"M";
    NSString *month = [df stringFromDate:today];
    df.dateFormat = @"y-M";
    if (month.integerValue == 12) {
        month = @"00";
        year = [NSString stringWithFormat:@"%d",[year intValue] + 1];
    }
    NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%@-%@", year, @(month.integerValue + 1).stringValue]];
    NSDate *beginDate;
    double interval;
    NSCalendar *c = [NSCalendar currentCalendar];
    [c rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:date];
    NSDate *nextMonthEndDate =  [beginDate dateByAddingTimeInterval:interval - 1];
    
    //月末所在周的周日
    df.dateFormat = @"yyyyMMdd";
    FMDatabase *db = [TFFmdb shareFmdb];
    [db open];
    FMResultSet *r = [db executeQueryWithFormat:@"SELECT MAX(END_DATE) FROM T_YX_SDCJ_WEEK WHERE START_DATE <= %@", [df stringFromDate:nextMonthEndDate]];
    NSDate *endWeekend;
    while ([r next]) {
        endWeekend = [df dateFromString:[r stringForColumnIndex:0]];
        break;
    }
    [db close];
    //周六
    endWeekend = [NSDate dateWithTimeInterval:-24 * 60 * 60 sinceDate:endWeekend];
    
    _monthDayPickerView.endDate = [endDate compare:endWeekend] < 0 ? endDate : endWeekend;
    
    if (selectedDate) {
        [_monthDayPickerView selectDate:selectedDate];
    }
}

#pragma mark - view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    //MYLog(@"%s", __func__);
}

@end
