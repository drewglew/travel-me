//
//  PaymentNSO.m
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PaymentNSO.h"

@implementation PaymentNSO
@synthesize description;
@synthesize homecurrencycode;
@synthesize localcurrencycode;
@synthesize activityname;
@synthesize amount;
@synthesize paymentdt;
@synthesize dtvalue;
@synthesize key;
@synthesize rate;
@synthesize status;

/*
 created date:      29/04/2018
 last modified:     15/05/2018
 remarks: transform NSString to NSDate.
 */
-(NSDate *)GetDtFromString :(NSString *) dt {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *returnValue = [[NSDate alloc] init];
    returnValue = [dateFormatter dateFromString:dt];
    return returnValue;
}



@end
