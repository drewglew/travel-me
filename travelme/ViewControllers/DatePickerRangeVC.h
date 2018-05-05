//
//  DatePickerRangeVC.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNSO.h"

@protocol SelectDateRangeDelegate <NSObject>
- (void)didPickDateSelection :(NSDate*)Start :(NSDate*)End;
@end

@interface DatePickerRangeVC : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerStart;
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerEnd;
@property (weak, nonatomic) IBOutlet UILabel *LabelEnd;
@property (weak, nonatomic) IBOutlet UILabel *LabelStart;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAcceptDates;
@property (strong, nonatomic) ActivityNSO *Activity;
@property (nonatomic, weak) id <SelectDateRangeDelegate> delegate;
@end
