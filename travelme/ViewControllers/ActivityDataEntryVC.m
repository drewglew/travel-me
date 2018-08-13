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
 last modified:     13/05/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.TextFieldName.layer.cornerRadius=8.0f;
    self.TextFieldName.layer.masksToBounds=YES;
    self.TextFieldName.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextFieldName.layer.borderWidth= 1.0f;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextViewNotes.layer.borderWidth= 1.0f;
    
    
    NSDate *today = [NSDate date];
    if (self.deleteitem) {
        UIImage *btnImage = [UIImage imageNamed:@"Delete"];
        [self.ButtonAction setImage:btnImage forState:UIControlStateNormal];
        [self.ButtonAction setTitle:@"" forState:UIControlStateNormal];
        
        [self LoadActivityData];
    } else if (!self.newitem && !self.transformed) {
        [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
        [self LoadActivityData];
        NSComparisonResult result = [self.Activity.startdt compare:today];
        if (self.Activity.startdt == self.Activity.enddt && result==NSOrderedAscending && self.Activity.activitystate==[NSNumber numberWithInt:1]) {
            self.ButtonCheckInOut.hidden = false;
            UIImage *btnImage = [UIImage imageNamed:@"ActivityCheckOut"];
            [self.ButtonCheckInOut setImage:btnImage forState:UIControlStateNormal];
        }

    } else if (self.transformed) {
        self.ButtonCheckInOut.hidden = false;
        UIImage *btnImage = [UIImage imageNamed:@"ActivityCheckIn"];
        [self.ButtonCheckInOut setImage:btnImage forState:UIControlStateNormal];
        //[self.ButtonCheckInOut setBackgroundColor:[UIColor clearColor]];
        [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
        [self LoadActivityData];
    } else if (self.newitem) {
        self.TextFieldName.text = self.Activity.poi.name;
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [cal setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSDateComponents * comp = [cal components:( NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
        [comp setMinute:0];
        [comp setHour:0];
        [comp setSecond:0];
        NSDate *startOfToday = [cal dateFromComponents:comp];
                
        self.Activity.startdt = startOfToday;
        self.Activity.enddt = startOfToday;
        self.Activity.costamt = [NSNumber numberWithInteger:200];
        [self LoadPoiData];
    }
    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    self.TextFieldName.delegate = self;
    self.TextViewNotes.delegate = self;
    
    self.ButtonPayment.layer.cornerRadius = 25;
    self.ButtonPayment.clipsToBounds = YES;
    self.ButtonPayment.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonCheckInOut.layer.cornerRadius = 25;
    self.ButtonCheckInOut.clipsToBounds = YES;
    self.ButtonCheckInOut.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonAction.layer.cornerRadius = 25;
    self.ButtonAction.clipsToBounds = YES;
    
    self.ButtonDateRange.layer.cornerRadius = 25;
    self.ButtonDateRange.clipsToBounds = YES;
    self.ButtonDateRange.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonDirections.layer.cornerRadius = 25;
    self.ButtonDirections.clipsToBounds = YES;
    self.ButtonDirections.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonCancel.layer.cornerRadius = 25;
    self.ButtonCancel.clipsToBounds = YES;

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
    self.Activity.startdt = self.Activity.startdt;
    self.Activity.enddt = self.Activity.enddt;
    [self FormatPrettyDates:self.Activity.startdt :self.Activity.enddt];
    self.Activity.costamt = [NSNumber numberWithInteger:200];
    [self LoadPoiData];
}


/*
 created date:      01/05/2018
 last modified:     01/05/2018
 remarks: Focus on Point of Interest Data
 */
-(void) LoadPoiData {

    NSArray *TypeDistanceItems  = @[
                                @40, // accomodation
                                @500, // airport
                                @100000, // asctronaut
                                @50, // beer
                                @50, // bicyle
                                @300, //bridge
                                @100, // car hire
                                @500, // casino
                                @200, // church
                                @2000, // city
                                @250, // club
                                @250, // concert
                                @50, // food and drink
                                @400, // historic
                                @20, // house
                                @500, // lake
                                @250, // lighthouse
                                @10000, // metropolis
                                @10000, // misc
                                @1000, // monument
                                @1000, // museum
                                @10000, // nature
                                @250, // office
                                @150, // restuarnat
                                @5000, // scenary
                                @5000, // coast
                                @1000, // ship
                                @250, // shopping
                                @5000, // skiing
                                @250, // sports
                                @150, // theatre
                                @500, // theme park
                                @150, // train
                                @10000, // trekking
                                @150, // venue
                                @1000 // zoo
                                ];
    
    /* set map */
    self.PoiMapView.delegate = self;

    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.Activity.poi.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.Activity.poi.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.Activity.poi.lat doubleValue], [self.Activity.poi.lon doubleValue]);
    
    anno.coordinate = coord;

    NSNumber *radius = [TypeDistanceItems objectAtIndex:[self.Activity.poi.categoryid unsignedLongValue]];
    
    [self.PoiMapView setCenterCoordinate:coord animated:YES];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 2.2, [radius doubleValue] * 2.2);
    
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
    
    MKCircle *myCircle = [MKCircle circleWithCenterCoordinate:coord radius:[radius doubleValue]];
    [self.PoiMapView addOverlay:myCircle];
    
    
}


- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay {
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer* aRenderer = [[MKCircleRenderer
                                        alloc]initWithCircle:(MKCircle *)overlay];
        aRenderer.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.9];
        aRenderer.lineWidth = 1;
        return aRenderer;
    }
    else
    {
        return nil;
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
    
    if (self.deleteitem) {
        [AppDelegateDef.Db DeleteActivity:self.Activity :nil];
        [self dismissViewControllerAnimated:YES completion:Nil];
        
    } else if (self.newitem || self.transformed) {
        /* working */
        if (self.newitem) self.Activity.key = [[NSUUID UUID] UUIDString];
        [AppDelegateDef.Db InsertActivityItem:self.Activity];
        // double dismissing so we flow back to the activity window bypassing the search..
        if (self.newitem) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
           [self dismissViewControllerAnimated:YES completion:Nil];
        }
    } else {
        [AppDelegateDef.Db UpdateActivityItem:self.Activity];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
}


/*
 created date:      03/05/2018
 last modified:     08/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowPoiDetail"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.Activity.poi;
        controller.newitem = false;
        controller.readonlyitem = true;
        controller.fromproject = false;
    } else if ([segue.identifier isEqualToString:@"ShowDateRangePicker"]){
        DatePickerRangeVC *controller = (DatePickerRangeVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = self.Activity;
    } else if ([segue.identifier isEqualToString:@"ShowDirections"]){
        // todo
        DirectionsVC *controller = (DirectionsVC *)segue.destinationViewController;
        controller.delegate = self;
        NSMutableArray *Route = [[NSMutableArray alloc] init];
        [Route addObject:self.Activity.poi];
        controller.Route = Route;
        /* soon to be obsolete */
        controller.LocationToCoord = CLLocationCoordinate2DMake([self.Activity.poi.lat doubleValue], [self.Activity.poi.lon doubleValue]);
    } else if ([segue.identifier isEqualToString:@"ShowPayments"]){
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = self.Activity;
        controller.activitystate = self.Activity.activitystate;
        
        /* here we add something new */
        
        controller.Project = nil;
        
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

/*
 created date:      04/05/2018
 last modified:     04/05/2018
 remarks:
 */
- (void)didPickDateSelection :(NSDate*)Start :(NSDate*)End {
    self.Activity.startdt = Start;
    self.Activity.enddt = End;
    [self FormatPrettyDates:Start :End];
}
/*
 created date:      04/05/2018
 last modified:     04/05/2018
 remarks:
 */
-(void)FormatPrettyDates :(NSDate*)Start :(NSDate*)End {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];
    
    self.LabelStartDT.text = [NSString stringWithFormat:@"%@ %@",[dateformatter stringFromDate:Start], [timeformatter stringFromDate:Start]];
     self.LabelEndDT.text = [NSString stringWithFormat:@"%@ %@",[dateformatter stringFromDate:End], [timeformatter stringFromDate :End]];
    
}

/*
 created date:      13/05/2018
 last modified:     13/05/2018
 remarks:
 */
- (IBAction)CheckInOutPressed:(id)sender {
    
    NSDate *today = [NSDate date];
    
    if (self.newitem || self.transformed) {
        self.Activity.startdt = today;
        self.Activity.enddt = today;
        
        if (self.newitem) self.Activity.key = [[NSUUID UUID] UUIDString];
        [AppDelegateDef.Db InsertActivityItem:self.Activity];
        // double dismissing so we flow back to the activity window bypassing the search..
        if (self.newitem) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:YES completion:Nil];
        }
    } else {
        self.Activity.enddt = today;
        [AppDelegateDef.Db UpdateActivityItem:self.Activity];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
}


-(void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

//remember to set your text view delegate
//but if you only have 1 text view in your view controller
//you can simply change currentTextField to the name of your text view
//and ignore this textViewDidBeginEditing delegate method
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.TextViewNotes = textView;
}

-(void)doneButtonClickedDismissKeyboard
{
    [self.TextViewNotes resignFirstResponder];
}

- (IBAction)SegmentPresenterChanged:(id)sender {
    
    if ([self.SegmentPresenter selectedSegmentIndex] == 0) {
        self.ViewMain.hidden = false;
        self.ViewNotes.hidden = true;
        self.ViewPhotos.hidden = true;
    } else if ([self.SegmentPresenter selectedSegmentIndex] == 1) {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = false;
        self.ViewPhotos.hidden = true;
    } else if ([self.SegmentPresenter selectedSegmentIndex] == 2) {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = true;
        self.ViewPhotos.hidden = false;
    }
}


- (void)didCreatePoiFromProject :(NSString*)Key {
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*
 created date:      15/07/2018
 last modified:     12/08/2018
 remarks:
 */
- (void)didUpdatePoi :(NSString*)Method :(PoiNSO*)Object {

}


@end
