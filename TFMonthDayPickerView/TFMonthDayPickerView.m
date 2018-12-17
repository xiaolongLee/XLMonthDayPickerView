//
//  TFMonthDayPickerView.m
//  MZSJ
//
//  Created by sqy on 16/5/11.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import "TFMonthDayPickerView.h"
#import "Time.h"

@interface TFMonthDayPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSMutableArray<NSString *> *datePickerMonthArray;
@property (strong, nonatomic) NSMutableDictionary *datePickerDayDic;

@property (assign, nonatomic) NSInteger lastSelectedMonthIndex;
@property (assign, nonatomic) NSInteger lastSelectedDayIndex;
@property (assign, nonatomic) NSInteger lastSelectedDay;

@end

@implementation TFMonthDayPickerView

#pragma mark - public method

- (void)selectDate:(NSDate *)date {
    _currentDate = date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone systemTimeZone]];

    df.dateFormat = @"M";
    NSString *month = [df stringFromDate:date];
    _lastSelectedMonthIndex = [_datePickerMonthArray indexOfObject:month];
    df.dateFormat = @"d";
    NSString *day = [df stringFromDate:date];
    _lastSelectedDay = day.integerValue;
    NSArray *array = _datePickerDayDic[month];
    _lastSelectedDayIndex = [array indexOfObject:day];
    [self reloadAllComponents];
    [self selectRow:[_datePickerMonthArray indexOfObject:month] inComponent:0 animated:NO];
    [self selectRow:_lastSelectedDayIndex inComponent:1 animated:NO];
}

#pragma mark - setter

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    if (!_endDate) {
        return;
    } else {
        [self configDatePickerData];
    }
}

- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate;
    if (!_startDate) {
        return;
    } else {
        [self configDatePickerData];
    }
}

#pragma mark - delegate / datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (_datePickerMonthArray) {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _datePickerMonthArray.count;
    } else {
        NSString *selectedMonth = _datePickerMonthArray[_lastSelectedMonthIndex];
        NSArray *array = _datePickerDayDic[selectedMonth];
        return array.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [_datePickerMonthArray[row] stringByAppendingString:@"月"];
    } else {
        NSString *selectedMonth = _datePickerMonthArray[_lastSelectedMonthIndex];
        return [_datePickerDayDic[selectedMonth][row] stringByAppendingString:@"日"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectedMonth = _datePickerMonthArray[_lastSelectedMonthIndex];
    NSArray *dateArray = _datePickerDayDic[selectedMonth];
    
    if (component == 0) {
        if (row != _lastSelectedMonthIndex) {
            _lastSelectedMonthIndex = row;
            selectedMonth = _datePickerMonthArray[_lastSelectedMonthIndex];
            dateArray = _datePickerDayDic[selectedMonth];
            
            //改变天数
            [pickerView reloadComponent:1];
            
            //选中的日不变
            NSInteger newSelectRow;
            NSString *firstDay = [dateArray firstObject];
            NSString *lastDay = [dateArray lastObject];
            if (_lastSelectedDay < firstDay.integerValue) {
                newSelectRow = 0;
            } else if (_lastSelectedDay > lastDay.integerValue) {
                newSelectRow = dateArray.count - 1;
            } else {
                newSelectRow = [dateArray indexOfObject:@(_lastSelectedDay).stringValue];
            }
            [pickerView selectRow:newSelectRow inComponent:1 animated:NO];
            _lastSelectedDayIndex = newSelectRow;
        }
    } else {
        _lastSelectedDayIndex = row;
    }
    
    //更新_date
    NSString *day = dateArray[_lastSelectedDayIndex];
    _lastSelectedDay = day.integerValue;
    
    NSString *todayStr = [[Time getFutureTime] substringToIndex:10];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    df.dateFormat = @"yy-MM-dd";
    NSDate *today = [df dateFromString:todayStr];
    df.dateFormat = @"y";
    NSString *year = [df stringFromDate:today];
    
    df.dateFormat = @"y-M-d";
    
    //从12月滚动到1月时，年份+1
    NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%@-%@-%@", year, selectedMonth, day]];
    if ([date timeIntervalSinceDate:_startDate] < -24 * 3600) {
        date = [df dateFromString:[NSString stringWithFormat:@"%@-%@-%@", @(year.integerValue + 1).stringValue, selectedMonth, day]];
    }
    
    _currentDate = date;
    
    [_tfDelegate tfMonthDayPickerViewSelectedRowDidChangeToDate:date];
}

#pragma mark - private method

- (void)configDatePickerData {
    //初始化
    _datePickerMonthArray = [NSMutableArray array];
    _datePickerDayDic = [NSMutableDictionary dictionary];
    
    //年
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    df.dateFormat = @"Y";
    NSString *startYear = [df stringFromDate:_startDate];
    
    //月
    df.dateFormat = @"M";
    NSString *startMonth = [df stringFromDate:_startDate];
    NSString *endMonth = [df stringFromDate:_endDate];
    
    //日
    df.dateFormat = @"d";
    NSString *startDay = [df stringFromDate:_startDate];
    _lastSelectedDay = startDay.integerValue;
    NSString *endDay = [df stringFromDate:_endDate];
    
    if ([startMonth isEqualToString:endMonth]) {
        //如果只有1个月
        //月
        [_datePickerMonthArray addObject:startMonth];
        //日
        NSMutableArray *dayArray = [NSMutableArray array];
        for (int i = startDay.intValue; i <= endDay.intValue; i++) {
            [dayArray addObject:@(i).stringValue];
        }
        _datePickerDayDic[startMonth] = dayArray;
    } else {
        //第1个月
        //月
        [_datePickerMonthArray addObject:startMonth];
        //日
        NSCalendar *c = [NSCalendar currentCalendar];
        NSRange dayRange;
        dayRange = [c rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:_startDate];
        NSInteger days = dayRange.length;
        NSMutableArray *dayArray = [NSMutableArray array];
        for (int i = startDay.intValue; i <= days; i++) {
            [dayArray addObject:@(i).stringValue];
        }
        _datePickerDayDic[startMonth] = dayArray;
        
        //最后1个月
        //月
        [_datePickerMonthArray addObject:endMonth];
        //日
        dayArray = [NSMutableArray array];
        for (int i = 1; i <= endDay.intValue; i++) {
            [dayArray addObject:@(i).stringValue];
        }
        _datePickerDayDic[endMonth] = dayArray;
        
        BOOL isThreeMonth;
        BOOL isFourMonth;
        if (endMonth.integerValue > startMonth.integerValue) {
            
            isThreeMonth = (endMonth.integerValue - startMonth.integerValue) > 1;
            isFourMonth = (endMonth.integerValue - startMonth.integerValue) > 2;
        }else{
            isThreeMonth = (12 - startMonth.integerValue + endMonth.integerValue) > 1;
            isFourMonth = (12 - startMonth.integerValue + endMonth.integerValue) > 2;
        }
        
        if (isThreeMonth) {
            //有3个月
            //月
            NSInteger month = startMonth.integerValue;
            NSInteger year = startYear.integerValue;
            if (month == 12) {
                month = 1;
                year++;
            } else {
                month++;
            }
            [_datePickerMonthArray insertObject:@(month).stringValue atIndex:1];
            //日
            df.dateFormat = @"y-M";
            NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%ld-%ld", year, month]];
            dayRange = [c rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
            days = dayRange.length;
            NSMutableArray *dayArray = [NSMutableArray array];
            for (int i = 1; i <= days; i++) {
                [dayArray addObject:@(i).stringValue];
            }
            _datePickerDayDic[@(month).stringValue] = dayArray;
            
            if (isFourMonth) {
                //有4个月
                //月
                if (month == 12) {
                    month = 1;
                    year++;
                } else {
                    month++;
                }
                [_datePickerMonthArray insertObject:@(month).stringValue atIndex:2];
                //日
                df.dateFormat = @"y-M";
                NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%ld-%ld", year, month]];
                dayRange = [c rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
                days = dayRange.length;
                NSMutableArray *dayArray = [NSMutableArray array];
                for (int i = 1; i <= days; i++) {
                    [dayArray addObject:@(i).stringValue];
                }
                _datePickerDayDic[@(month).stringValue] = dayArray;
            }
        }
    }
    [self reloadAllComponents];
}

#pragma mark - initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    _lastSelectedMonthIndex = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
