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

MKLocalSearch *localSearch;
MKLocalSearchResponse *results;

@synthesize MapView = _MapView;
@synthesize delegate;
@synthesize PointOfInterest;



/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchBar.delegate = self;
    self.TableViewSearchResult.delegate = self;
    
    [self startUserLocationSearch];
    
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
    self.TableViewSearchResult.rowHeight = 70;
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

/*
 created date:      11/05/2018
 last modified:     11/05/2018
 remarks:
 */
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
/*
 created date:      06/05/2018
 last modified:     11/06/2018
 remarks:
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
        } else {
            AnnotationMK *anno = [[AnnotationMK alloc] init];
            if ([placemarks count]>0) {
                CLPlacemark *placemark = [placemarks firstObject];
                anno.coordinate = placemark.location.coordinate;
                anno.title = placemark.name;
                NSString *AdminArea = placemark.subAdministrativeArea;
                if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                    AdminArea = placemark.administrativeArea;
                }
                
                anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea, placemark.ISOcountryCode ];
                
                anno.Country = placemark.country;
                anno.SubLocality = placemark.subLocality;
                anno.Locality = placemark.locality;
                anno.PostCode = placemark.postalCode;
                anno.CountryCode = placemark.ISOcountryCode;
                anno.FullThoroughFare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];

                [self.MapView addAnnotation:anno];
                [self.MapView setCenterCoordinate:anno.coordinate animated:YES];
                [self.MapView selectAnnotation:anno animated:true];
                
            } else {
                anno.title = @"Unknown Place";
            }
            [self.MapView addAnnotation:anno];
            [self.MapView selectAnnotation:anno animated:true];
        }
    }];
}



/*
 created date:      27/04/2018
 last modified:     29/04/2018
 remarks: User gestures a long tap, the annotation is placed where the figure is.
 */
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
                AnnotationMK *anno = [[AnnotationMK alloc] init];
                if ([placemarks count]>0) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    anno.coordinate = placemark.location.coordinate;
                    anno.title = placemark.name;
                    NSString *AdminArea = placemark.subAdministrativeArea;
                    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                        AdminArea = placemark.administrativeArea;
                    }
                    
                    anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea, placemark.ISOcountryCode ];
                    
                    anno.Country = placemark.country;
                    anno.SubLocality = placemark.subLocality;
                    anno.Locality = placemark.locality;
                    anno.PostCode = placemark.postalCode;
                    anno.CountryCode = placemark.ISOcountryCode;
                    anno.FullThoroughFare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];

                    //anno.subtitle = placemark.subLocality;
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

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.TableViewSearchResult.hidden=false;
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.MapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            return;
        }
        
        if ([response.mapItems count] == 0) {
            return;
        }
        results = response;
        [self.TableViewSearchResult reloadData];
    }];
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    SearchResultListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[SearchResultListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    NSDictionary *dictStructuredAddress = [[[item valueForKey:@"place"] valueForKey:@"address"] valueForKey:@"structuredAddress"];

    NSString *AdminArea = [dictStructuredAddress valueForKey:@"subAdministrativeArea"];
    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
        AdminArea = [dictStructuredAddress valueForKey:@"administrativeArea"];
    }
    cell.subTitle = [NSString stringWithFormat:@"%@, %@", AdminArea, [dictStructuredAddress valueForKey:@"countryCode"]];
    cell.LabelSearchItem.text = item.name;
    cell.LabelSearchCountryItem.text = cell.subTitle;

    return cell;
}

/*
 created date:      28/04/2018
 last modified:     09/05/2018
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.SearchBar setActive:NO animated:YES];
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    SearchResultListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[SearchResultListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    AnnotationMK *anno = [[AnnotationMK alloc] init];
    anno.title = item.name;
    
    NSString *AdminArea = item.placemark.subAdministrativeArea;
    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
        AdminArea = item.placemark.administrativeArea;
    }
    
    anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea,item.placemark.countryCode ];
    //fullThoroughfare 
    anno.Country = item.placemark.country;
    anno.SubLocality = item.placemark.subLocality;
    anno.Locality = item.placemark.locality;
    anno.PostCode = item.placemark.postalCode;
    anno.CountryCode = item.placemark.countryCode;
    anno.FullThoroughFare = [NSString stringWithFormat:@"%@, %@",item.placemark.thoroughfare, item.placemark.subThoroughfare];
    anno.coordinate = item.placemark.coordinate;
    
    [self.MapView addAnnotation:anno];
    [self.MapView selectAnnotation:anno animated:YES];
    [self.MapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    [self.MapView setUserTrackingMode:MKUserTrackingModeNone];
    self.SearchBar.text  = item.name;
    [self.SearchBar endEditing:YES];
    self.TableViewSearchResult.hidden = true;
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.SearchBar resignFirstResponder];
    self.TableViewSearchResult.hidden=true;
}
/*
 created date:      27/04/2018
 last modified:     19/05/2018
 remarks:
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id annotation = view.annotation;
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        AnnotationMK *annotation = (AnnotationMK *)[view annotation];
        self.PointOfInterest.name = annotation.title;
        self.PointOfInterest.administrativearea = annotation.subtitle;
        self.PointOfInterest.lat = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        self.PointOfInterest.lon = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        self.PointOfInterest.Coordinates = annotation.coordinate;
        self.PointOfInterest.country = annotation.Country;
        self.PointOfInterest.countrycode = annotation.CountryCode;
        self.PointOfInterest.locality = annotation.Locality;
        self.PointOfInterest.sublocality = annotation.SubLocality;
        self.PointOfInterest.fullthoroughfare = annotation.FullThoroughFare;
        self.PointOfInterest.postcode = annotation.PostCode;
        self.PointOfInterest.subadministrativearea = annotation.SubAdministrativeArea;
    } else {
        AnnotationMK *annotation = (AnnotationMK *)[view annotation];
        self.PointOfInterest.name = annotation.title;
        self.PointOfInterest.administrativearea = annotation.subtitle;
        self.PointOfInterest.lat = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        self.PointOfInterest.lon = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        self.PointOfInterest.Coordinates = annotation.coordinate;
    }
    
}

/*
 created date:      27/04/2018
 last modified:     09/05/2018
 remarks:
 */
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    //AnnotationMK *annotation = (AnnotationMK *)[view annotation];
    
    self.PointOfInterest.name = @"";
    self.PointOfInterest.administrativearea = @"";
    self.PointOfInterest.subadministrativearea = @"";
    self.PointOfInterest.locality = @"";
    self.PointOfInterest.sublocality = @"";
    self.PointOfInterest.postcode = @"";
    self.PointOfInterest.country = @"";
    self.PointOfInterest.countrycode = @"";
    self.PointOfInterest.fullthoroughfare = @"";
    self.PointOfInterest.Coordinates = kCLLocationCoordinate2DInvalid;
    self.PointOfInterest.lat = [NSNumber numberWithDouble:0];
    self.PointOfInterest.lon = [NSNumber numberWithDouble:0];
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
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
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
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
        controller.PointOfInterest = self.PointOfInterest;
        controller.newitem = true;
        controller.readonlyitem = false;
        controller.fromproject = self.fromproject;
    } else if([segue.identifier isEqualToString:@"ShowPoiWithoutMapData"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.PointOfInterest;
        controller.newitem = true;
        controller.readonlyitem = false;
        controller.fromproject = self.fromproject;
    }
}

/*
 created date:      11/06/2018
 last modified:     11/06/2018
 remarks:
 */
- (void)didCreatePoiFromProject :(NSString*)Key {
    [self.delegate didCreatePoiFromProjectPassThru:Key];
    [self dismissViewControllerAnimated:YES completion:Nil];
}
/*
 created date:      1/06/2018
 last modified:     11/06/2018
 remarks: Leave empty
 */
- (void)didCreatePoiFromProjectPassThru :(NSString*)Key {
}

@end
