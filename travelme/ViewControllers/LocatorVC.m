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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
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
 last modified:     28/04/2018
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
    
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = item.name;
    
    NSString *AdminArea = item.placemark.subAdministrativeArea;
    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
        AdminArea = item.placemark.administrativeArea;
    }
    
    anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea,item.placemark.countryCode ];
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
 last modified:     28/04/2018
 remarks:
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.PointOfInterest.name = view.annotation.title;
    self.PointOfInterest.administrativearea = view.annotation.subtitle;
    self.PointOfInterest.lat = [NSNumber numberWithDouble:view.annotation.coordinate.latitude];
    self.PointOfInterest.lon = [NSNumber numberWithDouble:view.annotation.coordinate.longitude];
    self.PointOfInterest.Coordinates = view.annotation.coordinate;
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    self.PointOfInterest.name = @"";
    self.PointOfInterest.administrativearea = @"";
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
        controller.db = self.db;
        controller.PointOfInterest = self.PointOfInterest;
        controller.newitem = true;
    } else if([segue.identifier isEqualToString:@"ShowPoiWithoutMapData"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        controller.PointOfInterest = self.PointOfInterest;
        controller.newitem = true;
    }
}



@end
