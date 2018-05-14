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


@protocol ActivityDelegate <NSObject>
@end

@interface ActivityDataEntryVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate, PoiDataEntryDelegate, SelectDateRangeDelegate, DirectionsDelegate, PaymentListingDelegate>

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



@end

