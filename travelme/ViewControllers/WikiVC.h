//
//  WikiVC.h
//  travelme
//
//  Created by andrew glew on 13/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "PoiNSO.h"
#import "AppDelegate.h"
#import "CountryNSO.h"

@protocol WikiGeneratorDelegate <NSObject>
@end
@interface WikiVC : UIViewController
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (nonatomic, weak) id <WikiGeneratorDelegate> delegate;
@property (nonatomic) NSNumber *gsradius;
@end
