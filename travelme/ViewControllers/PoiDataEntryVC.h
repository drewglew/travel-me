//
//  PoiDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Dal.h"
#import "PoiImageCell.h"
#import "PoiImageNSO.h"
#import "PoiNSO.h"

@protocol PoiDataEntryDelegate <NSObject>
@end

@interface PoiDataEntryVC : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) Dal *db;
@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (nonatomic) NSString *Title;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewPoiImages;
@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (nonatomic, weak) id <PoiDataEntryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentTypeOfPoi;


@end
