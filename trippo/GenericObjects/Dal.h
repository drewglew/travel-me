//
//  Dal.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>
#import <sqlite3.h>
#import "PoiNSO.h"
#import "PoiImageNSO.h"
#import "ProjectNSO.h"
#import "ActivityNSO.h"
#import "ScheduleNSO.h"
#import "CountryNSO.h"
#import "PaymentNSO.h"
#import "ImageNSO.h"

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
-(bool) DeletePayment :(PaymentNSO*) Payment;
-(bool) UpdatePaymentItem :(PaymentNSO*) Payment;
-(bool) DeleteActivity :(ActivityNSO*) Activity :(NSString*) ProjectKey;

-(NSMutableArray*) GetPoiContent :(NSString*) RequiredKey :(NSArray*) Countries :(NSString*) FilterOption;
-(NSMutableArray*) GetPoiData :(NSString*) RequiredKey;
-(NSMutableArray*) GetProjectContent :(NSString*) RequiredKey;
-(NSMutableArray*) GetActivityContent :(NSString*) RequiredKey;
-(NSMutableArray*) GetActivityListContentForState :(NSString*) RequiredProjectKey :(NSNumber*) RequiredState;
-(NSMutableArray*) GetActivitySchedule :(NSString *) ProjectKey :(NSNumber*) RequiredState;
-(NSMutableArray*) GetPaymentListContent :(ProjectNSO*) Project :(ActivityNSO *) Activity;
-(NSMutableArray*) GetProjectCountries :(NSString*) RequiredProjectKey;
-(CountryNSO *) GetCountryByCode :(NSString*) CountryCode;
-(NSNumber*) GetExchangeRate :(NSString *) LocalCurrencyCode :(NSString *) PaymentDt;
-(NSMutableArray *)GetImagesForSelectedPoi :(NSString *) RequiredKey;
-(NSMutableArray *)GetImagesForSelectedActivity :(NSString *) RequiredKey :(NSNumber*) RequiredState;
-(bool) InsertExchangeRate :(NSString*) LocalCurrencyCode :(NSString*) DateValue :(NSNumber*) Rate;
-(bool) InsertPayment :(PaymentNSO*) Payment :(ActivityNSO*) Activity;
-(bool) DeleteImage :(PoiImageNSO*) ImageItem;
-(bool) DeleteActivityImage :(ImageNSO*) ImageItem;
-(PoiNSO*) GetFeaturedPoi;
@end
