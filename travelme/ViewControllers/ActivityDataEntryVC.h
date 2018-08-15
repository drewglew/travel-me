//
//  ActivityDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ActivityNSO.h"
//#import "PoiNSO.h"
#import "PoiListCell.h"
//#import "ProjectNSO.h"
#import "PoiImageNSO.h"
#import "PoiDataEntryVC.h"
#import "DatePickerRangeVC.h"
#import "DirectionsVC.h"
#import "PaymentListingVC.h"
#import "HCSStarRatingView.h"


@protocol ActivityDelegate <NSObject>
@end

@interface ActivityDataEntryVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate, PoiDataEntryDelegate, SelectDateRangeDelegate, DirectionsDelegate, PaymentListingDelegate, UITextViewDelegate,UITextFieldDelegate>

@property (assign) bool newitem;
@property (assign) bool transformed;
@property (assign) bool deleteitem;
@property (nonatomic, weak) id <ActivityDelegate> delegate;
@property (strong, nonatomic) ActivityNSO *Activity;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewPoi;
@property (weak, nonatomic) IBOutlet MKMapView *PoiMapView;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldName;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAction;
@property (weak, nonatomic) IBOutlet UILabel *LabelStartDT;
@property (weak, nonatomic) IBOutlet UILabel *LabelEndDT;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCheckInOut;

@property (weak, nonatomic) IBOutlet UIButton *ButtonDirections;
@property (weak, nonatomic) IBOutlet UIButton *ButtonPayment;
@property (weak, nonatomic) IBOutlet UIButton *ButtonDateRange;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCancel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentPresenter;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewActivityClass;
@property (weak, nonatomic) IBOutlet UIView *ViewMain;
@property (weak, nonatomic) IBOutlet UIView *ViewNotes;
@property (weak, nonatomic) IBOutlet UIView *ViewPhotos;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ImageViewIdeaWidthConstraint;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ViewStarRating;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewEffectBlurDetailHeightConstraint;




@end

