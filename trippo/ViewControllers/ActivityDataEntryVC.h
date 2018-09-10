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
#import "PoiListCell.h"
#import "PoiImageNSO.h"
#import "PoiDataEntryVC.h"
#import "DatePickerRangeVC.h"
#import "DirectionsVC.h"
#import "PaymentListingVC.h"
#import "HCSStarRatingView.h"
#import "ImageNSO.h"
#import "ActivityImageCell.h"


@protocol ActivityDataEntryDelegate <NSObject>
- (void)didUpdateActivityImages :(bool) ForceUpdate;
@end

@interface ActivityDataEntryVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate, PoiDataEntryDelegate, SelectDateRangeDelegate, DirectionsDelegate, PaymentListingDelegate, UITextViewDelegate,UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate, UIScrollViewDelegate>
@property (nonatomic) UIImage *PoiImage;
@property (assign) bool newitem;
@property (assign) bool transformed;
@property (assign) bool deleteitem;
@property (assign) int imagestate;
@property (nonatomic) NSString *SelectedImageReference;
@property (nonatomic) NSString *SelectedImageKey;
@property (nonatomic) NSNumber *SelectedImageIndex;
@property (nonatomic, weak) id <ActivityDataEntryDelegate> delegate;
@property ActivityRLM *Activity;
@property PoiRLM *Poi;
@property TripRLM *Trip;
@property RLMRealm *realm;
@property (strong, nonatomic) NSMutableDictionary *ActivityImageDictionary;
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
@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewBlurImageOptionPanel;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewActivityImages;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchViewPhotoOptions;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewBlurHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *ViewTrash;
@property (weak, nonatomic) IBOutlet UIView *ViewSelectedKey;
@property (weak, nonatomic) IBOutlet UIImageView *ImagePicture;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollViewImage;
@property (strong, nonatomic) NSArray *TypeDistanceItems;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewKeyActivity;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUploadImage;


@end

