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
 last modified:     27/04/2018
 remarks:           Delete the database file cleanly
 */
-(void) Delete :(NSString*) databaseName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:databaseName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           Create a new database with model.
 */
-(bool)Create :(NSString*) databaseName {
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];

    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:databaseName]];
    
    NSLog(@"called create database");
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if([filemgr fileExistsAtPath:_databasePath] ==  NO) {
        
        const char *dbpath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
            char *errorMessage;

            
            /* PROJECT table */
            const char *sql_statement = "CREATE TABLE project (key TEXT PRIMARY KEY, title TEXT, imagelocation TEXT, notes TEXT)";
            
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
            sql_statement = "CREATE TABLE poi (key TEXT PRIMARY KEY, name TEXT, countrykey TEXT, categoryid INTEGER, lat DOUBLE, lon DOUBLE, FOREIGN KEY(countrykey) REFERENCES country(key))";
            
            
            if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                NSLog(@"failed to create poi table");
                sqlite3_close(_DB);
                return false;
            }

            /* POI table */
            sql_statement = "CREATE TABLE activity (projectkey TEXT, poikey TEXT, key TEXT PRIMARY KEY, name TEXT, totalprice INTEGER, notes TEXT, startdt TEXT, enddt TEXT, FOREIGN KEY(projectkey) REFERENCES project(key), FOREIGN KEY(poikey) REFERENCES poi(key))";
            
            
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
            sql_statement = "CREATE TABLE imageitem (filename TEXT, poikey TEXT, description TEXT, FOREIGN KEY(poikey) REFERENCES poi(key))";
            
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
 last modified:     28/04/2018
 remarks:
 */
-(bool)InsertPoiItem :(PoiNSO*)Poi {
    
    
    
    
    return true;
}

@end
