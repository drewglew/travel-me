//
//  PaymentNSO.h
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentNSO : NSObject

/* PAYMENT table
 sql_statement = "CREATE TABLE payment (projectkey TEXT, activitykey TEXT, key TEXT PRIMARY KEY, state INTEGER, amount INTEGER, currencycode TEXT, paymentdt TEXT, FOREIGN KEY(projectkey) REFERENCES project(key), FOREIGN KEY(activitykey) REFERENCES activity(key))";
 */

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *description;
@property (nonatomic) NSNumber *amount;
@property (nonatomic) NSString *homecurrencycode;
@property (nonatomic) NSString *localcurrencycode;
@property (nonatomic) NSDate   *paymentdt;
@property (nonatomic) NSString *dtvalue;
@property (nonatomic) NSNumber *rate;

-(NSDate *)GetDtFromString :(NSString *) dt;

@end
