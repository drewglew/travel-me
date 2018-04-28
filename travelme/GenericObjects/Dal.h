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


@interface Dal : NSObject

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *DB;

-(bool) Init :(NSString*) databaseName;
-(bool) Create;
-(void) Delete;
-(bool)InsertPoiItem :(PoiNSO*) Poi;
-(NSMutableArray*) GetPoiContent :(NSString*) RequiredKey;

@end
