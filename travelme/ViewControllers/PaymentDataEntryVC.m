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

    if (self.newitem) {
        /* get the expected currency code from the country of the point of interest.*/
        NSDictionary *components = [NSDictionary dictionaryWithObject:self.Activity.poi.countrycode forKey:NSLocaleCountryCode];
        NSString *localeIdent = [NSLocale localeIdentifierFromComponents:components];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdent];
        self.TextFieldCurrency.text = [locale objectForKey: NSLocaleCurrencyCode];
    } else {
        /* load expected values into text box cells */
    }
    self.LabelTitle.text = self.Activity.name;
    
}

- (IBAction)ButtonActionPressed:(id)sender {
   
    /* only now do we get the exchange rate from the web service
     and only in the case that:
       + we have a currency different to our home
       + that we have a payment date.
            if payment date is in the past than it is an actual payment
            if it is in the future we can only use our latest rate to calculate and it is an idea
            if it is empty ???
     */
    
    
    
    if (self.newitem) {
        
        
    } else {
        
    }
    
    
    
}




/* created 20170826 */
/* purpose is to call the remote webservice and load the reponse into a dictionary object */
/*-(void)fetchFromFixer:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
 
 NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
 [request setHTTPMethod:@"GET"];
 
 [request setValue:@"CEEC5067A7BDD7D0DC5F75725DE93908814441A812B74DFCF751FFEC5150F594" forHTTPHeaderField:@"tankers-api-key"];
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
 */

/*
 created on: 20170823
 last updated: 20180310
 */
/*
 1    USDEUR            0.811901
 1    USDGBP            0.71235
 
 how to get EUR-GBP?
 
 1      EURGBP          0.87 (1.13975012283)
 0.71235 / 0.811901 =   0.87738529697
 
 1     GBPEUR
 0.811901 / 0.71235 =   1.13975012283
 
 - (IBAction)GetLatestRates:(id)sender {
 
 http://apilayer.net/api/historical?access_key=f956861b2cdec495ba361719d013089d&date=2018-04-01
 
 NSString *url = @"http://data.fixer.io/api/latest?access_key=76c971a4fe13fe41b4dec3a05c0e7790&symbols=USD,EUR,GBP,DKK,SEK";
 
 //{"success":true,"timestamp":1525895413,"base":"EUR","date":"2018-05-09","rates":{"USD":1.185674,"EUR":1,"GBP":0.875229,"DKK":7.450122,"SEK":10.316618}}
 
 [self fetchFromTankers:url withDictionary:^(NSDictionary *data) {
 
 NSDictionary *resultObject = [data objectForKey:@"Object"];
 
 for (NSDictionary *dict in resultObject) {
 
 portNSO *p = [[portNSO alloc] init];
 p.code = [dict objectForKey:@"Code"];
 p.abc_code = [dict objectForKey:@"AbcCode"];
 p.name = [dict objectForKey:@"Name"];
 // to do bridge these together!!
 [self.db insertPortData :p];
 }
 }];
 }
 */



- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}





@end
