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


@protocol PoiDataEntryDelegate <NSObject>
@end

@interface PoiDataEntryVC : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (nonatomic) NSString *Title;
@property (assign) bool newitem;
@property (assign) bool readonlyitem;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewPoiImages;
@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (strong, nonatomic) NSArray *TypeItems;
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



@end
