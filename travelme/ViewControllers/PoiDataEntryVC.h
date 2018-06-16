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


@protocol PoiDataEntryDelegate <NSObject>
- (void)didCreatePoiFromProject :(NSString*)Key;
@end

@interface PoiDataEntryVC : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ImagePickerDelegate, WikiGeneratorDelegate>

@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (nonatomic) NSString *Title;
@property (nonatomic) NSString *SelectedImageReference;
@property (nonatomic) NSNumber *SelectedImageIndex;
@property (assign) bool newitem;
@property (assign) bool imagesupdated;
@property (assign) bool readonlyitem;
@property (assign) bool fromproject;
@property (assign) int imagestate;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewPoiImages;
@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (strong, nonatomic) NSArray *TypeItems;
@property (strong, nonatomic) NSArray *TypeLabelItems;
@property (strong, nonatomic) NSArray *TypeDistanceItems;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
// only used on preview controller
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentDetailOption;
@property (weak, nonatomic) IBOutlet UIImageView *ImagePicture;
@property (weak, nonatomic) IBOutlet UILabel *LabelPrivateNotes;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewKey;
@property (weak, nonatomic) IBOutlet UILabel *LabelPoi;
@property (nonatomic, weak) id <PoiDataEntryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *PickerType;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewBlurImageOptionPanel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonKey;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewBlurHeightConstraint;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchViewPhotoOptions;



@end
