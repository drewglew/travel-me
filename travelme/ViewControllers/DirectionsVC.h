//
//  DirectionsVC.h
//  travelme
//
//  Created by andrew glew on 06/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PoiNSO.h"
#import "PoiImageNSO.h"
#import "AppDelegate.h"
#import "AnnotationMK.h"
#import "ScheduleNSO.h"

@protocol DirectionsDelegate <NSObject>
@end

@interface DirectionsVC : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (nonatomic, retain) MKPolyline *routeLine; 
@property (nonatomic, retain) MKPolylineView *routeLineView;
@property (nonatomic, retain) MKPlacemark *startlocation;
@property (nonatomic, retain) MKPlacemark *destination;
@property (nonatomic, weak) id <DirectionsDelegate> delegate;
@property (nonatomic, readwrite) CLLocationCoordinate2D LocationFromCoord;
@property (nonatomic, readwrite) CLLocationCoordinate2D LocationToCoord;
@property (weak, nonatomic) IBOutlet UILabel *LabelJourneyDetail;
@property (strong, nonatomic) NSMutableArray *Route;
@property (assign) double Distance;
@property (strong, nonatomic) NSMutableArray *scheduleitems;

@property (weak, nonatomic) IBOutlet UILabel *LabelDistance;
@property (weak, nonatomic) IBOutlet UIButton *ButtonOpenMap;

@end