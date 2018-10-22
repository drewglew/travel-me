//
//  AppDelegate.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
#define AppDelegateDef ((AppDelegate *)[[UIApplication sharedApplication] delegate])
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *databasename;
@property (nonatomic) NSString *HomeCurrencyCode;
@property (nonatomic) NSString *HomeCountryCode;
@property (nonatomic) NSString *MeasurementSystem;
@property (assign) bool MetricSystem;
@property (strong, nonatomic) NSMutableArray *poiitems;
@property (strong, nonatomic) NSMutableDictionary *PoiBackgroundImageDictionary;
@property (strong, nonatomic) NSMutableDictionary *CountryDictionary;
@end

