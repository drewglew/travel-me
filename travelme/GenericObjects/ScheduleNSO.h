//
//  ScheduleNSO.h
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectNSO.h"
#import "PoiNSO.h"

@interface ScheduleNSO : NSObject
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate *dt;
@property (nonatomic) NSString *type;
@property (nonatomic) NSNumber *activitystate;
@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;

@property (strong, nonatomic) ProjectNSO *project;
@property (strong, nonatomic) PoiNSO *poi;

-(NSDate *)GetDtFromString :(NSString *) dt;
@end
