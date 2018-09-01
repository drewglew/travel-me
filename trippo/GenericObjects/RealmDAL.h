//
//  RealmDAL.h
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectNSO.h"
#import "TripRLM.h"
#import <Realm/Realm.h>
#import "CountryRLM.h"

@interface RealmDAL : NSObject
-(RLMResults<TripRLM *>*) GetTripCollection :(NSString*) RequiredKey;
-(bool)LoadCountryData :(RLMRealm*) realm;
@end
