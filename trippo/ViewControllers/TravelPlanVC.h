//
//  TravelPlanVC.h
//  trippo
//
//  Created by andrew glew on 19/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "TripRLM.h"
#import "ToolBoxNSO.h"
#import "JENTreeView.h"
#import "NodeNSO.h"
#import "JourneyItemNSO.h"
#import "ItineraryListCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TravelPlanDelegate <NSObject>
@end

@interface TravelPlanVC : UIViewController <JENTreeViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, weak) id <TravelPlanDelegate> delegate;
@property RLMRealm *realm;
@property TripRLM *Trip;
@property (strong, nonatomic) NSMutableArray *activitycollection;
@property (strong, nonatomic) NSMutableArray *excludedlisting;
@property (strong, nonatomic) NSMutableArray *itinerarycollection;
@property (strong, nonatomic) NSMutableDictionary *ActivityImageDictionary;
@property (weak, nonatomic) IBOutlet JENTreeView *treeview;
@property (nonatomic) UIImage *TripImage;
@property (nonatomic) NSNumber *ActivityState;

@property (weak, nonatomic) IBOutlet UIStepper *StepperScale;
@property (weak, nonatomic) IBOutlet UIView *ViewStateIndicator;
@property (weak, nonatomic) IBOutlet UILabel *LabelTripTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *JourneySidePanelViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *JorneySidePanelView;
@property (weak, nonatomic) IBOutlet UIButton *ButtonJourneySideButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ButtonTabWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *JourneySidePanelFullWidthConstraint;
@property (weak, nonatomic) IBOutlet UITableView *ItineraryTableView;
@property (assign) double AccumDistance;
@property (assign) double SequenceCounter;

@end

NS_ASSUME_NONNULL_END
