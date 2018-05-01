//
//  ActivityDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityDataEntryVC.h"

@interface ActivityDataEntryVC ()

@end

@implementation ActivityDataEntryVC
@synthesize ImageViewPoi;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self LoadPoiData];
    //[self.ImageViewPoi setImage:self.Poi.
    
    // Do any additional setup after loading the view.
}


-(void) LoadPoiData {
    /* set map */
    self.PoiMapView.delegate = self;

    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.PointOfInterest.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.PointOfInterest.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    anno.coordinate = coord;

    [self.PoiMapView setCenterCoordinate:coord animated:YES];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.PoiMapView regionThatFits:viewRegion];
    [self.PoiMapView setRegion:adjustedRegion animated:YES];
    [self.PoiMapView addAnnotation:anno];
    [self.PoiMapView selectAnnotation:anno animated:YES];
    
    /* load images from file - TODO make sure we locate them all */
    if (self.PointOfInterest.Images.count==0) {
        self.ImageViewPoi.image = [UIImage imageNamed:@"Poi"];
    } else {
    /*
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
        PoiImageNSO *FirstImage = [self.PointOfInterest.Images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",FirstImage.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
     */
        PoiImageNSO *img = [self.PointOfInterest.Images firstObject];
        self.ImageViewPoi.image = img.Image;
    }
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}



@end
