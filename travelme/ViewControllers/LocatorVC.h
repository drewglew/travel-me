//
//  LocatorVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PoiDataEntryVC.h"
#import "PoiNSO.h"
#import "PoiImageNSO.h"
#import "SearchResultListCell.h"
#import "AnnotationMK.h"
#import "ProjectNSO.h"
#import "Reachability.h"

@protocol LocatorDelegate <NSObject>
- (void)didCreatePoiFromProjectPassThru :(PoiNSO*)Object;
- (void)didUpdatePoi :(NSString*)Method :(PoiNSO*)Object;
@end

@interface LocatorVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate> {
    MKMapView *MapView;
}
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (strong, nonatomic) PoiNSO *TempPoi;
@property (assign) bool fromproject;
@property (nonatomic, weak) id <LocatorDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *TableViewSearchResult;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonClear;
@property (weak, nonatomic) IBOutlet UIButton *ButtonNext;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSkip;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewGlobe;

@property (weak, nonatomic) IBOutlet UILabel *LabelWarningNoInet;


@end
