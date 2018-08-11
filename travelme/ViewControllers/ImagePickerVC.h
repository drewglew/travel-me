//
//  ImagePickerVC.h
//  travelme
//
//  Created by andrew glew on 10/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Photos/Photos.h>
#import "PoiNSO.h"
#import "ImageCollectionCell.h"
#import "ImageNSO.h"
#import "ToolBoxNSO.h"

@protocol ImagePickerDelegate <NSObject>
- (void)didAddImages :(NSMutableArray*)ImageCollection;
@end

@interface ImagePickerVC : UIViewController<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSThread *queueThread;
}

@property (weak, nonatomic) IBOutlet UICollectionView *ImageCollectionView;
@property (strong, nonatomic) NSMutableArray *imageitems;
@property (nonatomic, readwrite) CGSize ImageSize;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityLoading;
@property (nonatomic, retain) IBOutlet UILabel *LabelPhotoCounter;
@property (weak, nonatomic) IBOutlet ImageCollectionCell *CellContent;
@property (weak, nonatomic) IBOutlet UIButton *ButtonStopSearching;
@property (weak, nonatomic) IBOutlet UILabel *LabelPoiName;
@property (nonatomic) NSNumber *distance;
@property (assign) bool wikiimages;
@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (nonatomic, weak) id <ImagePickerDelegate> delegate;

@end
