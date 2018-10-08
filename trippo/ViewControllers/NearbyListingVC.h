//
//  NearbyListingVC.h
//  travelme
//
//  Created by andrew glew on 16/07/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyPoiNSO.h"
#import "NearbyPoiCell.h"
#import "AppDelegate.h"
#import "CountryNSO.h"
#import "PoiDataEntryVC.h"
#import "Reachability.h"
#import "PoiRLM.h"

@protocol NearbyListingDelegate <NSObject>
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object;
@end

@interface NearbyListingVC : UIViewController <UITableViewDelegate, CLLocationManagerDelegate, PoiDataEntryDelegate> 
@property (weak, nonatomic) IBOutlet UITableView *TableViewNearbyPoi;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentWikiLanguageOption;
@property (weak, nonatomic) IBOutlet UILabel *LabelNearby;
@property (nonatomic, weak) id <NearbyListingDelegate> delegate;
@property (strong, nonatomic) PoiRLM *PointOfInterest;
@property (strong, nonatomic) NSMutableArray *nearbyitems;
@property (assign) bool UpdatedPoi;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property RLMRealm *realm;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;

@end
