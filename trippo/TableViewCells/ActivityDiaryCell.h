//
//  ActivityDiaryCell.h
//  trippo-app
//
//  Created by andrew glew on 20/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldDatePicker.h"
#import "ActivityRLM.h"
#import "ToolboxNSO.h"
NS_ASSUME_NONNULL_BEGIN

@interface ActivityDiaryCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UIButton *ButtonDelete;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldStartDt;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldEndDt;
@property (weak, nonatomic) IBOutlet UILabel *LabelName;
@property (strong, nonatomic) ActivityRLM *activity;
@property (strong, nonatomic) UIDatePicker * datePickerStart;
@property (strong, nonatomic) UIDatePicker * datePickerEnd;
@property (strong, nonatomic) UIToolbar * datePickerToolbar;
@property (strong, nonatomic) NSIndexPath *indexPathForCell;
@property (weak, nonatomic) IBOutlet UIView *CellBorder;
@property (weak, nonatomic) IBOutlet UIView *DurationView;
@property (weak, nonatomic) IBOutlet UILabel *LabelDuration;
@property (weak, nonatomic) IBOutlet UIView *DurationBar;
@end

NS_ASSUME_NONNULL_END
