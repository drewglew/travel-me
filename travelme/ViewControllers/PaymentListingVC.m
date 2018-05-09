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

- (void)viewDidLoad {
    [super viewDidLoad];
    /* going to receive an array of existing payments and what category */
    self.LabelTitle.text = [NSString stringWithFormat:@"%@", self.Activity.name];
    
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
 last modified:     09/05/2018
 remarks:
 */
-(void) LoadPaymentData {
        
    self.paymentitems = [AppDelegateDef.Db GetPaymentListContentForState :self.Activity.project.key :self.Activity.key :self.Activity.activitystate];
    [self.TableViewPayment reloadData];
}



/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.paymentitems.count;
}

/*
 created date:      30/04/2018
 last modified:     03/04/2018
 remarks:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCellId"];
    
    PaymentNSO *item = [self.paymentitems objectAtIndex:indexPath.row];
    cell.LabelDescription.text = item.description;
    /* might need to adjust this with rate */
    cell.LabelHomeAmt.text = [NSString stringWithFormat:@"%@",item.amount];
    cell.LabelHomeCurrencyCode.text = item.homecurrencycode;
    
    cell.LabelLocalAmt.text = [NSString stringWithFormat:@"%@",item.amount];
    cell.LabelLocalCurrencyCode.text = item.localcurrencycode;

    return cell;
}


/*
 created date:      03/05/2018
 last modified:     03/05/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowExistingPayment"]){
        PaymentDataEntryVC *controller = (PaymentDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = self.Activity;
        
        controller.newitem = false;
        
    } else if([segue.identifier isEqualToString:@"ShowNewPayment"]){
        PaymentDataEntryVC *controller = (PaymentDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = self.Activity;
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

@end
