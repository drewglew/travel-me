//
//  LocatorVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "LocatorVC.h"



@interface LocatorVC () <LocatorDelegate, PoiDataEntryDelegate>

@end


@implementation LocatorVC
@synthesize MapView = _MapView;
@synthesize delegate;
@synthesize PointOfInterest;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchBar.delegate = self;
    
    UILongPressGestureRecognizer* mapLongPressAddAnnotation = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(AddAnnotationToMap:)];
    [mapLongPressAddAnnotation setMinimumPressDuration:0.5];
    [self.MapView addGestureRecognizer:mapLongPressAddAnnotation];    // Do any additional setup after loading the view.
    self.MapView.delegate = self;
    
    self.PointOfInterest = [[PoiNSO alloc] init];
    self.PointOfInterest.name = @"";
    self.PointOfInterest.Coordinates = kCLLocationCoordinate2DInvalid;
    self.PointOfInterest.key = [[NSUUID UUID] UUIDString];
    self.PointOfInterest.Images  = [[NSMutableArray alloc] init];
    self.PointOfInterest.Links = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/* last modified 20170116 */
-(void)AddAnnotationToMap:(UILongPressGestureRecognizer *)gesture
{
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*) gesture;
    
    if(UIGestureRecognizerStateBegan == gesture.state)
    {
        CGPoint tapPoint = [recognizer locationInView:self.MapView];
        CLLocationCoordinate2D location = [self.MapView convertPoint:tapPoint toCoordinateFromView:self.MapView];

        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
            } else {
                MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
                if ([placemarks count]>0) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    anno.coordinate = placemark.location.coordinate;
                    if (placemark.subThoroughfare == nil) {
                        anno.title = placemark.thoroughfare;
                    } else {
                        
                        anno.title = [NSString stringWithFormat:@"%@, %@",placemark.thoroughfare, placemark.subThoroughfare];
                    }
                    
                    anno.subtitle = placemark.subLocality;
                    [self.MapView addAnnotation:anno];
                    [self.MapView selectAnnotation:anno animated:true];
                } else {
                    anno.title = @"Unknown Place";
                }
                 [self.MapView addAnnotation:anno];
                 [self.MapView selectAnnotation:anno animated:true];
            }
        }];
        
    }
    
}




- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.SearchBar resignFirstResponder];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder geocodeAddressString:self.SearchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
        } else {
            CLPlacemark *placemark = [placemarks firstObject];
            
            MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
            anno.coordinate = placemark.location.coordinate;
            if (placemark.subThoroughfare == nil && placemark.thoroughfare != nil) {
                anno.title = placemark.thoroughfare;
            } else if (placemark.thoroughfare == nil) {
                anno.title = self.SearchBar.text;
            } else {
                anno.title = [NSString stringWithFormat:@"%@, %@",placemark.thoroughfare, placemark.subThoroughfare];
            }
            anno.subtitle = placemark.subLocality;
            
            CLLocationCoordinate2D location = placemark.location.coordinate;
            [self.MapView setCenterCoordinate:location animated:TRUE];
            
            [self.MapView addAnnotation:anno];
            [self.MapView selectAnnotation:anno animated:true];
        }
    }];
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.PointOfInterest.name = view.annotation.title;
    self.PointOfInterest.Coordinates = view.annotation.coordinate;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    self.PointOfInterest.name = @"";
    self.PointOfInterest.Coordinates = kCLLocationCoordinate2DInvalid;

}


- (IBAction)ClearAnnotationsOnMapPressed:(id)sender {
    [self.MapView removeAnnotations:self.MapView.annotations];

    
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           trigger segue controls without map data
 */
- (IBAction)SkipMapDataPressed:(id)sender {

    [self performSegueWithIdentifier:@"ShowPoiWithoutMapData" sender:self];
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           trigger segue controls with map data if valid
 */
- (IBAction)UseMapDataPressed:(id)sender {
    bool coordinatesAreValid = (CLLocationCoordinate2DIsValid(self.PointOfInterest.Coordinates));
                                
    if (coordinatesAreValid) {
        [self performSegueWithIdentifier:@"ShowPoiWithMapData" sender:self];

    } else {
        
        NSLog(@"Nothing doing!");
    }
    
    
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowPoiWithMapData"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        controller.PointOfInterest = self.PointOfInterest;
    } else if([segue.identifier isEqualToString:@"ShowPoiWithoutMapData"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        controller.PointOfInterest = self.PointOfInterest;
    }
}



@end
