//
//  Dal.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "PoiNSO.h"
#import "PoiImageNSO.h"
#import "ProjectNSO.h"
#import "ActivityNSO.h"
#import "ScheduleNSO.h"
#import "CountryNSO.h"
#import "PaymentNSO.h"

@interface Dal : NSObject

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *DB;

-(bool) InitDb :(NSString*) databaseName;
-(void) CloseDb;
-(bool) CreateDb;
-(void) DeleteDb;

-(bool) InsertPoiItem :(PoiNSO*) Poi;
-(bool) UpdatePoiItem :(PoiNSO*) Poi;
-(bool) InsertProjectItem :(ProjectNSO*) Project;
-(bool) UpdateProjectItem :(ProjectNSO*) Project;
-(bool) InsertActivityItem :(ActivityNSO*) Activity;
-(bool) UpdateActivityItem :(ActivityNSO*) Activity;
-(bool) DeletePoi :(PoiNSO*) Poi;
-(bool) DeleteProject :(ProjectNSO*) Project;
-(bool) DeleteActivity :(ActivityNSO*) Activity :(NSString*) ProjectKey;

-(NSMutableArray*) GetPoiContent :(NSString*) RequiredKey :(NSArray*) Countries :(NSString*) FilterOption;
-(NSMutableArray*) GetProjectContent :(NSString*) RequiredKey;
-(NSMutableArray*) GetActivityContent :(NSString*) RequiredKey;
-(NSMutableArray*) GetActivityListContentForState :(NSString*) RequiredProjectKey :(NSNumber*) RequiredState;
-(NSMutableArray*) GetActivitySchedule :(NSString *) ProjectKey :(NSNumber*) RequiredState;
-(NSMutableArray*) GetPaymentListContentForState :(NSString *) ProjectKey :(NSString *) ActivityKey   :(NSNumber *) RequiredState;
-(NSMutableArray*) GetProjectCountries :(NSString*) RequiredProjectKey;
@end
