//
//  ActivityListVC.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityListVC.h"

@interface ActivityListVC ()

@end

@implementation ActivityListVC

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:           segue controls .
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.CollectionViewActivities.delegate = self;
    self.LabelProject.text =  [NSString stringWithFormat:@"Activities for %@", self.Project.name];
    self.editmode = false;
    // Do any additional setup after loading the view. 
}

/*
 created date:      30/04/2018
 last modified:     01/05/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
}

/*
 created date:      30/04/2018
 last modified:     01/05/2018
 remarks:
 */
-(void) LoadActivityData:(NSNumber*) State {
    
    self.activityitems = [AppDelegateDef.Db GetActivityListContentForState :self.Project.key :State];

    /* for each activity we need to show the image of the poi attached to it */
    /* load images from file - TODO make sure we locate them all */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (ActivityNSO *activity in self.activityitems) {
        if (activity.poi.Images.count>0) {
            PoiImageNSO *imageitem = [activity.poi.Images firstObject];
            NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageitem.ImageFileReference]];
            NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
            imageitem.Image = [UIImage imageWithData:pngData];
        }
    }
    
    
    [self.CollectionViewActivities reloadData];
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activityitems.count + 1;;
}

/*
 created date:      30/04/2018
 last modified:     24/06/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCellId" forIndexPath:indexPath];
    
    NSInteger NumberOfItems = self.activityitems.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.ImageViewActivity.image = [UIImage imageNamed:@"AddItem"];
        cell.VisualViewBlur.hidden = true;
        cell.VisualViewBlurBehindImage.hidden = true;
        cell.ImageBlurBackground.hidden = true;
        cell.ViewActiveBadge.hidden = true;
        
    } else {
        cell.activity = [self.activityitems objectAtIndex:indexPath.row];
        if (self.SegmentState.selectedSegmentIndex==1) {
            
            if (cell.activity.legendref== [NSNumber numberWithInt:2]) {
                cell.LabelActivityLegend.backgroundColor = [UIColor colorWithRed:250.0f/255.0f green:159.0f/255.0f blue:66.0f/255.0f alpha:1.0];
                cell.VisualViewBlur.hidden = true;
                cell.ButtonDelete.hidden = false;
            } else if (cell.activity.activitystate== [NSNumber numberWithInt:0]) {
                // show blurred image of activity!
                cell.ButtonDelete.hidden = true;
                cell.VisualViewBlur.hidden = false;
                // only on ideas..
                cell.LabelActivityLegend.backgroundColor = [UIColor colorWithRed:114.0f/255.0f green:24.0f/255.0f blue:23.0f/255.0f alpha:1.0];
            } else {
                // only on actual.
                cell.ButtonDelete.hidden = false;
                cell.VisualViewBlur.hidden = true;
                cell.LabelActivityLegend.backgroundColor = [UIColor colorWithRed:43.0f/255.0f green:65.0f/255.0f blue:98.0f/255.0f alpha:1.0];
            }
            
            if (cell.activity.startdt == cell.activity.enddt) {
                cell.ViewActiveItem.backgroundColor = [UIColor colorWithRed:252.0f/255.0f green:33.0f/255.0f blue:37.0f/255.0f alpha:1.0];
                
                cell.ViewActiveBadge.layer.cornerRadius = 35;
                cell.ViewActiveBadge.layer.masksToBounds = YES;
                cell.ViewActiveBadge.transform = CGAffineTransformMakeRotation(.34906585);
                
                cell.ViewActiveBadge.hidden = false;
            } else {
                 cell.ViewActiveItem.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
                cell.ViewActiveBadge.hidden = true;
            }
 
        } else {
            if (cell.activity.legendref== [NSNumber numberWithInt:2]) {
                cell.LabelActivityLegend.backgroundColor = [UIColor colorWithRed:250.0f/255.0f green:159.0f/255.0f blue:66.0f/255.0f alpha:1.0];
                
            } else if (cell.activity.legendref== [NSNumber numberWithInt:1]) {
                cell.LabelActivityLegend.backgroundColor = [UIColor colorWithRed:114.0f/255.0f green:24.0f/255.0f blue:23.0f/255.0f alpha:1.0];
            }
            cell.VisualViewBlur.hidden = true;
            cell.ButtonDelete.hidden = false;
            
            cell.ViewActiveItem.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
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
        
        cell.ImageViewTypeOfPoi.image = [UIImage imageNamed:[TypeItems objectAtIndex:[cell.activity.poi.categoryid integerValue]]];

        cell.LabelName.text = cell.activity.name;
        cell.LabelActivityLegend.layer.cornerRadius = 5;
        cell.LabelActivityLegend.layer.masksToBounds = YES;
        NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
        [dtformatter setDateFormat:@"dd MMM HH:mm"];
        cell.LabelDate.text = [NSString stringWithFormat:@"%@",[dtformatter stringFromDate:cell.activity.startdt]];
        cell.VisualViewBlurBehindImage.hidden = false;
        cell.ImageBlurBackground.hidden = false;
        if (cell.activity.poi.Images.count == 0) {
            cell.ImageViewActivity.image = [UIImage imageNamed:@"Activity"];
            cell.ImageBlurBackground.image = [UIImage imageNamed:@"Activity"];
        } else {
            PoiImageNSO *imageitem = [cell.activity.poi.Images firstObject];
            cell.ImageViewActivity.image = imageitem.Image;
            cell.ImageBlurBackground.image = imageitem.Image;
        }
    }
    return cell;
}


/*
 created date:      30/04/2018
 last modified:     14/05/2018
 remarks:  ImG todo
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger NumberOfItems = self.activityitems.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        [self performSegueWithIdentifier:@"ShowNewActivity" sender:nil];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.Activity = [self.activityitems objectAtIndex:indexPath.row];
        ActivityNSO *activity = [self.activityitems objectAtIndex:indexPath.row];
        
        NSMutableArray *Images = [[NSMutableArray alloc] init];
        [Images addObjectsFromArray:activity.poi.Images];
        
        controller.Activity.poi = [[AppDelegateDef.Db GetPoiContent:activity.poi.key :nil :nil] firstObject];
        if (activity.poi.Images.count > 0) {
            activity.poi.Images = Images;
        }
        controller.Activity.project = self.Project;
        long selectedSegmentState = self.SegmentState.selectedSegmentIndex;
        controller.newitem = false;
        if (selectedSegmentState == 1 && activity.activitystate == [NSNumber numberWithInt:0]) {
            // this is an activity item selected from the actual selection that is in fact an idea item.
            controller.transformed = true;
            controller.Activity.activitystate = [NSNumber numberWithInt:1];
            // how can we determine on destination controller what is a brand new item and a transformed item?  Do we need to?
        } else {
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
        controller.Activity = [[ActivityNSO alloc] init];
        controller.newitem = true;
        controller.transformed = false;
        controller.Activity.activitystate = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.Project = self.Project;
        
    } else if([segue.identifier isEqualToString:@"ShowSchedule"]) {
        ScheduleVC *controller = (ScheduleVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.activityitems = self.activityitems;
        controller.Project = self.Project;
        controller.ActivityState = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
    } else if([segue.identifier isEqualToString:@"ShowDeleteActivity"]) {
        
        ActivityDataEntryVC *controller = (ActivityDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView= [cellView superview])) {
                if([cellView isKindOfClass:[ActivityListCell class]]) {
                    ActivityListCell *cell = (ActivityListCell*)cellView;
                    NSIndexPath *indexPath = [self.CollectionViewActivities indexPathForCell:cell];
                    controller.Activity = [self.activityitems objectAtIndex:indexPath.row];
                }
            }
        }
        controller.deleteitem = true;
        controller.newitem = false;
        controller.transformed = false;
    } else if([segue.identifier isEqualToString:@"ShowProjectPaymentList"]) {
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Project = self.Project;
    }
}

- (IBAction)ActivityStateChanged:(id)sender {
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
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
@end
