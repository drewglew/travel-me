//
//  PaymentListingVC.m
//  travelme
//
//  Created by andrew glew on 08/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PaymentListingVC.h"

@interface PaymentListingVC ()

@end

@implementation PaymentListingVC

/*
 created date:      09/05/2018
 last modified:     15/05/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    /* going to receive an array of existing payments and what category */
    
    if (self.Project == nil) {
        PoiImageNSO *img = [self.Activity.poi.Images firstObject];
        if (img.Image.size.height==0) {
            self.ImageViewPoi.image = [UIImage imageNamed:@"Activity"];
        } else {
            self.ImageViewPoi.image = img.Image;
        }
        self.LabelTitle.text = [NSString stringWithFormat:@"Activity: %@", self.Activity.name];
    } else {
        if (self.Project.Image.size.height==0) {
            self.ImageViewPoi.image = [UIImage imageNamed:@"Project"];
        } else {
            self.ImageViewPoi.image = self.Project.Image;
        }
        NSLog(@"image size: %f",self.Project.Image.size.height );
        self.LabelTitle.text = [NSString stringWithFormat:@"Project: %@", self.Project.name];
        self.ButtonAction.hidden = true;
    }
    
    self.TableViewPayment.rowHeight = 80;
    // Do any additional setup after loading the view.
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
 last modified:     16/05/2018
 remarks:
 */
-(void) LoadPaymentData {

    self.paymentitems = [AppDelegateDef.Db GetPaymentListContent :self.Project :self.Activity];
    self.localcurrencyitems = [[NSSet setWithArray:[self.paymentitems valueForKey:@"localcurrencycode"]] allObjects];
    self.paymentsections = [[NSMutableArray alloc] initWithCapacity:self.localcurrencyitems.count];
    NSArray *rows = [[NSMutableArray alloc] init];
    
    for (NSString *item in self.localcurrencyitems) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localcurrencycode = %@", item];
        rows = [self.paymentitems filteredArrayUsingPredicate:predicate];
        [self.paymentsections addObject:rows];
    }

    [self.TableViewPayment reloadData];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.localcurrencyitems[section];
}


/*
 created date:      30/04/2018
 last modified:     16/05/2018
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCellId"];

    PaymentNSO *item = [[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (self.Project!=nil) {
        cell.LabelDescription.text = [NSString stringWithFormat:@"%@: %@",item.activityname, item.description];
    } else {
        cell.LabelDescription.text = item.description;
    }
        
    /* might need to adjust this with rate */
    cell.LabelLocalAmt.text = [NSString stringWithFormat:@"%@",item.amount];
    
    double localamt = ([item.amount doubleValue] / 100);
    
    cell.LabelLocalAmt.text = [NSString stringWithFormat:@"%.2f",localamt];
    cell.LabelLocalCurrencyCode.text = item.localcurrencycode;
    
    if ([item.rate intValue]==1) {
        cell.LabelHomeAmt.hidden = true;
        cell.LabelHomeCurrencyCode.hidden = true;
    } else if ([item.rate intValue]==0) {
        cell.LabelHomeAmt.text = @"unknown rate";
        cell.LabelHomeCurrencyCode.hidden = true;
    } else {
        cell.LabelHomeAmt.hidden = false;
        cell.LabelHomeCurrencyCode.hidden = false;
        
        double rate = [item.rate doubleValue] / 10000;
        double homeamt = ([item.amount doubleValue] / 100) * rate;
        
        cell.LabelHomeAmt.text = [NSString stringWithFormat:@"%.2f",homeamt];
        cell.LabelHomeCurrencyCode.text = [AppDelegateDef HomeCurrencyCode];
    }

    return cell;
}


/*
created date:      15/05/2018
last modified:     16/05/2018
remarks:
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"PaymentCellId";
    
    PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[PaymentListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    PaymentNSO *Payment = [[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];


    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PaymentDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PaymentDataEntryId"];
    controller.delegate = self;
    controller.Payment = Payment;
    controller.Activity = self.Activity;
    controller.newitem = false;
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
    if ([AppDelegateDef.Db DeletePayment:[[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]] == true)
    {
        [self LoadPaymentData];
    }
}

/*
 created date:      03/05/2018
 last modified:     15/05/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowNewPayment"]){
        PaymentDataEntryVC *controller = (PaymentDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = self.Activity;
        controller.Payment = nil;
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
