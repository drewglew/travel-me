//
//  ScheduleCell.h
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleNSO.h"

@interface ScheduleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewImage;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewBlur;

@property (weak, nonatomic) IBOutlet UILabel *LabelActivity;
@property (weak, nonatomic) IBOutlet UILabel *LabelSpanDateTime;
@property (strong, nonatomic) ScheduleNSO *schedule;

@end
