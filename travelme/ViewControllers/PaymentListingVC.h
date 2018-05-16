//
//  PaymentListingVC.h
//  travelme
//
//  Created by andrew glew on 08/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNSO.h"
#import "ProjectNSO.h"
#import "PaymentDataEntryVC.h"
#import "PaymentNSO.h"
#import "AppDelegate.h"
#import "PaymentListCell.h"
#import "PoiImageNSO.h"

@protocol PaymentListingDelegate <NSObject>
@end

@interface PaymentListingVC : UIViewController <PaymentDetailDelegate>
@property (weak, nonatomic) IBOutlet UITableView *TableViewPayment;
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (strong, nonatomic) NSMutableArray *paymentitems;
@property (strong, nonatomic) NSArray *localcurrencyitems;
@property (strong, nonatomic) NSMutableArray *paymentsections;

@property (strong, nonatomic) ActivityNSO *Activity;
@property (strong, nonatomic) ProjectNSO *Project;
@property (nonatomic, weak) id <PaymentListingDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewPoi;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAction;

@end
