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
 last modified:     06/05/2018
 remarks:           Delete the database file cleanly
 */
-(void) DeleteDb {

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

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      23/06/2018
 last modified:     23/06/2018
 remarks:
 */
-(BOOL)checkColumnExists :(NSString*) column :(NSString*) table
{
    BOOL columnExists = NO;
    
    sqlite3_stmt *selectStmt;
    
    NSString *sqlStatement = [NSString stringWithFormat:@"select %@ from %@", column, table];
    
    const char *statement = [sqlStatement UTF8String];
    
    if(sqlite3_prepare_v2(_DB, statement, -1, &selectStmt, NULL) == SQLITE_OK)
        columnExists = YES;
    
    return columnExists;
}


/*
 created date:      27/04/2018
 last modified:     17/07/2018
 remarks:           Create a new database with model.
 */
-(bool)InitDb :(NSString*) databaseName {

    NSURL *fileURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseName];
    
    NSURL *fileImageURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Images" isDirectory:YES];
    
    NSURL *fileWikiDocsURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WikiDocs" isDirectory:YES];
    
    _databasePath = [[NSString alloc] initWithString:[fileURL path]];

    NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [_databasePath UTF8String];
    
    if([filemgr fileExistsAtPath:_databasePath] ==  NO) {
        if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
            [self CreateDb];
            [self LoadCountryData];
        }
        return true;
    } else {
        if (sqlite3_open(dbpath, &_DB) == SQLITE_OK) {
            /* manage images if database is reloaded and the files are not available */
            NSError *err;
            if ([fileImageURL checkResourceIsReachableAndReturnError:&err] == NO) {
                NSLog(@"No folder exists for Images");
                char *errorMessage;
                const char *sql_statement = "DELETE FROM imageitem";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to delete all content from imageitem table");
                }
                sql_statement = "UPDATE project set imagefilename=''";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to remove all image content from project data table");
                }
                [filemgr createDirectoryAtURL:fileImageURL
                withIntermediateDirectories:YES attributes:nil error:&err];
            }
            if ([fileWikiDocsURL checkResourceIsReachableAndReturnError:&err] == NO) {
                NSLog(@"No folder exists for WikiDocs");
                [filemgr createDirectoryAtURL:fileWikiDocsURL
                  withIntermediateDirectories:YES attributes:nil error:&err];
            }
            /* check any updates to the db since the last version */
            if (![self checkColumnExists:@"language" :@"country"] ) {
                char *errorMessage;

                const char *sql_statement = "DELETE FROM country";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to delete all content from country table");
                }
                
                sql_statement = "ALTER TABLE country ADD COLUMN language TEXT;";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to alter table new column");
                }
                
                [self LoadCountryData];
            }
            
            /* check any updates to the db since the last version */
            if (![self checkColumnExists:@"wikititle" :@"poi"] ) {
                char *errorMessage;
                const char *sql_statement = "ALTER TABLE poi ADD COLUMN wikititle TEXT;";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to alter table new column");
                }
                sql_statement = "UPDATE poi set wikititle='';";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to update wikititle in poi column");
                }
            }
            /*
            if (![self checkColumnExists:@"flagged" :@"poi"] ) {
                char *errorMessage;
                const char *sql_statement = "ALTER TABLE poi ADD COLUMN flagged INTEGER;";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to alter table new column");
                }
                sql_statement = "UPDATE poi set flagged=0;";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to update wikititle in poi column");
                }
            }
            if (![self checkColumnExists:@"created_dt" :@"poi"] ) {
                char *errorMessage;
                const char *sql_statement = "ALTER TABLE poi ADD COLUMN created_dt TEXT;";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to alter table new column");
                }
                sql_statement = "UPDATE poi set created_dt='';";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to update created_dt in poi column");
                }
            }
            if (![self checkColumnExists:@"modified_dt" :@"poi"] ) {
                char *errorMessage;
                const char *sql_statement = "ALTER TABLE poi ADD COLUMN modified_dt TEXT;";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to alter table new column");
                }
                sql_statement = "UPDATE poi set modified_dt='';";
                if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                    NSLog(@"failed to update modified_dt in poi column");
                }
            }
            */
            
            NSLocale *theLocale = [NSLocale currentLocale];
            NSString *currencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
            NSLog(@"Currency Code : %@",currencyCode);
            NSString *measurementSystem = [theLocale objectForKey:NSLocaleMeasurementSystem];
            NSLog(@"Measurement System: %@",measurementSystem);
            NSString *metricSystem = [theLocale objectForKey:NSLocaleUsesMetricSystem];
            NSLog(@"Metric System: %@",metricSystem);
            return true;
        }
        return false;
    }
}


/*
 created date:      06/05/2018
 last modified:     06/05/2018
 remarks:           Close database with model.
 */
-(void)CloseDb {
    sqlite3_close(_DB);
}

/*
 created date:      27/04/2018
 last modified:     13/07/2018
 remarks:           Create a new database with model.  We need to remove Country table, but there are still
 some code attached to it.
 */
-(bool)CreateDb {
    bool retVal=true;
        char *errorMessage;
        /* PROJECT table */
        const char *sql_statement = "CREATE TABLE project (key TEXT PRIMARY KEY, name TEXT, privatenotes TEXT, imagefilename TEXT)";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create project table");
            retVal=false;
        }

        /* COUNTRY table */
        sql_statement = "CREATE TABLE country (countrycode TEXT PRIMARY KEY, name TEXT, currency TEXT, language TEXT, capital TEXT, lat DOUBLE, lon DOUBLE)";

        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create country table");
            retVal=false;
        }
  
        /* POI table */
        sql_statement = "CREATE TABLE poi (key TEXT PRIMARY KEY, name TEXT, administrativearea TEXT, subadministrativearea TEXT, fullthoroughfare TEXT, countrycode TEXT, locality TEXT, sublocality TEXT, postcode TEXT, categoryid INTEGER, privatenotes TEXT, lat DOUBLE, lon DOUBLE, wikititle TEXT)";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create poi table");
            retVal=false;
        }

        /* ACTIVITY table */
        sql_statement = "CREATE TABLE activity (projectkey TEXT, poikey TEXT, key TEXT, name TEXT, totalprice INTEGER, notes TEXT, startdt TEXT, enddt TEXT, state INTEGER, PRIMARY KEY(key,state), FOREIGN KEY(projectkey) REFERENCES project(key), FOREIGN KEY(poikey) REFERENCES poi(key))";
            
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create activity table");
            retVal=false;
        }
            
        /* LEG table */
        sql_statement = "CREATE TABLE leg (activitykey TEXT, startpoikey TEXT, endpoikey TEXT, key TEXT PRIMARY KEY, label TEXT, transport INTEGER, startdt TEXT, enddt TEXT, FOREIGN KEY(activitykey) REFERENCES activity(key), FOREIGN KEY(startpoikey) REFERENCES poi(key), FOREIGN KEY(endpoikey) REFERENCES poi(key))";
            
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create leg table");
            retVal=false;
        }
            
        /* IMAGE table */
        sql_statement = "CREATE TABLE imageitem (filename TEXT, poikey TEXT, keyimage INTEGER, description TEXT, PRIMARY KEY (filename, poikey), FOREIGN KEY(poikey) REFERENCES poi(key))";
    
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create images table");
            retVal=false;
        }

        /* IMAGE table */
        sql_statement = "CREATE TABLE imagepayment (filename TEXT, paymentkey TEXT, keyimage INTEGER, description TEXT, PRIMARY KEY (filename, paymentkey), FOREIGN KEY(paymentkey) REFERENCES payment(key))";
    
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create imagepayment table");
            retVal=false;
        }

        /* EXCHANGERATE table */
        sql_statement = "CREATE TABLE exchangerate (currencycode TEXT, homecurrencycode TEXT, rate INTEGER, dt TEXT, PRIMARY KEY (currencycode, homecurrencycode, dt))";
        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create exchangerate table");
        }
    
        /* PAYMENT table */
        sql_statement = "CREATE TABLE payment (projectkey TEXT, activitykey TEXT, key TEXT PRIMARY KEY, description TEXT, state INTEGER, amt_est INTEGER, amt_act INTEGER,  localcurrencycode TEXT, dt_est TEXT, dt_act TEXT, FOREIGN KEY(projectkey) REFERENCES project(key), FOREIGN KEY(activitykey) REFERENCES activity(key))";

        if(sqlite3_exec(_DB, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
            NSLog(@"failed to create payment table");
        }

    return retVal;
}


/*
 created date:      08/05/2018
 last modified:     14/06/2018
 remarks:
 */
-(bool)LoadCountryData {
    NSDictionary *dict = [self JSONFromFile];
    
    for (NSDictionary *country in dict) {
        NSString *Name = [country objectForKey:@"name"];
        NSString *CountryCode = [country objectForKey:@"alpha2Code"];
        NSString *Capital = [country objectForKey:@"capital"];
        NSArray *LatLng = [country objectForKey:@"latlng"];
        NSArray *Currencies = [country objectForKey:@"currencies"];
        if (Currencies.count>0) {
            NSString *CurrencyCode;
            for (NSDictionary *currency in Currencies) {
                CurrencyCode = [currency objectForKey:@"code"];
                break;
            }
            NSArray *Languages = [country objectForKey:@"languages"];
            NSString *LanguageCode = @"";
            if (Languages.count>0) {
                for (NSDictionary *language in Languages) {
                    LanguageCode = [language objectForKey:@"iso639_1"];
                    break;
                }
            }
            
            if (LatLng.count==2) {
                double Lat = [[LatLng objectAtIndex:0] doubleValue];
                double Lon = [[LatLng objectAtIndex:1] doubleValue];
                
                [self InsertCountry :CountryCode  :Name :CurrencyCode :LanguageCode :Capital :[NSNumber numberWithDouble:Lat] :[NSNumber numberWithDouble:Lon]];
            } else {
                NSLog(@"Skipping %@ as no coordinates attached", Name);
            }
        } else {
            NSLog(@"Skipping %@ as no currency attached", Name);
        }
    }
    
    return true;
}

/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (NSDictionary *)JSONFromFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}




/*
 created date:      27/04/2018
 last modified:     14/06/2018
 remarks:
 */
-(bool)InsertCountry :(NSString*)CountryCode :(NSString*)Name :(NSString*)CurrencyCode :(NSString*)Language :(NSString*)Capital :(NSNumber*) Lat :(NSNumber*) Lon {
    bool retVal=true;

    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(_DB, "INSERT INTO country (countrycode, name, currency, language, capital, lon, lat) VALUES (?,?,?,?,?,?,?)", -1, &stmt, nil);
    
    sqlite3_bind_text(stmt, 1, CountryCode==nil?"":[CountryCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, Name==nil?"":[Name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, CurrencyCode==nil?"":[CurrencyCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, Language==nil?"":[Language UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 5, Capital==nil?"":[Capital UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(stmt, 6, [Lat doubleValue]);
    sqlite3_bind_double(stmt, 7, [Lon doubleValue]);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Failed to insert new record %@ inside country table", Name);
        retVal = false;
    } else {
         NSLog(@"inserted new country record %@ inside table!", Name);
    }
    sqlite3_finalize(stmt);
    return retVal;
}




/*
 created date:      28/04/2018
 last modified:     03/06/2018
 remarks:           TODO add new way of inserting parms
 */
-(bool) UpdatePoiItem :(PoiNSO*) Poi {
    bool retVal=true;
    
    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(_DB, "UPDATE poi SET name = ?, categoryid = ?, privatenotes = ?, wikititle = ? WHERE key=?", -1, &stmt, nil);
    
    sqlite3_bind_text(stmt, 1, Poi.name==nil?"":[Poi.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 2, [Poi.categoryid intValue]);
    sqlite3_bind_text(stmt, 3, Poi.privatenotes==nil?"":[Poi.privatenotes UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, Poi.wikititle==nil?"":[Poi.wikititle UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 5, Poi.key==nil?"":[Poi.key UTF8String], -1, SQLITE_TRANSIENT);

    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Failed to update record(s) inside poi table");
        retVal = false;
    }
    [self InsertImages :Poi];
    [self UpdatePoiImages :Poi];
    sqlite3_finalize(stmt);
    
    return retVal;
}

/*
 created date:      29/04/2018
 last modified:     13/05/2018
 remarks:           TODO add new way of inserting parms
 */
-(bool) UpdateProjectItem :(ProjectNSO*) Project {
    bool retVal=true;
        sqlite3_stmt *statement;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE project SET name = '%@', privatenotes = '%@', imagefilename = '%@' WHERE key='%@'", Project.name, Project.privatenotes, Project.imagefilereference, Project.key];
        
        const char *update_statement = [updateSQL UTF8String];
        sqlite3_prepare_v2(_DB, update_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to update record(s) inside project table");
            retVal = false;
        }
        sqlite3_finalize(statement);
    
    return retVal;
}

/*
 created date:      30/04/2018
 last modified:     06/05/2018
 remarks:           TODO add new way of inserting parms
 */
-(bool) UpdateActivityItem :(ActivityNSO*) Activity {
    bool retVal=true;
        sqlite3_stmt *statement;

        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE activity SET name = '%@', notes = '%@', poikey = '%@', totalprice = '%d', startdt = '%@', enddt = '%@', state = %@ WHERE key='%@' and state=%@", Activity.name, Activity.privatenotes, Activity.poi.key, 100, [Activity GetStringFromDt :Activity.startdt], [Activity GetStringFromDt :Activity.enddt], Activity.activitystate, Activity.key, Activity.activitystate];
        
        const char *update_statement = [updateSQL UTF8String];
        sqlite3_prepare_v2(_DB, update_statement, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to update record(s) inside activity table");
            retVal = false;
        }
        sqlite3_finalize(statement);
    
    return retVal;
}

/*
 created date:      28/04/2018
 last modified:     06/05/2018
 remarks:           TODO add new way of inserting parms
 */
-(bool)InsertImages :(PoiNSO*) Poi {
    /* Images table */
    bool retVal = true;

        for (PoiImageNSO *imageitem in Poi.Images) {
            if (imageitem.NewImage) {
            
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO imageitem (filename, poikey, keyimage, description) VALUES ('%@','%@',%d ,'%@')", imageitem.ImageFileReference, Poi.key, imageitem.KeyImage, @"test"];
                sqlite3_stmt *statement;
                const char *insert_statement = [insertSQL UTF8String];
                sqlite3_prepare_v2(_DB, insert_statement, -1, &statement, NULL);
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    NSLog(@"Failed to insert new record inside imageitem table");
                    retVal = false;
                } else {
                    NSLog(@"Inserted new imageitem record inside table!");
                }
                sqlite3_finalize(statement);
            }
        }

    return retVal;
}

/*
 created date:      21/05/2018
 last modified:     21/05/2018
 remarks:           TODO add new way of inserting parms
 */
-(bool)UpdatePoiImages :(PoiNSO*) Poi {
    /* Images table */
    bool retVal = true;
    
    for (PoiImageNSO *imageitem in Poi.Images) {
        if (imageitem.UpdateImage) {
            
            NSString *insertSQL = [NSString stringWithFormat:@"UPDATE imageitem set keyimage=%d, description='%@' WHERE filename='%@'", imageitem.KeyImage, @"test", imageitem.ImageFileReference];
            sqlite3_stmt *statement;
            const char *update_statement = [insertSQL UTF8String];
            sqlite3_prepare_v2(_DB, update_statement, -1, &statement, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to update record inside imageitem table");
                retVal = false;
            } else {
                NSLog(@"Updated imageitem record inside table!");
            }
            sqlite3_finalize(statement);
        }
    }
    
    return retVal;
}




/*
 created date:      28/04/2018
 last modified:     07/05/2018
 remarks: using proper insertion of Poi character data.
 */
-(bool)InsertPoiItem :(PoiNSO*)Poi {

    bool retVal = true;
   
        Poi.key = [[NSUUID UUID] UUIDString];

        sqlite3_stmt *stmt = NULL;
        sqlite3_prepare_v2(_DB, "INSERT INTO poi (key, name, administrativearea, subadministrativearea, fullthoroughfare, countrycode, locality, sublocality, postcode, categoryid, privatenotes, lat, lon, wikititle) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", -1, &stmt, nil);
    
        sqlite3_bind_text(stmt, 1, [Poi.key UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [Poi.name UTF8String], -1, SQLITE_TRANSIENT);
    
        sqlite3_bind_text(stmt, 3, Poi.administrativearea==nil?"":[Poi.administrativearea UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 4, Poi.subadministrativearea==nil?"":[Poi.subadministrativearea UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 5, Poi.fullthoroughfare==nil?"":[Poi.fullthoroughfare UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 6, Poi.countrycode==nil?"":[Poi.countrycode UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 7, Poi.locality==nil?"":[Poi.locality UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 8, Poi.sublocality==nil?"":[Poi.sublocality UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 9, Poi.postcode==nil?"":[Poi.postcode UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 10, [Poi.categoryid intValue]);
        sqlite3_bind_text(stmt, 11, [Poi.privatenotes UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(stmt, 12, [Poi.lat doubleValue]);
        sqlite3_bind_double(stmt, 13, [Poi.lon doubleValue]);
        sqlite3_bind_text(stmt, 14, Poi.wikititle==nil?"":[Poi.wikititle UTF8String], -1, SQLITE_TRANSIENT);

        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"Failed to insert new record inside poi table");
            retVal = false;
        } else {
            NSLog(@"inserted new poi record inside table!");
        }
        sqlite3_finalize(stmt);
        [self InsertImages :Poi];
    
    return retVal;
}

/*
 created date:      29/04/2018
 last modified:     06/05/2018
 remarks: Flat table with single image representing the project.
 */
-(bool) InsertProjectItem :(ProjectNSO*) Project {
    bool retVal = true;
  
        /* PROJECT table */
        
        sqlite3_stmt *stmt = NULL;
        sqlite3_prepare_v2(_DB, "INSERT INTO project (key, name, privatenotes, imagefilename) VALUES (?,?,?,?)", -1, &stmt, nil);
        sqlite3_bind_text(stmt, 1, [Project.key UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [Project.name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [Project.privatenotes UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt,4,  [Project.imagefilereference UTF8String], -1, SQLITE_TRANSIENT);

        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"Failed to insert new record inside project table");
            retVal = false;
        } else {
            NSLog(@"inserted new project record inside table!");
        }
        sqlite3_finalize(stmt);

    return retVal;
}


/* todo     bool ReturnVal = true;
 if([self OpenDb]) { */

/*
 created date:      30/04/2018
 last modified:     06/05/2018
 remarks: Flat table with single image representing the project.
 */
-(bool) InsertActivityItem :(ActivityNSO*) Activity {
    bool retVal = true;
   
        sqlite3_stmt *stmt = NULL;
        sqlite3_prepare_v2(_DB, "INSERT INTO activity (projectkey, poikey, key, name, totalprice, notes, startdt, enddt, state) VALUES (?,?,?,?,?,?,?,?,?)", -1, &stmt, nil);
        sqlite3_bind_text(stmt, 1, [Activity.project.key UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [Activity.poi.key UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [Activity.key UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 4, [Activity.name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt,5, [Activity.costamt intValue]);
        sqlite3_bind_text(stmt, 6, [Activity.privatenotes UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 7, [[Activity GetStringFromDt :Activity.startdt] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 8, [[Activity GetStringFromDt :Activity.enddt] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt,9, [Activity.activitystate intValue]);
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"Failed to insert new record inside activity table");
            retVal = false;
        } else {
            NSLog(@"inserted new activity record inside table!");
        }
        sqlite3_finalize(stmt);
    
    return retVal;
}





/*
 created date:      28/04/2018
 last modified:     13/07/2018
 remarks:           TODO add new way of inserting parms
 */
-(NSMutableArray*) GetPoiContent :(NSString*) RequiredKey :(NSArray*) Countries :(NSString*) FilterOption {
    NSMutableArray *poidata  = [[NSMutableArray alloc] init];
   
        NSString *whereClause = @"";
            
        if (RequiredKey != nil) {
            whereClause = @"WHERE";
            whereClause = [NSString stringWithFormat:@"%@ %@='%@'", whereClause, @"key",RequiredKey];
        } else if (FilterOption != nil) {
            if ([FilterOption isEqualToString:@"unused"]) {
                whereClause = @"WHERE";
                whereClause = [NSString stringWithFormat:@"%@ %@", whereClause, @"p.key NOT IN (SELECT DISTINCT poikey FROM activity)"];
            }
        } else if (Countries != nil) {
            
            whereClause = @"WHERE";
            whereClause = [NSString stringWithFormat:@"%@ %@ IN (%@)", whereClause, @"countrycode", [Countries componentsJoinedByString:@ ","]];
        }
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT key,name,fullthoroughfare,administrativearea,subadministrativearea,countrycode,locality,sublocality,postcode,categoryid,privatenotes,lat,lon,wikititle,(select count(*) as counter from activity a where a.poikey=p.key) as sumofactivities FROM poi p %@ ORDER BY name", whereClause];
        sqlite3_stmt *statement;
        const char *select_statement = [selectSQL UTF8String];
    
    
    
        if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                PoiNSO *poi = [self LoadPoiImageData :[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)]];
                poi.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                poi.fullthoroughfare = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(statement, 2)];
                poi.administrativearea = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                poi.subadministrativearea = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                poi.countrycode = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                poi.locality = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
                poi.sublocality = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
                poi.postcode = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
                poi.categoryid = [NSNumber numberWithInt:sqlite3_column_int(statement, 9)];
                poi.privatenotes = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)];
                poi.lat = [NSNumber numberWithDouble:sqlite3_column_double(statement, 11)];
                poi.lon = [NSNumber numberWithDouble:sqlite3_column_double(statement, 12)];
                poi.wikititle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 13)];
                poi.connectedactivitycount = [NSNumber numberWithInt:sqlite3_column_int(statement, 14)];
                poi.Images = [NSMutableArray arrayWithArray:[self GetImagesForSelectedPoi:poi.key]];
                CountryNSO *country = [self GetCountryByCode:poi.countrycode];
                poi.country = country.name;
                poi.searchstring = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",poi.name,poi.administrativearea,poi.subadministrativearea,poi.postcode,poi.locality,poi.sublocality,poi.country];
                [poidata addObject:poi];
            }
        }
        sqlite3_finalize(statement);

    return poidata;
}


/*
 created date:      07/05/2018
 last modified:     14/06/2018
 remarks:           TODO add new way of inserting parms
 */
-(CountryNSO *) GetCountryByCode :(NSString*) CountryCode {
    sqlite3_stmt *statement;
    CountryNSO *country = [[CountryNSO alloc] init];
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT name, currency, language, capital, lon, lat FROM country WHERE countrycode='%@' LIMIT 1", CountryCode];
    const char *select_statement = [selectSQL UTF8String];
    
    if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            country.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            country.currency = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            country.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            country.capital = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            country.lat = [NSNumber numberWithDouble:sqlite3_column_double(statement, 4)];
            country.lon = [NSNumber numberWithDouble:sqlite3_column_double(statement, 5)];
        }
    }
    sqlite3_finalize(statement);
    return country;
};



/*
 created date:      29/04/2018
 last modified:     06/05/2018
 remarks:           TODO add new way of inserting parms
 */
-(NSMutableArray*) GetProjectContent :(NSString*) RequiredKey {
    NSMutableArray *projectdata  = [[NSMutableArray alloc] init];
    
        sqlite3_stmt *statement;

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
                project = [self GetProjectDateRanges :project];
                [projectdata addObject:project];
            }
        }
        sqlite3_finalize(statement);

    return projectdata;
}


/*
 created date:      27/05/2018
 last modified:     27/05/2018
 remarks:           we need to handle state of activities.  is the startdt actual or planned?
 */
-(ProjectNSO*) GetProjectDateRanges :(ProjectNSO*) project {
    sqlite3_stmt *statement;
    //NSString *selectSQL = [NSString stringWithFormat:@"SELECT IFNULL(MIN(startdt),''), IFNULL(MAX(enddt),''), COUNT(1) FROM activity where projectkey = '%@'", project.key];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT IFNULL(MIN(startdt),''), IFNULL(MAX(enddt),''), (select count(1) from (select key from activity where projectkey='%@' and state = 0) t1 LEFT JOIN (select key from activity where projectkey='%@' and state = 1) t2 ON t2.key = t1.key WHERE t2.key IS NULL), (select count(1) from (select key from activity where projectkey='%@' and state = 1) t1 LEFT JOIN (select key from activity where projectkey='%@' and state = 0) t2 ON t2.key = t1.key WHERE t2.key IS NULL), (select count (1) from (select count(1) as sum from activity where projectkey='%@' group by key) data where data.sum = 2) FROM activity where projectkey = '%@'", project.key, project.key, project.key, project.key, project.key, project.key];

    const char *select_statement = [selectSQL UTF8String];
    
    if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            project.startdt = [project GetDtFromString :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
            project.enddt = [project GetDtFromString :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
            project.numberofactivitiesonlyplanned = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
            project.numberofactivitiesonlyactual = [NSNumber numberWithInt:sqlite3_column_int(statement, 3)];
            project.numberofactivities = [NSNumber numberWithInt:sqlite3_column_int(statement, 4)];
        }
    }
    
    
    /*
     GET PLANNED ITEMS WITHOUT ACTUAL
     select count(1) from (select key from activity where projectkey='F0EC24F9-D8DB-483C-9F64-3EA49F008966' and state = 0) t1 LEFT JOIN (select key from activity where projectkey='F0EC24F9-D8DB-483C-9F64-3EA49F008966' and state = 1) t2 ON t2.key = t1.key WHERE t2.key IS NULL
     
     GET ACTUAL WITHOUT PLANNED
     select count(1) from (select key from activity where projectkey='F0EC24F9-D8DB-483C-9F64-3EA49F008966' and state = 1) t1 LEFT JOIN (select key from activity where projectkey='F0EC24F9-D8DB-483C-9F64-3EA49F008966' and state = 0) t2 ON t2.key = t1.key WHERE t2.key IS NULL
     
     GET PLANNED ITEMS THAT WERE MADE
     select count (1) from (select count(1) as sum from activity where projectkey='F0EC24F9-D8DB-483C-9F64-3EA49F008966' group by key) data where data.sum=2
     
     
     
     */
    
    
    sqlite3_finalize(statement);
    return project;
}

/*
 created date:      30/04/2018
 last modified:     06/05/2018
 remarks:  Only need to retrieve one record here.  TODO add new way of inserting parms
 */
-(ActivityNSO*) GetActivityContent :(NSString*) RequiredKey {
    
    ActivityNSO *activity = [[ActivityNSO alloc] init];

        sqlite3_stmt *statement;

        NSString *selectSQL = [NSString stringWithFormat:@"SELECT projectkey, poikey, key, name, notes, totalprice, startdt, enddt, state FROM activity WHERE key='%@' ORDER BY startdt", RequiredKey];
        
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

    return activity;
}


/*
 created date:      29/04/2018
 last modified:     06/05/2018
 remarks:
 */
-(NSMutableArray *)GetImagesForSelectedPoi :(NSString *) RequiredKey {
    NSMutableArray *ImagesDataSet = [[NSMutableArray alloc] init];

        sqlite3_stmt *statement;

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

    return ImagesDataSet;
}

/*
 created date:      01/05/2018
 last modified:     28/05/2018
 remarks:           state 1 = idea; state 2 = actual  - TODO add new way of inserting parms
 */
-(NSMutableArray*) GetActivityListContentForState :(NSString*) RequiredProjectKey :(NSNumber*) RequiredState {
    NSMutableArray *activitydata  = [[NSMutableArray alloc] init];

        sqlite3_stmt *statement;

        NSString *selectSQL;

        if ([RequiredState intValue] == 0) {
            /* Ideas */
            selectSQL = [NSString stringWithFormat:@"SELECT act.projectkey, act.poikey, act.key, act.name, act.notes, act.totalprice, act.startdt, act.enddt, act.state, (select count(1) from activity data where data.key=act.key group by data.key), poi.categoryid FROM activity act, poi WHERE act.projectkey='%@' AND act.state=0 AND act.poikey = poi.key ORDER BY act.startdt", RequiredProjectKey];
        }
        else
        {
            
            selectSQL = [NSString stringWithFormat:@"SELECT act.projectkey, act.poikey, act.key, act.name, act.notes, act.totalprice, act.startdt, act.enddt, act.state, (SELECT COUNT(1) FROM activity ds WHERE ds.key=act.key GROUP BY ds.key), poi.categoryid FROM activity act, poi, (SELECT MAX(state) AS maxstate, key FROM activity GROUP BY key) data WHERE act.key=data.key AND act.state=data.maxstate AND act.projectkey='%@' AND act.poikey = poi.key ORDER BY act.state desc, act.startdt", RequiredProjectKey];
            
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
                activity.legendref = [NSNumber numberWithInt:sqlite3_column_int(statement, 9)];
                activity.poi.categoryid = [NSNumber numberWithInt:sqlite3_column_int(statement, 10)];
                [activitydata addObject:activity];
            }
        }
        sqlite3_finalize(statement);

    return activitydata;
}

/*
 created date:      01/05/2018
 last modified:     06/05/2018
 remarks:           state 1 = idea; state 2 = actual
 */

//poi = [[PoiNSO alloc] init];
-(PoiNSO*) LoadPoiImageData :(NSString*) RequiredKey {

    PoiNSO *poi = [[PoiNSO alloc] init];
    poi.key = RequiredKey;
    poi.Images = [[NSMutableArray alloc] init];

        sqlite3_stmt *statement;

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
    return poi;
};

/*
 created date:      02/05/2018
 last modified:     20/05/2018
 remarks:
 */
-(bool) DeleteProject :(ProjectNSO*) Project {
    bool retVal = true;

    retVal = [self DeleteActivity:nil :Project.key];
        if (retVal) {
    
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
            NSFileManager *fm = [NSFileManager defaultManager];
    
            if (![Project.imagefilereference isEqualToString:@""]) {
                NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",Project.imagefilereference]];
                NSError *error = nil;
                for (NSString *file in [fm contentsOfDirectoryAtPath:dataPath error:&error]) {
                    BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", imagesDirectory, file] error:&error];
                    if (!success || error) {
                        NSLog(@"something failed in deleting unwanted data");
                        retVal = false;
                    }
                }
            }
            
            /* delete all references of project in payment table */
            sqlite3_stmt *statement;
            NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM payment WHERE projectkey = '%@'",Project.key];
            const char *deleteStatement = [deleteSQL UTF8String];
            sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to delete project record from payment");
                retVal = false;
            } else {
                NSLog(@"Successfuly deleted project record from payment");
            }
            sqlite3_finalize(statement);
            
            /* finally we can delete project safely */
            deleteSQL = [NSString stringWithFormat:@"DELETE FROM project WHERE key = '%@'",Project.key];
            deleteStatement = [deleteSQL UTF8String];
            sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to delete record from project");
                retVal = false;
            } else {
                NSLog(@"Successfuly deleted record from project");
            }
            sqlite3_finalize(statement);
        }
    return retVal;
}

/*
 created date:      02/05/2018
 last modified:     12/05/2018
 remarks:
 */
-(bool) DeleteActivity :(ActivityNSO*) Activity :(NSString*) ProjectKey {

    bool retVal = true;
        sqlite3_stmt *statement;
        NSString *deleteSQL;
        if (Activity==nil) {
            deleteSQL = [NSString stringWithFormat:@"DELETE FROM activity WHERE projectkey = '%@'",ProjectKey];
        } else {
            deleteSQL = [NSString stringWithFormat:@"DELETE FROM activity WHERE key = '%@' AND state=%@",Activity.key, Activity.activitystate];
        }

        const char *deleteStatement = [deleteSQL UTF8String];
        sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to delete record from activity");
            retVal = false;
        } else {
            NSLog(@"Successfuly deleted record from activity");
        }
        sqlite3_finalize(statement);

    return retVal;
}

/*
 created date:      02/05/2018
 last modified:     06/05/2018
 remarks:           
 */
-(bool) DeletePoi :(PoiNSO*) Poi {
    bool retVal = true;

        // we need to check if any activity is using the Poi
        if (Poi.connectedactivitycount > [NSNumber numberWithInt:0]) {
            retVal =  false;
        } else {
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
                    retVal = false;
                }
            }

            sqlite3_stmt *statement;
            NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM poi WHERE key = '%@'",Poi.key];

            const char *deleteStatement = [deleteSQL UTF8String];
            sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
        
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to delete record from poi");
                retVal = false;
            } else {
                NSLog(@"Successfuly deleted record from poi");
            }
            sqlite3_finalize(statement);
        }

    return retVal;
}

/*
 created date:      02/05/2018
 last modified:     06/05/2018
 remarks:
 */
-(bool) DeletePoiAttachments :(NSString *) poikey {

    bool retVal = true;

        sqlite3_stmt *statement;
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM imageitem WHERE poikey = '%@'",poikey];
        const char *deleteStatement = [deleteSQL UTF8String];
        sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to delete items from imageitem");
            retVal = false;
        } else {
            NSLog(@"Successfuly deleted items from imageitem");
        }
        sqlite3_finalize(statement);

    return retVal;
}



/*
 created date:      05/05/2018
 last modified:     19/05/2018
 remarks:
 */
-(NSMutableArray*) GetActivitySchedule :(NSString *) ProjectKey :(NSNumber *) RequiredState {

    NSMutableArray *activityschedulelist  = [[NSMutableArray alloc] init];

        sqlite3_stmt *statement;
        NSString *selectSQL;
        if (RequiredState == [NSNumber numberWithLong:0]) {
           selectSQL = [NSString stringWithFormat:@"select activity.key, activity.name, activity.startdt as dt, 'open' as legtype, activity.state from activity where projectkey = '%@' and activity.state = 0 union select activity.key, activity.name, activity.enddt as dt, 'close' as legtype, activity.state from activity where projectkey = '%@' and activity.state = 0 order by dt", ProjectKey, ProjectKey];
        } else {
            selectSQL = [NSString stringWithFormat:@"select activity.key, activity.name, activity.startdt as dt, 'open' as legtype, activity.state from activity, (select max(state) as maxstate, key from activity group by key) data where projectkey = '%@'  and activity.state = data.maxstate union select activity.key, activity.name, activity.enddt as dt, 'close' as legtype, activity.state from activity, (select max(state) as maxstate, key from activity group by key) data where projectkey = '%@' and activity.state = data.maxstate order by dt", ProjectKey, ProjectKey];
        }
        
        const char *select_statement = [selectSQL UTF8String];
        if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
        {
            int index = 0;
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                ScheduleNSO *schedule = [[ScheduleNSO alloc] init];
                schedule.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                schedule.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                schedule.dt = [schedule GetDtFromString :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
                
                schedule.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];

                if([schedule.type isEqualToString:@"open"]) {
                    index ++;
                    schedule.hierarcyindex = index;
                } else {
                    schedule.hierarcyindex = index;
                    index --;
                }
                schedule.activitystate = [NSNumber numberWithInt:sqlite3_column_int(statement, 4)];
                [activityschedulelist addObject:schedule];
                
            }
        }
        sqlite3_finalize(statement);

    return activityschedulelist;
 }

/*
 created date:      09/05/2018
 last modified:     16/05/2018
 remarks:
 */
-(NSMutableArray*) GetPaymentListContent :(ProjectNSO*) Project :(ActivityNSO *) Activity{
    NSMutableArray *activitypaymentlist  = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    NSString *selectSQL;
    NSString *whereClause=@"";

    if (Project != nil) {
        selectSQL = [NSString stringWithFormat:@"select p.key, p.description, p.amt_est, p.amt_act, p.localcurrencycode, p.dt_est, p.dt_act, p.state, (select name from activity a where a.key=p.activitykey LIMIT 1) name from payment p  WHERE p.projectkey = '%@'",Project.key];
    } else if (Activity != nil) {
        whereClause = @"WHERE";
        whereClause = [NSString stringWithFormat:@"%@ %@='%@'", whereClause, @"activitykey",Activity.key];
        selectSQL = [NSString stringWithFormat:@"select key, description, amt_est, amt_act, localcurrencycode, dt_est, dt_act, state from payment %@", whereClause];
    }

    const char *select_statement = [selectSQL UTF8String];
    if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            PaymentNSO *payment = [[PaymentNSO alloc] init];

            payment.key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            payment.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            payment.amt_est = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
            payment.amt_act = [NSNumber numberWithInt:sqlite3_column_int(statement, 3)];
            
            payment.localcurrencycode = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            payment.date_est = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            payment.date_act = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            
            if (payment.amt_est != 0) {
                payment.rate_est = [self GetExchangeRate:payment.localcurrencycode :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)]];
            }
            if (payment.amt_act != 0) {
                payment.rate_act = [self GetExchangeRate:payment.localcurrencycode :[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)]];
            }
            payment.status = [NSNumber numberWithInt:sqlite3_column_int(statement, 7)];
            if (Project != nil) {
                payment.activityname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
            }
            [activitypaymentlist addObject:payment];
        }
    }
    
    sqlite3_finalize(statement);
    return activitypaymentlist;
}

/*
 created date:      09/05/2018
 last modified:     14/05/2018
 remarks:  Issue here in update process
 */
-(NSNumber*) GetExchangeRate :(NSString *) LocalCurrencyCode :(NSString *) PaymentDt  {

    NSNumber *rate = [[NSNumber alloc] initWithInt:0];
    
    sqlite3_stmt *statement;
    NSString *selectSQL;
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *HomeCurrencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    
    if ([HomeCurrencyCode isEqualToString:LocalCurrencyCode]) {
        return [NSNumber numberWithInt:1];
    }

    selectSQL = [NSString stringWithFormat:@"select rate from exchangerate where currencycode='%@' and homecurrencycode='%@' and dt='%@'", LocalCurrencyCode, HomeCurrencyCode, PaymentDt];
    
    const char *select_statement = [selectSQL UTF8String];
    if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            rate = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
        }
    }

    sqlite3_finalize(statement);
    return rate;
}





/*
 created date:      14/05/2018
 last modified:     14/05/2018
 remarks:
 */
-(NSMutableArray*) GetProjectCountries :(NSString*) RequiredProjectKey {
    NSMutableArray *countries  = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    NSString *selectSQL;
    
    selectSQL = [NSString stringWithFormat:@"SELECT DISTINCT countrycode from poi, activity where poi.key = activity.poikey AND activity.projectkey='%@'", RequiredProjectKey];
    
    const char *select_statement = [selectSQL UTF8String];

    if (sqlite3_prepare_v2(_DB, select_statement, -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *country = [NSString stringWithFormat:@"'%@'",[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
            [countries addObject:country];
        }
    }

    return countries;
}

/*
 created date:      14/05/2018
 last modified:     15/05/2018
 remarks:
 */
-(bool) InsertExchangeRate :(NSString*) LocalCurrencyCode :(NSString*) DateValue :(NSNumber*) Rate {
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *HomeCurrencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    
    bool retVal = true;
    
    double adjustedRate = [Rate doubleValue] * 10000;
    int FormattedRate = (int)adjustedRate;
    
    
    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(_DB, "INSERT INTO exchangerate (currencycode, homecurrencycode, rate, dt) VALUES (?,?,?,?)", -1, &stmt, nil);
    sqlite3_bind_text(stmt, 1, [LocalCurrencyCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [HomeCurrencyCode UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt,3, (FormattedRate));
    sqlite3_bind_text(stmt, 4, [DateValue UTF8String], -1, SQLITE_TRANSIENT);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Failed to insert new record inside exchangerate table");
        retVal = false;
    } else {
        NSLog(@"inserted new exchangerate record inside table!");
    }
    sqlite3_finalize(stmt);
    
    return retVal;
}

/*
 created date:      14/05/2018
 last modified:     16/05/2018
 remarks:
 */
-(bool) InsertPayment :(PaymentNSO*) Payment :(ActivityNSO*) Activity {
    bool retVal = true;

    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(_DB, "INSERT INTO payment (projectkey, activitykey, key, description, amt_est, amt_act, localcurrencycode, dt_est, dt_act) VALUES (?,?,?,?,?,?,?,?,?)", -1, &stmt, nil);
    sqlite3_bind_text(stmt, 1, [Activity.project.key UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [Activity.key UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, [Payment.key UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, [Payment.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 5, [Payment.amt_est intValue]);
    sqlite3_bind_int(stmt, 6, [Payment.amt_act intValue]);
    sqlite3_bind_text(stmt, 7, [Payment.localcurrencycode UTF8String], -1, SQLITE_TRANSIENT);
     sqlite3_bind_text(stmt, 8, [Payment.date_est UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 9, [Payment.date_act UTF8String], -1, SQLITE_TRANSIENT);
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Failed to insert new record inside payment table");
        retVal = false;
    } else {
        NSLog(@"inserted new payment record inside table!");
    }
    sqlite3_finalize(stmt);
    
    return retVal;
    
}

/*
 created date:      16/05/2018
 last modified:     16/05/2018
 remarks:           update existing payment record
 */
-(bool) UpdatePaymentItem :(PaymentNSO*) Payment {
    bool retVal=true;
    sqlite3_stmt *statement;
   
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE payment SET description = '%@', amt_est = %@, amt_act = %@, localcurrencycode = '%@', dt_est = '%@', dt_act = '%@' WHERE key='%@'", Payment.description, Payment.amt_est, Payment.amt_act, Payment.localcurrencycode, Payment.date_est, Payment.date_act, Payment.key];
    
    const char *update_statement = [updateSQL UTF8String];
    sqlite3_prepare_v2(_DB, update_statement, -1, &statement, NULL);
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Failed to update record(s) inside payment table");
        retVal = false;
    }
    sqlite3_finalize(statement);
    
    return retVal;
}


/*
 created date:      15/05/2018
 last modified:     15/05/2018
 remarks:
 */
-(bool) DeletePayment :(PaymentNSO*) Payment {
    
    bool retVal = true;
    
    sqlite3_stmt *statement;
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM payment WHERE key = '%@'",Payment.key];
    const char *deleteStatement = [deleteSQL UTF8String];
    sqlite3_prepare_v2(_DB, deleteStatement, -1, &statement, NULL);
    
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Failed to delete payment from imageitem");
        retVal = false;
    } else {
        NSLog(@"Successfuly deleted items from payment");
    }
    sqlite3_finalize(statement);
    
    return retVal;
    
}


@end
