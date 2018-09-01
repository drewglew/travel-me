//
//  ActivityRLM.h
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Realm/Realm.h>
#import "ImageCollectionRLM.h"

@interface ActivityRLM : RLMObject
@property  (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSNumber<RLMInt> *state;
@property  (strong, nonatomic) NSString *compondkey;
@property  (strong, nonatomic) NSString *name;
@property  (strong, nonatomic) NSString *privatenotes;
@property  (strong, nonatomic) NSString *tripkey;
@property  (strong, nonatomic) NSString *poikey;
@property (strong, nonatomic) NSDate *createddt;
@property (strong, nonatomic) NSDate *modifieddt;
@property (nonatomic) NSNumber<RLMFloat> *rating;
@property (assign) NSNumber<RLMInt> *legendref;
@property (nonatomic) NSDate *startdt;
@property (nonatomic) NSDate *enddt;
@property RLMArray<ImageCollectionRLM *><ImageCollectionRLM> *images;
@end

RLM_ARRAY_TYPE(ActivityRLM)
