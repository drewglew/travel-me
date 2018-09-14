//
//  PoiDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "ToolBoxNSO.h"
#import "PoiImageCell.h"
#import "PoiImageNSO.h"
#import "PoiNSO.h"
#import "ImagePickerVC.h"
#import "ImageNSO.h"
#import "WikiVC.h"
#import "Reachability.h"
#import "TypeNSO.h"
#import "TypeCell.h"
#import "HCSStarRatingView.h"
#import "PoiRLM.h"

@protocol PoiDataEntryDelegate <NSObject>
- (void)didCreatePoiFromProject :(PoiRLM*)Object;
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object;
@end

@interface PoiDataEntryVC : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, ImagePickerDelegate, WikiGeneratorDelegate, UIScrollViewDelegate, UITextViewDelegate,UITextFieldDelegate, CLLocationManagerDelegate>

@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (nonatomic) NSString *Title;
@property (nonatomic) NSNumber *SelectedImageIndex;
@property (nonatomic) NSString *SelectedImageKey;
@property (assign) bool newitem;
@property (assign) bool imagesupdated;
@property (assign) bool readonlyitem;
@property (assign) bool fromproject;
@property (assign) bool fromnearby;
@property (assign) int imagestate;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewPoiImages;
@property (strong, nonatomic) NSMutableDictionary *PoiImageDictionary;
@property (strong, nonatomic) PoiRLM *PointOfInterest;
@property RLMRealm *realm;
@property (strong, nonatomic) NSArray *TypeItems;
@property (strong, nonatomic) NSMutableArray *CategoryItems;
@property (strong, nonatomic) NSArray *TypeLabelItems;
@property (strong, nonatomic) NSArray *TypeDistanceItems;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
// only used on preview controller
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (strong, nonatomic) MKCircle *CircleRange;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentDetailOption;
@property (weak, nonatomic) IBOutlet UIImageView *ImagePicture;
@property (weak, nonatomic) IBOutlet UILabel *LabelPrivateNotes;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewKey;
@property (weak, nonatomic) IBOutlet UILabel *LabelPoi;
@property (nonatomic, weak) id <PoiDataEntryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *PickerType;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewTypes;
@property (weak, nonatomic) IBOutlet UIView *ViewMain;
@property (weak, nonatomic) IBOutlet UIView *ViewNotes;
@property (weak, nonatomic) IBOutlet UIView *ViewMap;
@property (weak, nonatomic) IBOutlet UIView *ViewPhotos;
@property (weak, nonatomic) IBOutlet UIView *ViewTrash;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewBlurImageOptionPanel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonKey;
@property (weak, nonatomic) IBOutlet UIView *ViewSelectedKey;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewBlurHeightConstraint;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchViewPhotoOptions;
@property (weak, nonatomic) IBOutlet UIButton *ButtonWiki;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUpdate;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCancel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonGeo;

@property CGPoint translation;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollViewImage;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ViewStarRatings;
@property (weak, nonatomic) IBOutlet UILabel *LabelOccurances;
@property (weak, nonatomic) IBOutlet UILabel *LabelPhotoInfo;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUploadImages;


@end