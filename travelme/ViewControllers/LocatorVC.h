//
//  LocatorVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Dal.h"
#import "PoiDataEntryVC.h"
#import "PoiNSO.h"

@protocol LocatorDelegate <NSObject>
@end

@interface LocatorVC : UIViewController <UISearchBarDelegate, MKMapViewDelegate> {
    MKMapView *MapView;
}
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) PoiNSO *PointOfInterest;

@property (strong, nonatomic) Dal *db;
@property (nonatomic, weak) id <LocatorDelegate> delegate;

@end
