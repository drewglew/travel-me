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

/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.newitem && !self.transformed) {
        [self.ButtonAction setTitle:@"Upd" forState:UIControlStateNormal];
        [self LoadActivityData];
    } else if (self.transformed) {
        [self LoadActivityData];
    } else if (self.newitem) {
        self.TextFieldName.text = self.Activity.poi.name;
        self.Activity.startdt = [NSDate date];
        self.Activity.enddt = [NSDate date];
        self.Activity.costamt = [NSNumber numberWithInteger:200];
        [self LoadPoiData];
    }
    // Do any additional setup after loading the view.
}

/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks: Load the activity data received from the views 
 */
-(void) LoadActivityData {
    /* set text data */
    self.TextFieldName.text = self.Activity.name;
    self.TextViewNotes.text = self.Activity.privatenotes;
    self.Activity.startdt = [NSDate date];
    self.Activity.enddt = [NSDate date];
    self.Activity.costamt = [NSNumber numberWithInteger:200];
    [self LoadPoiData];
}


/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks: Focus on Point of Interest Data
 */
-(void) LoadPoiData {

    /* set map */
    self.PoiMapView.delegate = self;

    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.Activity.poi.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.Activity.poi.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.Activity.poi.lat doubleValue], [self.Activity.poi.lon doubleValue]);
    
    anno.coordinate = coord;

    [self.PoiMapView setCenterCoordinate:coord animated:YES];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.PoiMapView regionThatFits:viewRegion];
    [self.PoiMapView setRegion:adjustedRegion animated:YES];
    [self.PoiMapView addAnnotation:anno];
    [self.PoiMapView selectAnnotation:anno animated:YES];
    
    /* load images from file - TODO make sure we locate them all */
    if (self.Activity.poi.Images.count > 0) {
        PoiImageNSO *img = [self.Activity.poi.Images firstObject];
        self.ImageViewPoi.image = img.Image;
    } else {
        self.ImageViewPoi.image = [UIImage imageNamed:@"Poi"];
    }
}


/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextFieldName endEditing:YES];
    [self.TextViewNotes endEditing:YES];
}

/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks:
 */
- (IBAction)AddActivityPressed:(id)sender {
    /* validations perhaps? */
    
    if (self.TextFieldName.text == nil) {
        return;
    }
    self.Activity.name = self.TextFieldName.text;
    self.Activity.privatenotes = self.TextViewNotes.text;
    if (self.newitem || self.transformed) {
        /* working */
        if (self.newitem) self.Activity.key = [[NSUUID UUID] UUIDString];
        [self.db InsertActivityItem:self.Activity];
        // double dismissing so we flow back to the activity window bypassing the search..
        if (self.newitem) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
           [self dismissViewControllerAnimated:YES completion:Nil];
        }
    } else {
        [self.db UpdateActivityItem:self.Activity];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
}


/*
 created date:      03/05/2018
 last modified:     03/05/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowPoiDetail"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        controller.PointOfInterest = self.Activity.poi;
        controller.newitem = false;
        controller.readonlyitem = true;
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
