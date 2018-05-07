//
//  DirectionsVC.m
//  travelme
//
//  Created by andrew glew on 06/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "DirectionsVC.h"

@interface DirectionsVC ()

@end

@implementation DirectionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.MapView.delegate = self;
    // Do any additional setup after loading the view.
}

/*
 created date:      06/05/2018
 last modified:     06/05/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startUserLocationSearch];
}



-(void)startUserLocationSearch{
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];

    CLLocationCoordinate2D coordinateArray[2];

    coordinateArray[0] = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    coordinateArray[1] = self.LocationToCoord;
    
    MKPlacemark *placemark  = [[MKPlacemark alloc] initWithCoordinate:coordinateArray[0] addressDictionary:nil];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinateArray[0];
    annotation.title = @"My Location";
    [self.MapView addAnnotation:annotation];

    self.startlocation = placemark;
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:self.startlocation];
    
    MKPlacemark *placemark1  = [[MKPlacemark alloc] initWithCoordinate:coordinateArray[1] addressDictionary:nil];
    
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = coordinateArray[1];
    annotation1.title = @"Destination";
    [self.MapView addAnnotation:annotation1];
    
    self.destination = placemark1;
    
    MKMapItem *mapItem1 = [[MKMapItem alloc] initWithPlacemark:self.destination];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = mapItem1;
    
    request.destination = mapItem;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"ERROR");
             NSLog(@"%@",[error localizedDescription]);
         } else {
             [self showRoute:response];
             
             //self.LabelJourneyDetail.text = response.description;
             
         }
     }];
}



-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.MapView
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
        
        self.LabelDistance.text = [NSString stringWithFormat:@"Distance = %.02f km", (route.distance / 1000)];
        
        [self zoomToPolyLine:self.MapView polyline:route.polyline animated:true];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}

-(void)zoomToPolyLine: (MKMapView*)map polyline: (MKPolyline*)polyline animated: (BOOL)animated
{
    [map setVisibleMapRect:[polyline boundingMapRect] edgePadding:UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0) animated:animated];
}

- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}




@end
