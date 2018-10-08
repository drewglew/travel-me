//
//  PoiDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiDataEntryVC.h"
#define CLCOORDINATE_EPSILON 0.005f
#define CLCOORDINATES_EQUAL2( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

@interface PoiDataEntryVC () <PoiDataEntryDelegate>

@end

@implementation PoiDataEntryVC
@synthesize delegate;

/*
 created date:      28/04/2018
 last modified:     08/09/2018
 remarks: TODO - split load existing data into 2 - map data and images.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.PoiImageDictionary = [[NSMutableDictionary alloc] init];
    if (self.newitem && !self.fromnearby) {
        if (![self.PointOfInterest.name isEqualToString:@""]) {
            self.TextFieldTitle.text = self.PointOfInterest.name;
            self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        } else {
            self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        }
    } else if (self.fromnearby) {
        self.TextFieldTitle.text = self.PointOfInterest.name;
        self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        
    } else {
        if (self.readonlyitem) {
            self.TextFieldTitle.enabled = false;
            [self.TextViewNotes setEditable:false];
            self.CollectionViewPoiImages.scrollEnabled = true;
        }
        
        [self LoadImageDataCollection];
        
        /* Text fields and Segment */
        self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        self.TextFieldTitle.text = self.PointOfInterest.name;
    }
    
    self.ImagePicture.frame = CGRectMake(0, 0, self.ScrollViewImage.frame.size.width, self.ScrollViewImage.frame.size.height);
    self.ScrollViewImage.delegate = self;
    
    [self LoadCategoryData];

    [self LoadMapData];

    self.CollectionViewPoiImages.dataSource = self;
    self.CollectionViewPoiImages.delegate = self;
    
    
    self.CollectionViewTypes.dataSource = self;
    self.CollectionViewTypes.delegate = self;
    // Do any additional setup after loading the view.

    self.TextFieldTitle.layer.cornerRadius=8.0f;
    self.TextFieldTitle.layer.masksToBounds=YES;
    self.TextFieldTitle.layer.borderColor=[[UIColor clearColor]CGColor];
    self.TextFieldTitle.layer.borderWidth= 1.0f;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextViewNotes.layer.borderWidth= 1.0f;
    // heigtht of option blurred view is 60; view is 4 less; to make a circle we need half the remainder.
    self.ViewSelectedKey.layer.cornerRadius=28;
    self.ViewSelectedKey.layer.masksToBounds=YES;
    
    self.ViewTrash.layer.cornerRadius=28;
    self.ViewTrash.layer.masksToBounds=YES;
    
    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    self.TextFieldTitle.delegate = self;
    self.TextViewNotes.delegate = self;
    
    self.ButtonUpdate.layer.cornerRadius = 25;
    self.ButtonUpdate.clipsToBounds = YES;
    
    self.ButtonCancel.layer.cornerRadius = 25;
    self.ButtonCancel.clipsToBounds = YES;
    self.ButtonCancel.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if (self.checkInternet) {
        if ([self.PointOfInterest.countrycode isEqualToString:@""]) {
            self.ButtonGeo.layer.cornerRadius = 25;
            self.ButtonGeo.clipsToBounds = YES;
            self.ButtonGeo.hidden = false;
        }
        // TODO we need to check if Poi has missing data and that the internet is available...
        
    }
    
    self.ButtonWiki.layer.cornerRadius = 25;
    self.ButtonWiki.clipsToBounds = YES;
    self.ButtonWiki.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonScan.layer.cornerRadius = 25;
    self.ButtonScan.clipsToBounds = YES;
    self.ButtonScan.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonUploadImages.layer.cornerRadius = 25;
    self.ButtonUploadImages.clipsToBounds = YES;
    self.ButtonUploadImages.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.ButtonUploadImages.hidden = true;
    /*
    if (self.PointOfInterest.averageactivityrating!=0) {
        self.LabelOccurances.text = [NSString stringWithFormat:@"%@ Occurances", self.PointOfInterest.connectedactivitycount];
        self.LabelOccurances.hidden=false;
        
        self.ViewStarRatings.allowsHalfStars=TRUE;
        self.ViewStarRatings.accurateHalfStars=TRUE;
        self.ViewStarRatings.value = [self.PointOfInterest.averageactivityrating floatValue];
        self.ViewStarRatings.hidden=false;
    }
    */
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.PointOfInterest.categoryid unsignedLongValue] inSection:0];
    [self.CollectionViewTypes scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
}

/*
 created date:      28/04/2018
 last modified:     19/07/2018
 remarks: TODO - split load existing data into 2 - map data and images.
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self.PointOfInterest.wikititle isEqualToString:@""]) {
        [self.ButtonWiki setImage:[UIImage imageNamed:@"WikiFilled"] forState:UIControlStateNormal];
    } else {
       [self.ButtonWiki setImage:[UIImage imageNamed:@"Wiki"] forState:UIControlStateNormal];
    }
}


/*
 created date:      11/06/2018
 last modified:     05/10/2018
 remarks:
 */
-(void) LoadCategoryData {
  
    self.TypeItems = @[@"Cat-Accomodation",
                       @"Cat-Airport",
                       @"Cat-Astronaut",
                       @"Cat-Beer",
                       @"Cat-Bike",
                       @"Cat-Bridge",
                       @"Cat-CarHire",
                       @"Cat-Casino",
                       @"Cat-Church",
                       @"Cat-City",
                       @"Cat-Club",
                       @"Cat-Concert",
                       @"Cat-FoodWine",
                       @"Cat-Historic",
                       @"Cat-House",
                       @"Cat-Lake",
                       @"Cat-Lighthouse",
                       @"Cat-Metropolis",
                       @"Cat-Misc",
                       @"Cat-Monument",
                       @"Cat-Museum",
                       @"Cat-Nature",
                       @"Cat-Office",
                       @"Cat-Restaurant",
                       @"Cat-Scenary",
                       @"Cat-Sea",
                       @"Cat-Ship",
                       @"Cat-Shopping",
                       @"Cat-Ski",
                       @"Cat-Sports",
                       @"Cat-Theatre",
                       @"Cat-ThemePark",
                       @"Cat-Train",
                       @"Cat-Trek",
                       @"Cat-Venue",
                       @"Cat-Village",
                       @"Cat-Zoo"
                       ];
    
    self.TypeLabelItems  = @[
                             @"Accomodation",
                             @"Airport",
                             @"Astronaut",
                             @"Beer",
                             @"Bicycle",
                             @"Bridge",
                             @"Car Hire",
                             @"Casino",
                             @"Church",
                             @"City",
                             @"Club",
                             @"Concert",
                             @"Food and Wine",
                             @"Historic",
                             @"House",
                             @"Lake",
                             @"Lighthouse",
                             @"Metropolis",
                             @"Miscellaneous",
                             @"Monument/Statue",
                             @"Museum",
                             @"Nature",
                             @"Office",
                             @"Restaurant",
                             @"Scenery",
                             @"Coast",
                             @"Ship",
                             @"Shopping",
                             @"Skiing",
                             @"Sports",
                             @"Theatre",
                             @"Theme Park",
                             @"Train",
                             @"Trekking",
                             @"Venue",
                             @"Village",
                             @"Zoo"
                             ];
    
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
                             @1000, // village 35
                             @1000 // zoo, 35
                             ];

    self.LabelPoi.text = [self GetPoiLabelWithType:self.PointOfInterest.categoryid];
    
    if (self.newitem) {
        self.PointOfInterest.categoryid = [NSNumber numberWithLong:0];
    }
}

/*
 created date:      11/06/2018
 last modified:     10/08/2018
 remarks:
 */
-(void) LoadMapData {
    /* set map */
    self.MapView.delegate = self;

    [self.MapView setShowsPointsOfInterest :YES];

    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.PointOfInterest.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.PointOfInterest.administrativearea];

    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    anno.coordinate = coord;
    
    NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
    
    [self.MapView setCenterCoordinate:coord animated:YES];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 2.1, [radius doubleValue] * 2.1);
    MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
    [self.MapView setRegion:adjustedRegion animated:YES];
    [self.MapView addAnnotation:anno];
    [self.MapView selectAnnotation:anno animated:YES];

}

/*
 created date:      14/07/2018
 last modified:     19/07/2018
 remarks: this method handles the map circle that is placed as overlay onto map
 */
- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay {
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer* aRenderer = [[MKCircleRenderer
                                        alloc]initWithCircle:(MKCircle *)overlay];
        aRenderer.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.9];
        aRenderer.lineWidth = 2;
        return aRenderer;
    }
    else
    {
        return nil;
    }
}

/*
 created date:      28/04/2018
 last modified:     31/08/2018
 remarks:
 */
-(void) LoadImageDataCollection {

    /* load images from file - TODO make sure we locate them all */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    for (ImageCollectionRLM *imageitem in self.PointOfInterest.images) {
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageitem.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        
        UIImage *image;
        if (pngData!=nil) {
            image = [UIImage imageWithData:pngData];
        } else {
            image = [UIImage imageNamed:@"Poi"];
        }
        if (imageitem.KeyImage) {
            self.SelectedImageKey = imageitem.key;
            self.ViewSelectedKey.hidden = false;
            [self.ImagePicture setImage:image];
            [self.ImageViewKey setImage:image];
        }
        [self.PoiImageDictionary setObject:image forKey:imageitem.key];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      28/04/2018
 last modified:     12/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.CollectionViewPoiImages) {
        return self.PointOfInterest.images.count + 1;
    } else {
        return self.TypeItems.count;
    }
}

/*
 created date:      28/04/2018
 last modified:     12/08/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (collectionView == self.CollectionViewPoiImages) {
    
        PoiImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PoiImageId" forIndexPath:indexPath];
        NSInteger NumberOfItems = self.PointOfInterest.images.count + 1;
        if (indexPath.row == NumberOfItems -1) {
            cell.ImagePoi.image = [UIImage imageNamed:@"AddItem"];
        } else {
            ImageCollectionRLM *imgreference = [self.PointOfInterest.images objectAtIndex:indexPath.row];
            cell.ImagePoi.image = [self.PoiImageDictionary objectForKey:imgreference.key];
        }
        return cell;
        
    } else {
        
        TypeCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"TypeCellId" forIndexPath:indexPath];
        cell.TypeImageView.image = [UIImage imageNamed:[self.TypeItems objectAtIndex:indexPath.row]];
        if ([self.PointOfInterest.categoryid unsignedLongValue] == indexPath.row) {
            cell.ImageViewChecked.hidden = false;
        } else {
            cell.ImageViewChecked.hidden = true;
        }
       
        return cell;
    }
}


/*
 created date:      28/04/2018
 last modified:     17/08/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */
    
    if (collectionView == self.CollectionViewPoiImages) {
        NSInteger NumberOfItems = self.PointOfInterest.images.count + 1;
        
        if (indexPath.row == NumberOfItems - 1) {
            /* insert item */
            //self.PoiImage = [[PoiImageNSO alloc] init];
            self.imagestate = 1;
            [self InsertPoiImage];
        } else {
            
            if (!self.newitem) {
                ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:indexPath.row];
                self.SelectedImageKey = imgobject.key;
                self.SelectedImageIndex = [NSNumber numberWithLong:indexPath.row];
                if (imgobject.KeyImage==0) {
                    self.ViewSelectedKey.hidden = true;
                } else {
                    self.ViewSelectedKey.hidden = false;
                }
                [self.ImagePicture setImage:[self.PoiImageDictionary objectForKey:imgobject.key]];
                self.LabelPhotoInfo.text = imgobject.info;
                if (imgobject.ImageFlaggedDeleted==0) {
                    self.ViewTrash.hidden = true;
                } else {
                     self.ViewTrash.hidden = false;
                }

            }
            else {
                ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:indexPath.row];
                [self.ImagePicture setImage:[self.PoiImageDictionary objectForKey:imgobject.key]];
                self.LabelPhotoInfo.text = imgobject.info;
            }
        }
    } else {
        if (!self.readonlyitem) {
            [self.realm beginWriteTransaction];
            self.PointOfInterest.categoryid = [NSNumber numberWithLong:indexPath.row];
            [self.realm commitWriteTransaction];
            self.LabelPoi.text = [NSString stringWithFormat:@"Point Of Interest - %@",[self.TypeLabelItems objectAtIndex:[self.PointOfInterest.categoryid longValue]]];
            [collectionView reloadData];
        }
    }
}

/*
 created date:      13/08/2018
 last modified:     13/08/2018
 remarks:           Scrolls to selected catagory item.
 */
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    /*
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.PointOfInterest.categoryid unsignedLongValue] inSection:0];
    [self.CollectionViewTypes scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    */
}


/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks:
 */
-(PHFetchResult*) getAssetsFromLibraryWithStartDate:(NSDate *)startDate andEndDate:(NSDate*) endDate
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate > %@ AND creationDate < %@",startDate ,endDate];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    return allPhotos;
}

/*
 created date:      28/04/2018
 last modified:     30/08/2018
 remarks:
 */
-(void)InsertPoiImage {
    
    
    NSString *titleMessage = @"How would you like to add a photo to your Point Of Interest?";
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
                                                                  copiedpoi.key = self.PointOfInterest.key;
                                                                  copiedpoi.lon = self.PointOfInterest.lon;
                                                                  copiedpoi.lat = self.PointOfInterest.lat;
                                                                  copiedpoi.name = self.PointOfInterest.name;
                                                                  
                                                                  controller.PointOfInterest = copiedpoi;
                                                                  
                                                                  controller.distance = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
                                                                  
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
                                                                  copiedpoi.key = self.PointOfInterest.key;
                                                                  copiedpoi.lon = self.PointOfInterest.lon;
                                                                  copiedpoi.lat = self.PointOfInterest.lat;
                                                                  copiedpoi.name = self.PointOfInterest.name;
                                                                  copiedpoi.wikititle = self.PointOfInterest.wikititle;
                                                                  controller.PointOfInterest = copiedpoi;
                                                                  
                                                                  controller.distance = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
                                                                  
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
                                        CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);
                                        
                                        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                            targetSize:size
                                            contentMode:PHImageContentModeAspectFill
                                            options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                                                  
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                     
                                                    CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);

                                                    if (self.imagestate==1) {
                                                        ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
                                                        imgobject.key = [[NSUUID UUID] UUIDString];
                                                        
                                                        UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                        if (self.PointOfInterest.images.count==0) {
                                                           imgobject.KeyImage = 1;
                                                        }
                                                        [self.PoiImageDictionary setObject:image forKey:imgobject.key];
                                                        
                                                        [self.realm beginWriteTransaction];
                                                        [self.PointOfInterest.images.realm addObject:imgobject];
                                                        [self.realm commitWriteTransaction];
                                                        
                                                    } else if (self.imagestate==2) {
                                                        
                                                        /* need to save the new image into file location on update */
                                                        
                                                        ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:[self.SelectedImageIndex longValue]];
                                                        
                                                        UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                        [self.PoiImageDictionary setObject:image forKey:imgobject.key];
                                                        [self.realm beginWriteTransaction];
                                                        imgobject.UpdateImage = true;
                                                        [self.realm commitWriteTransaction];
                                                    }
                                                    [self.CollectionViewPoiImages reloadData];
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
    if (![self.PointOfInterest.wikititle isEqualToString:@""]) {
        [alert addAction:photoWikiAction];
    }
    [alert addAction:lastphotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
 created date:      28/04/2018
 last modified:     26/09/2018
 remarks:
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
   
    // OCR scan
    if (self.imagestate==3) {

        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:originalImage];
        cropViewController.delegate = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:cropViewController animated:YES completion:nil];
        }];
        
    } else {
        /* normal image from camera */
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        CGSize size;
        if (self.newitem) {
            size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width *2);
        } else {
            size = CGSizeMake(self.ImagePicture.frame.size.width * 2, self.ImagePicture.frame.size.width *2);
        }
        chosenImage = [ToolBoxNSO imageWithImage:chosenImage scaledToSize:size];
        if (self.imagestate==1) {
            ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
            imgobject.key = [[NSUUID UUID] UUIDString];
            
            if (self.PointOfInterest.images.count==0) {
                imgobject.KeyImage = 1;
            } else {
                imgobject.KeyImage = 0;
            }
            
            [self.realm beginWriteTransaction];
            [self.PointOfInterest.images addObject:imgobject];
            [self.realm commitWriteTransaction];
            
            [self.PoiImageDictionary setObject:chosenImage forKey:imgobject.key];
            
        } else if (self.imagestate == 2) {
            ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:[self.SelectedImageIndex longValue]];
            
            [self.realm beginWriteTransaction];
            imgobject.UpdateImage = true;
            [self.realm commitWriteTransaction];
            
            [self.PoiImageDictionary setObject:chosenImage forKey:imgobject.key];
        }
        [self.CollectionViewPoiImages reloadData];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
    }
    self.imagestate = 0;

}






/*
 created date:      26/09/2018
 last modified:     26/09/2018
 remarks:           TODO - is it worth presenting the black and white image?
 */
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    //tesseract.charWhitelist = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'-?@$%&().,:;";
    tesseract.image = [image g8_blackAndWhite];
    tesseract.maximumRecognitionTime = 20.0;
    [tesseract recognize];

    if (!self.TextViewNotes.selectedTextRange.empty) {
        // use selected position to obtain location where to add the text
        [self.TextViewNotes replaceRange:self.TextViewNotes.selectedTextRange withText:[tesseract recognizedText]];
    } else {
        // append to the end of the detail.
        self.TextViewNotes.text = [NSString stringWithFormat:@"%@\n%@", self.TextViewNotes.text, [tesseract recognizedText]];
    }
    NSLog(@"%@", [tesseract recognizedText]);
    
    [cropViewController dismissViewControllerAnimated:YES completion:NULL];
}



/*
 created date:      21/05/2018
 last modified:     21/05/2018
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CGSize size;
    if (collectionView == self.CollectionViewPoiImages) {
        /*CGFloat collectionWidth = self.CollectionViewPoiImages.frame.size.width - 20;
        float cellWidth = collectionWidth/6.0f;
        size = CGSizeMake(cellWidth,cellWidth);*/
        size = CGSizeMake(100,100);
    } else {
        size = CGSizeMake(50,50);
    }
    return size;
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextViewNotes endEditing:YES];
    [self.TextFieldTitle endEditing:YES];
}



/*
 created date:      28/04/2018
 last modified:     18/08/2018
 remarks:
 */
- (IBAction)ActionButtonPressed:(id)sender {

    if (self.newitem) {
        
        /* manage the images if any exist */
        if (self.PointOfInterest.images.count>0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];

            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",self.PointOfInterest.key]];
        
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

            for (ImageCollectionRLM *imgobject in self.PointOfInterest.images) {
                NSData *imageData =  UIImagePNGRepresentation([self.PoiImageDictionary objectForKey:imgobject.key]);
                NSString *filename = [NSString stringWithFormat:@"%@.png", imgobject.key];
                NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                [imageData writeToFile:filepathname atomically:YES];
                imgobject.NewImage = true;
                imgobject.ImageFileReference = [NSString stringWithFormat:@"Images/%@/%@",self.PointOfInterest.key,filename];
                
            }
        }
        self.PointOfInterest.name = self.TextFieldTitle.text;
        self.PointOfInterest.privatenotes = self.TextViewNotes.text;
        self.PointOfInterest.modifieddt = [NSDate date];
        self.PointOfInterest.createddt = [NSDate date];
        self.PointOfInterest.searchstring =  [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",self.PointOfInterest.name,self.PointOfInterest.administrativearea,self.PointOfInterest.subadministrativearea,self.PointOfInterest.postcode,self.PointOfInterest.locality,self.PointOfInterest.sublocality,self.PointOfInterest.country];
        
        [self.realm beginWriteTransaction];
        [self.realm addObject:self.PointOfInterest];
        [self.realm commitWriteTransaction];

        
        if (self.fromproject) {
            [self.delegate didCreatePoiFromProject :self.PointOfInterest];
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (self.fromnearby) {
            [self.delegate didUpdatePoi:@"created" :self.PointOfInterest];
             [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.delegate didUpdatePoi:@"created" :self.PointOfInterest];
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }

    } else {
        [self.realm beginWriteTransaction];
        self.PointOfInterest.name = self.TextFieldTitle.text;
        self.PointOfInterest.privatenotes = self.TextViewNotes.text;
        self.PointOfInterest.modifieddt = [NSDate date];
        self.PointOfInterest.searchstring =  [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",self.PointOfInterest.name,self.PointOfInterest.administrativearea,self.PointOfInterest.subadministrativearea,self.PointOfInterest.postcode,self.PointOfInterest.locality,self.PointOfInterest.sublocality,self.PointOfInterest.country];
        
        if ([self.PointOfInterest.privatenotes isEqualToString:@""]) {
            self.PointOfInterest.privatenotes = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@", self.PointOfInterest.name, self.PointOfInterest.fullthoroughfare, self.PointOfInterest.administrativearea, self.PointOfInterest.subadministrativearea,  self.PointOfInterest.locality, self.PointOfInterest.sublocality, self.PointOfInterest.postcode];
        
        }
    
        if (self.PointOfInterest.images.count > 0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
        
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",self.PointOfInterest.key]];
        
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

            NSInteger count = [self.PointOfInterest.images count];
            //bool NoKeyPhoto = true;
            /* loop through in reverse as it is easier to handle deletions in array */
            for (NSInteger index = (count - 1); index >= 0; index--) {
                ImageCollectionRLM *imgobject = self.PointOfInterest.images[index];
                if (imgobject.ImageFlaggedDeleted) {
                    /* else we are good to delete it */
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    NSError *error = nil;
                    BOOL success = [fm removeItemAtPath:filepathname error:&error];
                    if (!success || error) {
                        NSLog(@"something failed in deleting unwanted data");
                    }
                    [self.PointOfInterest.images removeObjectAtIndex:index];
                } else if ([imgobject.ImageFileReference isEqualToString:@""] || imgobject.ImageFileReference==nil) {
                    /* here we add the attachment to file system and dB */
                    imgobject.NewImage = true;
                    NSData *imageData =  UIImagePNGRepresentation([self.PoiImageDictionary objectForKey:imgobject.key]);
                    NSString *filename = [NSString stringWithFormat:@"%@.png", imgobject.key];
                    NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                    [imageData writeToFile:filepathname atomically:YES];
                    imgobject.ImageFileReference = [NSString stringWithFormat:@"Images/%@/%@",self.PointOfInterest.key,filename];
                    NSLog(@"new image");
                } else if (imgobject.UpdateImage) {
                    /* we might swap it out as user has replaced the original file */
                    NSData *imageData =  UIImagePNGRepresentation([self.PoiImageDictionary objectForKey:imgobject.key]);
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    [imageData writeToFile:filepathname atomically:YES];
                    imgobject.UpdateImage = false;
                    NSLog(@"updated image");
                }
                
            }
        }
        [self.realm commitWriteTransaction];
        [self.delegate didUpdatePoi:@"modified" :self.PointOfInterest];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
}

/*
 created date:      28/04/2018
 last modified:     21/05/2018
 remarks:
 */
- (IBAction)UpdatePoiItemPressed:(id)sender {

}

/*
 created date:      28/04/2018
 last modified:     26/09/2018
 remarks:
 */
-(IBAction)SegmentOptionChanged:(id)sender {
    
    UISegmentedControl *segment = sender;
    if (segment.selectedSegmentIndex==0) {
        self.ViewMain.hidden = false;
        self.ViewNotes.hidden = true;
        self.ViewMap.hidden = true;
        self.ViewPhotos.hidden =true;
        self.SwitchViewPhotoOptions.hidden=true;
        self.ButtonUploadImages.hidden=true;
        if (self.ButtonGeo.layer.cornerRadius==25) {
            self.ButtonGeo.hidden = false;
        }
        self.ButtonScan.hidden = true;

    } else if (segment.selectedSegmentIndex==1) {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = false;
        self.ButtonScan.hidden = false;
        self.ViewMap.hidden = true;
        self.ViewPhotos.hidden =true;
        self.SwitchViewPhotoOptions.hidden=true;
        self.ButtonUploadImages.hidden = true;
        self.ButtonGeo.hidden = true;
        
     } else if (segment.selectedSegmentIndex==2) {
         self.ViewMain.hidden = true;
         self.ViewNotes.hidden = true;
         self.ViewMap.hidden = false;
         self.ViewPhotos.hidden =true;
         self.SwitchViewPhotoOptions.hidden=true;
         self.ButtonGeo.hidden = true;
         self.ButtonScan.hidden = true;
        
        for (id<MKOverlay> overlay in self.MapView.overlays)
        {
            [self.MapView removeOverlay:overlay];
        }
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
        
        NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
        
        [self.MapView setCenterCoordinate:coord animated:YES];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 2.1, [radius doubleValue] * 2.1);
        MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
        [self.MapView setRegion:adjustedRegion animated:YES];

        CLLocationDistance RadiusAmt = [radius doubleValue];
        
        self.CircleRange = [MKCircle circleWithCenterCoordinate:coord radius:RadiusAmt];
        
        [self.MapView addOverlay:self.CircleRange];
        self.ButtonUploadImages.hidden = true;
        
    } else {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = true;
        self.ViewMap.hidden = true;
        self.ViewPhotos.hidden =false;
        self.ButtonGeo.hidden = true;
        self.ButtonUploadImages.hidden = false;
        self.ButtonScan.hidden = true;

        if (self.PointOfInterest.images.count > 0 && !self.readonlyitem) {
            self.ViewBlurHeightConstraint.constant = 0;
            self.ViewBlurImageOptionPanel.hidden=false;
            self.SwitchViewPhotoOptions.hidden=false;
        }
    }
}


-(NSString *)GetPoiLabelWithType :(NSNumber*) PoiType {
    NSString *LabelText;
    
    LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",[self.TypeLabelItems objectAtIndex:[PoiType integerValue]]];
    return LabelText;
}



/*
 created date:      21/05/2018
 last modified:     30/08/2018
 remarks:
 */
- (IBAction)ButtonImageDeletePressed:(id)sender {
    bool DeletedFlagEnabled = false;
    if (self.PointOfInterest.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else {
        for (ImageCollectionRLM *imgobject in self.PointOfInterest.images) {
           
            if ([imgobject.key isEqualToString:self.SelectedImageKey]) {
                 [self.realm beginWriteTransaction];
                if (imgobject.ImageFlaggedDeleted==0) {
                    //if (item.KeyImage==0) {
                        self.ViewTrash.hidden = false;
                        imgobject.ImageFlaggedDeleted = 1;
                        DeletedFlagEnabled = true;
                        imgobject.UpdateImage = true;
                    //}
                }
                else {
                    self.ViewTrash.hidden = true;
                    imgobject.ImageFlaggedDeleted = 0;
                }
                [self.realm commitWriteTransaction];
            }
            
        }
    }

    
    
}

/*
 created date:      21/05/2018
 last modified:     09/08/2018
 remarks:
 */
- (IBAction)ButtonImageKeyPressed:(id)sender {

    bool KeyImageEnabled = false;
    if (self.PointOfInterest.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else if (self.PointOfInterest.images.count==1) {
        
    } else {
        [self.realm beginWriteTransaction];
        for (ImageCollectionRLM *imgobject in self.PointOfInterest.images) {
            
            if ([imgobject.key isEqualToString:self.SelectedImageKey]) {
                if (imgobject.KeyImage==0) {
                    self.ViewSelectedKey.hidden = false;
                    imgobject.KeyImage = 1;
                    KeyImageEnabled = true;
                    imgobject.UpdateImage = true;
                    [self.ImageViewKey setImage:self.ImagePicture.image];
                } else {
                    self.ViewSelectedKey.hidden = true;
                    imgobject.KeyImage = 0;
                    imgobject.UpdateImage = true;
                }
            } else {
                if (imgobject.KeyImage == 1) {
                    imgobject.KeyImage = 0;
                    imgobject.UpdateImage = true;
                }
            }
            
        }
        [self.realm commitWriteTransaction];
    }
}

/*
 created date:      11/06/2018
 last modified:     01/09/2018
 remarks:
 */
- (void)didAddImages :(NSMutableArray*)ImageCollection {
    bool AddedImage = false;
    for (ImageNSO *img in ImageCollection) {
    
        ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
        imgobject.key = [[NSUUID UUID] UUIDString];
        [self.PoiImageDictionary setObject:img.Image forKey:imgobject.key];
        
        if (self.PointOfInterest.images.count==0) {
            imgobject.KeyImage = 1;
        } else {
            imgobject.KeyImage = 0;
        }
        imgobject.info = img.Description;
        [self.realm beginWriteTransaction];
        [self.PointOfInterest.images addObject:imgobject];
        [self.realm commitWriteTransaction];
        
        AddedImage = true;
    }
    if (AddedImage) {
        [self.CollectionViewPoiImages reloadData];
    }

}

/*
 created date:      13/06/2018
 last modified:     16/06/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"WikiGenerator"]){
        WikiVC *controller = (WikiVC *)segue.destinationViewController;
        controller.delegate = self;
        
        PoiRLM *poi = [[PoiRLM alloc] init];
        poi.name = self.PointOfInterest.name;
        poi.lat = self.PointOfInterest.lat;
        poi.lon = self.PointOfInterest.lon;
        poi.wikititle = self.PointOfInterest.wikititle;
        poi.key = self.PointOfInterest.key;
        
        controller.PointOfInterest = poi;
        controller.PointOfInterest.name = self.TextFieldTitle.text;
        controller.gsradius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
    } 
}


/*
 created date:      26/09/2018
 last modified:     26/09/2018
 remarks:
 */
- (IBAction)ButtonWikiPressed:(id)sender {


    if (self.SegmentDetailOption.selectedSegmentIndex!=1) {
       
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        WikiVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"WikiViewId"];
        controller.delegate = self;
        
        PoiRLM *poi = [[PoiRLM alloc] init];
        poi.name = self.PointOfInterest.name;
        poi.lat = self.PointOfInterest.lat;
        poi.lon = self.PointOfInterest.lon;
        poi.wikititle = self.PointOfInterest.wikititle;
        poi.key = self.PointOfInterest.key;
        
        controller.PointOfInterest = poi;
        controller.PointOfInterest.name = self.TextFieldTitle.text;
        controller.gsradius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        if (![self.PointOfInterest.wikititle isEqualToString:@""]) {
            // add text to notes from wiki page.
  
            NSArray *parms = [self.PointOfInterest.wikititle componentsSeparatedByString:@"~"];
            
            NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=%@",[parms objectAtIndex:0],[parms objectAtIndex:1]];
            
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            /* get data */
            [self fetchFromWikiApi:url withDictionary:^(NSDictionary *data) {
                
                NSDictionary *query = [data objectForKey:@"query"];
                NSDictionary *pages =  [query objectForKey:@"pages"];
                NSArray *keys = [pages allKeys];
                NSDictionary *item =  [pages objectForKey:[keys firstObject]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (!self.TextViewNotes.selectedTextRange.empty) {
                    
                        // use selected position to obtain location where to add the text
                        [self.TextViewNotes replaceRange:self.TextViewNotes.selectedTextRange withText:[item objectForKey:@"extract"]];
                        
                    } else {
                        // we append to the end of the contents.
                        NSString *content = self.TextViewNotes.text;
                        if ([content isEqualToString:@""]) {
                            content = [item objectForKey:@"extract"];
                        } else {
                            content = [NSString stringWithFormat:@"%@\n\n%@", content, [item objectForKey:@"extract"]];
                        }
                        self.TextViewNotes.text = content;
                    }
                });
            }];
            
        }
        
    }
}


/*
 created date:      26/09/2018
 last modified:     26/09/2018
 remarks:           Copied from Nearby View Controller 
 */
-(void)fetchFromWikiApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
}








/*
 created date:      23/05/2018
 last modified:     19/07/2018
 remarks:
 */
- (IBAction)ButtonImageEditPressed:(id)sender {
    self.imagestate = 2;
    [self InsertPoiImage];
}

- (IBAction)SwitchViewPhotoOptionsChanged:(id)sender {
    [self.view layoutIfNeeded];
    bool showkeyview = self.ViewSelectedKey.hidden;
    bool showdeletedflag = self.ViewTrash.hidden;
    self.ViewSelectedKey.hidden = true;
    self.ViewTrash.hidden = true;
    if (self.ViewBlurHeightConstraint.constant==60) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.ViewSelectedKey.hidden = showkeyview;
            self.ViewTrash.hidden = showdeletedflag;
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=60;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.ViewSelectedKey.hidden = showkeyview;
            self.ViewTrash.hidden = showdeletedflag;
        }];
    }
}

/*
 created date:      13/07/2018
 last modified:     31/08/2018
 remarks:
 */
- (void)updatePoiFromWikiActvity :(PoiRLM*)Object {

    [self.realm beginWriteTransaction];
    self.PointOfInterest.wikititle = Object.wikititle;
    [self.realm commitWriteTransaction];
    
}

- (void)didCreatePoiFromProject :(PoiRLM*)Object {
}

- (void)didCreatePoiFromNearby {
}

/* Delegate methods for ScrollView */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.ScrollViewImage viewWithTag:5];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
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

- (IBAction)TitleEditingDidEnd:(id)sender {
     //[self.TextFieldTitle resignFirstResponder];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.TextFieldTitle.backgroundColor = [UIColor whiteColor];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.TextFieldTitle.backgroundColor = [UIColor clearColor];
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
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    
}

/*
 created date:      28/04/2018
 last modified:     19/07/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    
    if (self.newitem) {
        // discard wikipage if it exists!
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
        
        NSError *error = nil;
        [fileManager removeItemAtPath:wikiDataFilePath error:&error];
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (bool)checkInternet
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        return false;
    }
    else
    {
        //connection available
        return true;
    }
    
}

/*
 created date:      10/08/2018
 last modified:     10/08/2018
 remarks: TODO add all items that might have originally been added on insert.
 */
- (IBAction)GeoButtonPressed:(id)sender {
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    self.Coordinates = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:self.Coordinates.latitude longitude:self.Coordinates.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
        } else {
            if ([placemarks count]>0) {
                CLPlacemark *placemark = [placemarks firstObject];
                NSString *AdminArea = placemark.subAdministrativeArea;
                if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                    AdminArea = placemark.administrativeArea;
                }
                
                NSLog(@"%@",placemark);
                self.PointOfInterest.administrativearea = placemark.administrativeArea;
                self.PointOfInterest.lat = [NSNumber numberWithDouble:self.Coordinates.latitude];
                self.PointOfInterest.lon = [NSNumber numberWithDouble:self.Coordinates.longitude];
                self.PointOfInterest.country = placemark.country;
                self.PointOfInterest.countrycode = placemark.ISOcountryCode;
                self.PointOfInterest.locality = placemark.locality;
                self.PointOfInterest.sublocality = placemark.subLocality;
                self.PointOfInterest.fullthoroughfare = placemark.thoroughfare;
                self.PointOfInterest.postcode = placemark.postalCode;
                self.PointOfInterest.subadministrativearea = placemark.subAdministrativeArea;
                self.ButtonGeo.hidden = true;
                /* reset note if it contains autotext detail */

                [self.TextViewNotes setText:[self.TextViewNotes.text stringByReplacingOccurrencesOfString:@"No GeoData has been supplied except coordinates. Please press 'Geo' button when internet connectivity is next available!" withString:@""]];
                
            } else {
                self.PointOfInterest.administrativearea = @"Unknown Place";
            }
           
        }
    }];
    
    
}
/*
 created date:      08/09/2018
 last modified:     08/09/2018
 remarks:
 */
- (IBAction)UploadImagesPressed:(id)sender {
    
    
    NSData *dataImage = UIImagePNGRepresentation(self.ImagePicture.image);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:0];

    NSString *ImageFileReference = [NSString stringWithFormat:@"Images/%@/%@.png",self.PointOfInterest.key, self.SelectedImageKey];
    
    NSString *ImageFileDirectory = [NSString stringWithFormat:@"Images/%@",self.PointOfInterest.key];

    NSDictionary* dataJSON = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Point of Interest",
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
    url = [url URLByAppendingPathComponent:@"Poi.trippo"];
    
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
 created date:      25/09/2018
 last modified:     25/09/2018
 remarks:           OCR obtain image and scan for text
 */
- (IBAction)ScanImagePressed:(id)sender {
    
    self.imagestate=3;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }else
    {
       
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;

        //picker.
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    
    
    
}



@end
