//
//  PaymentDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PaymentDataEntryVC.h"

@interface PaymentDataEntryVC ()

@end

@implementation PaymentDataEntryVC
/*
 created date:      14/05/2018
 last modified:     16/05/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self.DatePickerPaymentDt setValue:[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0] forKey:@"textColor"];
    
    if (self.newitem) {
        /* get the expected currency code from the country of the point of interest.*/
        NSDictionary *components = [NSDictionary dictionaryWithObject:self.Activity.poi.countrycode forKey:NSLocaleCountryCode];
        NSString *localeIdent = [NSLocale localeIdentifierFromComponents:components];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdent];
        self.TextFieldCurrency.text = [locale objectForKey: NSLocaleCurrencyCode];
    } else {

        self.TextFieldCurrency.text = self.Payment.localcurrencycode;
        self.TextFieldDescription.text = self.Payment.description;
        NSDate *date;
        
        if (self.Payment.amt_act !=  [NSNumber numberWithInt:0]) {
            self.SegmentPaymentType.selectedSegmentIndex=1;
            double amount = [self.Payment.amt_act doubleValue];
            amount = amount / 100.0;
            self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];
            date = [dateFormatter dateFromString:self.Payment.date_act];
        } else {
            self.SegmentPaymentType.selectedSegmentIndex=0;
            double amount = [self.Payment.amt_est doubleValue];
            amount = amount / 100.0;
            self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];
            date = [dateFormatter dateFromString:self.Payment.date_est];
        }
        self.DatePickerPaymentDt.date = date;
    }
    self.LabelTitle.text = self.Activity.name;
    
}

/*
 created date:      14/05/2018
 last modified:     14/05/2018
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextFieldCurrency endEditing:YES];
    [self.TextFieldDescription endEditing:YES];
    [self.TextFieldAmt endEditing:YES];
    
}

/*
 created date:      14/05/2018
 last modified:     16/05/2018
 remarks:
 */
- (IBAction)ButtonActionPressed:(id)sender {
    
    if ([self.TextFieldDescription.text isEqualToString:@""]) {
        return;
    }
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;

    if (self.newitem) {
        self.Payment = [[PaymentNSO alloc] init];
        self.Payment.key = [[NSUUID UUID] UUIDString];
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    self.Payment.description = self.TextFieldDescription.text;
    self.Payment.status = [NSNumber numberWithLong:self.SegmentPaymentType.selectedSegmentIndex];

    if (self.Payment.status == [NSNumber numberWithLong:0] ) {

        self.Payment.amt_est = [f numberFromString:self.TextFieldAmt.text];
        double temp = [self.Payment.amt_est doubleValue];
        temp = temp * 100;
        self.Payment.amt_est = [NSNumber numberWithDouble:temp];
        
        self.Payment.dt_est = self.DatePickerPaymentDt.date;
        self.Payment.date_est = [dateFormatter stringFromDate:self.Payment.dt_est];
        
        self.Payment.dt_act = self.Payment.dt_est;
        self.Payment.date_act = self.Payment.date_est;
        self.Payment.amt_act = [NSNumber numberWithInt:0];
        
    } else {
        self.Payment.amt_act = [f numberFromString:self.TextFieldAmt.text];
        double temp = [self.Payment.amt_act doubleValue];
        temp = temp * 100;
        self.Payment.amt_act = [NSNumber numberWithDouble:temp];
        
        self.Payment.dt_act = self.DatePickerPaymentDt.date;
        self.Payment.date_act = [dateFormatter stringFromDate:self.Payment.dt_act];
        self.Payment.amt_act = [NSNumber numberWithDouble:temp];
        if (self.newitem) {
            self.Payment.dt_est = self.Payment.dt_act;
            self.Payment.date_est = self.Payment.date_act;
            self.Payment.amt_est = self.Payment.amt_act;
        }
    }

    self.Payment.localcurrencycode = self.TextFieldCurrency.text;
    self.Payment.homecurrencycode = [AppDelegateDef HomeCurrencyCode];
    
    if (![self.Payment.localcurrencycode isEqualToString:self.Payment.homecurrencycode]) {
        /* might return zero, but it worked.. */
        if (self.Payment.status == [NSNumber numberWithLong:0] ) {
            self.Payment.rate_est = [self GetExchangeRates :self.Payment];
        } else {
            self.Payment.rate_act = [self GetExchangeRates :self.Payment];
            if (self.newitem) {
                self.Payment.rate_est = self.Payment.rate_act;
            }
        }
    } else {
        self.Payment.rate_est = [NSNumber numberWithInt:1*10000];
        self.Payment.rate_act = self.Payment.rate_est;
    }
    
    /*
     we need to add payment record to database
     */
    if (self.newitem) {
        [AppDelegateDef.Db InsertPayment:self.Payment :self.Activity];
    } else {
         [AppDelegateDef.Db UpdatePaymentItem:self.Payment];
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      14/05/2018
 last modified:     15/05/2018
 remarks:
 */
-(void)fetchFromExchangeRateApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
}


/*
 created date:      14/05/2018
 last modified:     16/05/2018
 remarks:
 */
- (NSNumber*)GetExchangeRates:(PaymentNSO*)payment {
   
    NSString *AccessKey = @"";
    NSString *DateValue = self.Payment.date_act;
    if (self.Payment.status==[NSNumber numberWithLong:0]) {
        DateValue = self.Payment.date_est;
    }
    
    NSNumber *ExchangeRate = [AppDelegateDef.Db GetExchangeRate:payment.localcurrencycode :DateValue];
    
    if (ExchangeRate == [NSNumber numberWithInt:0]) {
    
        NSString *url = [NSString stringWithFormat:@"https://free.currencyconverterapi.com/api/v5/convert?q=%@_%@&compact=ultra&date=%@&apikey=%@", payment.localcurrencycode, payment.homecurrencycode, DateValue, AccessKey];

        [self fetchFromExchangeRateApi:url withDictionary:^(NSDictionary *data) {
        
            dispatch_async(dispatch_get_main_queue(), ^(void){
                NSDictionary *LocalToHome = [data objectForKey:[NSString stringWithFormat:@"%@_%@", payment.localcurrencycode, payment.homecurrencycode]];
                NSNumber *LocalToHomeRate = [LocalToHome valueForKey:DateValue];
                 [AppDelegateDef.Db InsertExchangeRate:payment.localcurrencycode :DateValue :LocalToHomeRate];
            });
        }];
        return 0;
        
    } else {
        return ExchangeRate;
    }
}


- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)AmountEditingEnded:(id)sender {
    double amount = [self.TextFieldAmt.text doubleValue];
    amount = (round(amount*100)) / 100.0;
    //amount = amount * 100;
    
    if (self.Payment.status==[NSNumber numberWithLong:0]) {
        self.Payment.amt_est = [NSNumber numberWithDouble:amount];
    } else {
        self.Payment.amt_act = [NSNumber numberWithDouble:amount];
        if (self.newitem) {
            self.Payment.amt_est = self.Payment.amt_act;
        }
    }
    self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];
}


- (IBAction)SegmentStatusChanged:(id)sender {
    
}



@end
