//
//  WikiVC.m
//  travelme
//
//  Created by andrew glew on 13/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "WikiVC.h"

@interface WikiVC ()

@end

@implementation WikiVC

/*
 created date:      13/06/2018
 last modified:     16/06/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    /*
    NSArray *parms = [self.PointOfInterest.wikititle componentsSeparatedByString:@"~"];
    NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/api/rest_v1/page/media/%@",[parms objectAtIndex:0] , [parms objectAtIndex:1]];
    
    (self.PointOfInterest.wikititle)
    */
    
    NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *countryCode = [theLocale objectForKey:NSLocaleCountryCode];
    CountryNSO *HomeCountry = [AppDelegateDef.Db GetCountryByCode:countryCode];

    if (![fileManager fileExistsAtPath:wikiDataFilePath]){
        /* generate a PDF of WikiPage */
        NSString *TitleText = [self.PointOfInterest.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        [self MakeWikiFile :TitleText :wikiDataFilePath :HomeCountry.language];
    } else {
        /* present the WikiPage that is saved already */
        NSURL *targetURL = [NSURL fileURLWithPath:wikiDataFilePath];
        NSData *data = [NSData dataWithContentsOfURL:targetURL];
        [self.webView loadData:data MIMEType:@"application/pdf" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    }
    
    self.webView.hidden=false;
    
    // Do any additional setup after loading the view.
}

/*
 created date:      13/06/2018
 last modified:     14/07/2018
 remarks:  search by name first?  if nothing found then by closest location?
 */
-(bool)SearchWikiDocByLocation :(NSString *)wikiPathName :(NSString *)language {
    bool RetValue = false;
    
    /*
     Obtain Wiki records based on coordinates & local language.  (radius is in meters, we should use same range as type used to search photos)
     https://en.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=1000&gscoord=52.5208626606277|13.4094035625458&format=json
    
     Or search by name with redirect.
     https://en.wikipedia.org/w/api.php?action=query&titles=Göteborg&redirects&format=jsonfm&formatversion=2
     */

    NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=query&list=geosearch&gsprop=type|name|dim|country|region|globe&gsradius=%@&gscoord=%@|%@&format=json&redirects",language, self.gsradius, self.PointOfInterest.lat, self.PointOfInterest.lon];
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self fetchFromWikiApiByLocation:url withDictionary:^(NSDictionary *data) {

            NSDictionary *query = [data objectForKey:@"query"];
            NSDictionary *geosearch =  [query objectForKey:@"geosearch"];
            
            NSLog(@"%@",geosearch);
            
            NSString *titleText = @"";
            
            /* we can process all later, but am only interested in the closest wiki entry */
            for (NSDictionary *item in geosearch) {

                titleText = [[item valueForKey:@"title"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];

                self.PointOfInterest.wikititle =  [NSString stringWithFormat:@"%@~%@",language,titleText];
                
                [self.delegate updatePoiFromWikiActvity :self.PointOfInterest];
                
                [self MakeWikiFile:titleText :wikiPathName :language];
                
                /*
                 https://en.wikipedia.org/api/rest_v1/page/pdf/Berlin_Alexanderplatz_station
                 */
                break;
                
            }
    }];

    return RetValue;
}

/*
 created date:      16/06/2018
 last modified:     18/07/2018
 remarks:  search by name first?  if nothing found then by closest location?
 */
-(void) MakeWikiFile :(NSString*)Title :(NSString *)wikiPathName :(NSString *)language {
NSString *urlstring = [NSString stringWithFormat:@"https://%@.wikipedia.org/api/rest_v1/page/pdf/%@",language,Title];
NSURL *url = [NSURL URLWithString:[urlstring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                      dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          [data writeToFile:wikiPathName options:NSDataWritingAtomic error:&error];
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^(void){
                                              
                                              self.PointOfInterest.wikititle =  [NSString stringWithFormat:@"%@~%@",language,Title];
                                              
                                              [self.delegate updatePoiFromWikiActvity :self.PointOfInterest];
                                              
                                              [self.webView loadData:data MIMEType:@"application/pdf" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
                                              
                                              self.webView.hidden=false;
                                              
                                          });
                                          
                                      }];

        [downloadTask resume];
}



/*
 created date:      13/06/2018
 last modified:     15/06/2018
 remarks:
 */
-(void)fetchFromWikiApiByLocation:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
}


/*
 created date:      15/06/2018
 last modified:     20/06/2018
 remarks:
 */
- (IBAction)UpdateWikiPagePressed:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
    
    NSError *error = nil;
    [fileManager removeItemAtPath:wikiDataFilePath error:&error];
    
    CountryNSO *Country;
    if (self.SegmentLanguageOption.selectedSegmentIndex == 0) {
        
        NSLocale *theLocale = [NSLocale currentLocale];
        NSString *countryCode = [theLocale objectForKey:NSLocaleCountryCode];
        Country = [AppDelegateDef.Db GetCountryByCode:countryCode];
    }
    else if (self.SegmentLanguageOption.selectedSegmentIndex == 1) {
        Country = [AppDelegateDef.Db GetCountryByCode:self.PointOfInterest.countrycode];
    } else {
        Country = [AppDelegateDef.Db GetCountryByCode:@"UK"];
    }
    
    if (![fileManager fileExistsAtPath:wikiDataFilePath]){
        [self SearchWikiDocByLocation :wikiDataFilePath  :Country.language];
    }
}

/*
 created date:      16/06/2018
 last modified:     14/07/2018
 remarks:
 */
- (IBAction)UpdateWikiPageByTitlePressed:(id)sender {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
    
    NSError *error = nil;
    [fileManager removeItemAtPath:wikiDataFilePath error:&error];
    
    CountryNSO *Country;
    if (self.SegmentLanguageOption.selectedSegmentIndex == 0) {
    
        NSLocale *theLocale = [NSLocale currentLocale];
        NSString *countryCode = [theLocale objectForKey:NSLocaleCountryCode];
        Country = [AppDelegateDef.Db GetCountryByCode:countryCode];
    } else if (self.SegmentLanguageOption.selectedSegmentIndex == 1) {
        Country = [AppDelegateDef.Db GetCountryByCode:self.PointOfInterest.countrycode];
    } else {
        Country = [AppDelegateDef.Db GetCountryByCode:@"GB"];
    }
    
    NSString *TitleText = [self.PointOfInterest.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];

    self.PointOfInterest.wikititle = [NSString stringWithFormat:@"%@~%@",Country.language,TitleText];
    
    [self.delegate updatePoiFromWikiActvity :self.PointOfInterest];

    [self MakeWikiFile :TitleText :wikiDataFilePath :Country.language];

}


/*
 created date:      13/07/2018
 last modified:     13/07/2018
 remarks:
 */
- (void)updatePoiFromWikiActvity :(PoiNSO*)PointOfInterest {
}

/*
 created date:      13/06/2018
 last modified:     13/06/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
