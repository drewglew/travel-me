//
//  PaymentListingVC.m
//  travelme
//
//  Created by andrew glew on 08/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PaymentListingVC.h"

@interface PaymentListingVC ()
@property RLMNotificationToken *notification;
@end

@implementation PaymentListingVC

/*
 created date:      09/05/2018
 last modified:     02/02/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    /* going to receive an array of existing payments and what category */
    
    NSString *Title = [NSString stringWithFormat:@"Expenses\n%@", self.ActivityItem.name];
    if (self.TripItem == nil) {
        self.ViewTripAmount.hidden = true;
    } else {
        Title = [NSString stringWithFormat:@"Trip Expenses\n%@", self.TripItem.name];
        self.ViewTripAmount.hidden = false;
    }
    
    self.LabelTitle.text = Title;
    self.ImageView.image = self.headerImage;
    
    self.ImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.ImageView.layer.borderWidth = 2.0f;
    
    
    self.TableViewPayment.rowHeight = 100;
    self.TableViewPayment.sectionFooterHeight = 110;
    // Do any additional setup after loading the view.
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.TableViewPayment.tableFooterView = footer;
    
    
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadPaymentData];
        [weakSelf.TableViewPayment reloadData];
    }];
}

/*
 created date:      09/05/2018
 last modified:     09/05/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadPaymentData];
}


/*
 created date:      09/05/2018
 last modified:     15/09/2018
 remarks:  
 */
-(void) LoadPaymentData {

    if (self.TripItem == nil) {
        self.ExpenseCollection = [PaymentRLM objectsWhere:@"activitykey=%@",self.ActivityItem.key];
    }
    else {
        self.ExpenseCollection = [PaymentRLM objectsWhere:@"tripkey=%@",self.TripItem.key];
    }

    self.localcurrencyitems = [[NSSet setWithArray:[self.ExpenseCollection valueForKey:@"localcurrencycode"]] allObjects];
    
    
    self.paymentsections = [[NSMutableArray alloc] initWithCapacity:self.localcurrencyitems.count];
    RLMResults <PaymentRLM*> *rows;
    //NSArray *rows = [[NSArray alloc] init];
    
    
    for (NSString *item in self.localcurrencyitems) {
        NSLog(@"item=%@", item);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localcurrencycode = %@", item];
        rows = [self.ExpenseCollection objectsWithPredicate:predicate];
        
        for (PaymentRLM *test in rows) {
            NSLog(@"localcurrencycode=%@", test.localcurrencycode);
        }
        
        [self.paymentsections addObject:rows];
    }
    
    /* work out trip price rate */
    if (self.TripItem != nil) {
        
        /* get total days as fraction */
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitHour
                                                            fromDate:self.TripItem.startdt
                                                              toDate:self.TripItem.enddt
                                                             options:0];
        
        long Days = [components hour]/24;
        long RemainingHours = [components hour]%24;
        double TotalDays = Days + (double)RemainingHours/24.0f;
        
        
        /* if there are no days or even partial days we need to hide the badge */
        if (TotalDays > 0) {
            /* now get home currency actual paid amount */
            double actrate=0, actamt=0;
            for (PaymentRLM *item in self.ExpenseCollection) {
                actrate = [item.rate_act.rate doubleValue] / 10000;
                if ([item.rate_act.rate intValue]==1) {
                    actamt += ([item.amt_act doubleValue] / 100);
                } else {
                    actamt +=  ([item.amt_act doubleValue] / 100) * actrate;
                }
            }
            /* simply calculate trip rate */
            double TripRate = 0;
            if (actamt!=0) {
                TripRate = actamt / TotalDays;
            }
            
            self.LabelTripAmount.text = [NSString stringWithFormat:@"%.2f\n%@",TripRate,[AppDelegateDef HomeCurrencyCode]];
            
            self.ViewTripAmount.layer.cornerRadius = self.ViewTripAmount.bounds.size.width/2;
            self.ViewTripAmount.transform = CGAffineTransformMakeRotation(.17);
        } else {
            self.ViewTripAmount.hidden = true;
        }
    }
    
    [self.TableViewPayment reloadData];
}

- (NSInteger)minutesBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSTimeInterval interval = [secondDate timeIntervalSinceDate:firstDate];
    return (int)interval / 60;
}

/*
 created date:      08/05/2018
 last modified:     16/05/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.localcurrencyitems.count;
}



/*
 created date:      08/05/2018
 last modified:     16/05/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *temp = self.paymentsections[section];
    return temp.count;
}

/*
 created date:      19/09/2018
 last modified:     19/09/2018
 remarks:           Added currency symbol to header.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:self.localcurrencyitems[section]];
    NSString *currencySymbol = [NSString stringWithFormat:@"%@",[locale displayNameForKey:NSLocaleCurrencySymbol value:self.localcurrencyitems[section]]];
    
    return [NSString stringWithFormat:@" %@ (%@)",self.localcurrencyitems[section],currencySymbol];
}

/*
 created date:      09/06/2018
 last modified:     03/03/2019
 remarks:           table view with sections.
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    NSArray *temp = self.paymentsections[section];

    double actrate=0, plannedrate=0;
    double actamt=0, plannedamt=0;
    
    for (PaymentRLM *item in temp) {
        
        actrate = [item.rate_act.rate doubleValue] / 10000;
        if ([item.rate_act.rate intValue]==1) {
            actamt += ([item.amt_act doubleValue] / 100);
        } else {
            actamt +=  ([item.amt_act doubleValue] / 100) * actrate;
        }
        plannedrate = [item.rate_est.rate doubleValue] / 10000;
        if ([item.rate_est.rate intValue]==1) {
            plannedamt += ([item.amt_est doubleValue] / 100);
        } else {
            plannedamt +=  ([item.amt_est doubleValue] / 100) * plannedrate;
        }
    }

    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 64)];
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];

    // 2. Set a custom background color and a border footer summary
    backgroundView.backgroundColor = [UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0];

    [footerView addSubview:backgroundView];
    
    
    // 3. Add a label
    UILabel* actualSummaryLabel = [[UILabel alloc] init];
    actualSummaryLabel.frame = CGRectMake(10, 5, tableView.frame.size.width - 200, 20);
    
    actualSummaryLabel.backgroundColor = [UIColor clearColor];
    actualSummaryLabel.textColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    actualSummaryLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    actualSummaryLabel.text = @"Actual Total";
    actualSummaryLabel.textAlignment = NSTextAlignmentLeft;
    
    // 4. Add the label to the header view
    [footerView addSubview:actualSummaryLabel];

    /*10 trailing
     40 width of currency field
     10 spacer
     100 width of amount
     */

    // 3. Add a label
    UILabel* actualSummaryAmtLabel = [[UILabel alloc] init];
    actualSummaryAmtLabel.frame = CGRectMake(tableView.frame.size.width - 160, 5, 100, 20);
    actualSummaryAmtLabel.backgroundColor = [UIColor clearColor];
    actualSummaryAmtLabel.textColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    actualSummaryAmtLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];;
    actualSummaryAmtLabel.text = [NSString stringWithFormat:@"%.2f",actamt];
    actualSummaryAmtLabel.textAlignment = NSTextAlignmentRight;
    
    [footerView addSubview:actualSummaryAmtLabel];
    
    UILabel* actualSummaryCurrLabel = [[UILabel alloc] init];
    actualSummaryCurrLabel.frame = CGRectMake(tableView.frame.size.width - 50, 5, 40, 20);
    actualSummaryCurrLabel.backgroundColor = [UIColor clearColor];
    actualSummaryCurrLabel.textColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    actualSummaryCurrLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    actualSummaryCurrLabel.text = [NSString stringWithFormat:@"%@",[AppDelegateDef HomeCurrencyCode]];
    actualSummaryCurrLabel.textAlignment = NSTextAlignmentRight;
    
    [footerView addSubview:actualSummaryCurrLabel];

    UILabel* plannedSummaryLabel = [[UILabel alloc] init];
    plannedSummaryLabel.frame = CGRectMake(10, 26, tableView.frame.size.width - 200, 20);
    plannedSummaryLabel.backgroundColor = [UIColor clearColor];
    plannedSummaryLabel.textColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    plannedSummaryLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    plannedSummaryLabel.text = @"Planned Total";
    plannedSummaryLabel.textAlignment = NSTextAlignmentLeft;
    
    [footerView addSubview:plannedSummaryLabel];

    UILabel* plannedSummaryAmtLabel = [[UILabel alloc] init];
    plannedSummaryAmtLabel.frame = CGRectMake(tableView.frame.size.width - 160, 26, 100, 20);
    plannedSummaryAmtLabel.backgroundColor = [UIColor clearColor];
    plannedSummaryAmtLabel.textColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    plannedSummaryLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    plannedSummaryAmtLabel.text = [NSString stringWithFormat:@"%.2f",plannedamt];
    plannedSummaryAmtLabel.textAlignment = NSTextAlignmentRight;
    
    [footerView addSubview:plannedSummaryAmtLabel];

    UILabel* plannedSummaryCurrLabel = [[UILabel alloc] init];
    plannedSummaryCurrLabel.frame = CGRectMake(tableView.frame.size.width - 50, 26, 40, 20);
    plannedSummaryCurrLabel.backgroundColor = [UIColor clearColor];
    plannedSummaryCurrLabel.textColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    plannedSummaryCurrLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    plannedSummaryCurrLabel.text = [NSString stringWithFormat:@"%@",[AppDelegateDef HomeCurrencyCode]];
    plannedSummaryCurrLabel.textAlignment = NSTextAlignmentRight;
    
    [footerView addSubview:plannedSummaryCurrLabel];

    // 5. Finally return
    return footerView;
}


/*
 created date:      30/04/2018
 last modified:     19/09/2018
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCellId"];

    PaymentRLM *item = [[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
   
    if (self.TripItem == nil) {
        cell.LabelDescription.text = item.desc;
    } else {
        NSLog(@"%@",item.activityname);
        cell.LabelDescription.text = [NSString stringWithFormat:@"%@: %@",item.activityname, item.desc];
    }

    /* might need to adjust this with rate */
    cell.LabelLocalAmt.text = [NSString stringWithFormat:@"%@",item.amt_act];
    double localamt = ([item.amt_act doubleValue] / 100);
    cell.LabelLocalAmt.text = [NSString stringWithFormat:@"%.2f",localamt];
    
    cell.LabelLocalAmtEst.text = [NSString stringWithFormat:@"%@",item.amt_est];
    double localamtest = ([item.amt_est doubleValue] / 100);
    cell.LabelLocalAmtEst.text = [NSString stringWithFormat:@"%.2f",localamtest];
    
    cell.LabelLocalCurrencyCode.text = item.localcurrencycode;
    cell.LabelLocalCurrencyCodeEst.text = item.localcurrencycode;
    

    if ([item.rate_act.rate intValue]==1) {
        cell.LabelLocalAmt.hidden = true;
        cell.LabelLocalCurrencyCode.hidden = true;
        cell.LabelHomeAmt.text = cell.LabelLocalAmt.text;
        cell.LabelLocalCurrencyCode.text = item.localcurrencycode;
        
    } else {
        cell.LabelHomeAmt.hidden = false;
        cell.LabelHomeCurrencyCode.hidden = false;
        double rate = [item.rate_act.rate doubleValue] / 10000;
        double homeamt = ([item.amt_act doubleValue] / 100) * rate;
        cell.LabelHomeAmt.text = [NSString stringWithFormat:@"%.2f",homeamt];
        cell.LabelHomeCurrencyCode.text = [AppDelegateDef HomeCurrencyCode];
    }
    
    if ([item.rate_est.rate intValue]==1) {
        cell.LabelLocalAmtEst.hidden = true;
        cell.LabelLocalCurrencyCodeEst.hidden = true;
        cell.LabelHomeAmtEst.text = cell.LabelLocalAmtEst.text;
        cell.LabelLocalCurrencyCodeEst.text = item.localcurrencycode;
    } else /*if ([item.rate_est.rate intValue]==0) {
        NSLog(@"item2 %@",item.rate_est.rate);
        cell.LabelHomeAmtEst.text = @"unknown rate";
        cell.LabelHomeCurrencyCodeEst.hidden = true;
    } else */ {
        cell.LabelHomeAmtEst.hidden = false;
        cell.LabelHomeCurrencyCodeEst.hidden = false;
        
        double rate = [item.rate_est.rate doubleValue] / 10000;
        double homeamt = ([item.amt_est doubleValue] / 100) * rate;
        cell.homeAmount = [NSNumber numberWithDouble:homeamt];
        
        cell.LabelHomeAmtEst.text = [NSString stringWithFormat:@"%.2f",homeamt];
        cell.LabelHomeCurrencyCodeEst.text = [AppDelegateDef HomeCurrencyCode];
    }

    return cell;
}

/*
 created date:      22/06/2018
 last modified:     22/06/2018
 remarks:
 */
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:216.0f/255.0f green:201.0f/255.0f blue:155.0f/255.0f alpha:1.0]];
     
}


/*
created date:      15/05/2018
last modified:     09/04/2019
remarks:
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"PaymentCellId";
    
    PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[PaymentListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    PaymentRLM *Expense = [[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];


    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ExpenseDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ExpenseDataEntryId"];
    controller.delegate = self;
    controller.ExpenseItem = Expense;
    NSString *Title = [NSString stringWithFormat:@"Expense on %@", self.ActivityItem.name];
    if (self.TripItem != nil) {
        self.ActivityItem = [[ActivityRLM alloc] init];
        self.ActivityItem.tripkey = self.TripItem.key;
        self.ActivityItem.state = self.activitystate;
        Title = [NSString stringWithFormat:@"General Trip Expense for %@", self.TripItem.name];
    }
    controller.TitleText = Title;
    
    controller.ActivityItem = self.ActivityItem;
    controller.newitem = false;
    controller.realm = self.realm;
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
}

/*
 created date:      15/05/2018
 last modified:     16/05/2018
 remarks:
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              [self tableView:tableView deletePayment:indexPath];
                                              self.TableViewPayment.editing = NO;
                                              
                                          }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}
/*
 created date:      15/05/2018
 last modified:     16/05/2018
 remarks:           Might not be totally necessary, but seperated out from editActionsForRowAtIndexPath method above.
 */
- (void)tableView:(UITableView *)tableView deletePayment:(NSIndexPath *)indexPath  {
 //   if ([AppDelegateDef.Db DeletePayment:[[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]] == true)
   // {
   //     [self LoadPaymentData];
   // }
}

/*
 created date:      03/05/2018
 last modified:     09/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowNewPayment"]){
        PaymentDataEntryVC *controller = (PaymentDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        if (self.TripItem != nil) {
            self.ActivityItem = [[ActivityRLM alloc] init];
            self.ActivityItem.tripkey = self.TripItem.key;
            self.ActivityItem.state = self.activitystate;
        }
        controller.realm = self.realm;
        controller.ActivityItem  = self.ActivityItem;
        controller.ExpenseItem = nil;
        controller.newitem = true;
    } else if([segue.identifier isEqualToString:@"ShowNewExpense"]){
        ExpenseDataEntryVC *controller = (ExpenseDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        if (self.TripItem != nil) {
            self.ActivityItem = [[ActivityRLM alloc] init];
            self.ActivityItem.tripkey = self.TripItem.key;
            self.ActivityItem.state = self.activitystate;
        }
        NSString *Title = [NSString stringWithFormat:@"New Expense on %@", self.ActivityItem.name];
        if (self.TripItem != nil) {
            Title = [NSString stringWithFormat:@"General Trip Expense for %@", self.TripItem.name];
        }
        controller.TitleText = Title;
        
        controller.realm = self.realm;
        controller.ActivityItem  = self.ActivityItem;
        controller.newitem = true;
    }
        
}



/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)SegmentPaymentType:(id)sender {
}
@end
