//
//  ActivityNSO.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectNSO.h"
#import "PoiNSO.h"

@interface ActivityNSO : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *privatenotes;
@property (nonatomic) NSDate *startdt;
@property (nonatomic) NSDate *enddt;
@property (nonatomic) NSString *currency;
@property (nonatomic) NSNumber *costamt;
@property (assign) NSNumber *activitystate;
@property (strong, nonatomic) ProjectNSO *project;
@property (strong, nonatomic) PoiNSO *poi;

-(NSString *)GetStringFromDt :(NSDate *) dt;
-(NSDate *)GetDtFromString :(NSString *) dt;

@end