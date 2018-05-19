//
//  ScheduleCV.h
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleCell.h"
#import "AppDelegate.h"
#import "DirectionsVC.h"

@protocol ScheduleListDelegate <NSObject>
@end

@interface ScheduleVC : UIViewController <UITableViewDelegate, DirectionsDelegate>
@property (weak, nonatomic) IBOutlet UITableView *TableViewScheduleItems;
@property (strong, nonatomic) NSMutableArray *scheduleitems;
@property (strong, nonatomic) NSMutableArray *activityitems;
@property (nonatomic) NSNumber *ActivityState;
@property (nonatomic, weak) id <ScheduleListDelegate> delegate;
@property (strong, nonatomic) ProjectNSO *Project;
@property (assign) int level;
@end
