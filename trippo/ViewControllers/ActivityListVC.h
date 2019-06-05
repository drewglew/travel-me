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
#import "PoiSearchVC.h"
#import "ActivityListCell.h"
#import "ActivityDataEntryVC.h"
#import "ActivityDiaryCell.h"
#import "PoiImageNSO.h"
#import "ScheduleVC.h"
#import "PaymentListingVC.h"
#import "ActivityRLM.h"
#import "TripRLM.h"
#import "ImageCollectionRLM.h"
#import "ToolboxNSO.h"
#import "DiaryDatesNSO.h"
#import "MultiplierConstraint.h"
#import "CustomCollectionView.h"


@protocol ActivityListDelegate <NSObject>
@end

@interface ActivityListVC : UIViewController <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate,    UITextFieldDelegate, ActivityDataEntryDelegate, ScheduleListDelegate, PaymentListingDelegate, PoiSearchDelegate>

@property (assign) bool editmode;

@property TripRLM *Trip;
@property (nonatomic, weak) id <ActivityListDelegate> delegate;
@property (weak, nonatomic) IBOutlet CustomCollectionView *CollectionViewActivities;
@property (weak, nonatomic) IBOutlet UILabel *LabelProject;
@property (strong, nonatomic) NSMutableArray *activityitems;
@property NSMutableArray *activitycollection;
@property NSMutableArray *diarycollection;
@property NSMutableArray *sectionheaderdaystitle;
@property (strong, nonatomic) NSMutableDictionary *ActivityImageDictionary;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentState;
@property (weak, nonatomic) IBOutlet UIView *ViewAction;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonRouting;
@property (weak, nonatomic) IBOutlet UIButton *ButtonPayment;
@property RLMResults<ActivityRLM*> *AllActivitiesInTrip;
@property (assign) bool ImagesNeedUpdating;
@property (assign) bool keyboardIsShowing;
@property RLMRealm *realm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FooterWithSegmentConstraint;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSwapMainView;
@property (weak, nonatomic) IBOutlet UITableView *TableViewDiary;
@property (nonatomic) NSDate *IdentityStartDt;
@property (nonatomic) NSDate *IdentityEndDt;
@property (weak, nonatomic) IBOutlet UIButton *ButtonTweet;
@property (assign) bool tweetview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeaderViewHeightConstraint;

@end
