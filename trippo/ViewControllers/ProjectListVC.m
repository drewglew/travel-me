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
@synthesize delegate;

/*
 created date:      29/04/2018
 last modified:     29/08/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.CollectionViewProjects.delegate = self;
    self.editmode = false;
    
    self.ButtonBack.layer.cornerRadius = 25;
    self.ButtonBack.clipsToBounds = YES;
    self.ButtonBack.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    /* user selected specific option from startup view */
    self.tripcollection = [TripRLM allObjects];
    
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadSupportingData];
        [weakSelf.CollectionViewProjects reloadData];
    }];
    
    self.ImageCollection = [[NSMutableArray alloc] init];
    
    [self LoadSupportingData];
}


/*
 created date:      29/04/2018
 last modified:     29/08/2018
 remarks:
 */
-(void) LoadSupportingData {
    /* 1. Get Images from file. */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (TripRLM *trip in self.tripcollection) {
        
        ImageCollectionRLM *image = [trip.images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData!=nil) {
            //image.Image = [UIImage imageWithData:pngData];
            [self.ImageCollection addObject:[UIImage imageWithData:pngData]];
        } else {
            
            UIImage *dummy = [[UIImage alloc] init];
            [self.ImageCollection addObject:dummy];
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
 last modified:     29/08/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProjectListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];
    
    NSInteger NumberOfItems = self.tripcollection.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.ImageViewProject.image = [UIImage imageNamed:@"AddItem"];
        cell.isNewAccessor = true;
        cell.VisualEffectsViewBlur.hidden = true;
    } else {
        TripRLM *trip = [self.tripcollection objectAtIndex:indexPath.row];
        
        UIImage *image = [self.ImageCollection objectAtIndex:indexPath.row];
        
        if (CGSizeEqualToSize(image.size, CGSizeZero)) {
            cell.ImageViewProject.image = [UIImage imageNamed:@"Project"];
        } else {
            cell.ImageViewProject.image = image;
        }

        cell.LabelProjectName.text = trip.name;
        
        if (trip.startdt != nil) {
            NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
            [dtformatter setDateFormat:@"EEE, dd MMM HH:mm"];
            cell.LabelDateRange.text = [NSString stringWithFormat:@"%@\n%@",[dtformatter stringFromDate:trip.startdt], [dtformatter stringFromDate:trip.enddt]];
        } else {
            cell.LabelDateRange.text = @"";
        }
        /*
        int TotalDataPoints = [project.numberofactivitiesonlyactual intValue] +  [project.numberofactivities intValue] + [project.numberofactivitiesonlyplanned intValue];
        
        if (TotalDataPoints >0 && self.editmode) {
            
            float degreesPart1 = ([project.numberofactivitiesonlyactual floatValue] / TotalDataPoints)*360.0f;
            float degreesPart2 = ([project.numberofactivities floatValue] / TotalDataPoints)*360.0f;
            
            
            CirclePart *part1 = [[CirclePart alloc] initWithStartDegree:0 endDegree:degreesPart1 partColor:[UIColor colorWithRed:114.0f/255.0f green:24.0f/255.0f blue:23.0f/255.0f alpha:1.0]];
            CirclePart *part2 = [[CirclePart alloc] initWithStartDegree:degreesPart1 endDegree:degreesPart1 + degreesPart2 partColor:[UIColor colorWithRed:250.0f/255.0f green:159.0f/255.0f blue:66.0f/255.0f alpha:1.0]];
            CirclePart *part3 = [[CirclePart alloc] initWithStartDegree:degreesPart1 + degreesPart2 endDegree:360 partColor:[UIColor colorWithRed:43.0f/255.0f green:65.0f/255.0f blue:98.0f/255.0f alpha:1.0]];
            
            NSArray *circleParts = [[NSArray alloc] initWithObjects:part1, part2, part3, nil];
            
            CGRect rect = CGRectMake(10, 10, 50, 50);
            CGPoint circleCenter = CGPointMake(rect.size.width / 2, rect.size.height / 2);
            
            GraphView *graphView = [[GraphView alloc] initWithFrame:rect CentrePoint:circleCenter radius:80 lineWidth:2 circleParts:circleParts];
            graphView.backgroundColor = [UIColor clearColor];
            graphView.layer.borderColor = [UIColor clearColor].CGColor;
            graphView.layer.cornerRadius = 25;
            graphView.clipsToBounds = YES;
            
            graphView.layer.borderWidth = 1.0f;
            
            [cell.VisualEffectsViewBlur addSubview:graphView];
        
        }
        */
        
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
    }
    return cell;
}


/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger NumberOfItems = self.tripcollection.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        /* insert new project item */
        [self performSegueWithIdentifier:@"ShowNewProject" sender:nil];
    } else {
        /* we select project and go onto it's activities! */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
        controller.delegate = self;
        controller.realm = self.realm;
        controller.Trip = [self.tripcollection objectAtIndex:indexPath.row];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
        
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
        controller.deleteitem = false;

        
    } else if([segue.identifier isEqualToString:@"ShowDeleteProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView= [cellView superview])) {
                if([cellView isKindOfClass:[ProjectListCell class]]) {
                    ProjectListCell *cell = (ProjectListCell*)cellView;
                    NSIndexPath *indexPath = [self.CollectionViewProjects indexPathForCell:cell];
                    controller.Trip = [self.tripcollection objectAtIndex:indexPath.row];
                }
            }
        }
        controller.newitem = false;
        controller.deleteitem = true;

    } else if([segue.identifier isEqualToString:@"ShowNewProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        controller.Trip = [[TripRLM alloc] init];
        controller.Project = [[ProjectNSO alloc] init];
        controller.newitem = true;
        controller.deleteitem = false;
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
 last modified:     29/08/2018
 remarks:
 */
-(void)FilterProjectCollectionView {
    
     NSDate* currentDate = [NSDate date];
    
    if (self.SegmentFilterProjects.selectedSegmentIndex == 0) {
        NSLog(@"All - %d",0);
        self.tripcollection = [TripRLM allObjects];
    } else if (self.SegmentFilterProjects.selectedSegmentIndex == 1) {
        NSLog(@"Past - %d",1);
        self.tripcollection = [TripRLM objectsInRealm:self.realm where:@"enddt < %@",currentDate];
    } else if (self.SegmentFilterProjects.selectedSegmentIndex == 2) {
        NSLog(@"Future - %d",2);
        self.tripcollection = [TripRLM objectsInRealm:self.realm where:@"startdt > %@",currentDate];
    } else {
        self.tripcollection = [TripRLM objectsInRealm:self.realm where:@"startdt > %@ && enddt < %@",currentDate,currentDate];
    }
    [self.CollectionViewProjects reloadData];
}


@end
