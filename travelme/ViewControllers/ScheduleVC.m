//
//  ScheduleCV.m
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ScheduleVC.h"

@interface ScheduleVC ()

@end

@implementation ScheduleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.TableViewScheduleItems.delegate = self;
    self.TableViewScheduleItems.rowHeight = 120;
    self.level = 0;
    
    if (self.ActivityState == [NSNumber numberWithLong:0]) {
        self.labelHeader.text = [NSString stringWithFormat:@"%@ - Planned Schedule", self.Project.name];
        self.ButtonDeleteIdeas.hidden = true;
    } else {
        self.labelHeader.text = [NSString stringWithFormat:@"%@ - Actual Schedule", self.Project.name];;
    }
    [self LoadScheduleData];
    // Do any additional setup after loading the view.
}


/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

/*
 created date:      28/04/2018
 last modified:     19/05/2018
 remarks:
 */
-(void) LoadScheduleData {
    self.scheduleitems = [AppDelegateDef.Db GetActivitySchedule:self.Project.key :self.ActivityState];
    /* used to dynamically set the width of the hiararcy view */
    self.MaxNbrOfHierarcyLevels=0;
    
    /* loop through to get the key images we need as well as the maximum amount of levels in hierarcy */
    for (ScheduleNSO *schedule in self.scheduleitems) {
        if(schedule.hierarcyindex > self.MaxNbrOfHierarcyLevels) {
            self.MaxNbrOfHierarcyLevels = schedule.hierarcyindex;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key==%@",schedule.key];
        NSArray *results = [self.activityitems filteredArrayUsingPredicate:predicate];
        ActivityNSO *activity = [results firstObject];
        schedule.poi = activity.poi;
    }
    
    self.LabelItemCounter.text = [NSString stringWithFormat:@"Nbr of Items:%lu",(unsigned long)self.scheduleitems.count];
    
    [self.TableViewScheduleItems reloadData];
}


- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}


/*
 created date:      05/05/2018
 last modified:     05/05/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      05/05/2018
 last modified:     05/05/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scheduleitems.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewScheduleItems.frame.size.width, 62)];
    return headerView;
}



/*
 created date:      05/05/2018
 last modified:     19/05/2018
 remarks:
 */
- (ScheduleCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ScheduleCellId";
    ScheduleCell *cell = [self.TableViewScheduleItems dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ScheduleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    ScheduleNSO *schedule = [self.scheduleitems objectAtIndex:indexPath.row];
    
    //linestyle 0 = start
    //linestyle 1 = through
    //linestyle 2 = end
    //linestyle 3 = none
    
    int linestyle = 0;
    if (indexPath.row == 0) {
        linestyle = 0;
    } else if (self.scheduleitems.count <= indexPath.row + 1) {
        linestyle = 2;
    } else {
        ScheduleNSO *nextSchedule = [self.scheduleitems objectAtIndex:indexPath.row + 1];
        ScheduleNSO *prevSchedule = [self.scheduleitems objectAtIndex:indexPath.row - 1];
        if (prevSchedule.hierarcyindex < schedule.hierarcyindex && nextSchedule.hierarcyindex < schedule.hierarcyindex ) {
            linestyle = 3;
        } else if (nextSchedule.hierarcyindex < schedule.hierarcyindex) {
            linestyle = 2;
        } else if (prevSchedule.hierarcyindex < schedule.hierarcyindex) {
            linestyle = 0;
        } else {
            linestyle = 1;
        }
    }

    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.ViewHierarcyDetail attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.MaxNbrOfHierarcyLevels * 25.0]];
    
    
    
    cell.LabelActivity.text = schedule.name;
    cell.LabelSpanDateTime.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDates :schedule.dt]];
    [cell.ViewHierarcyDetail addColumns :schedule.hierarcyindex :linestyle];

    NSArray *viewsToRemove = [cell.ViewHierarcyDetail subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    // 20 is half the size of the image.
    CGFloat imageYpos = (cell.contentView.bounds.size.height / 2) - 20;
    UIImageView *view=[[UIImageView alloc]initWithFrame:CGRectMake(0 + (20 * (schedule.hierarcyindex - 1)), imageYpos, 40, 40)];

   

    if (schedule.poi.Images.count==0) {
        [view setImage:[UIImage imageNamed:@"Poi"]];
    } else {
        PoiImageNSO *FirstImageItem = [schedule.poi.Images firstObject];
        [view setImage:FirstImageItem.Image];
        view.layer.cornerRadius = 20;
        view.layer.masksToBounds = YES;
    }
    
    if ((schedule.activitystate == [NSNumber numberWithInt:0] && self.ActivityState == [NSNumber numberWithLong:1])) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        if (schedule.poi.Images.count!=0) {
            visualEffectView.alpha = 0.75f;
            visualEffectView.frame = view.bounds;
        }
        [view addSubview:visualEffectView];
    }
    

    [cell.ViewHierarcyDetail addSubview:view];
    [cell.ViewHierarcyDetail setNeedsDisplay];
    return cell;
}


/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              [self tableView:tableView deleteSchedule:indexPath];
                                              self.TableViewScheduleItems.editing = NO;
                                              
                                          }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}
/*
 created date:      08/05/2018
 last modified:     19/05/2018
 remarks:
 */
- (void)tableView:(UITableView *)tableView deleteSchedule:(NSIndexPath *)indexPath  {
    ScheduleNSO *schedule = [self.scheduleitems objectAtIndex:indexPath.row];
    if ([schedule.type isEqualToString:@"close"] || [schedule.type isEqualToString:@"single"]) {
        [self.scheduleitems removeObjectAtIndex:indexPath.row];
        if ([schedule.type isEqualToString:@"close"]) {
            // set the matching 'open' type item to "single"
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key MATCHES %@) AND (activitystate == %@)",schedule.key,schedule.activitystate];
            NSArray *results = [self.scheduleitems filteredArrayUsingPredicate:predicate];
            if (results.count>0) {
                ScheduleNSO *foundschedule = [results firstObject];
                foundschedule.type = @"single";
            }
        }
    } else if ([schedule.type isEqualToString:@"open"]) {
        // delete the close too.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (key MATCHES %@) OR (activitystate != %@ AND key MATCHES %@)",schedule.key, schedule.activitystate, schedule.key];
        [self.scheduleitems filterUsingPredicate:predicate];
    }
    
    int index = 0;
    for (ScheduleNSO *schedule in self.scheduleitems) {
        if([schedule.type isEqualToString:@"open"]) {
            index ++;
            schedule.hierarcyindex = index;
        } else if ([schedule.type isEqualToString:@"single"]) {
            schedule.hierarcyindex = index + 1;
        } else {
            schedule.hierarcyindex = index;
            index --;
        }
    }
    self.LabelItemCounter.text = [NSString stringWithFormat:@"Nbr of Items:%lu",(unsigned long)self.scheduleitems.count];
    [self.TableViewScheduleItems reloadData];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewScheduleItems.frame.size.width, 70)];
    return footerView;
}


/*
 created date:      06/05/2018
 last modified:     06/05/2018
 remarks:
 */
-(NSString*)FormatPrettyDates :(NSDate*)ActivityDt {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"dd MMM yyyy HH:mm"];
    [dateformatter setTimeZone:[NSTimeZone localTimeZone]];
    return [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:ActivityDt]];
}

/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:           segue controls.
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowProjectDirections"]){
        // todo
        DirectionsVC *controller = (DirectionsVC *)segue.destinationViewController;
        controller.delegate = self;
        NSMutableArray *Route = [[NSMutableArray alloc] init];
        for (ScheduleNSO *schedule in self.scheduleitems) {
            [Route addObject:schedule.poi];
        }
        controller.Route = Route;
        controller.scheduleitems = self.scheduleitems;
    }
}

- (IBAction)ResetPressed:(id)sender {
    [self LoadScheduleData];
    if (self.ActivityState == [NSNumber numberWithLong:1] ) {
        self.ButtonDeleteIdeas.hidden = false;
    }
}

- (IBAction)DeleteAllIdeasPressed:(id)sender {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(activitystate == %@)", self.ActivityState];
    [self.scheduleitems filterUsingPredicate:predicate];
    int index = 0;
    for (ScheduleNSO *schedule in self.scheduleitems) {
        if([schedule.type isEqualToString:@"open"]) {
            index ++;
            schedule.hierarcyindex = index;
        } else if ([schedule.type isEqualToString:@"single"]) {
            schedule.hierarcyindex = index + 1;
        } else {
            schedule.hierarcyindex = index;
            index --;
        }
    }
    self.LabelItemCounter.text = [NSString stringWithFormat:@"Nbr of Items:%lu",(unsigned long)self.scheduleitems.count];
    [self.TableViewScheduleItems reloadData];
    self.ButtonDeleteIdeas.hidden = true;
}



@end
