//
//  ExpenseRLM.h
//  trippo
//
//  Created by andrew glew on 03/09/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>

@interface ExpenseRLM : RLMObject
@property NSString *key;
@property NSString *desc;
@property NSNumber<RLMInt> *amt_est;
@property NSNumber<RLMInt> *amt_act;
@property NSString *homecurrencycode;
@property NSString *localcurrencycode;
@property NSString *date_est;
@property NSString *date_act;
@property NSNumber<RLMInt> *rate_est;
@property NSNumber<RLMInt> *rate_act;
@property NSNumber<RLMInt> *status;
@end

RLM_ARRAY_TYPE(ExpenseRLM)
