//
//  RealmDAL.m
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "RealmDAL.h"

@implementation RealmDAL

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
 created date:      30/08/2018
 last modified:     30/08/2018
 remarks:
 */
-(bool)LoadCountryData :(RLMRealm*) realm {

    NSDictionary *dict = [self JSONFromFile];
    
    for (NSDictionary *country in dict) {
        
        CountryRLM *c = [[CountryRLM alloc] init];
        
        c.name = [country objectForKey:@"name"];
        c.code = [country objectForKey:@"alpha2Code"];
        c.capital = [country objectForKey:@"capital"];
        NSArray *LatLng = [country objectForKey:@"latlng"];
        NSArray *Currencies = [country objectForKey:@"currencies"];
        if (Currencies.count>0) {
            
            for (NSDictionary *currency in Currencies) {
                c.currency = [currency objectForKey:@"code"];
                break;
            }
            NSArray *Languages = [country objectForKey:@"languages"];
            c.language = @"";
            if (Languages.count>0) {
                for (NSDictionary *language in Languages) {
                    c.language = [language objectForKey:@"iso639_1"];
                    break;
                }
            }
            
            if (LatLng.count==2) {
                c.lat = [LatLng objectAtIndex:0];
                c.lon = [LatLng objectAtIndex:1];
                [realm beginWriteTransaction];
                [realm addObject:c];
                [realm commitWriteTransaction];
            } else {
                NSLog(@"Skipping %@ as no coordinates attached", c.name);
            }
        } else {
            NSLog(@"Skipping %@ as no currency attached", c.name);
        }
    }
    return true;
}


/*
 created date:      25/08/2018
 last modified:     25/08/2018
 remarks:           TODO add new way of inserting parms
 */
-(RLMResults<TripRLM *>*) GetTripCollection :(NSString*) Key {
    /*
    RLMSyncUser *user = [RLMSyncUser currentUser];
    NSURL *syncServerURL = [NSURL URLWithString: @"realms://incredible-wooden-hat.de1a.cloud.realm.io/~/trippo"];
    RLMRealmConfiguration *config = [user configurationWithURL:syncServerURL fullSynchronization:true];
    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:nil];
     */
    
    
    if (Key!=nil) {
        // we use the key
        //ProjectNSO *project = [[ProjectNSO alloc] init];
        //TripRLM *specificTrip = [TripRLM objectForPrimaryKey: Key];
        //project.key = specificTrip.key;
        //project.name = specificTrip.name;
        //project.privatenotes = specificTrip.privatenotes;
         RLMResults<TripRLM *> *trip = [TripRLM objectsWhere:@"key==%@",Key];
         return trip;
        
    } else {
        RLMResults<TripRLM *> *trip = [TripRLM allObjects];
        return trip;
        
        
        /* we need all the projects */
        /*RLMResults<TripRLM *> *trips = [TripRLM allObjects];
        for (TripRLM *trip in trips) {
            //ProjectNSO *project = [[ProjectNSO alloc] init];
            //project.key = trip.key;
            //project.name = trip.name;
            //project.privatenotes = trip.privatenotes;
           

        }
         */
    }

}




@end
