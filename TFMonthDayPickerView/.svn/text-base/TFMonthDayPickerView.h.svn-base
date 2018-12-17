//
//  TFMonthDayPickerView.h
//  MZSJ
//
//  Created by sqy on 16/5/11.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TFMonthDayPickerViewDelegate <NSObject>

- (void)tfMonthDayPickerViewSelectedRowDidChangeToDate:(NSDate *)date;

@end

@interface TFMonthDayPickerView : UIPickerView

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic, readonly) NSDate *currentDate;

@property (weak, nonatomic) id<TFMonthDayPickerViewDelegate> tfDelegate;

- (void)selectDate:(NSDate *)date;

@end
