//
//  PaymentListingVC.h
//  travelme
//
//  Created by andrew glew on 08/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNSO.h"
#import "PaymentDataEntryVC.h"
#import "PaymentNSO.h"
#import "AppDelegate.h"
#import "PaymentListCell.h"

@protocol PaymentListingDelegate <NSObject>
@end

@interface PaymentListingVC : UIViewController <PaymentDetailDelegate>
@property (weak, nonatomic) IBOutlet UITableView *TableViewPayment;
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (strong, nonatomic) NSMutableArray *paymentitems;
@property (strong, nonatomic) ActivityNSO *Activity;
@property (nonatomic, weak) id <PaymentListingDelegate> delegate;
@end
