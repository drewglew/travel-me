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
    self.TableViewScheduleItems.rowHeight = 80;
    // Do any additional setup after loading the view.
}


/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadScheduleData];
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(void) LoadScheduleData {
    self.scheduleitems = [AppDelegateDef.Db GetActivitySchedule:self.Project.key :self.ActivityState];
    
    
    for (ScheduleNSO *schedule in self.scheduleitems) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key==%@",schedule.key];
        NSArray *results = [self.activityitems filteredArrayUsingPredicate:predicate];
        ActivityNSO *activity = [results firstObject];
        schedule.poi = activity.poi;
    }
    
    
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

/*
 created date:      05/05/2018
 last modified:     06/05/2018
 remarks:
 */
- (ScheduleCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ScheduleCellId";
    ScheduleCell *cell = [self.TableViewScheduleItems dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ScheduleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //cell.poi = [self.poifiltereditems objectAtIndex:indexPath.row];
    
    ScheduleNSO *schedule = [self.scheduleitems objectAtIndex:indexPath.row];
    
    cell.LabelActivity.text = schedule.name;
    cell.LabelSpanDateTime.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDates :schedule.dt]];
    
    if (schedule.poi.Images.count==0) {
        [cell.ImageViewImage setImage:[UIImage imageNamed:@"Poi"]];
    } else {
        PoiImageNSO *FirstImageItem = [schedule.poi.Images firstObject];
        [cell.ImageViewImage setImage:FirstImageItem.Image];
    }
    
    if ((schedule.activitystate==[NSNumber numberWithInt:0] && self.ActivityState==[NSNumber numberWithLong:1])) {
        [cell.ViewBlur setHidden:false];
    } else {
        [cell.ViewBlur setHidden:true];
    }
    
    
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
 last modified:     09/05/2018
 remarks:           Might not be totally necessary, but seperated out from editActionsForRowAtIndexPath method above.
 */
- (void)tableView:(UITableView *)tableView deleteSchedule:(NSIndexPath *)indexPath  {
    
    ScheduleNSO *schedule = [self.scheduleitems objectAtIndex:indexPath.row];
    //if ([schedule.type isEqualToString:@"close"]) {
        [self.scheduleitems removeObjectAtIndex:indexPath.row];
        [self.TableViewScheduleItems reloadData];
    //} else {
        // do nothing.
    //}
    
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
    }
}




@end
