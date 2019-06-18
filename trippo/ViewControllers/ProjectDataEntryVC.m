//
//  ProjectDataEntry.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectDataEntryVC.h"

@interface ProjectDataEntryVC ()

@end

@implementation ProjectDataEntryVC
@synthesize delegate;
bool loadedActualWeatherData = false;
bool loadedPlannedWeatherData = false;

/*
 created date:      29/04/2018
 last modified:     12/06/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.loadedActualWeatherData = false;
    self.loadedPlannedWeatherData = false;
    // Do any additional setup after loading the view.
    if (!self.newitem) {
        [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
        [self LoadExistingData];
        self.updatedimage = false;
    }

    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    self.TextViewNotes.delegate = self;
    self.TextFieldName.delegate = self;
    self.MapView.delegate = self;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    //self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0]CGColor];
    //self.TextViewNotes.layer.borderWidth= 2.0f;
    
    self.ViewSummary.layer.cornerRadius=8.0f;
    self.ViewSummary.layer.masksToBounds=YES;
    //self.ViewSummary.layer.borderColor=[[UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0]CGColor];
    //self.ViewSummary.layer.borderWidth= 2.0f;
    
    
    NSDate *startOfToday = [[NSDate alloc] init];
    
    /* if a new trip, set both start & end dates to today at 00:00  */
    if (self.newitem) {
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [cal setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSDateComponents * comp = [cal components:( NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
        [comp setMinute:0];
        [comp setHour:0];
        [comp setSecond:0];
        startOfToday = [cal dateFromComponents:comp];
     }
    
    /* initialize the datePicker for start dt */
    self.datePickerStart = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePickerStart setDatePickerMode:UIDatePickerModeDateAndTime];
    
    if (self.newitem) {
        [self.datePickerStart setDate:startOfToday];
        self.Trip.startdt = startOfToday;
    } else {
        [self.datePickerStart setDate:self.Trip.startdt];
    }
    [self.datePickerStart addTarget:self action:@selector(onDatePickerStartValueChanged:) forControlEvents:UIControlEventValueChanged];

    /* initialize the datePicker for end dt */
    self.datePickerEnd = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePickerEnd setDatePickerMode:UIDatePickerModeDateAndTime];
    if (self.newitem) {
        [self.datePickerEnd setDate:startOfToday];
        self.Trip.enddt = startOfToday;
    } else {
        [self.datePickerEnd setDate:self.Trip.enddt];
    }
    [self.datePickerEnd addTarget:self action:@selector(onDatePickerEndValueChanged:) forControlEvents:UIControlEventValueChanged];

    /* add toolbar control for 'Done' option */
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(HideDatePicker)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];

    /* extend features on the input view of the text field for start dt */
    self.TextFieldStartDt.inputView = self.datePickerStart;
    self.TextFieldStartDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.datePickerStart.date]];
    [self.TextFieldStartDt setInputAccessoryView:toolBar];
    
    /* extend features on the input view of the text field for end dt */
    self.TextFieldEndDt.inputView = self.datePickerEnd;
    self.TextFieldEndDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.datePickerEnd.date]];
    [self.TextFieldEndDt setInputAccessoryView:toolBar];

   
}



/*
 created date:      14/06/2019
 last modified:     14/06/2019
 remarks:           This procedure handles the call to the web service and returns a dictionary back to GetExchangeRates method.
 */
-(void)fetchFromDarkSkyApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
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
 created date:      14/06/2019
 last modified:     14/06/2019
 */
- (bool)checkInternet
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable)
    {
        return false;
    }
    else
    {
        //connection available
        return true;
    }
    
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    
    MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    AnnotationMK *myAnnotation = (AnnotationMK*) annotation;
    
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        
        //pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    } else {
        pinView.annotation = annotation;
    }
    
    pinView.image = [UIImage imageNamed:myAnnotation.Type];
    pinView.calloutOffset = CGPointMake(0, 0);
    pinView.centerOffset = CGPointMake(0, -pinView.image.size.height / 2);
    return pinView;
}


/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (void) zoomToAnnotationsBounds:(NSArray *)annotations {
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (AnnotationMK *annotation in annotations) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    // If your markers were 40 in height and 20 in width, this would zoom the map to fit them perfectly. Note that there is a bug in mkmapview's set region which means it will snap the map to the nearest whole zoom level, so you will rarely get a perfect fit. But this will ensure a minimum padding.
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0);
    CLLocationCoordinate2D relativeFromCoord = [self.MapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.MapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D rightCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D bottomCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D leftCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.MapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    // MKMapView BUG: this snaps to the nearest whole zoom level, which is wrong- it doesn't respect the exact region you asked for. See http://stackoverflow.com/questions/1383296/why-mkmapview-region-is-different-than-requested
    [self.MapView setRegion:region animated:NO];
}


/*
 created date:      16/02/2019
 last modified:     16/02/2019
 remarks:
 */
-(NSString*)FormatPrettyDate :(NSDate*)Dt {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];
    return [NSString stringWithFormat:@"%@ %@",[dateformatter stringFromDate:Dt], [timeformatter stringFromDate:Dt]];
}


/*
 created date:      16/02/2019
 last modified:     17/02/2019
 remarks:
 */
- (void)HideDatePicker
{
    [self.TextFieldStartDt resignFirstResponder];
    [self.TextFieldEndDt resignFirstResponder];
}


/*
 created date:      16/02/2019
 last modified:     16/02/2019
 remarks:
 */
- (void)onDatePickerStartValueChanged:(UIDatePicker *)datePicker
{
    self.TextFieldStartDt.text = [self FormatPrettyDate:datePicker.date];
    NSComparisonResult result = [self.datePickerEnd.date compare:datePicker.date];
    
    switch (result)
    {
        case NSOrderedAscending:
            NSLog(@"%@ is in future from %@", datePicker.date, self.datePickerEnd.date);
            self.datePickerEnd.date = datePicker.date;
            self.TextFieldEndDt.text = [self FormatPrettyDate:datePicker.date];
            break;
        case NSOrderedDescending: NSLog(@"%@ is in past from %@", datePicker.date, self.datePickerEnd.date); break;
        case NSOrderedSame: NSLog(@"%@ is the same as %@", datePicker.date, self.datePickerEnd.date); break;
        default: NSLog(@"erorr dates %@, %@", datePicker.date, self.datePickerEnd.date); break;
    }
    //self.LabelDuration.text = [ToolBoxNSO PrettyDateDifference:datePicker.date :self.datePickerEnd.date :@""];
    
}

/*
 created date:      16/02/2019
 last modified:     16/02/2019
 remarks:
 */
- (void)onDatePickerEndValueChanged:(UIDatePicker *)datePicker
{
    self.TextFieldEndDt.text = [self FormatPrettyDate:datePicker.date];
    NSComparisonResult result = [datePicker.date compare: self.datePickerStart.date];
    
    switch (result)
    {
        case NSOrderedAscending:
            NSLog(@"%@ is in future from %@", self.datePickerStart.date, datePicker.date);
            self.datePickerStart.date = datePicker.date;
            self.TextFieldStartDt.text = [self FormatPrettyDate:datePicker.date];
            break;
        case NSOrderedDescending:
            NSLog(@"%@ is in past from %@", self.datePickerStart.date, datePicker.date);
            
            break;
        case NSOrderedSame: NSLog(@"%@ is the same as %@", self.datePickerStart.date, datePicker.date); break;
        default: NSLog(@"erorr dates %@, %@", self.datePickerStart.date, datePicker.date); break;
    }
    //self.LabelDuration.text = [ToolBoxNSO PrettyDateDifference:self.datePickerStart.date :datePicker.date :@""];
}








/*
 created date:      29/04/2018
 last modified:     08/10/2018
 remarks:
 */
-(void) LoadExistingData {
    
    self.TextFieldName.text = self.Trip.name;
    self.TextViewNotes.text = self.Trip.privatenotes;

    NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
    [dtformatter setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
   
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.numberStyle = NSNumberFormatterDecimalStyle;
    nf.maximumFractionDigits = 2;
    
    
    
    if (self.Trip.routeactualcalculateddt==nil) {
        self.LabelActCalcDist.hidden = true;
        self.LabelActCalcTravelTime.hidden = true;
        self.LabelActCalcTitle.hidden = false;
        self.LabelActCalcTitle.text = @"No summary for Actual trip available";
    } else {
        self.LabelActCalcDist.hidden = false;
        self.LabelActCalcTravelTime.hidden = false;
        self.LabelActCalcTitle.hidden = false;
        self.LabelActCalcTitle.text = [NSString stringWithFormat:@"Actual Summary generated on:\n%@",[dtformatter stringFromDate:self.Trip.routeactualcalculateddt]];
        self.LabelActCalcTravelTime.text = [NSString stringWithFormat:@"%@ hours",[self stringFromTimeInterval:self.Trip.routeactualtotaltravelminutes]];
        
        self.LabelActCalcDist.text = [NSString stringWithFormat:@"%@", [self formattedDistanceForMeters :[self.Trip.routeactualtotaltraveldistance doubleValue]]];
                                      
    }
    if (self.Trip.routeplannedcalculateddt==nil) {
        self.LabelEstCalcDist.hidden = true;
        self.LabelEstCalcTravelTime.hidden = true;
        self.LabelEstCalcTitle.hidden = false;
        self.LabelEstCalcTitle.text = @"No summary for Planned trip available";
    } else {
        self.LabelEstCalcDist.hidden = false;
        self.LabelEstCalcTravelTime.hidden = false;
        self.LabelEstCalcTitle.hidden = false;
        self.LabelEstCalcTitle.text = [NSString stringWithFormat:@"Planned Summary generated on:\n%@",[dtformatter stringFromDate:self.Trip.routeplannedcalculateddt]];
       
        self.LabelEstCalcTravelTime.text = [NSString stringWithFormat:@"%@ hours",[self stringFromTimeInterval:self.Trip.routeplannedtotaltravelminutes]];
        self.LabelEstCalcDist.text = [NSString stringWithFormat:@"%@", [self formattedDistanceForMeters :[self.Trip.routeplannedtotaltraveldistance doubleValue]]];
    }
   
    /* generate the flags */
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey = %@",self.Trip.key];
    
    for (ActivityRLM *activity in activities) {
        if (activity.poi != nil && activity.poi.countrycode != nil && ![activity.poi.countrycode isEqualToString:@""]) {
            [dictionary setObject:[self emojiFlagForISOCountryCode:activity.poi.countrycode] forKey:activity.poi.countrycode];
        }
    }
    
    for(id key in dictionary) {
        self.LabelFlags.text = [NSString stringWithFormat:@"%@ %@",self.LabelFlags.text,[dictionary objectForKey:key]];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    ImageCollectionRLM *image = [self.Trip.images firstObject];
    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    if (pngData!=nil) {
        self.ImageViewProject.image = [UIImage imageWithData:pngData];
    } else {
        [self.ImageViewProject setImage:[UIImage imageNamed:@"Project"]];
    }
}

- (NSString *)stringFromTimeInterval:(NSNumber*)interval {
    long ti = [interval longValue];
    long seconds = ti % 60;
    long minutes = (ti / 60) % 60;
    long hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}


/*
 created date:      29/04/2018
 last modified:     29/03/2019
 remarks:
 */
- (IBAction)ProjectActionPressed:(id)sender {
    
    NSDate *startdt = self.datePickerStart.date;
    NSDate *enddt = self.datePickerEnd.date;
    
    NSString *prettystartdt = [ToolBoxNSO FormatPrettyDate :startdt];
    NSString *prettyenddt = [ToolBoxNSO FormatPrettyDate :enddt];

    // first validation round is between the 2 dates on this page.
    NSComparisonResult result = [startdt compare:enddt];
    
    NSString *AlertMessage = [[NSString alloc] init];
    
    switch (result)
    {
        case NSOrderedDescending:
            AlertMessage = [NSString stringWithFormat:@"The start date %@ cannot be after the end date %@. \nPlease correct.", prettystartdt, prettyenddt];
            break;
        case NSOrderedAscending:
            // all good!!
            break;
        case NSOrderedSame:
            AlertMessage = [NSString stringWithFormat:@"The start date %@ cannot be the same as the end date.\nPlease correct", prettystartdt];
            break;
        default:
            NSLog(@"error dates %@, %@", startdt, enddt);
            break;
    }
    
    if (![AlertMessage isEqualToString:@""])  {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error in dates chosen"
                                     message:AlertMessage
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {

                                    }];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        int StartDtsAmendedCount = 0;
        int EndDtsAmendedCount = 0;
        int DraftAmendedCount = 0;
        
        /* ERROR */

        RLMResults <ActivityRLM*> *plannedactivities = [ActivityRLM objectsWhere:@"tripkey=%@ and state=0",self.Trip.key];
       
        if (plannedactivities.count==0) {
            [self UpdateTripRealmData];
        } else {
            
            for (ActivityRLM* activity in plannedactivities) {
               
                NSDate *activitystartdt = activity.startdt;
                NSDate *activityenddt = activity.enddt;
                
                NSComparisonResult resultstartdt = [self.Trip.startdt compare:activitystartdt];
                NSComparisonResult resultenddt = [self.Trip.enddt compare:activityenddt];
                
                if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedSame) {
                    DraftAmendedCount ++;
                } else if (resultstartdt == NSOrderedDescending && resultenddt == NSOrderedSame) {
                    StartDtsAmendedCount ++;
                } else if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedAscending) {
                    EndDtsAmendedCount ++;
                }
            }
            
            if (DraftAmendedCount + StartDtsAmendedCount + EndDtsAmendedCount > 0)  {

                UIAlertController * alertInfo = [UIAlertController
                                             alertControllerWithTitle:@"Information"
                                             message:[NSString stringWithFormat:@"This update will adjust %d draft items, %d start dates and %d end dates inside activities. Are you sure you want to make this change?", DraftAmendedCount, StartDtsAmendedCount, EndDtsAmendedCount]
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                           actionWithTitle:@"Yes"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               
                                               for (ActivityRLM* activity in plannedactivities) {
                                                   
                                                   NSDate *activitystartdt = activity.startdt;
                                                   NSDate *activityenddt = activity.enddt;
                                                   
                                                   NSComparisonResult resultstartdt = [self.Trip.startdt compare:activitystartdt];
                                                   NSComparisonResult resultenddt = [self.Trip.enddt compare:activityenddt];
                                                   
                                                   if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedSame) {
                                                       [activity.realm beginWriteTransaction];
                                                       activity.startdt = startdt;
                                                       activity.enddt = enddt;
                                                       [activity.realm commitWriteTransaction];
                                                      
                                                   } else if (resultstartdt == NSOrderedDescending  && resultenddt == NSOrderedSame) {
                                                       [activity.realm beginWriteTransaction];
                                                       activity.startdt = startdt;
                                                       if ([startdt compare:activityenddt] == NSOrderedAscending)
                                                       {
                                                            activity.enddt = startdt;
                                                       }
                                                       [activity.realm commitWriteTransaction];
                                                   } else if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedAscending) {
                                                       [activity.realm beginWriteTransaction];
                                                       activity.enddt = enddt;
                                                       if ([enddt compare:activitystartdt] == NSOrderedDescending)
                                                       {
                                                           activity.startdt = enddt;
                                                       }
                                                       [activity.realm commitWriteTransaction];
                                                   }
                                               }
                                               
                                               [self UpdateTripRealmData];
                                           }];
                
                UIAlertAction* noButton = [UIAlertAction
                                           actionWithTitle:@"No"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               
                                           }];
                
                
                [alertInfo addAction:yesButton];
                [alertInfo addAction:noButton];
                
                [self presentViewController:alertInfo animated:YES completion:nil];
            } else {
                
                [self UpdateTripRealmData];
            }
        }
    }
}


/*
 created date:      21/02/2019
 last modified:     21/02/2019
 remarks:
 */
- (void)UpdateTripRealmData
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    if (self.newitem) {
        
        // new item
        
        self.Trip.key = [[NSUUID UUID] UUIDString];
        if (self.updatedimage) {
            
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@",self.Trip.key]];
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSData *imageData =  UIImagePNGRepresentation(self.ImageViewProject.image);
            
            NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
            [imageData writeToFile:filepathname atomically:YES];
            
            ImageCollectionRLM *image = [[ImageCollectionRLM alloc] init];
            image.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
            [self.Trip.images addObject:image];
            
        } else {
            // just set the single placeholder for the trip
            ImageCollectionRLM *image = [[ImageCollectionRLM alloc] init];
            image.ImageFileReference = @"";
            [self.Trip.images addObject:image];
        }
        
        self.Trip.name = self.TextFieldName.text;
        self.Trip.privatenotes = self.TextViewNotes.text;
        self.Trip.modifieddt = [NSDate date];
        self.Trip.createddt = [NSDate date];
        self.Trip.startdt = [self.datePickerStart date];
        self.Trip.enddt = [self.datePickerEnd date];
        
        [self.realm beginWriteTransaction];
        NSLog(@"addObject startdate=%@",self.Trip.startdt);
        [self.realm addObject:self.Trip];
        [self.realm commitWriteTransaction];
    }
    else
    {
        // potential update
        if ([self.Trip.privatenotes isEqualToString:self.TextViewNotes.text] && [self.Trip.name isEqualToString:self.TextFieldName.text] && !self.updatedimage && self.Trip.startdt == self.datePickerStart.date && self.Trip.enddt == self.datePickerEnd.date ) {
            // nothing to do
        } else {
            [self.Trip.realm beginWriteTransaction];
            if (self.updatedimage) {
                NSData *imageData =  UIImagePNGRepresentation(self.ImageViewProject.image);
                NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@",self.Trip.key]];
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
                [imageData writeToFile:filepathname atomically:YES];
                ImageCollectionRLM *image = [self.Trip.images firstObject];
                image.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
            }
            
            self.Trip.privatenotes = self.TextViewNotes.text;
            self.Trip.name = self.TextFieldName.text;
            self.Trip.modifieddt = [NSDate date];
            self.Trip.startdt = [self.datePickerStart date];
            self.Trip.enddt = [self.datePickerEnd date];
            [self.Trip.realm commitWriteTransaction];
            
        }
    }
    [self dismissViewControllerAnimated:YES completion:Nil];

}

/*
 created date:      29/04/2018
 last modified:     30/03/2019
 remarks:
 */
- (IBAction)EditImagePressed:(id)sender {
    
    NSString *titleMessage = @"How would you like to add a photo to your Project?";
    NSString *alertMessage = @"";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleMessage
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *cameraOption = @"Take a photo with the camera";
    NSString *photorollOption = @"Choose a photo from camera roll";
    NSString *lastphotoOption = @"Select last photo taken";
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraOption
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                   
                                                                   
                                                                   UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
                                                                   
                                                                   UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                                                                   
                                                                   [alert addAction:defaultAction];
                                                                   [self presentViewController:alert animated:YES completion:nil];
                                                                   
                                                                   
                                                               }else
                                                               {
                                                                   
                                                                   UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                   picker.delegate = self;
                                                                   picker.allowsEditing = YES;
                                                                   picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                   picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                                                
                                                                   [self presentViewController:picker animated:YES completion:NULL];
                                                                   
                                                               }
                                                               
                                                               
                                                               NSLog(@"you want a photo");
                                                               
                                                           }];
    
    
    UIAlertAction *lastphotoAction = [UIAlertAction actionWithTitle:lastphotoOption
                                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                                    if (status == PHAuthorizationStatusNotDetermined) {
                                    // Access has not been determined.
                                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                    }];
                                    }
                                    
                                    if (status == PHAuthorizationStatusAuthorized)
                                    {
                                        PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
                                        options.version = PHImageRequestOptionsVersionCurrent;
                                        options.deliveryMode =  PHImageRequestOptionsDeliveryModeHighQualityFormat;
                                        options.resizeMode = PHImageRequestOptionsResizeModeExact;
                                        options.synchronous = NO;
                                        options.networkAccessAllowed =  TRUE;
    
                                        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                                        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                                        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
                                        PHAsset *lastAsset = [fetchResult lastObject];

                                        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                                               targetSize:self.ImageViewProject.frame.size
                                                                              contentMode:PHImageContentModeAspectFill
                                                                                  options:options
                                                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    self.Project.Image = result;
                                                                                    self.ImageViewProject.image = result;
                                                                                    self.updatedimage = true;
                                                                                });
                                                                            }];                                    
                                    }
                                }];
    
    
    
    UIAlertAction *photorollAction = [UIAlertAction actionWithTitle:photorollOption
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                  picker.delegate = self;
                                                                  picker.allowsEditing = YES;
                                                                  
                                                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                  [self presentViewController:picker animated:YES completion:nil];
                                                                  
                                                                  NSLog(@"you want to select a photo");
                                                                  
                                                              }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed cancel");
                                                           }];
    
    
    
    [alert addAction:cameraAction];
    [alert addAction:photorollAction];
    [alert addAction:lastphotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
 created date:      29/04/2018
 last modified:     30/03/2019
 remarks:
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    chosenImage = [ToolBoxNSO imageWithImage:chosenImage scaledToSize:self.ImageViewProject.frame.size];
    self.Project.Image = chosenImage;
    self.ImageViewProject.image = chosenImage;
    self.updatedimage = true;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      28/04/2018
 last modified:     17/02/2019
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextViewNotes endEditing:YES];
    [self.TextFieldName endEditing:YES];
    [self.TextFieldEndDt endEditing:YES];
    [self.TextFieldStartDt endEditing:YES];
}

-(void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    [doneToolbar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.TextViewNotes = textView;
}

-(void)doneButtonClickedDismissKeyboard
{
    [self.TextViewNotes resignFirstResponder];
}


/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


/*
 created date:      09/09/2018
 last modified:     09/09/2018
 remarks:
 */
- (IBAction)UploadImagePressed:(id)sender {
    NSData *dataImage = UIImagePNGRepresentation(self.ImageViewProject.image);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:0];
    
    NSString *ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
    
    NSString *ImageFileDirectory = [NSString stringWithFormat:@"Images/Trips/%@",self.Trip.key];
    
    NSDictionary* dataJSON = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Trip",
                              @"type",
                              ImageFileReference,
                              @"filereference",
                              ImageFileDirectory,
                              @"directory",
                              stringImage,
                              @"image",
                              nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataJSON
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:imagesDirectory];
    url = [url URLByAppendingPathComponent:@"Trip.trippo"];
    
    [jsonData writeToURL:url atomically:NO];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        //Delete file
        NSError *errorBlock;
        if([[NSFileManager defaultManager] removeItemAtURL:url error:&errorBlock] == NO) {
            //NSLog(@"error deleting file %@",error);
            return;
        }
    }];
    
    
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

/*
 created date:      07/10/2018
 last modified:     07/10/2018
 remarks:           Obtain flag of country where Poi is located.
 */
- (NSString *)emojiFlagForISOCountryCode:(NSString *)countryCode {
    NSAssert(countryCode.length == 2, @"Expecting ISO country code");
    
    int base = 127462 -65;
    
    wchar_t bytes[2] = {
        base +[countryCode characterAtIndex:0],
        base +[countryCode characterAtIndex:1]
    };
    
    return [[NSString alloc] initWithBytes:bytes
                                    length:countryCode.length *sizeof(wchar_t)
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

/*
 created date:      08/10/2018
 last modified:     08/10/2018
 remarks:
 */
-(NSString *)formattedDistanceForMeters:(double)distance
{
    NSLengthFormatter *lengthFormatter = [NSLengthFormatter new];
    [lengthFormatter.numberFormatter setMaximumFractionDigits:2];
    
    if ([[AppDelegateDef MeasurementSystem] isEqualToString:@"U.K."] || ![AppDelegateDef MetricSystem]) {
        return [lengthFormatter stringFromValue:distance / 1609.34 unit:NSLengthFormatterUnitMile];
        
    } else {
        return [lengthFormatter stringFromValue:distance / 1000 unit:NSLengthFormatterUnitKilometer];
    }
}


/*
 created date:      12/06/2019
 last modified:     15/06/2019
 remarks:           Plan is as follows:
 Obtain actual activities unique to poi key.
 load into new object array containing the activity name and the coordinates along with color X marker
 Next get estimated activities unique to poi key
 test if they exist in the obect array already.  if they do set the marker to a different color Y, if they do not
 set marker to color Z.
 */
-(void) constructWeatherMapPointData :(bool)IsActual {

    if ([self checkInternet]) {
        double spacer = self.MapView.bounds.size.width / 5.0f;
        for (int column = 0; column < 5; column++)
        {
            if (column == 1 || column == 4) {
                for (int row = 0; row < 5; row++)
                {
                    if (row == 1 || row == 4) {
                        CGPoint Point = CGPointMake(spacer * row, spacer * column);
                        CLLocationCoordinate2D Coord;
                        Coord = [self.MapView convertPoint:Point toCoordinateFromView:self.MapView];
                        
                        NSString *url = [NSString stringWithFormat:@"https://api.darksky.net/forecast/d339db567160bdd560169ea4eef3ee5a/%.4f,%.4f?exclude=minutely,flags,alerts&units=uk2", Coord.latitude, Coord.longitude];
                        
                        [self fetchFromDarkSkyApi:url withDictionary:^(NSDictionary *data) {
                            
                            dispatch_sync(dispatch_get_main_queue(), ^(void){
                                NSLog(@"%@",data);
                               
                                NSDictionary *JSONdata = [data objectForKey:@"currently"];

                                NSString *iconItem = [JSONdata valueForKey:@"icon"];
                                AnnotationMK *annotation = [[AnnotationMK alloc] init];
                                annotation.coordinate = Coord;
                                annotation.title = [JSONdata valueForKey:@"summary"];
                                annotation.subtitle = [NSString stringWithFormat:@"%@ °C",[JSONdata valueForKey:@"temperature"]];
                                annotation.Type = [NSString stringWithFormat:@"weather-%@",iconItem];
                                
                                if (IsActual) {
                                    [self.WeatherActualAnnotationCollection addObject:annotation];
                                } else {
                                     [self.WeatherPlannedAnnotationCollection addObject:annotation];
                                }
                                
                                [self.MapView addAnnotation:annotation];
                            });
                        }];
                    }
                }
            }
        }
            
    }
}


/*
 created date:      15/06/2019
 last modified:     15/06/2019
 remarks:
 */
- (IBAction)SegmentAnnotationsChanged:(id)sender {
    
    self.AnnotationCollection = [[NSMutableArray alloc] init];
    
    [self.MapView removeAnnotations:self.MapView.annotations];
    
    NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
    
    if (self.SegmentAnnotations.selectedSegmentIndex == 0) {

        RLMResults<ActivityRLM *> *PlannedActivitiesCollection = [[ActivityRLM objectsWhere:@"tripkey = %@ and state = 0",self.Trip.key] distinctResultsUsingKeyPaths:keypaths];
        
        for (ActivityRLM* PlannedActivity in PlannedActivitiesCollection) {
            AnnotationMK *annotation = [[AnnotationMK alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake([PlannedActivity.poi.lat doubleValue], [PlannedActivity.poi.lon doubleValue]);
            annotation.title = PlannedActivity.name;
            annotation.subtitle = @"Planned";
            annotation.PoiKey = PlannedActivity.poi.key;
            annotation.Type = @"marker-planned";
            
            
            [self.AnnotationCollection addObject:annotation];
        }
        
        for (AnnotationMK *annotation in self.AnnotationCollection) {
            [self.MapView addAnnotation:annotation];
        }

        if (self.AnnotationCollection.count > 0) {
            [self zoomToAnnotationsBounds :self.MapView.annotations];
            if (!self.loadedPlannedWeatherData) {
                self.WeatherPlannedAnnotationCollection  = [[NSMutableArray alloc] init];
                [self constructWeatherMapPointData :false];
                self.loadedPlannedWeatherData = true;
            } else {
                for (AnnotationMK *annotation in self.WeatherPlannedAnnotationCollection) {
                    [self.MapView addAnnotation:annotation];
                }
            }
        }
    } else if (self.SegmentAnnotations.selectedSegmentIndex == 1) {
        
        RLMResults<ActivityRLM *> *ActualActivitiesCollection = [[ActivityRLM objectsWhere:@"tripkey = %@ and state = 1",self.Trip.key] distinctResultsUsingKeyPaths:keypaths];
        
        
        for (ActivityRLM* ActualActivity in ActualActivitiesCollection) {
            AnnotationMK *annotation = [[AnnotationMK alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake([ActualActivity.poi.lat doubleValue], [ActualActivity.poi.lon doubleValue]);
            annotation.title = ActualActivity.name;
            annotation.subtitle = @"Actual";
            annotation.PoiKey = ActualActivity.poi.key;
            annotation.Type = @"marker-actual";
            
            [self.AnnotationCollection addObject:annotation];
        }
        
        for (AnnotationMK *annotation in self.AnnotationCollection) {
            [self.MapView addAnnotation:annotation];
        }

        if (self.AnnotationCollection.count > 0) {
            [self zoomToAnnotationsBounds :self.MapView.annotations];
            if (!self.loadedActualWeatherData) {
                self.WeatherActualAnnotationCollection  = [[NSMutableArray alloc] init];
                [self constructWeatherMapPointData :true];
                self.loadedActualWeatherData = true;
            } else {
                for (AnnotationMK *annotation in self.WeatherActualAnnotationCollection) {
                    [self.MapView addAnnotation:annotation];
                }
            }
        }
    }
}


@end
