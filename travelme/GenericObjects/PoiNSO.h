//
//  PoiNSO.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PoiNSO : NSObject
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *categoryid;
@property (nonatomic) NSString *countrykey;
@property (nonatomic) NSString *countrycode;
@property (nonatomic) NSString *administrativearea;
@property (nonatomic) NSString *privatenotes;
@property (nonatomic) NSString *locality;
@property (nonatomic) NSString *postcode;
@property (nonatomic) NSNumber *lat;
@property (nonatomic) NSNumber *lon;
@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (strong, nonatomic) NSMutableArray *Images;
@property (strong, nonatomic) NSMutableArray *Links;
@end
