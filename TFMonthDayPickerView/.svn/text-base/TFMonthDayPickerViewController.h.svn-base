//
//  TFMonthDayPickerViewController.h
//  MZSJ
//
//  Created by sqy on 16/8/18.
//  Copyright © 2016年 李小龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFMonthDayPickerView;

typedef void(^ConfirmBlock)(NSDate *);

@interface TFMonthDayPickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet TFMonthDayPickerView *monthDayPickerView;

@property (copy, nonatomic) ConfirmBlock confirmBlock;

- (void)configDateStartDate:(NSDate *)startDate selectedDate:(NSDate *)selectedDate endDate:(NSDate *)endDate;

@end
