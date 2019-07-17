//
//  TripListVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectListVC.h"

@interface ProjectListVC ()
@property RLMNotificationToken *notification;
@end



@implementation ProjectListVC
CGFloat ProjectListFooterFilterHeightConstant;
CGFloat TripNumberOfCellsInRow = 2.0f;
CGFloat TripScale = 4.14f;
@synthesize delegate;

/*
 created date:      29/04/2018
 last modified:     21/06/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.CollectionViewProjects.delegate = self;
    
    self.editmode = true;
    
    if (![ToolBoxNSO HasTopNotch]) {
        self.HeaderViewHeightConstraint.constant = 70.0f;
    }
    
    /* user selected specific option from startup view */
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadSupportingData];
        [weakSelf.CollectionViewProjects reloadData];
    }];
    [self LoadSupportingData];
    ProjectListFooterFilterHeightConstant = self.FooterWithSegmentConstraint.constant;
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    [self.CollectionViewProjects addGestureRecognizer:pinch];
}


/*
 created date:      29/04/2018
 last modified:     15/06/2019
 remarks:
 */
-(void) LoadSupportingData {

    self.tripcollection = [TripRLM allObjects];
    self.TripImageDictionary = [[NSMutableDictionary alloc] init];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
  
    for (TripRLM *trip in self.tripcollection) {
        ImageCollectionRLM *image = [trip.images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData!=nil) {
            [self.TripImageDictionary setObject:[UIImage imageWithData:pngData] forKey:trip.key];
        } else {
            UIImage *dummy = [[UIImage alloc] init];
            [self.TripImageDictionary setObject:dummy forKey:trip.key];
        }
    }
}

/*
 created date:      21/06/2019
 last modified:     21/06/2019
 remarks:
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:
(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:
(NSIndexPath *)indexPath
{
    return CGSizeMake(50*TripScale, 50*TripScale);
}

/*
 created date:      21/06/2019
 last modified:     21/06/2019
 remarks:           Works on iPhone XR - will it work on an smaller iPhone 7?
 */
-(void)onPinch:(UIPinchGestureRecognizer*)gestureRecognizer
{
    static CGFloat scaleStart;
    CGFloat collectionWidth = self.CollectionViewProjects.frame.size.width;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        scaleStart = TripScale;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TripScale = scaleStart * gestureRecognizer.scale;
        
        if ( TripScale*50 < collectionWidth / 6) {
            TripScale = (collectionWidth / 6) / 50;
        }
        else
        {
            [self.CollectionViewProjects.collectionViewLayout invalidateLayout];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        // snap to pretty border distribution
        if ( TripScale*50 < collectionWidth / 5) {
            TripScale = (collectionWidth / 5) / 50;
            TripNumberOfCellsInRow = 5.0f;
        } else if (TripScale*50 < collectionWidth / 4) {
            TripScale = (collectionWidth / 4) / 50;
            TripNumberOfCellsInRow = 4.0f;
        } else if (TripScale*50 < collectionWidth / 3) {
            TripScale = (collectionWidth / 3) / 50;
            TripNumberOfCellsInRow = 3.0f;
        } else if (TripScale*50 < collectionWidth / 2) {
            TripScale = (collectionWidth / 2) / 50;
            TripNumberOfCellsInRow = 2.0f;
        } else {
            TripScale = collectionWidth / 50;
            TripNumberOfCellsInRow = 1.0f;
        }
        
        [self.CollectionViewProjects.collectionViewLayout invalidateLayout];
        [self.CollectionViewProjects reloadData];
        
    }
    
}


/*
 created date:      29/04/2018
 last modified:     29/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tripcollection.count + 1;;
}

/*
 created date:      29/04/2018
 last modified:     21/06/2019
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProjectListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];
    
    NSInteger NumberOfItems = self.tripcollection.count + 1;
   
    if (indexPath.row == NumberOfItems -1) {
        cell.ImageViewProject.image = [UIImage imageNamed:@"AddItem"];
        [cell.ImageViewProject setTintColor: [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
        cell.isNewAccessor = true;
        cell.VisualEffectsViewBlur.hidden = true;
        cell.ImageConstraint = [cell.ImageConstraint updateMultiplier:0.6];
        // TODO ISSUES!!!
    } else {
        cell.trip = [self.tripcollection objectAtIndex:indexPath.row];
        
        UIImage *image = [self.TripImageDictionary objectForKey:cell.trip.key];
        
        if (CGSizeEqualToSize(image.size, CGSizeZero)) {
            cell.ImageViewProject.image = [UIImage imageNamed:@"Project"];
        } else {
            cell.ImageViewProject.image = image;
        }

        if (cell.trip.startdt != nil) {
            NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
            [dtformatter setDateFormat:@"EEE, dd MMM HH:mm"];
        } 
        
        cell.isNewAccessor = false;
        if (self.editmode) {
            cell.editButton.hidden=false;
            cell.deleteButton.hidden=false;
            cell.VisualEffectsViewBlur.hidden = false;
        } else {
            cell.editButton.hidden=true;
            cell.deleteButton.hidden=true;
            cell.VisualEffectsViewBlur.hidden = true;
        }
        cell.ImageConstraint = [cell.ImageConstraint updateMultiplier:0.995];

        
        //UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:14.0];
        UIFont *font = [UIFont systemFontOfSize:16.0];
        
        if (TripNumberOfCellsInRow >= 3.0f) {
            font = [UIFont systemFontOfSize:12.0];
            
            if (TripNumberOfCellsInRow > 3.0f) {
                cell.deleteButton.hidden = true;
            }
        } else {
            cell.deleteButton.hidden = false;
        }
        
        NSDictionary *attributes = @{NSBackgroundColorAttributeName:[UIColor colorWithRed:35.0f/255.0f green:35.0f/255.0f blue:35.0f/255.0f alpha:1.0], NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:font};
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:cell.trip.name attributes:attributes];
        cell.LabelProjectName.attributedText = string;
        
    }
    return cell;
}


/*
 created date:      29/04/2018
 last modified:     30/03/2019
 remarks:           presents the trip data entry view in various forms as well as loading from API any weather data.
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger NumberOfItems = self.tripcollection.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        /* insert new project item */
        [self performSegueWithIdentifier:@"ShowNewProject" sender:nil];
    } else {
        ProjectListCell *cell = (ProjectListCell *)[self.CollectionViewProjects cellForItemAtIndexPath:indexPath];

        [cell.ActivityIndicatorView startAnimating];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        /* we select project and go onto it's activities! */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
        controller.delegate = self;
        controller.realm = self.realm;
        
        controller.Trip = [self.tripcollection objectAtIndex:indexPath.row];
        if ([self checkInternet]) {
            NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
            RLMResults<ActivityRLM *> *ActivitiesCollection = [[ActivityRLM objectsWhere:@"tripkey = %@",controller.Trip.key] distinctResultsUsingKeyPaths:keypaths];

            if (ActivitiesCollection.count == 0)  {
                [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                [self presentViewController:controller animated:YES completion:nil];
                [cell.ActivityIndicatorView stopAnimating];
            } else {
            
                __block int PoiCounter = 1;
                for (ActivityRLM *activity in ActivitiesCollection) {

                    if ([activity.poi.IncludeWeather intValue] == 1) {

                        /* we only want to update the forecast if it is older than 1 hour */
                        RLMResults <WeatherRLM*> *weatherresult = [activity.poi.weather objectsWhere:@"timedefition='currently'"];
                        NSNumber *maxtime = [weatherresult maxOfProperty:@"time"];
     
                        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
                        NSNumber *now = [NSNumber numberWithDouble: timestamp];
                        
                        if (([maxtime doubleValue] + 3600 < [now doubleValue]) || maxtime == nil) {
                        
                            /* clean up previous data */
                            if (maxtime != nil) {
                                [self.realm transactionWithBlock:^{
                                    [self.realm deleteObjects:activity.poi.weather];
                                }];
                            }
                            NSString *url = [NSString stringWithFormat:@"https://api.darksky.net/forecast/d339db567160bdd560169ea4eef3ee5a/%@,%@?exclude=minutely,flags,alerts&units=uk2", activity.poi.lat, activity.poi.lon];
                            
                             [self fetchFromDarkSkyApi:url withDictionary:^(NSDictionary *data) {
                             
                                 dispatch_sync(dispatch_get_main_queue(), ^(void){

                                     WeatherRLM *weather = [[WeatherRLM alloc] init];
                                     NSDictionary *JSONdata = [data objectForKey:@"currently"];
                                     weather.icon = [NSString stringWithFormat:@"weather-%@",[JSONdata valueForKey:@"icon"]];
                                     weather.summary = [JSONdata valueForKey:@"summary"];
                                     double myDouble = [[JSONdata valueForKey:@"temperature"] doubleValue];
                                     NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                                     [fmt setPositiveFormat:@"0.#"];
                                     weather.temperature = [NSString stringWithFormat:@"%@",[fmt stringFromNumber:[NSNumber numberWithFloat:myDouble]]];
                                     weather.timedefition = @"currently";
                                     weather.time = [JSONdata valueForKey:@"time"];
                                     
                                     [self.realm transactionWithBlock:^{
                                         [activity.poi.weather addObject:weather];
                                     }];
                                     
                                     NSDictionary *JSONHourlyData = [data objectForKey:@"hourly"];
                                     NSArray *dataHourly = [JSONHourlyData valueForKey:@"data"];
                                     
                                     for (NSMutableDictionary *item in dataHourly) {
                                         WeatherRLM *weather = [[WeatherRLM alloc] init];
                                         weather.icon = [NSString stringWithFormat:@"weather-%@",[item valueForKey:@"icon"]];
                                         weather.summary = [item valueForKey:@"summary"];
                                         double myDouble = [[item valueForKey:@"temperature"] doubleValue];
                                         NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                                         [fmt setPositiveFormat:@"0.#"];
                                         weather.temperature = [NSString stringWithFormat:@"%@",[fmt stringFromNumber:[NSNumber numberWithFloat:myDouble]]];
                                         weather.timedefition = @"hourly";
                                         weather.time = [item valueForKey:@"time"];
                                         
                                         [self.realm transactionWithBlock:^{
                                             [activity.poi.weather addObject:weather];
                                         }];
                                     }
                                     NSDictionary *JSONDailyData = [data objectForKey:@"daily"];
                                     NSArray *dataDaily = [JSONDailyData valueForKey:@"data"];
                                     
                                     for (NSMutableDictionary *item in dataDaily) {
                                         WeatherRLM *weather = [[WeatherRLM alloc] init];
                                         weather.icon = [NSString stringWithFormat:@"weather-%@",[item valueForKey:@"icon"]];
                                         weather.summary = [item valueForKey:@"summary"];
                                         double tempLow = [[item valueForKey:@"temperatureLow"] doubleValue];
                                         double tempHigh = [[item valueForKey:@"temperatureHigh"] doubleValue];
                                         NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                                         [fmt setPositiveFormat:@"0.#"];
                                          weather.temperature = [NSString stringWithFormat:@"Lowest %@ °C, Highest %@ °C",[fmt stringFromNumber:[NSNumber numberWithFloat:tempLow]], [fmt stringFromNumber:[NSNumber numberWithFloat:tempHigh]]];
                                         weather.timedefition = @"daily";
                                         weather.time = [item valueForKey:@"time"];
                                         
                                         [self.realm transactionWithBlock:^{
                                             [activity.poi.weather addObject:weather];
                                         }];
                                     }
                                     
                                     if (PoiCounter == ActivitiesCollection.count) {
                                         /* after looping through, we fall back into the segue task of presenting next view controller */
                                         [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                                         [self presentViewController:controller animated:YES completion:nil];
                                         [cell.ActivityIndicatorView stopAnimating];
                                     } else {
                                         PoiCounter ++;
                                     }
                                 });
                             }];
                        } else {
                            if (PoiCounter == ActivitiesCollection.count) {
                                [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                                [self presentViewController:controller animated:YES completion:nil];
                                [cell.ActivityIndicatorView stopAnimating];
                            } else {
                                PoiCounter ++;
                            }
                        }
                    } else {
                        if (PoiCounter == ActivitiesCollection.count) {
                            [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                            [self presentViewController:controller animated:YES completion:nil];
                            [cell.ActivityIndicatorView stopAnimating];
                        } else {
                            PoiCounter ++;
                        }
                    }
                }
            }
        } else {
            [controller setModalPresentationStyle:UIModalPresentationFullScreen];
            [self presentViewController:controller animated:YES completion:nil];
            [cell.ActivityIndicatorView stopAnimating];
        }
    }
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




/*
 created date:      05/02/2019
 last modified:     05/02/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
        
    if (velocity.y > 0 && self.FooterWithSegmentConstraint.constant == ProjectListFooterFilterHeightConstant){
        NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FooterWithSegmentConstraint.constant = 0.0f;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FooterWithSegmentConstraint.constant == 0.0f){
        NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterWithSegmentConstraint.constant = ProjectListFooterFilterHeightConstant;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}





/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:            .
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];

}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:            .
 */
- (IBAction)EditModePressed:(id)sender {
    self.editmode = !self.editmode;
    [self.CollectionViewProjects reloadData];
    
}

- (IBAction)SwitchEditModePressed:(id)sender {
    self.editmode = !self.editmode;
    [self.CollectionViewProjects reloadData];
}


/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowUpdateProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView = [cellView superview])) {
                if([cellView isKindOfClass:[ProjectListCell class]]) {
                    ProjectListCell *cell = (ProjectListCell*)cellView;
                    NSIndexPath *indexPath = [self.CollectionViewProjects indexPathForCell:cell];
                    controller.Trip = [self.tripcollection objectAtIndex:indexPath.row];
                }
            }
         }
        controller.newitem = false;

    } else if([segue.identifier isEqualToString:@"ShowDeleteProject"]){
        [self DeleteTrip:sender];
        
    } else if([segue.identifier isEqualToString:@"ShowNewProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        controller.Trip = [[TripRLM alloc] init];
        controller.Project = [[ProjectNSO alloc] init];
        controller.newitem = true;
    }
}
/*
 created date:      24/06/2018
 last modified:     24/06/2018
 remarks:
 */
- (IBAction)SegmentFilteredChanged:(id)sender {
    //NSLog(@"%@",[NSNumber numberWithInteger:self.SegmentFilterProjects.selectedSegmentIndex]);
    [self FilterProjectCollectionView];
}

/*
 created date:      24/06/2018
 last modified:     15/06/2019
 remarks:
 */
-(void)FilterProjectCollectionView {

    NSDate* currentDate = [NSDate date];
    
    self.tripcollection = [TripRLM allObjects];
    
    if (self.SegmentFilterProjects.selectedSegmentIndex == 0) {
        NSLog(@"All - %d",0);
    } else if (self.SegmentFilterProjects.selectedSegmentIndex == 1) {
        NSLog(@"Past - %d",1);

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"enddt < %@", currentDate];
        self.tripcollection = [self.tripcollection objectsWithPredicate:predicate];
        
        //self.tripcollection = [TripRLM objectsInRealm:self.realm where:@"enddt < %@",currentDate];
    } else if (self.SegmentFilterProjects.selectedSegmentIndex == 2) {
        NSLog(@"Future - %d",2);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startdt > %@", currentDate];
        self.tripcollection = [self.tripcollection objectsWithPredicate:predicate];
    } else {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startdt <= %@ AND enddt >= %@", currentDate,currentDate];
        
        self.tripcollection = [self.tripcollection objectsWithPredicate:predicate];
        // date BETWEEN {%@, %@}
    }
    [self.CollectionViewProjects reloadData];
}

/*
 created date:      07/10/2018
 last modified:     07/10/2018
 remarks:
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
 created date:      30/03/2019
 last modified:     30/03/2019
 remarks:
 */
-(void)DeleteTrip: (id)sender {
    
    TripRLM *TripToDelete = [[TripRLM alloc] init];
    if ([sender isKindOfClass: [UIButton class]]) {
        UIView * cellView=(UIView*)sender;
        while ((cellView= [cellView superview])) {
            if([cellView isKindOfClass:[ProjectListCell class]]) {
                ProjectListCell *cell = (ProjectListCell*)cellView;
                TripToDelete = cell.trip;
            }
        }
    }
    
    if (TripToDelete!=nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Delete Trip\n%@", TripToDelete.name ] message:@"Are you sure you want to remove complete trip and all activities?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      
                                                                      /* locate all activities */
                                                                      RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey=%@",self.Trip.key];
                                                                      
                                                                      /* remove any notifications attached */
                                                                      for (ActivityRLM* activity in activities) {
                                                                          [self RemoveGeoNotification :true :activity];
                                                                          [self RemoveGeoNotification :false :activity];
                                                                      }
                                                                      
                                                                      /* delete actvities */
                                                                      [self.realm transactionWithBlock:^{
                                                                          [self.realm deleteObjects:activities];
                                                                      }];
                                                                      
                                                                      /* finally delete trip */
                                                                      [self.realm transactionWithBlock:^{
                                                                          [self.realm deleteObject:TripToDelete];
                                                                      }];
                                                                      
                                                                  });
                                                              }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Canel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 // do nothing..
                                                                 
                                                             }];
        
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*
 created date:      30/03/2019
 last modified:     30/03/2019
 remarks:
 */
-(void) RemoveGeoNotification :(bool) NotifyOnEntry :(ActivityRLM*) activity {
    NSString *identifier;
    
    if (NotifyOnEntry) {
        identifier = [NSString stringWithFormat:@"CHECKIN~%@", activity.compondkey];
    } else {
        identifier = [NSString stringWithFormat:@"CHECKOUT~%@", activity.compondkey];
    }
    
    NSArray *pendingNotification = [NSArray arrayWithObjects:identifier, nil];
    [AppDelegateDef.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:pendingNotification];
}

@end
