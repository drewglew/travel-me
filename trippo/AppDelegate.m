//
//  AppDelegate.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "AppDelegate.h"
#import <Realm/Realm.h>
#import "MenuVC.h"
#import "LoginVC.h"

@interface AppDelegate ()

@end


@implementation AppDelegate
@synthesize databasename;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
    
    //self.databasename = @"travelme_003.db";
    //self.Db = [[Dal alloc] init];
    NSLocale *theLocale = [NSLocale currentLocale];
    self.HomeCurrencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    self.HomeCountryCode = [theLocale objectForKey:NSLocaleCountryCode];
    self.MeasurementSystem = [theLocale objectForKey:NSLocaleMeasurementSystem];
    self.MetricSystem = [theLocale objectForKey:NSLocaleUsesMetricSystem];
    self.poiitems = [[NSMutableArray alloc] init];
    /* countries / language dictionary */
    
    self.CountryDictionary = [[NSMutableDictionary alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    for (NSDictionary *country in dict) {
        NSString *CountryCode = [country objectForKey:@"alpha2Code"];
        NSArray *Languages = [country objectForKey:@"languages"];
        NSString *LanguageCode = @"";
        if (Languages.count>0) {
            for (NSDictionary *language in Languages) {
                LanguageCode = [language objectForKey:@"iso639_1"];
                NSLog(@"%@-%@",LanguageCode,CountryCode);
                break;
            }
            if (CountryCode != nil && LanguageCode != nil) {
                [self.CountryDictionary setObject:LanguageCode forKey:CountryCode];
            }
        }
    }

    if (url){
        [self InitRealm :url];
    } else {
        [self InitRealm :nil];
    }
    return YES;
}

-(void) InitRealm :(NSURL*) url {
    self.PoiBackgroundImageDictionary = [[NSMutableDictionary alloc] init];
    
    [RLMSyncManager sharedManager].errorHandler = ^(NSError *error, RLMSyncSession *session) {
        NSLog(@"A global error has occurred! %@", error);
    };
    
    NSDictionary<NSString *, RLMSyncUser *> *allUsers = [RLMSyncUser allUsers];
    
    if (allUsers.count==1) {
        /* idea here is to login with default configuration, so not being dependent upon internet. */
        NSURL *syncURL = [NSURL URLWithString:@"realms://incredible-wooden-hat.de1a.cloud.realm.io/~/trippo"];
        RLMRealmConfiguration.defaultConfiguration = [RLMSyncUser.currentUser configurationWithURL:syncURL fullSynchronization:YES];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MenuVC *menu = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
        menu.realm = realm;
        self.window.rootViewController = menu;
        [self.window makeKeyAndVisible];
    }
    else {
        /* here we must log the user in */
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginVC *login = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.window.rootViewController = login;
        [self.window makeKeyAndVisible];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /* open db */
   self.databasename = @"travelme_01.db";
    /* open db */
 //   self.Db = [[Dal alloc] init];
//    [self.Db InitDb:self.databasename];

}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    if (url){
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:url
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
                    documentsURL = [documentsURL URLByAppendingPathComponent:@"ImportedImage.trippo"];
                    [data writeToURL:documentsURL atomically:YES];
                    [self ProcessImportFile];
                    
                }] resume];
    }
    return YES;
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/*
 created date:      08/09/2018
 last modified:     09/09/2018
 remarks:           Have plugged in Poi and Activity (tested Poi, not Activity).  Need to add Project too.
 */
-(bool) ProcessImportFile {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:@"ImportedImage.trippo"];
    bool ImportedFile = false;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
    
        NSData *dataJSON = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *imagedata = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
        NSString *typeofimage = [imagedata objectForKey:@"type"];
        NSString *imagestring = [imagedata objectForKey:@"image"];
        NSData *nsdataFromBase64String  = [[NSData alloc] initWithBase64EncodedString:imagestring options:0];
    
        NSString *imagefilereference = [imagedata objectForKey:@"filereference"];
        NSString *imagefiledirectory = [imagedata objectForKey:@"directory"];
        
        NSString *NewPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imagefiledirectory]];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:NewPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *dataFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imagefilereference]];

        [nsdataFromBase64String writeToFile:dataFilePath atomically:YES];

        NSError *error;
        if (![nsdataFromBase64String writeToFile:dataFilePath options:NSDataWritingFileProtectionNone error:&error]) {
            // Error occurred. Details are in the error object.
            NSLog(@"%@",error);
        }
        

        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];

        // now show the alert
        UIAlertController *alertController;
        if (error==nil && nsdataFromBase64String!=nil) {
            alertController = [UIAlertController alertControllerWithTitle:@"Imported!" message:[NSString stringWithFormat:@"\n\n%@ image has been added to your device!",typeofimage] preferredStyle:UIAlertControllerStyleAlert];
            
            /* try and add image into view. */
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
            img.image = [UIImage imageWithData:nsdataFromBase64String];
            [alertController.view addSubview:img];
            ImportedFile = true;
            
            
        } else {
            alertController = [UIAlertController alertControllerWithTitle:@"Failed!" message:@"Unable to import image.  Maybe it has already been added or it is in an unexpected format." preferredStyle:UIAlertControllerStyleAlert];
        }
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ( viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed ) {
            viewController = viewController.presentedViewController;
        }

        NSLayoutConstraint *constraint = [NSLayoutConstraint
                                          constraintWithItem:alertController.view
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationLessThanOrEqual
                                          toItem:nil
                                          attribute:NSLayoutAttributeNotAnAttribute
                                          multiplier:1
                                          constant:viewController.view.frame.size.height*2.0f];
        
        [alertController.view addConstraint:constraint];
        [viewController presentViewController:alertController animated:YES completion:^{}];
    
    }
    return ImportedFile;
}

@end
