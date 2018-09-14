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

int BlurredMainViewPresentedHeight;
int BlurredImageViewPresentedHeight=60;
@implementation ActivityDataEntryVC
@synthesize ImageViewPoi;
@synthesize delegate;

/*
 created date:      01/05/2018
 last modified:     01/09/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ActivityImageDictionary = [[NSMutableDictionary alloc] init];
    
    self.TextFieldName.layer.cornerRadius=8.0f;
    self.TextFieldName.layer.masksToBounds=YES;
    self.TextFieldName.layer.borderColor=[[UIColor clearColor] CGColor];
    self.TextFieldName.layer.borderWidth= 1.0f;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextViewNotes.layer.borderWidth= 1.0f;
    
    self.ViewSelectedKey.layer.cornerRadius=28;
    self.ViewSelectedKey.layer.masksToBounds=YES;
    
    self.ViewTrash.layer.cornerRadius=28;
    self.ViewTrash.layer.masksToBounds=YES;
    
    self.TypeDistanceItems  = @[
                                @40, // accomodation 0
                                @500, // airport 1
                                @20000, // astronaut 2
                                @50, // beer 3
                                @50, // bicyle 4
                                @300, //bridge 5
                                @100, // car hire 6
                                @500, // casino 7
                                @200, // church 8
                                @2000, // city 9
                                @250, // club 10
                                @250, // concert 11
                                @50, // food and drink 12
                                @400, // historic, 13
                                @20, // house, 14
                                @500, // lake, 15
                                @250, // lighthouse, 16
                                @10000, // metropolis, 17
                                @10000, // misc, 18
                                @1000, // monument, 19
                                @1000, // museum, 20
                                @10000, // nature, 21
                                @250, // office, 22
                                @150, // restuarnat, 23
                                @5000, // scenary, 24
                                @5000, // coast, 25
                                @1000, // ship, 26
                                @250, // shopping, 27
                                @5000, // skiing, 28
                                @250, // sports, 29
                                @150, // theatre, 30
                                @500, // theme park, 31
                                @150, // train, 32
                                @10000, // trekking, 33
                                @150, // venue, 34
                                @1000 // zoo, 35
                                ];
    
    NSDate *today = [NSDate date];
    if (self.deleteitem) {
        UIImage *btnImage = [UIImage imageNamed:@"Delete"];
        [self.ButtonAction setImage:btnImage forState:UIControlStateNormal];
        [self.ButtonAction setBackgroundColor:[UIColor colorWithRed:251.0f/255.0f green:13.0f/255.0f blue:68.0f/255.0f alpha:1.0]];
        [self.ButtonAction setTitle:@"" forState:UIControlStateNormal];
        
        [self LoadActivityData];
        
        //self.Activity.Images = [NSMutableArray arrayWithArray:[AppDelegateDef.Db GetImagesForSelectedActivity:self.Activity.key :self.Activity.state]];
        
        self.CollectionViewActivityImages.scrollEnabled = true;
    } else if (!self.newitem && !self.transformed) {
        [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
         //self.Activity.Images = [NSMutableArray arrayWithArray:[AppDelegateDef.Db GetImagesForSelectedActivity:self.Activity.key :self.Activity.activitystate]];
        [self LoadActivityData];
        
        self.CollectionViewActivityImages.scrollEnabled = true;

        NSComparisonResult result = [self.Activity.startdt compare:today];
        if (self.Activity.startdt == self.Activity.enddt && result==NSOrderedAscending && self.Activity.state==[NSNumber numberWithInt:1]) {
            self.ButtonCheckInOut.hidden = false;
            UIImage *btnImage = [UIImage imageNamed:@"ActivityCheckOut"];
            [self.ButtonCheckInOut setImage:btnImage forState:UIControlStateNormal];
        }

    } else if (self.transformed) {
        self.ButtonCheckInOut.hidden = false;
        UIImage *btnImage = [UIImage imageNamed:@"ActivityCheckIn"];
        [self.ButtonCheckInOut setImage:btnImage forState:UIControlStateNormal];
        [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
        [self LoadActivityData];
        self.CollectionViewActivityImages.scrollEnabled = true;
        self.Activity.startdt = [NSDate date];
        self.Activity.enddt = [NSDate date];
        [self FormatPrettyDates:self.Activity.startdt :self.Activity.enddt];
        
    } else if (self.newitem) {
        self.TextFieldName.text = self.Poi.name;
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [cal setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSDateComponents * comp = [cal components:( NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
        [comp setMinute:0];
        [comp setHour:0];
        [comp setSecond:0];
        NSDate *startOfToday = [cal dateFromComponents:comp];
        //self.Activity.Images = [[NSMutableArray alloc] init];
        self.Activity.startdt = startOfToday;
        self.Activity.enddt = startOfToday;
        [self LoadPoiData];
    }
    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    self.TextFieldName.delegate = self;
    self.TextViewNotes.delegate = self;
    
    self.ButtonUploadImage.layer.cornerRadius = 25;
    self.ButtonUploadImage.clipsToBounds = YES;
    self.ButtonUploadImage.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonPayment.layer.cornerRadius = 25;
    self.ButtonPayment.clipsToBounds = YES;
    self.ButtonPayment.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonCheckInOut.layer.cornerRadius = 25;
    self.ButtonCheckInOut.clipsToBounds = YES;
    self.ButtonCheckInOut.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonAction.layer.cornerRadius = 25;
    self.ButtonAction.clipsToBounds = YES;
    self.ButtonAction.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonDateRange.layer.cornerRadius = 25;
    self.ButtonDateRange.clipsToBounds = YES;
    self.ButtonDateRange.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonDirections.layer.cornerRadius = 25;
    self.ButtonDirections.clipsToBounds = YES;
    self.ButtonDirections.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonCancel.layer.cornerRadius = 25;
    self.ButtonCancel.clipsToBounds = YES;
    self.ButtonCancel.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if (self.Activity.state==[NSNumber numberWithInt:1]) {
        self.ImageViewIdeaWidthConstraint.constant = 0;
        BlurredMainViewPresentedHeight = 140;
        self.ViewEffectBlurDetailHeightConstraint.constant = BlurredMainViewPresentedHeight;
        self.ViewStarRating.hidden = false;
        
        self.ViewStarRating.maximumValue = 5;
        self.ViewStarRating.minimumValue = 0;
        self.ViewStarRating.value = [self.Activity.rating floatValue];
        self.ViewStarRating.allowsHalfStars = YES;
        self.ViewStarRating.accurateHalfStars = YES;
        
    } else {
        BlurredMainViewPresentedHeight = 100;
    }

    self.CollectionViewActivityImages.dataSource = self;
    self.CollectionViewActivityImages.delegate = self;
    
    self.ImagePicture.frame = CGRectMake(0, 0, self.ScrollViewImage.frame.size.width, self.ScrollViewImage.frame.size.height);
    self.ScrollViewImage.delegate = self;

}

/*
 created date:      01/05/2018
 last modified:     01/09/2018
 remarks: Load the activity data received from the views 
 */
-(void) LoadActivityData {
    /* set text data */
    self.TextFieldName.text = self.Activity.name;
    self.TextViewNotes.text = self.Activity.privatenotes;
    //self.LabelStartDT.text = self.Activity.startdt;
    //self.Activity.enddt = self.Activity.enddt;
    [self FormatPrettyDates:self.Activity.startdt :self.Activity.enddt];
    //self.Activity.costamt = [NSNumber numberWithInteger:200];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    long ImageIndex = 0;
    for (ImageCollectionRLM *imgobject in self.Activity.images) {
        UIImage *image = [[UIImage alloc] init];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData==nil) {
            image = [UIImage imageNamed:@"Activity"];
        } else {
            image = [UIImage imageWithData:pngData];
        }
        if (imgobject.KeyImage) {
            self.SelectedImageKey = imgobject.key;
            self.SelectedImageReference = imgobject.ImageFileReference;
            self.SelectedImageIndex = [NSNumber numberWithLong:ImageIndex];
            self.ViewSelectedKey.hidden = false;
            [self.ImagePicture setImage:image];
            [self.ImageViewKeyActivity setImage:image];
        }
        
        [self.ActivityImageDictionary setObject:image forKey:imgobject.key];
        
        ImageIndex ++;
    }
    
    
    [self LoadPoiData];
}




/*
 created date:      01/05/2018
 last modified:     09/09/2018
 remarks: Focus on Point of Interest Data
 */
-(void) LoadPoiData {

    /* set map */
    self.PoiMapView.delegate = self;

    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.Poi.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.Poi.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.Poi.lat doubleValue], [self.Poi.lon doubleValue]);
    
    anno.coordinate = coord;

    NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.Poi.categoryid unsignedLongValue]];
    
    [self.PoiMapView setCenterCoordinate:coord animated:YES];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 2.2, [radius doubleValue] * 2.2);
    
    MKCoordinateRegion adjustedRegion = [self.PoiMapView regionThatFits:viewRegion];
    [self.PoiMapView setRegion:adjustedRegion animated:YES];
    [self.PoiMapView addAnnotation:anno];
    [self.PoiMapView selectAnnotation:anno animated:YES];
    
    /* load images from file - TODO make sure we locate them all */
    if (self.PoiImage==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
        
        if (self.Poi.images.count>0) {
            
            ImageCollectionRLM *imgobject = [[self.Poi.images objectsWhere:@"KeyImage==1"] firstObject];
            
            NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
            
            NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
            
            if (pngData!=nil) {
                self.ImageViewPoi.image = [UIImage imageWithData:pngData];
            } else {
                self.ImageViewPoi.image = [UIImage imageNamed:@"Poi"];
            }
        } else {
            self.ImageViewPoi.image = [UIImage imageNamed:@"Poi"];
        }
    } else {
        self.ImageViewPoi.image = self.PoiImage;
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
 last modified:     14/09/2018
 remarks:  TODO [self.delegate didUpdateActivityImage]; add to update
 */
- (IBAction)ActionButtonPressed:(id)sender {
    /* validations perhaps? */
    
    if (self.TextFieldName.text == nil) {
        return;
    }

    if (self.deleteitem) {
        
        [self.realm transactionWithBlock:^{
            [self.realm deleteObject:[ActivityRLM objectForPrimaryKey:self.Activity.compondkey]];
        }];
        
        //[AppDelegateDef.Db DeleteActivity:self.Activity :nil];
        [self dismissViewControllerAnimated:YES completion:Nil];
        
    } else if (self.newitem || self.transformed) {
        /* working */
        self.Activity.name = self.TextFieldName.text;
        self.Activity.privatenotes = self.TextViewNotes.text;
        self.Activity.rating = [NSNumber numberWithFloat: self.ViewStarRating.value];
        self.Activity.modifieddt = [NSDate date];
        self.Activity.createddt = [NSDate date];
        //self.Activity.Poi = self.Poi;
        self.Activity.poikey = self.Poi.key;
        self.Activity.tripkey = self.Trip.key;
        
        if (self.newitem) self.Activity.key = [[NSUUID UUID] UUIDString];
        self.Activity.compondkey = [NSString stringWithFormat:@"%@~%@",self.Activity.key,self.Activity.state];
        
        if (self.Activity.images.count>0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@/Activities/%@",self.Activity.tripkey, self.Activity.compondkey]];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
            
            int counter = 1;
            for (ImageCollectionRLM *activityimgobject in self.Activity.images) {
                NSData *imageData =  UIImagePNGRepresentation([self.ActivityImageDictionary objectForKey:activityimgobject.key]);
                NSString *filename = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
                NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                [imageData writeToFile:filepathname atomically:YES];
                //activityimgobject.NewImage = true;
                activityimgobject.ImageFileReference = [NSString stringWithFormat:@"/Images/Trips/%@/Activities/%@/%@",self.Activity.tripkey, self.Activity.compondkey,filename];
                //activityimgobject.State = self.Activity.state;
                counter++;
            }
            [delegate didUpdateActivityImages:true];
        }
        [self.realm beginWriteTransaction];
        [self.realm addObject:self.Activity];
        [self.realm commitWriteTransaction];
        
        if (self.newitem) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
           [self dismissViewControllerAnimated:YES completion:Nil];
        }
    } else {
        [self.realm beginWriteTransaction];
        self.Activity.name = self.TextFieldName.text;
        self.Activity.privatenotes = self.TextViewNotes.text;
        self.Activity.rating = [NSNumber numberWithFloat: self.ViewStarRating.value];
        self.Activity.modifieddt = [NSDate date];
        
        if (self.Activity.images.count>0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@/Activities/%@",self.Trip.key, self.Activity.compondkey]];
            
            
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

            NSInteger count = [self.Activity.images count];
            
            for (NSInteger index = (count - 1); index >= 0; index--) {
                ImageCollectionRLM *imgobject = self.Activity.images[index];
                
                if (imgobject.ImageFlaggedDeleted) {
                    /* else we are good to delete it */
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    NSError *error = nil;
                    BOOL success = [fm removeItemAtPath:filepathname error:&error];
                    if (!success || error) {
                        NSLog(@"something failed in deleting unwanted data");
                    }
                    
                    [self.Activity.images removeObjectAtIndex:index];
                    
                } else if ([imgobject.ImageFileReference isEqualToString:@""] || imgobject.ImageFileReference==nil) {
                    /* here we add the attachment to file system and dB */
                    imgobject.NewImage = true;
                    NSData *imageData =  UIImagePNGRepresentation([self.ActivityImageDictionary objectForKey:imgobject.key]);
                    NSString *filename = [NSString stringWithFormat:@"%@.png", imgobject.key];
                    NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                    [imageData writeToFile:filepathname atomically:YES];
                    
                    imgobject.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/Activities/%@/%@",self.Trip.key, self.Activity.compondkey,filename];
                    NSLog(@"new image");
                    [delegate didUpdateActivityImages:true];
                    
                } else if (imgobject.UpdateImage) {
                    /* we might swap it out as user has replaced the original file */
                    NSData *imageData =  UIImagePNGRepresentation([self.ActivityImageDictionary objectForKey:imgobject.key]);
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    [imageData writeToFile:filepathname atomically:YES];
                    NSLog(@"updated image");
                    [delegate didUpdateActivityImages:true];
                    
                }
                
            }
            
        }
        [self.realm commitWriteTransaction];
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
        //PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:self.Activity.poikey];
        controller.PointOfInterest = self.Poi;
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
        [Route addObject:self.Poi];
        controller.Route = Route;
        /* soon to be obsolete */
        controller.LocationToCoord = CLLocationCoordinate2DMake([self.Poi.lat doubleValue], [self.Poi.lon doubleValue]);
    } else if ([segue.identifier isEqualToString:@"ShowPayments"]){
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = self.Activity;
        controller.activitystate = self.Activity.state;
        
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
 last modified:     09/09/2018
 remarks:
 */
- (void)didPickDateSelection :(NSDate*)Start :(NSDate*)End {
    
    [self.realm beginWriteTransaction];
    self.Activity.startdt = Start;
    self.Activity.enddt = End;
    [self.realm commitWriteTransaction];
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
        [self.realm beginWriteTransaction];
        [self.realm addObject:self.Activity];
        [self.realm commitWriteTransaction];

        [self.delegate didUpdateActivityImages :true];
        // double dismissing so we flow back to the activity window bypassing the search..
        if (self.newitem) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:YES completion:Nil];
        }
        
    } else {
        [self.realm beginWriteTransaction];
        self.Activity.enddt = today;
        [self.realm commitWriteTransaction];
        [self.delegate didUpdateActivityImages :true];
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



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
     self.TextFieldName.backgroundColor = [UIColor whiteColor];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
     self.TextFieldName.backgroundColor = [UIColor clearColor];
    return YES;
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



/*
 created date:      19/08/2018
 last modified:     01/09/2018
 remarks:
 */
-(void)InsertActivityImage {
    
    //CHANGE
    NSString *titleMessage = @"How would you like to add a photo to your Activity?";
    NSString *alertMessage = @"";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleMessage
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *cameraOption = @"Take a photo with the camera";
    NSString *photorollOption = @"Choose a photo from camera roll";
    NSString *photoCloseToPoiOption = @"Choose own photos nearby";
    NSString *photoFromWikiOption = @"Choose photos from web";
    NSString *lastphotoOption = @"Select last photo taken";
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraOption
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                   
                                                                   
                                                                   UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
                                                                   
                                                                   UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                                                                   
                                                                   [alert addAction:defaultAction];
                                                                   [self presentViewController:alert animated:YES completion:nil];
                                                                   
                                                                   
                                                               }else
                                                               {
                                                                   
                                                                   UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                   picker.delegate = self;
                                                                   picker.allowsEditing = YES;
                                                                   picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                   picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                                                   
                                                                   [self presentViewController:picker animated:YES completion:NULL];
                                                                   
                                                               }
                                                               
                                                               
                                                               NSLog(@"you want a photo");
                                                               
                                                           }];
    
    
    
    UIAlertAction *photorollAction = [UIAlertAction actionWithTitle:photorollOption
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                  picker.delegate = self;
                                                                  picker.allowsEditing = YES;
                                                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                  [self presentViewController:picker animated:YES completion:nil];
                                                                  
                                                                  NSLog(@"you want to select a photo");
                                                                  
                                                              }];
    
    UIAlertAction *photosCloseToPoiAction = [UIAlertAction actionWithTitle:photoCloseToPoiOption
                                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                         
                                                                         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                         ImagePickerVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ImagePickerViewController"];
                                                                         controller.delegate = self;
                                                                         
                                                                         PoiRLM *copiedpoi = [[PoiRLM alloc] init];
                                                                         copiedpoi.key = self.Poi.key;
                                                                         copiedpoi.lon = self.Poi.lon;
                                                                         copiedpoi.lat = self.Poi.lat;
                                                                         copiedpoi.name = self.Poi.name;
                                                                         
                                                                         controller.PointOfInterest = copiedpoi;
                                                                         
                                                                         controller.distance = [self.TypeDistanceItems objectAtIndex:[self.Poi.categoryid longValue]];
                                                                         
                                                                         controller.wikiimages = false;
                                                                         
                                                                         controller.ImageSize = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);
                                                                         [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                                                                         [self presentViewController:controller animated:YES completion:nil];
                                                                         
                                                                     }];
    
    
    UIAlertAction *photoWikiAction = [UIAlertAction actionWithTitle:photoFromWikiOption
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                  ImagePickerVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ImagePickerViewController"];
                                                                  controller.delegate = self;
                                                                  
                                                                  PoiRLM *copiedpoi = [[PoiRLM alloc] init];
                                                                  copiedpoi.key = self.Poi.key;
                                                                  copiedpoi.lon = self.Poi.lon;
                                                                  copiedpoi.lat = self.Poi.lat;
                                                                  copiedpoi.name = self.Poi.name;
                                                                  copiedpoi.wikititle = self.Poi.wikititle;
                                                                  controller.PointOfInterest = copiedpoi;
                                                                  
                                                                  controller.distance = [self.TypeDistanceItems objectAtIndex:[self.Poi.categoryid longValue]];
                                                                  
                                                                  controller.wikiimages = true;
                                                                  
                                                                  controller.ImageSize = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);
                                                                  [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                                                                  [self presentViewController:controller animated:YES completion:nil];
                                                              }];
    
    
    UIAlertAction *lastphotoAction = [UIAlertAction actionWithTitle:lastphotoOption
                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                  PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                                  if (status == PHAuthorizationStatusNotDetermined) {
                                      // Access has not been determined.
                                      [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                      }];
                                  }
                                  
                                  if (status == PHAuthorizationStatusAuthorized)
                                  {
                                      PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
                                      options.version = PHImageRequestOptionsVersionCurrent;
                                      options.deliveryMode =  PHImageRequestOptionsDeliveryModeHighQualityFormat;
                                      options.resizeMode = PHImageRequestOptionsResizeModeExact;
                                      options.synchronous = NO;
                                      options.networkAccessAllowed =  TRUE;
                                      
                                      PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                                      fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                                      PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
                                      PHAsset *lastAsset = [fetchResult lastObject];
                                      CGSize size = CGSizeMake(self.ScrollViewImage.frame.size.width * 2, self.ScrollViewImage.frame.size.width * 2);
                                      
                                      [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                                                 targetSize:size
                                                                                contentMode:PHImageContentModeAspectFill
                                                                                    options:options
                                                                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                  
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  
                                                  CGSize size = CGSizeMake(self.ScrollViewImage.frame.size.width * 2, self.ScrollViewImage.frame.size.width * 2);
                                                  
                                                  if (self.imagestate==1) {
                                                      ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
                                                      imgobject.key = [[NSUUID UUID] UUIDString];
                                                      
                                                      UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                      if (self.Activity.images.count==0) {
                                                          imgobject.KeyImage = 1;
                                                      }
                                                      [self.ActivityImageDictionary setObject:image forKey:imgobject.key];
                                                      
                                                      [self.realm beginWriteTransaction];
                                                      [self.Activity.images.realm addObject:imgobject];
                                                      [self.realm commitWriteTransaction];
                                                      
                                                  } else if (self.imagestate==2) {
                                                      
                                                      ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:[self.SelectedImageIndex longValue]];
                                                      
                                                      UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                      
                                                      [self.ActivityImageDictionary setObject:image forKey:imgobject.key];

                                                      [self.realm beginWriteTransaction];
                                                      imgobject.UpdateImage = true;
                                                      [self.realm commitWriteTransaction];
                                                  }
                                                  [self.CollectionViewActivityImages reloadData];
                                              });
                                          }];
                                  }
                              }];
    
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed cancel");
                                                           }];
    
    
    
    [alert addAction:cameraAction];
    [alert addAction:photorollAction];
    [alert addAction:photosCloseToPoiAction];
    if (![self.Poi.wikititle isEqualToString:@""]) {
        [alert addAction:photoWikiAction];
    }
    [alert addAction:lastphotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/* Delegate methods for ScrollView */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.ScrollViewImage viewWithTag:5];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (self.newitem) {
        
        CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width *2);
        chosenImage = [ToolBoxNSO imageWithImage:chosenImage scaledToSize:size];
        
    } else {
        
        CGSize size = CGSizeMake(self.ImagePicture.frame.size.width * 2, self.ImagePicture.frame.size.width *2);
        chosenImage = [ToolBoxNSO imageWithImage:chosenImage scaledToSize:size];
    }
    
    if (self.imagestate==1) {
        ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
        imgobject.key = [[NSUUID UUID] UUIDString];
        
        
        if (self.Activity.images.count==0) {
            imgobject.KeyImage = 1;
        } else {
            imgobject.KeyImage = 0;
        }
        
        [self.realm beginWriteTransaction];
        [self.Activity.images addObject:imgobject];
        [self.realm commitWriteTransaction];
        
        [self.ActivityImageDictionary setObject:chosenImage forKey:imgobject.key];
        
        
    } else if (self.imagestate == 2) {
        ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:[self.SelectedImageIndex longValue]];
        
        [self.realm beginWriteTransaction];
        imgobject.UpdateImage = true;
        [self.realm commitWriteTransaction];
        
        [self.ActivityImageDictionary setObject:chosenImage forKey:imgobject.key];
        
    }
    
    self.imagestate = 0;
    
    [self.delegate didUpdateActivityImages :true];
    
    [self.CollectionViewActivityImages reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



/*
 created date:      19/08/2018
 last modified:     01/08/2018
 remarks:
 */
- (void)didAddImages :(NSMutableArray*)ImageCollection {
    
    bool AddedImage = false;
    for (ImageNSO *img in ImageCollection) {
        
        ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
        imgobject.key = [[NSUUID UUID] UUIDString];
        [self.ActivityImageDictionary setObject:img.Image forKey:imgobject.key];
        
        if (self.Activity.images.count==0) {
            imgobject.KeyImage = 1;
        } else {
            imgobject.KeyImage = 0;
        }
        imgobject.info = img.Description;
        [self.realm beginWriteTransaction];
        [self.Activity.images addObject:imgobject];
        [self.realm commitWriteTransaction];
        
        AddedImage = true;
    }
    if (AddedImage) {
        [self.CollectionViewActivityImages reloadData];
        [self.delegate didUpdateActivityImages :true];
    }
}



/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.Activity.images.count + 1;
    
}

/*
 created date:      19/04/2018
 last modified:     01/09/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ActivityImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityImageId" forIndexPath:indexPath];
    NSInteger NumberOfItems = self.Activity.images.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.ImageActivity.image = [UIImage imageNamed:@"AddItem"];
    } else {
        ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:indexPath.row];
        cell.ImageActivity.image = [self.ActivityImageDictionary objectForKey: imgobject.key];
    }
    return cell;
    
}


/*
 created date:      28/04/2018
 last modified:     01/09/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */

    NSInteger NumberOfItems = self.Activity.images.count + 1;
        
    if (indexPath.row == NumberOfItems - 1) {
        self.imagestate = 1;
        [self InsertActivityImage];
    } else {
        if (!self.newitem) {
            ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:indexPath.row];
            self.SelectedImageKey = imgobject.key;
            self.SelectedImageReference = imgobject.ImageFileReference;
            self.SelectedImageIndex = [NSNumber numberWithLong:indexPath.row];
            if (imgobject.KeyImage==0) {
                self.ViewSelectedKey.hidden = true;
            } else {
                self.ViewSelectedKey.hidden = false;
            }
            [self.ImagePicture setImage: [self.ActivityImageDictionary objectForKey: imgobject.key]];
            
            if (imgobject.ImageFlaggedDeleted==0) {
                self.ViewTrash.hidden = true;
            } else {
                self.ViewTrash.hidden = false;
            }
            
        }
        else {
            ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:indexPath.row];
            [self.ImagePicture setImage: [self.ActivityImageDictionary objectForKey: imgobject.key]];
        }
    }
}

- (void)didCreatePoiFromProject :(NSString*)Key {
}



// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.TextFieldName.backgroundColor = [UIColor clearColor];
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


/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */

- (IBAction)SwitchViewPhotoOptionsChanged:(id)sender {
    [self.view layoutIfNeeded];
    
    if (self.ViewPhotos.hidden == false) {
        bool showkeyview = self.ViewSelectedKey.hidden;
        bool showdeletedflag = self.ViewTrash.hidden;
        self.ViewSelectedKey.hidden = true;
        self.ViewTrash.hidden = true;
        if (self.ViewBlurHeightConstraint.constant==BlurredImageViewPresentedHeight) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewBlurHeightConstraint.constant=0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.ViewSelectedKey.hidden = showkeyview;
                self.ViewTrash.hidden = showdeletedflag;
            }];
            
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewBlurHeightConstraint.constant=BlurredImageViewPresentedHeight;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.ViewSelectedKey.hidden = showkeyview;
                self.ViewTrash.hidden = showdeletedflag;
            }];
        }
    } else if (self.ViewMain.hidden == false) {

        if (self.ViewEffectBlurDetailHeightConstraint.constant==BlurredMainViewPresentedHeight) {
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewEffectBlurDetailHeightConstraint.constant=0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
            
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewEffectBlurDetailHeightConstraint.constant=BlurredMainViewPresentedHeight;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (IBAction)DeleteImageButtonPressed:(id)sender {
    bool DeletedFlagEnabled = false;
    if (self.Activity.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else {
        for (ImageNSO *item in self.Activity.images) {
            
            if ([item.ImageFileReference isEqualToString:self.SelectedImageReference]) {
                [self.realm beginWriteTransaction];
                if (item.ImageFlaggedDeleted==0) {
                    
                    self.ViewTrash.hidden = false;
                    item.ImageFlaggedDeleted = 1;
                    DeletedFlagEnabled = true;
                    item.UpdateImage = true;
                    
                }
                else {
                    self.ViewTrash.hidden = true;
                    item.ImageFlaggedDeleted = 0;
                }
                [self.realm commitWriteTransaction];
            }
        }
    }
}

/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (IBAction)KeyImageButtonPressed:(id)sender {
    bool KeyImageEnabled = false;
    if (self.Activity.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else if (self.Activity.images.count==1) {
        
    } else {
        [self.realm beginWriteTransaction];
        for (ImageNSO *item in self.Activity.images) {
            if ([item.ImageFileReference isEqualToString:self.SelectedImageReference]) {
                if (item.KeyImage==0) {
                    self.ViewSelectedKey.hidden = false;
                    item.KeyImage = 1;
                    KeyImageEnabled = true;
                    item.UpdateImage = true;
                } else {
                    self.ViewSelectedKey.hidden = true;
                    item.KeyImage = 0;
                    item.UpdateImage = true;
                }
            } else {
                if (item.KeyImage == 1) {
                    item.KeyImage = 0;
                    item.UpdateImage = true;
                }
            }
        }
        [self.realm commitWriteTransaction];
    }
    [self.delegate didUpdateActivityImages :true];
    
}

/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (IBAction)EditButtonPressed:(id)sender {
    self.imagestate = 2;
    [self InsertActivityImage];
}

/*
 created date:      08/09/2018
 last modified:     14/09/2018
 remarks:
 */
- (IBAction)UploadImagePressed:(id)sender {
    

    NSData *dataImage = UIImagePNGRepresentation(self.ImagePicture.image);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:0];

    NSString *ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/Activities/%@/%@.png",self.Activity.tripkey, self.Activity.compondkey, self.SelectedImageKey];

    NSString *ImageFileDirectory = [NSString stringWithFormat:@"Images/Trips/%@/Activities/%@",self.Activity.tripkey, self.Activity.compondkey];
    
    NSDictionary* dataJSON = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Activity",
                              @"type",
                              ImageFileReference,
                              @"filereference",
                              ImageFileDirectory,
                              @"directory",
                              stringImage,
                              @"image",
                              nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataJSON
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:imagesDirectory];
    url = [url URLByAppendingPathComponent:@"Activity.trippo"];
    
    [jsonData writeToURL:url atomically:NO];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        //Delete file
        NSError *errorBlock;
        if([[NSFileManager defaultManager] removeItemAtURL:url error:&errorBlock] == NO) {
            //NSLog(@"error deleting file %@",error);
            return;
        }
    }];
    
    
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

/*
 created date:      09/09/2018
 last modified:     09/09/2018
 remarks:  TODO, make sure it is optimal and not called multiple times!
 */
- (void)didUpdateActivityImages :(bool)ForceUpdate {
    
}


@end
