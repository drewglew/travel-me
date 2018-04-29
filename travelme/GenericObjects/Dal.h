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


@interface Dal : NSObject

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *DB;

-(bool) Init :(NSString*) databaseName;
-(bool) Create;
-(void) Delete;
-(bool) InsertPoiItem :(PoiNSO*) Poi;
-(bool) UpdatePoiItem :(PoiNSO*) Poi;
-(bool) InsertProjectItem :(ProjectNSO*) Project;
-(bool) UpdateProjectItem :(ProjectNSO*) Project;
-(NSMutableArray*) GetPoiContent :(NSString*) RequiredKey;
-(NSMutableArray*) GetProjectContent :(NSString*) RequiredKey;
@end
