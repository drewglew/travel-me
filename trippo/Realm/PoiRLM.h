//
//  PoiRLM.h
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ImageCollectionRLM.h"
#import <Realm/Realm.h>

@interface PoiRLM : RLMObject
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber<RLMInt> *categoryid;
@property (strong, nonatomic) NSString *countrykey;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *countrycode;
@property (strong, nonatomic) NSString *administrativearea;
@property (strong, nonatomic) NSString *subadministrativearea;
@property (strong, nonatomic) NSString *fullthoroughfare;
@property (strong, nonatomic) NSString *privatenotes;
@property (strong, nonatomic) NSString *locality;
@property (strong, nonatomic) NSString *sublocality;
@property (strong, nonatomic) NSString *postcode;
@property (strong, nonatomic) NSString *wikititle;
@property (strong, nonatomic) NSString *searchstring;
@property (strong, nonatomic) NSNumber<RLMDouble> *lat;
@property (strong, nonatomic) NSNumber<RLMDouble> *lon;
@property (strong, nonatomic) NSDate *createddt;
@property (strong, nonatomic) NSDate *modifieddt;
@property RLMArray<ImageCollectionRLM *><ImageCollectionRLM> *images;
@end
