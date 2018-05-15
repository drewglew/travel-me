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
        //self.TextFieldAmt.text = [NSString stringWithFormat:@"%@",self.Payment.amount];
        
        double amount = [self.Payment.amount doubleValue];
        amount = amount / 100.0;
        self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];

        NSDate *date = [dateFormatter dateFromString:self.Payment.dtvalue];
        self.DatePickerPaymentDt.date = date;
        
        /* load expected values into text box cells */
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
 last modified:     14/05/2018
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
    self.Payment.amount = [f numberFromString:self.TextFieldAmt.text];
    
    double temp = [self.Payment.amount doubleValue];
    temp = temp * 100;
    self.Payment.amount = [NSNumber numberWithDouble:temp];
    
    
    if (self.SegmentPaymentType == 0 ) {
        self.Payment.paymentdt = nil;
    } else {
        self.Payment.paymentdt = self.DatePickerPaymentDt.date;
        self.Payment.dtvalue = [dateFormatter stringFromDate:self.Payment.paymentdt];
    }

    self.Payment.localcurrencycode = self.TextFieldCurrency.text;
    self.Payment.homecurrencycode = [AppDelegateDef HomeCurrencyCode];
    
    if (![self.Payment.localcurrencycode isEqualToString:self.Payment.homecurrencycode] && self.Payment.paymentdt!=nil) {
        /* might return zero, but it worked.. */
        self.Payment.rate = [self GetExchangeRates :self.Payment];
    } else {
        self.Payment.rate = [NSNumber numberWithInt:1*10000];
    }
    
    /*
     we need to add payment record to database
     */
    [AppDelegateDef.Db InsertPayment:self.Payment :self.Activity];
    
    
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
 last modified:     15/05/2018
 remarks:
 */
- (NSNumber*)GetExchangeRates:(PaymentNSO*)payment {
   
    NSString *AccessKey = @"";

    NSNumber *ExchangeRate = [AppDelegateDef.Db GetExchangeRate:payment.localcurrencycode :payment.dtvalue];
    
    if (ExchangeRate == [NSNumber numberWithInt:0]) {
    
        NSString *url = [NSString stringWithFormat:@"https://free.currencyconverterapi.com/api/v5/convert?q=%@_%@&compact=ultra&date=%@&apikey=%@", payment.localcurrencycode, payment.homecurrencycode, payment.dtvalue, AccessKey];

        [self fetchFromExchangeRateApi:url withDictionary:^(NSDictionary *data) {
        
            dispatch_async(dispatch_get_main_queue(), ^(void){
                NSDictionary *LocalToHome = [data objectForKey:[NSString stringWithFormat:@"%@_%@", payment.localcurrencycode, payment.homecurrencycode]];
                NSNumber *LocalToHomeRate = [LocalToHome valueForKey:payment.dtvalue];
                 [AppDelegateDef.Db InsertExchangeRate:payment.localcurrencycode :payment.dtvalue :LocalToHomeRate];
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
    self.Payment.amount = [NSNumber numberWithDouble:amount];
    self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];
}




@end
