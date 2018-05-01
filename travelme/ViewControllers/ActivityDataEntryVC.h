//
//  ActivityDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Dal.h"
#import "ActivityNSO.h"
#import "PoiNSO.h"
#import "PoiListCell.h"
#import "ProjectNSO.h"
#import "PoiImageNSO.h"


@protocol ActivityDelegate <NSObject>
@end

@interface ActivityDataEntryVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (strong, nonatomic) ProjectNSO *Project;
@property (strong, nonatomic) Dal *db;
@property (assign) bool newitem;
@property (nonatomic, weak) id <ActivityDelegate> delegate;
@property (strong, nonatomic) ActivityNSO *Activity;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewPoi;
@property (weak, nonatomic) IBOutlet MKMapView *PoiMapView;




@end

