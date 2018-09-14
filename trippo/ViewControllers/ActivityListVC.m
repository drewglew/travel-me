//
//  ActivityListVC.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityListVC.h"

@interface ActivityListVC ()
@property RLMNotificationToken *notification;
@end

@implementation ActivityListVC
@synthesize delegate;
/*
 created date:      30/04/2018
 last modified:     01/09/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.ActivityImageDictionary = [[NSMutableDictionary alloc] init];
    self.CollectionViewActivities.delegate = self;
    
    self.editmode = false;
    // Do any additional setup after loading the view.
    
    self.ButtonBack.layer.cornerRadius = 25;
    self.ButtonBack.clipsToBounds = YES;
    self.ButtonBack.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonPayment.layer.cornerRadius = 25;
    self.ButtonPayment.clipsToBounds = YES;
    self.ButtonPayment.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonRouting.layer.cornerRadius = 25;
    self.ButtonRouting.clipsToBounds = YES;
    self.ButtonRouting.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if (self.Trip.itemgrouping==[NSNumber numberWithInt:1]) {
        self.SegmentState.selectedSegmentIndex = 1;
        self.LabelProject.text =  [NSString stringWithFormat:@"%@ - Activities in Last Trip", self.Trip.name];
    } else if (self.Trip.itemgrouping==[NSNumber numberWithInt:4]) {
        self.LabelProject.text =  [NSString stringWithFormat:@"Next Trip in %@", self.Trip.name];
    } else if (self.Trip.itemgrouping==[NSNumber numberWithInt:2]) {
        self.SegmentState.selectedSegmentIndex = 1;
        self.LabelProject.text =  [NSString stringWithFormat:@"Active Trip in %@", self.Trip.name];
    } else {
         self.LabelProject.text =  [NSString stringWithFormat:@"Activities for %@", self.Trip.name];
    }
    
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
    [self LoadActivityImageData];
    
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        if (weakSelf.ImagesNeedUpdating) {
            [weakSelf LoadActivityImageData];
        }
        [weakSelf LoadActivityData :[NSNumber numberWithInteger:weakSelf.SegmentState.selectedSegmentIndex]];
        [weakSelf.CollectionViewActivities reloadData];
    }];
}


/*
 created date:      30/04/2018
 last modified:     01/09/2018
 remarks:
 */
-(void) LoadActivityData:(NSNumber*) State {
    
    NSMutableDictionary *dataset = [[NSMutableDictionary alloc] init];
    /* obtain the planned activities, both planned and actual activities are interested in this */

    self.AllActivitiesInTrip = [ActivityRLM objectsWhere:@"tripkey = %@", self.Trip.key];
    
    RLMResults<ActivityRLM*> *plannedactivities = [self.AllActivitiesInTrip objectsWhere:@"state==0"];
    for (ActivityRLM* planned in plannedactivities) {
        [dataset setObject:planned forKey:planned.key];
    }
    /* next only for actual activities we search for those too and replace using dictionary any of them */
    if (State==[NSNumber numberWithLong:1]) {
        RLMResults<ActivityRLM*> *actualactivities = [self.AllActivitiesInTrip objectsWhere:@"state==1"];
        for (ActivityRLM* actual in actualactivities) {
            [dataset setObject:actual forKey:actual.key];
        }
    }
    
    NSArray *temp2 = [[NSArray alloc] initWithArray:[dataset allValues]];

    NSSortDescriptor *sortDescriptorState = [[NSSortDescriptor alloc] initWithKey:@"state" ascending:NO];
    NSSortDescriptor *sortDescriptorStartDt = [[NSSortDescriptor alloc] initWithKey:@"startdt"
                                                 ascending:YES];
    
    temp2 = [temp2 sortedArrayUsingDescriptors:@[sortDescriptorState,sortDescriptorStartDt]];
    self.activitycollection = [NSMutableArray arrayWithArray:temp2];

}

/*
 created date:      01/09/2018
 last modified:     01/09/2018
 remarks:  Load all Activity images for Trip
 */
-(void)LoadActivityImageData {
    /* for each activity we need to show the image of the poi attached to it */
    /* load images from file - TODO make sure we locate them all */
    
    RLMResults<ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey==%@",self.Trip.key];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
    ImageCollectionRLM *imgobject;
    RLMResults *filteredResults;
    
    for (ActivityRLM *activityobj in activities) {
        imgobject = [[ImageCollectionRLM alloc] init];
        filteredResults = [activityobj.images objectsWithPredicate:predicate];
        if (filteredResults.count>0) {
            imgobject = [filteredResults firstObject];
        } else {
            PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:activityobj.poikey];
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
            [self.ActivityImageDictionary setObject:[UIImage imageNamed:@"Activity"] forKey:activityobj.compondkey];
        } else {
        
            [self.ActivityImageDictionary setObject:[UIImage imageWithData:pngData] forKey:activityobj.compondkey];
        }
    }
    self.ImagesNeedUpdating=false;
    
}



/*
 created date:      30/04/2018
 last modified:     31/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activitycollection.count + 1;;
}

/*
 created date:      30/04/2018
 last modified:     14/09/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCellId" forIndexPath:indexPath];
    
    NSInteger NumberOfItems = self.activitycollection.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.ImageViewActivity.image = [UIImage imageNamed:@"AddItem"];
        cell.VisualViewBlur.hidden = true;
        cell.VisualViewBlurBehindImage.hidden = true;
        cell.ImageBlurBackground.hidden = true;
        cell.ViewActiveBadge.hidden = true;
        cell.ViewActiveItem.backgroundColor = [UIColor clearColor];
        
    } else {
        cell.activity = [self.activitycollection objectAtIndex:indexPath.row];
        
        RLMResults <ActivityRLM*> *activitySet = [self.AllActivitiesInTrip objectsWhere:[NSString stringWithFormat:@"key = '%@'",cell.activity.key]];
        NSNumber *CountOfActivitiesInSet = [NSNumber numberWithLong:activitySet.count];
        
        if (self.SegmentState.selectedSegmentIndex == 1) {
            
            if (CountOfActivitiesInSet == [NSNumber numberWithLong:2]) {
                [cell.ImageViewBookmark setImage:[UIImage imageNamed:@""]];
            } else {
                ActivityRLM *single = [activitySet firstObject];
                if (single.state == [NSNumber numberWithInteger:1]) {
                    [cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Yellow"]];
                } else {
                    /* Activity not set as active */
                    [cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Blue"]];
                }
            }

            if (cell.activity.state == [NSNumber numberWithInteger:0]) {
                cell.ButtonDelete.hidden = true;
                cell.VisualViewBlur.hidden = false;
            } else {
                cell.ButtonDelete.hidden = false;
                cell.VisualViewBlur.hidden = true;
            }
           
            if ([cell.activity.startdt compare: cell.activity.enddt] == NSOrderedSame && cell.activity.startdt!=nil) {
                // only show badge when activity is Actual.
                //int state = [cell.activity.state intValue];
                if (cell.activity.state == [NSNumber numberWithInteger:1]) {
                    cell.ViewActiveBadge.layer.cornerRadius = 35;
                    cell.ViewActiveBadge.layer.masksToBounds = YES;
                    cell.ViewActiveBadge.transform = CGAffineTransformMakeRotation(.34906585);
                    cell.ViewActiveItem.backgroundColor = [UIColor colorWithRed:252.0f/255.0f green:33.0f/255.0f blue:37.0f/255.0f alpha:1.0];
                    cell.ViewActiveBadge.hidden = false;
                } else  {
                    cell.ViewActiveBadge.hidden = true;
                }
            } else {
                cell.ViewActiveItem.backgroundColor = [UIColor clearColor];
                cell.ViewActiveBadge.hidden = true;
            }
 
        } else {

            if (CountOfActivitiesInSet == [NSNumber numberWithLong:2]) {
                [cell.ImageViewBookmark setImage:[UIImage imageNamed:@""]];
            } else {
                [cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Blue"]];
            }
            
            cell.VisualViewBlur.hidden = true;
            cell.ButtonDelete.hidden = false;
            cell.ViewActiveItem.backgroundColor = [UIColor clearColor];

            cell.ViewActiveBadge.hidden = true;
            
        }

        NSArray *TypeItems = @[@"Cat-Accomodation",
                               @"Cat-Airport",
                               @"Cat-Astronaut",
                               @"Cat-Beer",
                               @"Cat-Bike",
                               @"Cat-Bridge",
                               @"Cat-CarHire",
                               @"Cat-Casino",
                               @"Cat-Church",
                               @"Cat-City",
                               @"Cat-Club",
                               @"Cat-Concert",
                               @"Cat-FoodWine",
                               @"Cat-Historic",
                               @"Cat-House",
                               @"Cat-Lake",
                               @"Cat-Lighthouse",
                               @"Cat-Metropolis",
                               @"Cat-Misc",
                               @"Cat-Monument",
                               @"Cat-Museum",
                               @"Cat-Nature",
                               @"Cat-Office",
                               @"Cat-Restaurant",
                               @"Cat-Scenary",
                               @"Cat-Sea",
                               @"Cat-Ship",
                               @"Cat-Shopping",
                               @"Cat-Ski",
                               @"Cat-Sports",
                               @"Cat-Theatre",
                               @"Cat-ThemePark",
                               @"Cat-Train",
                               @"Cat-Trek",
                               @"Cat-Venue",
                               @"Cat-Zoo"
                               ];
        
        PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:cell.activity.poikey];
        
        cell.ImageViewTypeOfPoi.image = [UIImage imageNamed:[TypeItems objectAtIndex:[poiobject.categoryid integerValue]]];

        //cell.LabelName.text = cell.activity.name;
        //[cell.LabelName sizeToFit];
        
        NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
        [dtformatter setDateFormat:@"EEE dd MMM HH:mm"];
        //cell.LabelDate.text = [NSString stringWithFormat:@"%@",[dtformatter stringFromDate:cell.activity.startdt]];
        cell.VisualViewBlurBehindImage.hidden = false;
        cell.ImageBlurBackground.hidden = false;

        cell.ImageViewActivity.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];
        cell.ImageBlurBackground.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];;
        
        cell.LabelName.attributedText=[[NSAttributedString alloc]
                                       initWithString:cell.activity.name
                                       attributes:@{
                                                    NSStrokeWidthAttributeName: @-2.0,
                                                    NSStrokeColorAttributeName:[UIColor blackColor],
                                                    NSForegroundColorAttributeName:[UIColor whiteColor]
                                                    }
                                       ];
        
        cell.LabelDate.attributedText=[[NSAttributedString alloc]
                                       initWithString:[NSString stringWithFormat:@"%@",[dtformatter stringFromDate:cell.activity.startdt]]
                                       attributes:@{
                                                    NSStrokeWidthAttributeName: @-2.0,
                                                    NSStrokeColorAttributeName:[UIColor blackColor],
                                                    NSForegroundColorAttributeName:[UIColor whiteColor]
                                                    }
                                       ];
        
    }
    return cell;
}

/*
 created date:      05/09/2018
 last modified:     05/09/2018
 remarks:  ImG
 */
-(UIImage*) RetrievePoiImageItem :(PoiRLM*) poi {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    UIImage *image = [[UIImage alloc] init];
    if (poi.images.count>0) {
        ImageCollectionRLM *imgobject = [poi.images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData==nil) {
            image = [UIImage imageNamed:@"Poi"];
        } else {
            image = [UIImage imageWithData:pngData];
        }
    } else {
        image = [UIImage imageNamed:@"Poi"];
    }
    return image;
}


/*
 created date:      30/04/2018
 last modified:     05/09/2018
 remarks:  ImG todo
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger NumberOfItems = self.activitycollection.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        [self performSegueWithIdentifier:@"ShowNewActivity" sender:nil];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.realm = self.realm;
        
        ActivityRLM *activity = [self.activitycollection objectAtIndex:indexPath.row];
        
        controller.Poi = [PoiRLM objectForPrimaryKey:activity.poikey];
        controller.PoiImage = [self RetrievePoiImageItem :controller.Poi];
       
        controller.Trip = self.Trip;
        long selectedSegmentState = self.SegmentState.selectedSegmentIndex;
        controller.newitem = false;
        if (selectedSegmentState == 1 && activity.state == [NSNumber numberWithInteger:0]) {
            // this is an activity item selected from the actual selection that is in fact an idea item.
            ActivityRLM *new = [[ActivityRLM alloc] init];
            new.key = activity.key;
            new.state = [NSNumber numberWithInt:1];
            new.compondkey = [NSString stringWithFormat:@"%@~1",activity.key];
            new.name = activity.name;
            new.tripkey = activity.tripkey;
            new.poikey = activity.poikey;
            new.createddt = [NSDate date];
            new.modifieddt = [NSDate date];
            controller.Activity = new;
            controller.transformed = true;
            // how can we determine on destination controller what is a brand new item and a transformed item?  Do we need to?
        } else {
            controller.Activity = [self.activitycollection objectAtIndex:indexPath.row];
            controller.transformed = false;
        }
        controller.deleteitem = false;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }

}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.CollectionViewActivities.frame.size.width;
    float cellWidth = collectionWidth/3.0f;
    CGSize size = CGSizeMake(cellWidth, cellWidth);
    if (self.editmode) {
        size = CGSizeMake(cellWidth,cellWidth*2);
        
    }
    return size;
}



/*
 created date:      30/04/2018
 last modified:     12/05/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if([segue.identifier isEqualToString:@"ShowNewActivity"]){
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = [[ActivityRLM alloc] init];
        controller.newitem = true;
        controller.transformed = false;
        controller.Activity.state = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.TripItem = self.Trip;
        controller.realm = self.realm;
        
    } else if([segue.identifier isEqualToString:@"ShowSchedule"]) {
        ScheduleVC *controller = (ScheduleVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.activityitems = self.activityitems;
        //controller.Project = self.Project;
        controller.ActivityState = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
    } else if([segue.identifier isEqualToString:@"ShowDeleteActivity"]) {
        
        ActivityDataEntryVC *controller = (ActivityDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView= [cellView superview])) {
                if([cellView isKindOfClass:[ActivityListCell class]]) {
                    ActivityListCell *cell = (ActivityListCell*)cellView;
                    //NSIndexPath *indexPath = [self.CollectionViewActivities indexPathForCell:cell];
                    controller.Activity = cell.activity;
                    controller.Poi = [PoiRLM objectForPrimaryKey:cell.activity.poikey];
                    controller.PoiImage = [self.ActivityImageDictionary objectForKey:cell.activity.key];
                    controller.Trip = self.Trip;
                    controller.realm = self.realm;
                }
            }
            
        }
        
        controller.deleteitem = true;
        controller.newitem = false;
        controller.transformed = false;
    } else if([segue.identifier isEqualToString:@"ShowProjectPaymentList"]) {
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;
        //controller.Project = self.Project;
        controller.activitystate = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
    }
}

- (IBAction)ActivityStateChanged:(id)sender {
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
    [self.CollectionViewActivities reloadData];
}



- (IBAction)SwitchEditModeChanged:(id)sender {
    self.editmode = !self.editmode;

    [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { }];
    
    [self.CollectionViewActivities reloadData];
}



/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:           segue controls .
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      08/09/2018
 last modified:     08/09/2018
 remarks:
 */
- (void)didUpdateActivityImages :(bool)ForceUpdate {
    self.ImagesNeedUpdating = true;
}

@end