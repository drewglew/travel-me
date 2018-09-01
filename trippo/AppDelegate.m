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
    
    self.databasename = @"travelme_003.db";
    self.Db = [[Dal alloc] init];
    NSLocale *theLocale = [NSLocale currentLocale];
    self.HomeCurrencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    self.poiitems = [[NSMutableArray alloc] init];
    [self.Db InitDb:self.databasename];
    
    
    self.PoiBackgroundImageDictionary = [[NSMutableDictionary alloc] init];
    
    self.rlm = [[RealmDAL alloc] init];
    
    [RLMSyncManager sharedManager].errorHandler = ^(NSError *error, RLMSyncSession *session) {
        NSLog(@"A global error has occurred! %@", error);
    };
    
    NSDictionary<NSString *, RLMSyncUser *> *allUsers = [RLMSyncUser allUsers];

    if (allUsers.count==1) {
        
        
        RLMSyncUser *user = [RLMSyncUser currentUser];
        
        NSURL *syncServerURL = [NSURL URLWithString: @"realms://incredible-wooden-hat.de1a.cloud.realm.io/~/trippo"];
        RLMRealmConfiguration *config = [user configurationWithURL:syncServerURL fullSynchronization:TRUE];
        
        [RLMRealm asyncOpenWithConfiguration:config
                               callbackQueue:dispatch_get_main_queue()
                                    callback:^(RLMRealm *realm, NSError *error) {
                                        if (realm) {
                                            
                                            //NSURL *syncServerURL = [NSURL URLWithString: @"realms://incredible-wooden-hat.de1a.cloud.realm.io/~/trippo"];
                                            
                                            RLMRealmConfiguration.defaultConfiguration = [user configurationWithURL:syncServerURL fullSynchronization:YES];
                                            
                                            /* we need SQLite db table for this? */
                                            if ([[CountryRLM allObjects] count]==0) {
                                                [self.rlm LoadCountryData:realm];
                                            }
                                                
                                            
                                            self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
                                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                            MenuVC *menu = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
                                            menu.realm = realm;
                                            self.window.rootViewController = menu;
                                            [self.window makeKeyAndVisible];
                                        }
                                    }];
        
                                            
    }
    else {

        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginVC *login = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.window.rootViewController = login;
       [self.window makeKeyAndVisible];
    }
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /* close db */
    [self.Db CloseDb];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
        [self.Db InitDb:self.databasename];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /* open db */
 //   self.databasename = @"travelme_01.db";
    /* open db */
 //   self.Db = [[Dal alloc] init];
//    [self.Db InitDb:self.databasename];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /* close db */
    [self.Db CloseDb];
}


@end
