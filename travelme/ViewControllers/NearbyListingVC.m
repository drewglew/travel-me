//
//  NearbyListingVC.m
//  travelme
//
//  Created by andrew glew on 16/07/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "NearbyListingVC.h"

@interface NearbyListingVC ()

@end

@implementation NearbyListingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self checkInternet]) {
        if (self.PointOfInterest==nil) {
            NSLog(@"Get Location");
            [self startUserLocationSearch];
        } else {
            
            self.LabelNearby.text = [NSString stringWithFormat:@"Nearby %@",self.PointOfInterest.name];
            
            [self LoadNearbyPoiItemsData];
        }
    }
    else
        NSLog(@"Device is not connected to the Internet");
    
    
   
    self.TableViewNearbyPoi.delegate = self;
    self.TableViewNearbyPoi.rowHeight = 77;
    // Do any additional setup after loading the view.
}

/*
 created date:      17/07/2018
 last modified:     17/07/2018
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
 created date:      17/07/2018
 last modified:     17/07/2018
 remarks:
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    
    self.PointOfInterest = [[PoiNSO alloc] init];
    
    self.PointOfInterest.Coordinates = self.locationManager.location.coordinate;
    self.PointOfInterest.lat = [NSNumber numberWithDouble: self.locationManager.location.coordinate.latitude];
    self.PointOfInterest.lon = [NSNumber numberWithDouble: self.locationManager.location.coordinate.longitude];
    
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
        } else {
            if ([placemarks count]>0) {
                CLPlacemark *placemark = [placemarks firstObject];
                self.PointOfInterest.countrycode = placemark.ISOcountryCode;
            }
            
            [self LoadNearbyPoiItemsData];
            
        }
    }];
    
    
    
}

/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:  calls the wiki API and gets Array of results
 */
-(void) LoadNearbyPoiItemsData {
    self.nearbyitems = [[NSMutableArray alloc] init];
    CountryNSO *Country;
    NSString *language;
    
    if (self.SegmentWikiLanguageOption.selectedSegmentIndex == 0) {
        NSLocale *theLocale = [NSLocale currentLocale];
        NSString *countryCode = [theLocale objectForKey:NSLocaleCountryCode];
        Country = [AppDelegateDef.Db GetCountryByCode:countryCode];
        language = Country.language;
    } else if (self.SegmentWikiLanguageOption.selectedSegmentIndex == 1) {
        Country = [AppDelegateDef.Db GetCountryByCode:self.PointOfInterest.countrycode];
        language = Country.language;
    } else {
        language = @"en";
    }
        
        
    /*
     Obtain Wiki records based on coordinates & local language.  (radius is in meters, we should use same range as type used to search photos)
     https://en.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=1000&gscoord=52.5208626606277|13.4094035625458&format=json
     
     Or search by name with redirect.
     https://en.wikipedia.org/w/api.php?action=query&titles=Göteborg&redirects&format=jsonfm&formatversion=2
     */
    
    NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=query&list=geosearch&gsprop=type|name|dim|country|region|globe&gsradius=10000&gscoord=%@|%@&format=json&redirects&gslimit=120",language ,self.PointOfInterest.lat, self.PointOfInterest.lon];
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self fetchFromWikiApi:url withDictionary:^(NSDictionary *data) {
        
        NSDictionary *query = [data objectForKey:@"query"];
        NSDictionary *geosearch =  [query objectForKey:@"geosearch"];
        
        NSLog(@"%@",geosearch);
        
        /* we can process all later, but am only interested in the closest wiki entry */
        for (NSDictionary *item in geosearch) {
            NearbyPoiNSO *poi = [[NearbyPoiNSO alloc] init];
            
            poi.wikititle = [NSString stringWithFormat:@"%@~%@",language,[[item valueForKey:@"title"] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
            poi.title = [item valueForKey:@"title"];
            poi.dist = [item valueForKey:@"dist"];
            poi.Coordinates = CLLocationCoordinate2DMake([[item valueForKey:@"lat"] doubleValue], [[item valueForKey:@"lon"] doubleValue]);
            
            [self.nearbyitems addObject:poi];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.TableViewNearbyPoi reloadData];
        });
        
        
    }];
    
   
    
}

/*
 created date:      13/06/2018
 last modified:     17/07/2018
 remarks:
 */
-(void)fetchFromWikiApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
}



/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nearbyitems.count;
}



/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NearbyPoiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearbyCellId"];
    
    NearbyPoiNSO *item = [self.nearbyitems objectAtIndex:indexPath.row];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    cell.LabelDist.text = [NSString stringWithFormat:@"%@ metres",[fmt stringFromNumber:item.dist]];

    cell.LabelTitle.text = item.title;

    return cell;
}

/*
 created date:      16/07/2018
 last modified:     19/07/2018
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([self checkInternet]) {
        static NSString *IDENTIFIER = @"NearbyCellId";
        
        NearbyPoiCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[NearbyPoiCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }
        
        NearbyPoiNSO *Nearby = [self.nearbyitems objectAtIndex:indexPath.row];
        
        self.PointOfInterest = [[PoiNSO alloc] init];
        self.PointOfInterest.key = [[NSUUID UUID] UUIDString];
        self.PointOfInterest.Images = [[NSMutableArray alloc] init];
        self.PointOfInterest.Coordinates = Nearby.Coordinates;
        self.PointOfInterest.lat = [NSNumber numberWithDouble:Nearby.Coordinates.latitude];
        self.PointOfInterest.lon = [NSNumber numberWithDouble:Nearby.Coordinates.longitude];
        self.PointOfInterest.wikititle = Nearby.wikititle;
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:Nearby.Coordinates.latitude longitude:Nearby.Coordinates.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
            } else {
                if ([placemarks count]>0) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    
                    NSString *AdminArea = placemark.subAdministrativeArea;
                    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                        AdminArea = placemark.administrativeArea;
                    }
                    self.PointOfInterest.administrativearea = [NSString stringWithFormat:@"%@, %@", AdminArea,placemark.ISOcountryCode];
                    self.PointOfInterest.country = placemark.country;
                    self.PointOfInterest.sublocality = placemark.subLocality;
                    self.PointOfInterest.locality = placemark.locality;
                    self.PointOfInterest.postcode = placemark.postalCode;
                    self.PointOfInterest.countrycode = placemark.ISOcountryCode;
                    self.PointOfInterest.fullthoroughfare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];
                    
                }
                self.PointOfInterest.name = Nearby.title;

                /*
                 Obtain Wiki records based on coordinates & local language.  (radius is in meters, we should use same range as type used to search photos)
                 https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=Chichester
                */
                
                NSArray *parms = [self.PointOfInterest.wikititle componentsSeparatedByString:@"~"];

                NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=%@",[parms objectAtIndex:0],[parms objectAtIndex:1]];
                
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

                /* get data */
                [self fetchFromWikiApi:url withDictionary:^(NSDictionary *data) {
                    
                    NSDictionary *query = [data objectForKey:@"query"];
                    NSDictionary *pages =  [query objectForKey:@"pages"];
                    NSArray *keys = [pages allKeys];
                    NSDictionary *item =  [pages objectForKey:[keys firstObject]];
                    self.PointOfInterest.privatenotes = [item objectForKey:@"extract"];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        
                        PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
                        
                        controller.delegate = self;
                        controller.PointOfInterest = self.PointOfInterest;
                        controller.newitem = true;
                        controller.readonlyitem = false;
                        controller.fromproject = false;
                        controller.fromnearby = true;
                        
                        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                        [self presentViewController:controller animated:YES completion:nil];
                    });
                    
                }];
       
            }
        }];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewNearbyPoi.frame.size.width, 70)];
    return footerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewNearbyPoi.frame.size.width, 110)];
    return headerView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:
 */
- (void)didCreatePoiFromProject :(NSString*)Key {
}



/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:
 */
- (void)didUpdatePoi :(bool)IsUpdated {
    self.UpdatedPoi = true;
}


/*
 created date:      17/07/2018
 last modified:     17/07/2018
 remarks:
 */
- (IBAction)SegmentLanguageChanged:(id)sender {
    
    if ([self checkInternet]) {
       [self LoadNearbyPoiItemsData];
    }
}

/*
 created date:      19/07/2018
 last modified:     19/07/2018
 remarks:
 */
- (bool)checkInternet
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        return false;
    }
    else
    {
        //connection available
        return true;
    }
    
}


/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    if (self.UpdatedPoi) {
        [self.delegate didUpdatePoi:true];
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
