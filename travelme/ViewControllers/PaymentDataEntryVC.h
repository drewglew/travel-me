//
//  PaymentDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNSO.h"
#import "PaymentNSO.h"
#import "AppDelegate.h"
#import "CurrencyPickerVC.h"
#import "Reachability.h"

@protocol PaymentDetailDelegate <NSObject>
@end

@interface PaymentDataEntryVC : UIViewController <UITextFieldDelegate, CurrencyPickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *TextFieldDescription;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldAmt;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldCurrency;
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerPaymentDt;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAction;
@property (strong, nonatomic) ActivityNSO *Activity;
@property (strong, nonatomic) PaymentNSO *Payment;
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (assign) bool newitem;
@property (nonatomic, weak) id <PaymentDetailDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentPaymentType;
@property(nonatomic, retain) NSDate *date;
@property (weak, nonatomic) IBOutlet UIButton *ButtonHomeCurrency;
@property (weak, nonatomic) IBOutlet UIButton *ButtonLocalCurrency;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCancel;


@end
