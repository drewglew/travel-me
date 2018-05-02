//
//  Dal.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "Dal.h"

@implementation Dal

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           Delete the database file cleanly
 */
-(void) Delete {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:imagesDirectory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", imagesDirectory, file] error:&error];
        if (!success || error) {
            NSLog(@"something failed in deleting unwanted data");
        }
    }
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           Create a new database with model.
 */
-(bool)Init :(NSString*) databaseName {
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:databaseName]];

    NSFileManager *filemgr = [NSFileManager defaultManager];
    if([filemgr fileExistsAtPath:_databasePath] ==  NO) {
        return false;
    }
    return true;
}

/*
 created date:      27/04/2018
 last modified:     29/04/2018
 remarks:           Create a new database with model.
 */
-(bool)Create {
    const char *dbpath = [_databasePath UTF8String];
        
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        char *errorMessage;

            
        /* PROJECT table */
        const char *sql_statement = "CREATE TABLE project (key TEXT PRIMARY KEY, name TEXT, privatenotes TEXT, imagefilename TEXT)";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create project table");
            sqlite3_close(_DB);
            return false;
        }

        /* COUNTRY table */
        sql_statement = "CREATE TABLE country (key TEXT PRIMARY KEY, name TEXT, currency TEXT, capital TEXT, lat DOUBLE, lon DOUBLE)";

        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create country table");
            sqlite3_close(_DB);
            return false;
        }

        [self InsertCountry :@"United Kingdom" :@"GBP" :@"London" :[NSNumber numberWithDouble:54.0] :[NSNumber numberWithDouble:-2.0]];
            
        [self InsertCountry :@"Denmark" :@"DKK" :@"Copenhagen" :[NSNumber numberWithDouble:56.0] :[NSNumber numberWithDouble:10.0]];
            
        [self InsertCountry :@"Sweden" :@"SEK" :@"Stockholm" :[NSNumber numberWithDouble:62.0] :[NSNumber numberWithDouble:15.0]];
            
        [self InsertCountry :@"Germany" :@"EUR" :@"Berlin" :[NSNumber numberWithDouble:51.0] :[NSNumber numberWithDouble:9.0]];
            
        [self InsertCountry :@"Switzerland" :@"CHF" :@"Bern" :[NSNumber numberWithDouble:47.0] :[NSNumber numberWithDouble:8.0]];
            
            
        /* POI table */
        sql_statement = "CREATE TABLE poi (key TEXT PRIMARY KEY, name TEXT, administrativearea TEXT, categoryid INTEGER, privatenotes TEXT, lat DOUBLE, lon DOUBLE)";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create poi table");
            sqlite3_close(_DB);
            return false;
        }

        /* ACTIVITY table */
        sql_statement = "CREATE TABLE activity (projectkey TEXT, poikey TEXT, key TEXT, name TEXT, totalprice INTEGER, notes TEXT, startdt TEXT, enddt TEXT, state INTEGER, PRIMARY KEY(key,state), FOREIGN KEY(projectkey) REFERENCES project(key), FOREIGN KEY(poikey) REFERENCES poi(key))";
            
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create activity table");
            sqlite3_close(_DB);
            return false;
        }
            
        /* LEG table */
        sql_statement = "CREATE TABLE leg (activitykey TEXT, startpoikey TEXT, endpoikey TEXT, key TEXT PRIMARY KEY, label TEXT, transport INTEGER, startdt TEXT, enddt TEXT, FOREIGN KEY(activitykey) REFERENCES activity(key), FOREIGN KEY(startpoikey) REFERENCES poi(key), FOREIGN KEY(endpoikey) REFERENCES poi(key))";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create leg table");
            sqlite3_close(_DB);
            return false;
        }
            
        /* IMAGE table */
        sql_statement = "CREATE TABLE imageitem (filename TEXT, poikey TEXT, keyimage INTEGER, description TEXT, PRIMARY KEY (filename, poikey), FOREIGN KEY(poikey) REFERENCES poi(key))";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create images table");
            sqlite3_close(_DB);
            return false;
        }
            
        /* LINK table */
        sql_statement = "CREATE TABLE linkitem (url TEXT, poikey TEXT, description TEXT, FOREIGN KEY(poikey) REFERENCES poi(key))";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create leg table");
            sqlite3_close(_DB);
            return false;
        }
        sqlite3_close(_DB);
    } else {
        NSLog(@"failed to create database for travel-me App");
        return false;
    }
    return true;
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
-(bool)InsertCountry :(NSString*)Name :(NSString*)Currency :(NSString*)Capital :(NSNumber*) Lat :(NSNumber*) Lon {
    
    NSString *key = [[NSUUID UUID] UUIDString];

    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO country (key, name, currency, capital, lon, lat) VALUES ('%@','%@','%@','%@', %f, %f)", key, Name, Currency, Capital, [Lat doubleValue], [Lon doubleValue]];
    
    sqlite3_stmt *statement;
    const char *insert_statement = [insertSQL UTF8String];
    sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Failed to insert new record inside country table");
        return false;
    } else {
        NSLog(@"inserted new country record inside table!");
    }
    sqlite3_finalize(statement);
    return true;
}

/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(bool) UpdatePoiItem :(PoiNSO*) Poi {
  
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
        
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE poi SET name = '%@', categoryid = %@, privatenotes = '%@' WHERE key='%@'", Poi.name, Poi.categoryid, Poi.privatenotes, Poi.key];
        
        const char *update_statement = [updateSQL UTF8String];
        sqlite3_prepare_v2(_DB, update_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to update record(s) inside poi table");
        }
        [self InsertImages :Poi];
        
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
    return true;
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(bool) UpdateProjectItem :(ProjectNSO*) Project {
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE project SET name = '%@', privatenotes = '%@' WHERE key='%@'", Project.name, Project.privatenotes, Project.key];
        
        const char *update_statement = [updateSQL UTF8String];
        sqlite3_prepare_v2(_DB, update_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to update record(s) inside project table");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
    return true;
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
-(bool) UpdateActivityItem :(ActivityNSO*) Activity {
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE activity SET name = '%@', notes = '%@', poikey = '%@', totalprice = '%d', startdt = '%@', enddt = '%@', state = %@ WHERE key='%@' and state=%@", Activity.name, Activity.privatenotes, Activity.poi.key, 100, [Activity GetStringFromDt :Activity.startdt], [Activity GetStringFromDt :Activity.enddt], Activity.activitystate, Activity.key, Activity.activitystate];
        
        const char *update_statement = [updateSQL UTF8String];
        sqlite3_prepare_v2(_DB, update_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to update record(s) inside activity table");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
    return true;
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(bool)InsertImages :(PoiNSO*) Poi {
    /* Images table */
    for (PoiImageNSO *imageitem in Poi.Images) {
        if (imageitem.NewImage) {
            
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO imageitem (filename, poikey, keyimage, description) VALUES ('%@','%@',%d ,'%@')", imageitem.ImageFileReference, Poi.key, imageitem.KeyImage, @"test"];
            sqlite3_stmt *statement;
            const char *insert_statement = [insertSQL UTF8String];
            sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to insert new record inside imageitem table");
                return false;
            } else {
                NSLog(@"Inserted new imageitem record inside table!");
            }
            sqlite3_finalize(statement);
        }
        
    }
    return true;
}



/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(bool)InsertPoiItem :(PoiNSO*)Poi {

    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        /* POI table */
        Poi.key = [[NSUUID UUID] UUIDString];
    
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO poi (key, name, administrativearea, categoryid, privatenotes, lat, lon) VALUES ('%@','%@','%@',%@,'%@', %@, %@)", Poi.key, Poi.name, Poi.administrativearea, Poi.categoryid, Poi.privatenotes, Poi.lat, Poi.lon];
    
        sqlite3_stmt *statement;
        const char *insert_statement = [insertSQL UTF8String];
        sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to insert new record inside poi table");
            return false;
        } else {
            NSLog(@"inserted new poi record inside table!");
        }
        sqlite3_finalize(statement);
        [self InsertImages :Poi];
    }
    sqlite3_close(_DB);
    return true;
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks: Flat table with single image representing the project.
 */
-(bool) InsertProjectItem :(ProjectNSO*) Project {
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        /* PROJECT table */
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO project (key, name, privatenotes, imagefilename) VALUES ('%@','%@','%@','%@')", Project.key, Project.name, Project.privatenotes, Project.imagefilereference];
        
        sqlite3_stmt *statement;
        const char *insert_statement = [insertSQL UTF8String];
        sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to insert new record inside project table");
            return false;
        } else {
            NSLog(@"inserted new project record inside table!");
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(_DB);
    return true;
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks: Flat table with single image representing the project.
 */
-(bool) InsertActivityItem :(ActivityNSO*) Activity {
    const char *dbpath = [_databasePath UTF8String];

    if(sqlite3_open(dbpath, &_DB) == SQLITE_OK) {

        /* ACTIVITY table */
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO activity (projectkey, poikey, key, name, totalprice, notes, startdt, enddt, state) VALUES ('%@','%@','%@','%@', %d, '%@','%@','%@', %@)", Activity.project.key, Activity.poi.key, Activity.key, Activity.name, 100, Activity.privatenotes, [Activity GetStringFromDt :Activity.startdt], [Activity GetStringFromDt :Activity.enddt], Activity.activitystate];
        
        sqlite3_stmt *statement;
        const char *insert_statement = [insertSQL UTF8String];
        sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to insert new record inside activity table");
            return false;
        } else {
            NSLog(@"inserted new activity record inside table!");
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(_DB);
    return true;
}





/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(NSMutableArray*) GetPoiContent :(NSString*) RequiredKey {
    NSMutableArray *poidata  = [[NSMutableArray alloc] init];
   
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
        
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
            
        NSString *whereClause = @"";
            
        if (RequiredKey != nil) {
            whereClause = @"WHERE";
            whereClause = [NSString stringWithFormat:@"%@ %@='%@' AND ", whereClause, @"key",RequiredKey];
            if (![whereClause isEqualToString:@"WHERE"]) {
                whereClause = [whereClause substringToIndex:[whereClause length]-5];
            }
        }
        
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT key,name,administrativearea,categoryid,privatenotes,lat,lon,(select count(*) as counter from activity a where a.poikey=p.key) as sumofactivities FROM poi p %@ ORDER BY name", whereClause];

        
        const char *select_statement = [selectSQL UTF8String];
            
            
            if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    PoiNSO *poi = [self LoadPoiImageData :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
                    poi.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    poi.administrativearea = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    poi.categoryid = [NSNumber numberWithInt:sqlite3_column_int(statement, 3)];
                    poi.privatenotes = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                    poi.lat = [NSNumber numberWithDouble:sqlite3_column_double(statement, 5)];
                    poi.lon = [NSNumber numberWithDouble:sqlite3_column_double(statement, 6)];
                    poi.connectedactivitycount = [NSNumber numberWithInt:sqlite3_column_int(statement, 7)];
                    poi.Images = [NSMutableArray arrayWithArray:[self GetImagesForSelectedPoi:poi.key]];
                    poi.searchstring = [NSString stringWithFormat:@"%@|%@",poi.name,poi.administrativearea];
                    [poidata addObject:poi];
                }
            }
            sqlite3_finalize(statement);
            sqlite3_close(_DB);
        } else {
            NSLog(@"Cannot open database");
        }
        
        return poidata;
    }

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(NSMutableArray*) GetProjectContent :(NSString*) RequiredKey {
    NSMutableArray *projectdata  = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
        NSString *whereClause = @"";
        if (RequiredKey != nil) {
            whereClause = @"WHERE";
            whereClause = [NSString stringWithFormat:@"%@ %@='%@' AND ", whereClause, @"key",RequiredKey];
            if (![whereClause isEqualToString:@"WHERE"]) {
                whereClause = [whereClause substringToIndex:[whereClause length]-5];
            }
        }
        
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT key, name, privatenotes, imagefilename FROM project %@ ORDER BY name", whereClause];
        
        const char *select_statement = [selectSQL UTF8String];

        if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                ProjectNSO *project = [[ProjectNSO alloc] init];
                project.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                project.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                project.privatenotes = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                project.imagefilereference = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                
                [projectdata addObject:project];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    } else {
        NSLog(@"Cannot open database");
    }
    
    return projectdata;
}

/*
 created date:      30/04/2018
 last modified:     01/05/2018
 remarks:  Only need to retrieve one record here.
 */
-(ActivityNSO*) GetActivityContent :(NSString*) RequiredKey {
    
    ActivityNSO *activity = [[ActivityNSO alloc] init];

    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
   
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT projectkey, poikey, key, name, notes, totalprice, startdt, enddt, state FROM activity WHERE key='%@' ORDER BY name", RequiredKey];
        
        const char *select_statement = [selectSQL UTF8String];
        
        if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                activity.project.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                activity.poi.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                activity.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                activity.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                activity.privatenotes = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                activity.costamt = [NSNumber numberWithInt:sqlite3_column_int(statement, 5)];
                activity.startdt = [activity GetDtFromString :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)]];
                activity.enddt = [activity GetDtFromString :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)]];
                activity.activitystate = [NSNumber numberWithInt:sqlite3_column_int(statement, 8)];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    } else {
        NSLog(@"Cannot open database");
    }
    
    return activity;
}





/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(NSMutableArray *)GetImagesForSelectedPoi :(NSString *) RequiredKey {
    NSMutableArray *ImagesDataSet = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT filename, keyimage FROM imageitem WHERE poikey='%@'", RequiredKey];

        const char *select_statement = [selectSQL UTF8String];
        
        if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                PoiImageNSO *imgitem = [[PoiImageNSO alloc] init];
                imgitem.ImageFileReference = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                imgitem.KeyImage = sqlite3_column_int(statement, 1);
                imgitem.NewImage = false;
                [ImagesDataSet addObject:imgitem];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    } else {
        NSLog(@"Cannot open database");
    }
    return ImagesDataSet;
}

/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks:           state 1 = idea; state 2 = actual
 */
-(NSMutableArray*) GetActivityListContentForState :(NSString*) RequiredProjectKey :(NSNumber*) RequiredState {
    NSMutableArray *activitydata  = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        NSString *selectSQL;

        if ([RequiredState intValue] == 0) {
            /* Ideas */
            selectSQL = [NSString stringWithFormat:@"SELECT projectkey, poikey, key, name, notes, totalprice, startdt, enddt, state FROM activity WHERE projectkey='%@' AND state=0 ORDER BY name", RequiredProjectKey];
        }
        else
        {
            
            selectSQL = [NSString stringWithFormat:@"SELECT projectkey, poikey, activity.key, name, notes, totalprice, startdt, enddt, activity.state FROM activity, (select max(state) as maxstate, key from activity group by key) data where activity.key=data.key and activity.state=data.maxstate and projectkey='%@' ORDER BY name", RequiredProjectKey];
            
        }
        
        const char *select_statement = [selectSQL UTF8String];
        
        if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                ActivityNSO *activity = [[ActivityNSO alloc] init];
                
                activity.project.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                activity.poi = [self LoadPoiImageData :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
                //activity.poi.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                activity.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                activity.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                activity.privatenotes = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                activity.costamt = [NSNumber numberWithInt:sqlite3_column_int(statement, 5)];
                activity.startdt = [activity GetDtFromString :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)]];
                activity.enddt = [activity GetDtFromString :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)]];
                activity.activitystate = [NSNumber numberWithInt:sqlite3_column_int(statement, 8)];
                //activity.poi = [self loadPoiImageData :activity.poi.key];
                [activitydata addObject:activity];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    } else {
        NSLog(@"Cannot open database");
    }
    
    return activitydata;
}

/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks:           state 1 = idea; state 2 = actual
 */

//poi = [[PoiNSO alloc] init];
-(PoiNSO*) LoadPoiImageData :(NSString*) RequiredKey {

    PoiNSO *poi = [[PoiNSO alloc] init];
    poi.key = RequiredKey;
    poi.Images = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT filename, keyimage FROM imageitem WHERE poikey='%@' and keyimage=1 LIMIT 1", RequiredKey];
        
        const char *select_statement = [selectSQL UTF8String];
        
        if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                PoiImageNSO *imgitem = [[PoiImageNSO alloc] init];
                imgitem.ImageFileReference = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                imgitem.KeyImage = sqlite3_column_int(statement, 1);
                imgitem.NewImage = false;
                [poi.Images addObject:imgitem];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    } else {
        NSLog(@"Cannot open database");
    }
    return poi;
};

/*
 created date:      02/05/2018
 last modified:     02/05/2018
 remarks:
 */
-(bool) DeleteProject :(ProjectNSO*) Project {
    
    bool returnValue = [self DeleteActivity:nil :Project.key];
    if (returnValue) {
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
        NSFileManager *fm = [NSFileManager defaultManager];
    
        NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",Project.imagefilereference]];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:dataPath error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", imagesDirectory, file] error:&error];
            if (!success || error) {
                NSLog(@"something failed in deleting unwanted data");
            }
        }
    
        sqlite3_stmt *statement;
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM project WHERE key = '%@'",Project.key];
        const char *dbpath = [_databasePath UTF8String];
    
        if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
            const char *deleteStatement = [deleteSQL UTF8String];
            sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to delete record from project");
                returnValue = false;
            } else {
                NSLog(@"Successfuly deleted record from project");
            }
            sqlite3_finalize(statement);
            sqlite3_close(_DB);
        }
    }
    return returnValue;
}

/*
 created date:      02/05/2018
 last modified:     02/05/2018
 remarks:
 */
-(bool) DeleteActivity :(ActivityNSO*) Activity :(NSString*) ProjectKey {
    
    bool returnValue = true;
    sqlite3_stmt *statement;
    NSString *deleteSQL;
    if (Activity==nil) {
        deleteSQL = [NSString stringWithFormat:@"DELETE FROM activity WHERE projectkey = '%@'",ProjectKey];
    } else {
        deleteSQL = [NSString stringWithFormat:@"DELETE FROM activity WHERE key = '%@'",Activity.key];
    }
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
        const char *deleteStatement = [deleteSQL UTF8String];
        sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to delete record from activity");
            returnValue = false;
        } else {
            NSLog(@"Successfuly deleted record from activity");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
    return returnValue;

}





/*
 created date:      02/05/2018
 last modified:     02/05/2018
 remarks:           
 */
-(bool) DeletePoi :(PoiNSO*) Poi {
    
    // we need to check if any activity is using the Poi
   
    if (Poi.connectedactivitycount > [NSNumber numberWithInt:0]) {
        return false;
    }
    
    // if no activity is linked with Poi - we firstly delete any images. that includes any that might exist on the file system.
    [self DeletePoiAttachments :Poi.key];
    // then we delete the Poi
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",Poi.key]];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:dataPath error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", imagesDirectory, file] error:&error];
        if (!success || error) {
            NSLog(@"something failed in deleting unwanted data");
        }
    }

    bool returnValue = true;
    sqlite3_stmt *statement;
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM poi WHERE key = '%@'",Poi.key];
    
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
        const char *deleteStatement = [deleteSQL UTF8String];
        sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to delete record from poi");
            returnValue = false;
        } else {
            NSLog(@"Successfuly deleted record from poi");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
    return returnValue;
}

/*
 created date:      02/05/2018
 last modified:     02/05/2018
 remarks:
 */
-(bool) DeletePoiAttachments :(NSString *) poikey {
    bool returnValue = true;
    sqlite3_stmt *statement;
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM imageitem WHERE poikey = '%@'",poikey];
    
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
        
        const char *deleteStatement = [deleteSQL UTF8String];
        sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to delete items from imageitem");
            returnValue = false;
        } else {
            NSLog(@"Successfuly deleted items from imageitem");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_DB);
    }
    return returnValue;
}



@end
