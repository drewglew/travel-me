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

@protocol LocatorDelegate <NSObject>
- (void)didCreatePoiFromProjectPassThru :(NSString*)Key;
- (void)didUpdatePoi :(bool)IsUpdated;
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

@end
