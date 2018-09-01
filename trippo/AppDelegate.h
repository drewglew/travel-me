//
//  AppDelegate.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dal.h"
#import "RealmDAL.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
#define AppDelegateDef ((AppDelegate *)[[UIApplication sharedApplication] delegate])
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Dal *Db;
@property (strong, nonatomic) RealmDAL *rlm;
@property (nonatomic) NSString *databasename;
@property (nonatomic) NSString *HomeCurrencyCode;
@property (strong, nonatomic) NSMutableArray *poiitems;
@property (strong, nonatomic) NSMutableDictionary *PoiBackgroundImageDictionary;
@end

