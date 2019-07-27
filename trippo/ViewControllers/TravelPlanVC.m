//
//  TravelPlanVC.m
//  trippo
//
//  Created by andrew glew on 19/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "TravelPlanVC.h"
#import "JENNode.h"
#import "JENTreeView.h"
#import "JENDefaultNodeView.h"
#import "JENCustomDecorationView.h"

@interface TravelPlanVC ()
@property RLMNotificationToken *notification;
@end


@implementation TravelPlanVC

/*
 created date:      19/07/2019
 last modified:     22/07/2019
 remarks:           Constructs the root node and calls the method in same class to load tree.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    JENNode *root = [[JENNode alloc] init];
    root.nodeName = @"Trip";
    root.activityImage = self.TripImage;
    self.treeview.rootNode                  = root;
    self.treeview.dataSource                = self;
    self.LabelTripTitle.text = self.Trip.name;
    self.ViewStateIndicator.layer.cornerRadius = (self.ViewStateIndicator.bounds.size.width / 2);
    self.ViewStateIndicator.clipsToBounds = YES;
    if (self.ActivityState == [NSNumber numberWithInteger:0]) {
        [self.ViewStateIndicator setBackgroundColor:[UIColor orangeColor]];
    }

    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadTreeFromActivityData];
        weakSelf.itinerarycollection = [[NSMutableArray alloc] init];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDt" ascending:YES];
        NSArray *sortedChildren = [weakSelf.treeview.rootNode.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        [weakSelf obtainJourney :sortedChildren :nil :weakSelf.treeview.rootNode];
        [weakSelf.ItineraryTableView reloadData];
    }];
    [self LoadTreeFromActivityData];
    
    self.itinerarycollection = [[NSMutableArray alloc] init];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDt" ascending:YES];
    NSArray *sortedChildren = [self.treeview.rootNode.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    [self obtainJourney :sortedChildren :nil :self.treeview.rootNode];
    [self.ItineraryTableView reloadData];
    
    UILabel *lbl= [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, self.ButtonJourneySideButton.frame.size.width,self.ButtonJourneySideButton.frame.size.height)];
    lbl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    lbl.text = @"journey";
    lbl.textColor =[UIColor whiteColor];
    lbl.backgroundColor =[UIColor clearColor];
    [self.ButtonJourneySideButton addSubview:lbl];
    
    self.JourneySidePanelFullWidthConstraint.constant = self.view.bounds.size.width;
    
    self.JourneySidePanelViewTrailingConstraint.constant = 0 - self.JourneySidePanelFullWidthConstraint.constant + self.ButtonTabWidthConstraint.constant;
    
    self.ButtonJourneySideButton.layer.cornerRadius = 5; // this value vary as per your desire
    self.ButtonJourneySideButton.clipsToBounds = YES;
    self.ItineraryTableView.delegate = self;
    self.ItineraryTableView.rowHeight = 100;
}

/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Original from GitHub https://github.com/chikuba/JENTreeView.
 */
-(void)layoutTreeview:(UISwitch*)sender {
    self.treeview.alignChildren        =  0;
    self.treeview.invertedLayout    =  0;
    [self.treeview layoutGraph];
}

/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Original from GitHub https://github.com/chikuba/JENTreeView.
 */
-(void)reloadTreeView:(UISwitch*)sender {
    self.treeview.showSubviews        = true;
    self.treeview.showSubviewFrames    = true;
    [self.treeview reloadData];
}

/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Original from GitHub https://github.com/chikuba/JENTreeView.  Constructs node with its data.
 */
-(UIView*)treeView:(JENTreeView*)treeView
nodeViewForModelNode:(id<JENTreeViewModelNode>)modelNode {
    
    JENDefaultNodeView* view = [[JENDefaultNodeView alloc] initWithParm:self.StepperScale.value];
    view.nodeName               = modelNode.nodeName;
    view.activity               = modelNode.activity;
    view.activityImage          = modelNode.activityImage;
    view.startDt                = modelNode.startDt;
    view.nodeSize               = modelNode.nodeSize;
    view.transportType          = modelNode.transportType;
    view.travelBack             = modelNode.travelBack;
    return view;
}


/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Copied from GitHub https://github.com/chikuba/JENTreeView
 */
-(UIView<JENDecorationView>*)treeView:(JENTreeView*)treeView
           decorationViewForModelNode:(id<JENTreeViewModelNode>)modelNode {
    
    JENCustomDecorationView *decorationView = [[JENCustomDecorationView alloc] init];
    
    decorationView.ortogonalConnection  =  1;
    decorationView.showView             = false;
    decorationView.showViewFrame        = false;
    
    return decorationView;
}

/*
 created date:      21/07/2019
 last modified:     21/07/2019
 remarks:           Resets the tree effectively losing any changes user manually made.
 */
- (IBAction)ResetPressed:(id)sender {
    [self LoadTreeFromActivityData];
}


/*
 created date:      20/07/2019
 last modified:     21/07/2019
 remarks:           Regenerates the tree from realm db.  Called on startup and reset button press.
 */
- (void)LoadTreeFromActivityData {

    self.excludedlisting  = [[NSMutableArray alloc] init];
    
    NSDate *MinDate = self.Trip.startdt;
    NSDate *MaxDate = self.Trip.enddt;
    
    /* build a controller set that can check off items already loaded */
    for (ActivityRLM *activityobj in self.activitycollection) {
         NodeNSO *item = [[NodeNSO alloc] init];
         item.Activity = activityobj;
         item.isUsed = false;
         if([activityobj.startdt compare: MinDate] == NSOrderedAscending ) {
             MinDate = activityobj.startdt;
         }
         if([activityobj.enddt compare: MaxDate] == NSOrderedDescending ) {
            MaxDate = activityobj.enddt;
         }
    }

    RLMResults<ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"startdt BETWEEN {%@, %@} and enddt BETWEEN {%@, %@} and state=%@ and tripkey=%@", MinDate, MaxDate, MinDate, MaxDate, self.ActivityState, self.Trip.key];
    
    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:YES];
    activities = [activities sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    self.treeview.rootNode.children = [NSSet setWithArray:[self getChildren :MinDate :MaxDate :activities]];
    self.treeview.dataSource                = self;
    self.treeview.alignChildren             =  0;
    self.treeview.invertedLayout            =  0;
    self.treeview.showSubviews              = false;
    self.treeview.showSubviewFrames         = false;
    [self.treeview reloadData];

}


/*
 created date:      20/07/2019
 last modified:     21/07/2019
 remarks:           Recursive function that creates nodes and identifies children.
 */
-(NSMutableArray*) getChildren :(NSDate*)StartDt :(NSDate*)EndDt :(RLMResults*) activities {
    NSMutableArray *children = [[NSMutableArray alloc] init];
    
    /* possibly could reuse existing */
    RLMResults<ActivityRLM*> *dataset = [activities objectsWhere:@"startdt BETWEEN {%@, %@} and enddt BETWEEN {%@, %@} and state=%@ and tripkey=%@", StartDt, EndDt, StartDt, EndDt, self.ActivityState, self.Trip.key];
    
    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:YES];
    activities = [activities sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    for (ActivityRLM *item in dataset) {
        bool IgnoreActivity = false;
        
        for (ActivityRLM *excludeditem in self.excludedlisting) {
            if ([item.key isEqualToString:excludeditem.key]) {
                IgnoreActivity = true;
            }
        }
        if (!IgnoreActivity) {
            /* excluded list includes all items already processed */
            [self.excludedlisting addObject:item];
            
            JENNode *leaf = [[JENNode alloc] init];
            leaf.nodeName = item.name;
            leaf.startDt = item.startdt;
            leaf.activity = item;
            leaf.insertNode = false;
            leaf.nodeSize = self.StepperScale.value;
            
            if (item.traveltransportid == nil) {
                leaf.transportType = 0;
            } else {
                leaf.transportType = item.traveltransportid;
            }
            leaf.travelBack = item.travelbackflag;
            
            if ([self.ActivityImageDictionary objectForKey:item.compondkey] == nil) {
                NSLog(@"empty image...");
                [self getActivityImage :item];
            }
            leaf.activityImage = [self.ActivityImageDictionary objectForKey:item.compondkey];
            
            leaf.children = [NSSet setWithArray:[self getChildren:item.startdt :item.enddt :dataset]];
            [children addObject:leaf];
        }
    }
    return children;
}


/*
 created date:      22/07/2019
 last modified:     22/07/2019
 remarks:           Load single Activity image for Trip - TODO optimize this.
 use thumbnail image if it exists, else - create it (the activity data entry point will
 also need to do some management - when it deletes an activity or a key image delete its thumbnail
 */
-(void)getActivityImage :(ActivityRLM*) activity {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
    RLMResults *filteredResults;
    ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
    
    CGSize CellSize = CGSizeMake(200,200);
    
    filteredResults = [activity.images objectsWithPredicate:predicate];
    if (filteredResults.count>0) {
        imgobject = [filteredResults firstObject];
    } else {
        PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:activity.poikey];
        filteredResults = [poiobject.images objectsWithPredicate:predicate];
        if (filteredResults.count==0) {
            imgobject = [poiobject.images firstObject];
        } else {
            imgobject = [filteredResults firstObject];
        }
    }
    
    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    if (pngData==nil) {
        if (activity.state == [NSNumber numberWithInteger:0]) {
            @autoreleasepool {
                UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Planning"] toFitInSize:CellSize];
                [self.ActivityImageDictionary setObject:image forKey:activity.compondkey];
                image = nil;
            }
        } else {
            @autoreleasepool {
                UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Activity"] toFitInSize:CellSize];
                [self.ActivityImageDictionary setObject:image  forKey:activity.compondkey];
                image = nil;
            }
        }
    } else {
        @autoreleasepool {
            UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageWithData:pngData]  toFitInSize:CellSize];
            [self.ActivityImageDictionary setObject:image forKey:activity.compondkey];
            image = nil;
        }
        
    }
}


/*
 created date:      21/07/2019
 last modified:     21/07/2019
 remarks:           Resize the nodes on stepper pressed.
 */
- (IBAction)StepperPressed:(id)sender {
    [self.treeview reloadData];
}

/*
 created date:      23/07/2019
 last modified:     23/07/2019
 remarks:           Animations.
 */
- (IBAction)JourneySideButtonPressed:(id)sender {
    CGFloat ViewWidth =  (self.JorneySidePanelView.frame.size.width - self.ButtonTabWidthConstraint.constant) * -1;
    if (self.JourneySidePanelViewTrailingConstraint.constant == ViewWidth ) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.JourneySidePanelViewTrailingConstraint.constant -= ViewWidth;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished)
         {
             
             
         }];
    } else {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.JourneySidePanelViewTrailingConstraint.constant += ViewWidth;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished)
         {}];
    }
}

/*
 created date:      23/07/2019
 last modified:     25/07/2019
 remarks:           Calculate the journey while passing the tree.
 */
- (IBAction)ButtonCalculateJourneyPressed:(id)sender {
    
    

    for (JourneyItemNSO *item in self.itinerarycollection) {
        if ([item.Distance doubleValue] == 0.0f) {
            [self calculateDistance :item ];
        }
    }
    
}



/*
 created date:      24/07/2019
 last modified:     25/07/2019
 remarks:
 */
- (ActivityRLM*) obtainJourney :(NSArray *) children :(ActivityRLM *) lastActivity :(JENNode *) parentNode  {
    ActivityRLM *lastItem = lastActivity;
    
    self.SequenceCounter = 0;
    
    for (JENNode *node in children) {
        if (lastItem != nil) {
            if (lastItem.travelbackflag == [NSNumber numberWithLong:0] && node.activity.travelbackflag == [NSNumber numberWithLong:1] && ![lastItem.key isEqualToString:parentNode.activity.key]) {
                [self insertItinerary :lastItem :node.activity];
                
                lastItem = node.activity;
            } else if (node.activity.travelbackflag == [NSNumber numberWithLong:1] && ![lastItem.key isEqualToString:parentNode.activity.key]) {
                [self insertItinerary :lastItem :parentNode.activity];
                [self insertItinerary :parentNode.activity :node.activity];

                lastItem = node.activity;
            } else if (lastItem.travelbackflag == [NSNumber numberWithLong:1] && node.activity.travelbackflag == [NSNumber numberWithLong:0] && ![lastItem.key isEqualToString:parentNode.activity.key]) {
                [self insertItinerary :lastItem :parentNode.activity];
                [self insertItinerary :parentNode.activity :node.activity];

                lastItem = node.activity;
            }  else {
                [self insertItinerary :lastItem :node.activity];
                
                lastItem = node.activity;
            }
           
        }
        if (node.children.count > 0) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDt" ascending:YES];
            NSArray *sortedChildren = [node.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            lastItem =  [self obtainJourney :sortedChildren :node.activity :node];
            if (node.activity.travelbackflag == [NSNumber numberWithLong:1]) {
                [self insertItinerary :lastItem :node.activity];
                [self insertItinerary :node.activity :parentNode.activity];

                lastItem = parentNode.activity;
            } else {
                [self insertItinerary :lastItem :node.activity];
                
                lastItem = node.activity;
            }
            
        } else {
            lastItem = node.activity;
        }
        
    }
    return lastItem;
}


-(void) insertItinerary :(ActivityRLM*) activityFrom :(ActivityRLM*) activityTo {
    
    NSLog(@"%@ <-> %@", activityFrom.name, activityTo.name);
    
    self.SequenceCounter ++;
    
    JourneyItemNSO *item = [[JourneyItemNSO alloc] init];
    item.SequenceNo = [NSNumber numberWithInt:self.SequenceCounter];
    item.Route = [NSString stringWithFormat:@"%@ to %@",activityFrom.name, activityTo.name];
    //item.Distance = [NSNumber numberWithDouble:0.0f];
    item.from = activityFrom;
    item.to = activityTo;
    [self.itinerarycollection addObject:item];
}
    
-(void) calculateDistance :(JourneyItemNSO *) item {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *pmFrom  = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([item.from.poi.lat doubleValue], [item.from.poi.lon doubleValue]) addressDictionary:nil];
    MKMapItem *from = [[MKMapItem alloc] initWithPlacemark:pmFrom];

    MKPlacemark *pmTo  = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([item.to.poi.lat doubleValue], [item.to.poi.lon doubleValue]) addressDictionary:nil];
    MKMapItem *to = [[MKMapItem alloc] initWithPlacemark:pmTo];
    
    request.source = from;
    request.destination = to;
    request.requestsAlternateRoutes = NO;
    
    item.TransportId = item.to.traveltransportid;
    
    if (item.TransportId==nil) {
        request.transportType = MKDirectionsTransportTypeAny;
    } else if (item.TransportId==[NSNumber numberWithInt:1]) {
        request.transportType = MKDirectionsTransportTypeWalking;
    } else  if (item.TransportId==[NSNumber numberWithInt:2]) {
        request.transportType = MKDirectionsTransportTypeTransit;
    } else {
        request.transportType = MKDirectionsTransportTypeAutomobile;
    }
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"ERROR");
             NSLog(@"%@",[error localizedDescription]);
         } else {
             double Distance = 0.0f;
             long TravelTime = 0;
             for (MKRoute *route in response.routes)
             {
                 Distance += route.distance;
                 TravelTime += (route.expectedTravelTime);
             }

             dispatch_async(dispatch_get_main_queue(), ^(void){
                 // self.AccumDistance += Distance;
                 // item.AccumDistance = [NSNumber numberWithDouble:self.AccumDistance];
                 item.Distance = [NSNumber numberWithDouble:Distance];
                 item.ExpectedTravelTime = [NSNumber numberWithLong:TravelTime];
                 [self.ItineraryTableView reloadData];
             });
             
             
         }
     }];
 
}


/*
created date:      25/07/2019
last modified:     25/07/2019
remarks:
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itinerarycollection count];
}

/*
 created date:      25/07/2019
 last modified:     25/07/2019
 remarks:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"ItineraryCellId";
    
    ItineraryListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[ItineraryListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }

    JourneyItemNSO *journey = [self.itinerarycollection objectAtIndex:indexPath.row];
    cell.LabelRoute.text = journey.Route;
    
    if (journey.TransportId == [NSNumber numberWithLong:1]) {
        [cell.TransportImageView setImage:[UIImage imageNamed:@"transport-walk"]];
    } else if (journey.TransportId == [NSNumber numberWithLong:2]) {
        [cell.TransportImageView setImage:[UIImage imageNamed:@"transport-public"]];
    } else {
        [cell.TransportImageView setImage:[UIImage imageNamed:@"transport-car"]];
    }
    
    NSArray *subArray = [self.itinerarycollection subarrayWithRange:NSMakeRange(0, indexPath.row + 1)];
    
    double accum = 0.0f;
    double accumExpectedTime = 0;
    for (JourneyItemNSO *item in subArray) {
        if (item.TransportId != [NSNumber numberWithLong:1] && item.TransportId != [NSNumber numberWithLong:2]) {
            accum += [item.Distance doubleValue];
            accumExpectedTime += [item.ExpectedTravelTime longValue];
        }
    }
    journey.AccumDistance = [NSNumber numberWithDouble:accum];

    NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    NSNumberFormatter *numberformatter = [[NSNumberFormatter alloc] init];
    [numberformatter setMaximumFractionDigits:1];
    [formatter setNumberFormatter:numberformatter];

    NSMeasurement *distance = [[NSMeasurement alloc] initWithDoubleValue:[journey.Distance doubleValue] unit:NSUnitLength.meters];

    NSMeasurement *accumdistance = [[NSMeasurement alloc] initWithDoubleValue:[journey.AccumDistance doubleValue] unit:NSUnitLength.meters];
    
    cell.LabelDistance.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:distance]];

    cell.LabelAccumDistance.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:accumdistance]];
    
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    cell.LabelExpectedTravelTime.text = [dateComponentsFormatter stringFromTimeInterval:[journey.ExpectedTravelTime doubleValue]];
    cell.LabelAccumExpectedTravelTime.text = [dateComponentsFormatter stringFromTimeInterval:accumExpectedTime];
    
    return cell;
}

/*
 created date:      25/07/2019
 last modified:     25/07/2019
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}


/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Usual back button
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}

@end
