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
@synthesize delegate;

/*
 created date:      29/04/2018
 last modified:     29/03/2019
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
 created date:      29/04/2018
 last modified:     29/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tripcollection.count + 1;;
}

/*
 created date:      29/04/2018
 last modified:     15/06/2019
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

        //UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:17.0];
        UIFont *font = [UIFont systemFontOfSize:22.0];
        //NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        //paragraphStyle.paragraphSpacing = 0.5 * font.lineHeight;
        NSDictionary *attributes = @{NSBackgroundColorAttributeName:[UIColor colorWithRed:35.0f/255.0f green:35.0f/255.0f blue:35.0f/255.0f alpha:1.0], NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:font};
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:cell.trip.name attributes:attributes];
        cell.LabelProjectName.attributedText = string;

        
    }
    return cell;
}


/*
 created date:      29/04/2018
 last modified:     30/03/2019
 remarks:
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
        NSLog(@"startdt = %@",controller.Trip.startdt);
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];

        [cell.ActivityIndicatorView stopAnimating];
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
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.CollectionViewProjects.frame.size.width;
    float cellWidth = collectionWidth/2.0f;
    CGSize size = CGSizeMake(cellWidth,cellWidth);
    
    return size;
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
