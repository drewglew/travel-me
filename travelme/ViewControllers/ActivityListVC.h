//
//  ActivityListVC.h
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectNSO.h"
#import "AppDelegate.h"
#import "ActivityListCell.h"
#import "PoiSearchVC.h"
#import "ActivityDataEntryVC.h"
#import "PoiImageNSO.h"
#import "ScheduleVC.h"
#import "PaymentListingVC.h"

@protocol ActivityListDelegate <NSObject>
@end

@interface ActivityListVC : UIViewController <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PoiSearchDelegate, ActivityDelegate, ScheduleListDelegate, PaymentListingDelegate>

@property (assign) bool editmode;

@property (strong, nonatomic) ProjectNSO *Project;
@property (nonatomic, weak) id <ActivityListDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewActivities;
@property (weak, nonatomic) IBOutlet UILabel *LabelProject;
@property (strong, nonatomic) NSMutableArray *activityitems;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentState;
@property (weak, nonatomic) IBOutlet UIView *ViewAction;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonRouting;
@property (weak, nonatomic) IBOutlet UIButton *ButtonPayment;

@end
