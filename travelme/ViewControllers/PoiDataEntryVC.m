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
 last modified:     19/07/2018
 remarks: TODO - split load existing data into 2 - map data and images.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
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
            self.PointOfInterest.Images = [NSMutableArray arrayWithArray:[AppDelegateDef.Db GetImagesForSelectedPoi:self.PointOfInterest.key]];

            self.CollectionViewPoiImages.scrollEnabled = true;
        }

        [self LoadExistingData];
        
    }
    
    self.ImagePicture.frame = CGRectMake(0, 0, self.ScrollViewImage.frame.size.width, self.ScrollViewImage.frame.size.height);
    self.ScrollViewImage.delegate = self;
    
    [self LoadTypePicker];
    
    self.PickerType.delegate = self;
    self.PickerType.dataSource = self;
    
    [self.PickerType selectRow:[self.PointOfInterest.categoryid longValue] inComponent:0 animated:YES];
    
    [self LoadMapData];

    self.CollectionViewPoiImages.dataSource = self;
    self.CollectionViewPoiImages.delegate = self;
    // Do any additional setup after loading the view.

    self.TextFieldTitle.layer.cornerRadius=8.0f;
    self.TextFieldTitle.layer.masksToBounds=YES;
    self.TextFieldTitle.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextFieldTitle.layer.borderWidth= 1.0f;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextViewNotes.layer.borderWidth= 1.0f;
    // heigtht of option blurred view is 60; view is 4 less; to make a circle we need half the remainder.
    self.ViewSelectedKey.layer.cornerRadius=28;
    self.ViewSelectedKey.layer.masksToBounds=YES;
    
    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    self.TextFieldTitle.delegate = self;
    self.TextViewNotes.delegate = self;
    
    self.ButtonUpdate.layer.cornerRadius = 25;
    self.ButtonUpdate.clipsToBounds = YES;
    
    self.ButtonCancel.layer.cornerRadius = 25;
    self.ButtonCancel.clipsToBounds = YES;
    
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.TypeItems.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *pickerCustomView = [UIView new];
    UIImageView *myIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.TypeItems[row]]];
    [myIcon setFrame:CGRectMake(5, 5, 30, 30)];
    [pickerCustomView addSubview:myIcon];
    return pickerCustomView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

/*
 created date:      11/06/2018
 last modified:     16/06/2018
 remarks:
 */
-(void) LoadTypePicker {
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
                             @"Zoo"
                             ];
    
    self.TypeDistanceItems  = @[
                             @40, // accomodation
                             @500, // airport
                             @20000, // astronaut
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

    self.LabelPoi.text = [self GetPoiLabelWithType:[NSNumber numberWithLong:[self.PointOfInterest.categoryid integerValue]]];
    
    if (self.newitem) {
        self.PointOfInterest.categoryid = [NSNumber numberWithInteger:0];
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
    
    NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PickerType selectedRowInComponent:0]];
    
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
 last modified:     19/07/2018
 remarks:
 */
-(void) LoadExistingData {

    /* load images from file - TODO make sure we locate them all */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    long ImageIndex = 0;
    for (PoiImageNSO *imageitem in self.PointOfInterest.Images) {
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageitem.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        imageitem.Image = [UIImage imageWithData:pngData];
        if (imageitem.KeyImage) {
            self.SelectedImageReference = imageitem.ImageFileReference;
            self.SelectedImageIndex = [NSNumber numberWithLong:ImageIndex];;
            self.ViewSelectedKey.hidden = false;
            [self.ImagePicture setImage:imageitem.Image];
            [self.ImageViewKey setImage:imageitem.Image];
        }
        ImageIndex ++;
    }
    /* Text fields and Segment */
    self.TextViewNotes.text = self.PointOfInterest.privatenotes;
    self.TextFieldTitle.text = self.PointOfInterest.name;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //if (self.readonlyitem) {
    //    return self.PointOfInterest.Images.count;
    //} else {
        return self.PointOfInterest.Images.count + 1;
    //}
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PoiImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PoiImageId" forIndexPath:indexPath];
    NSInteger NumberOfItems = self.PointOfInterest.Images.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.ImagePoi.image = [UIImage imageNamed:@"AddItem"];
    } else {
        PoiImageNSO *img = [self.PointOfInterest.Images objectAtIndex:indexPath.row];
        cell.ImagePoi.image = img.Image;
    }
    return cell;
}


/*
 created date:      28/04/2018
 last modified:     19/07/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */
    NSInteger NumberOfItems = self.PointOfInterest.Images.count + 1;
    
    if (indexPath.row == NumberOfItems - 1) {
        /* insert item */
        //self.PoiImage = [[PoiImageNSO alloc] init];
        self.imagestate = 1;
        [self InsertPoiImage];
    } else {
        
        if (!self.newitem) {
            PoiImageNSO *item = [self.PointOfInterest.Images objectAtIndex:indexPath.row];
            self.SelectedImageReference = item.ImageFileReference;
            self.SelectedImageIndex = [NSNumber numberWithLong:indexPath.row];
            if (item.KeyImage==0) {
                self.ViewSelectedKey.hidden = true;
            } else {
                self.ViewSelectedKey.hidden = false;
            }
            [self.ImagePicture setImage:item.Image];
        }
        else {
            PoiImageNSO *item = [self.PointOfInterest.Images objectAtIndex:indexPath.row];
            [self.ImagePicture setImage:item.Image];
        }
    }
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
 last modified:     14/07/2018
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
                                                                  controller.PointOfInterest = self.PointOfInterest;
                                                                  
                                                                  controller.distance = [self.TypeDistanceItems objectAtIndex:[self.PickerType selectedRowInComponent:0]];
                                                                  
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
                                                                  controller.PointOfInterest = self.PointOfInterest;
                                                                  
                                                                  controller.distance = [self.TypeDistanceItems objectAtIndex:[self.PickerType selectedRowInComponent:0]];
                                                                  
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
                                                        PoiImageNSO *img = [[PoiImageNSO alloc] init];
                                                        img.Image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                        if (self.PointOfInterest.Images.count==0) {
                                                           img.KeyImage = 1;
                                                        }
                                                        [self.PointOfInterest.Images addObject:img];
                                                    } else if (self.imagestate==2) {
                                                        
                                                        /* need to save the new image into file location on update */
                                                        
                                                        PoiImageNSO *PoiImage = [self.PointOfInterest.Images objectAtIndex:[self.SelectedImageIndex longValue]];
                                                        PoiImage.Image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                        PoiImage.UpdateImage = true;
                                                        [self.PointOfInterest.Images replaceObjectAtIndex:[self.SelectedImageIndex longValue] withObject:PoiImage];
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
 last modified:     02/05/2018
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
        PoiImageNSO *PoiImage = [[PoiImageNSO alloc] init];
        PoiImage.Image = chosenImage;
        if (self.PointOfInterest.Images.count==0) {
            PoiImage.KeyImage = 1;
        } else {
            PoiImage.KeyImage = 0;
        }
        [self.PointOfInterest.Images addObject:PoiImage];
    } else if (self.imagestate == 2) {
        PoiImageNSO *PoiImage = [self.PointOfInterest.Images objectAtIndex:[self.SelectedImageIndex longValue]];
        PoiImage.Image = chosenImage;
        PoiImage.UpdateImage = true;
        [self.PointOfInterest.Images replaceObjectAtIndex:[self.SelectedImageIndex longValue] withObject:PoiImage];
    }
    
    self.imagestate = 0;
    
    [self.CollectionViewPoiImages reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      21/05/2018
 last modified:     21/05/2018
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.CollectionViewPoiImages.frame.size.width - 20;
    float cellWidth = collectionWidth/6.0f;
    CGSize size = CGSizeMake(cellWidth,cellWidth);
    
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
 last modified:     10/08/2018
 remarks:
 */
- (IBAction)ActionButtonPressed:(id)sender {

    if (self.newitem) {
        /* manage the images if any exist */
        if (self.PointOfInterest.Images.count>0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];

            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",self.PointOfInterest.key]];
        
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

            int counter = 1;
            for (PoiImageNSO *imageitem in self.PointOfInterest.Images) {
                NSData *imageData =  UIImagePNGRepresentation(imageitem.Image);
                NSString *filename = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
                NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                [imageData writeToFile:filepathname atomically:YES];
                imageitem.NewImage = true;
                imageitem.ImageFileReference = [NSString stringWithFormat:@"Images/%@/%@",self.PointOfInterest.key,filename];
                counter++;
            }
        }
        self.PointOfInterest.name = self.TextFieldTitle.text;
        self.PointOfInterest.privatenotes = self.TextViewNotes.text;
        self.PointOfInterest.categoryid = [NSNumber numberWithLong:[self.PickerType selectedRowInComponent:0]];
        [AppDelegateDef.Db InsertPoiItem :self.PointOfInterest];
        
        if (self.fromproject) {
            [self.delegate didCreatePoiFromProject :self.PointOfInterest.name];
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (self.fromnearby) {
             [self.delegate didUpdatePoi:true];
             [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.delegate didUpdatePoi:true];
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }

    } else {
        self.PointOfInterest.name = self.TextFieldTitle.text;
        self.PointOfInterest.privatenotes = self.TextViewNotes.text;
    
        if ([self.PointOfInterest.privatenotes isEqualToString:@""]) {
            self.PointOfInterest.privatenotes = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@", self.PointOfInterest.name, self.PointOfInterest.fullthoroughfare, self.PointOfInterest.administrativearea, self.PointOfInterest.subadministrativearea,  self.PointOfInterest.locality, self.PointOfInterest.sublocality, self.PointOfInterest.postcode];
        
        }
        self.PointOfInterest.categoryid = [NSNumber numberWithLong:[self.PickerType selectedRowInComponent:0]];
    
        if (self.PointOfInterest.Images.count>0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
        
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",self.PointOfInterest.key]];
        
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        
            int counter = 1;
        
            /* handle new images, updated images are already identified in the button pressed actions */
            for (PoiImageNSO *imageitem in self.PointOfInterest.Images) {
            
                if ([imageitem.ImageFileReference isEqualToString:@""] || imageitem.ImageFileReference==nil) {
                    imageitem.NewImage = true;
                    NSData *imageData =  UIImagePNGRepresentation(imageitem.Image);
                    NSString *filename = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
                    NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                    [imageData writeToFile:filepathname atomically:YES];
                    imageitem.ImageFileReference = [NSString stringWithFormat:@"Images/%@/%@",self.PointOfInterest.key,filename];
                    NSLog(@"new image");
                } else if (imageitem.UpdateImage) {
                    NSData *imageData =  UIImagePNGRepresentation(imageitem.Image);
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imageitem.ImageFileReference];
                    [imageData writeToFile:filepathname atomically:YES];
                    NSLog(@"updated image");
                }
                counter++;
            }
        }
        // TODO - update only contains main items at the moment.  we need to apply columns all as anything can be updated now.
        
        [AppDelegateDef.Db UpdatePoiItem :self.PointOfInterest];
        [self.delegate didUpdatePoi:true];
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
 last modified:     21/05/2018
 remarks:
 */
-(IBAction)SegmentOptionChanged:(id)sender {
    
    UISegmentedControl *segment = sender;
    if (segment.selectedSegmentIndex==0) {
        self.MapView.hidden=true;
        self.CollectionViewPoiImages.hidden=true;
        self.ScrollViewImage.hidden=true;
        self.SwitchViewPhotoOptions.hidden=true;
        self.ViewBlurImageOptionPanel.hidden=true;
        self.LabelPrivateNotes.hidden=false;
        self.TextViewNotes.hidden=false;
        self.PickerType.hidden=false;
        self.TextFieldTitle.hidden=false;
        self.ImageViewKey.hidden=false;
        self.LabelPoi.hidden=false;
        
    } else if (segment.selectedSegmentIndex==1) {
        self.MapView.hidden=false;
        self.CollectionViewPoiImages.hidden=true;
        self.ScrollViewImage.hidden=true;
        self.SwitchViewPhotoOptions.hidden=true;
        self.ViewBlurImageOptionPanel.hidden=true;
        self.LabelPrivateNotes.hidden=true;
        self.TextViewNotes.hidden=true;
        self.PickerType.hidden=true;
        self.TextFieldTitle.hidden=true;
        self.ImageViewKey.hidden=true;
        self.LabelPoi.hidden=true;
        
        for (id<MKOverlay> overlay in self.MapView.overlays)
        {
            [self.MapView removeOverlay:overlay];
        }
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
        
        NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PickerType selectedRowInComponent:0]];
        
        [self.MapView setCenterCoordinate:coord animated:YES];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 2.1, [radius doubleValue] * 2.1);
        MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
        [self.MapView setRegion:adjustedRegion animated:YES];
        //100,000
        
        CLLocationDistance RadiusAmt = [radius doubleValue];
        
        self.CircleRange = [MKCircle circleWithCenterCoordinate:coord radius:RadiusAmt];
        
        [self.MapView addOverlay:self.CircleRange];
        
    } else {
        self.MapView.hidden=true;
        if (self.PointOfInterest.Images.count > 0 && !self.readonlyitem) {
        //if (self.PointOfInterest.Images.count > 0 ) {
            self.ViewBlurHeightConstraint.constant = 0;
            self.ViewBlurImageOptionPanel.hidden=false;
            self.SwitchViewPhotoOptions.hidden=false;
        }
        self.CollectionViewPoiImages.hidden=false;
        self.ScrollViewImage.hidden=false;
        self.LabelPrivateNotes.hidden=true;
        self.TextViewNotes.hidden=true;
        self.PickerType.hidden=true;
        self.TextFieldTitle.hidden=true;
        self.ImageViewKey.hidden=true;
        self.LabelPoi.hidden=true;
    }

}


-(NSString *)GetPoiLabelWithType :(NSNumber*) PoiType {
    NSString *LabelText;
    
    LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",[self.TypeLabelItems objectAtIndex:[PoiType integerValue]]];
    return LabelText;
}

/*
 created date:      14/07/2018
 last modified:     19/07/2018
 remarks:
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    self.LabelPoi.text = [self GetPoiLabelWithType:[NSNumber numberWithInteger:row]];
    self.PointOfInterest.categoryid = [NSNumber numberWithLong:[self.PickerType selectedRowInComponent:0]];


    
}

/*
 created date:      21/05/2018
 last modified:     21/05/2018
 remarks:
 */
- (IBAction)ButtonImageDeletePressed:(id)sender {
}

/*
 created date:      21/05/2018
 last modified:     19/07/2018
 remarks:
 */
- (IBAction)ButtonImageKeyPressed:(id)sender {

    bool KeyImageEnabled = false;
    if (self.PointOfInterest.Images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else if (self.PointOfInterest.Images.count==1) {
        
    } else {
        for (PoiImageNSO *item in self.PointOfInterest.Images) {
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
    }
    if (!KeyImageEnabled) {
        PoiImageNSO *item = [self.PointOfInterest.Images firstObject];
        item.KeyImage = 1;
        item.UpdateImage = true;
    }
}

/*
 created date:      11/06/2018
 last modified:     11/06/2018
 remarks:
 */
- (void)didAddImages :(NSMutableArray*)ImageCollection {
    bool AddedImage = false;
    for (ImageNSO *imageitem in ImageCollection) {
    
        PoiImageNSO *PoiImage = [[PoiImageNSO alloc] init];
        PoiImage.Image = imageitem.Image;
        if (self.PointOfInterest.Images.count==0) {
            PoiImage.KeyImage = 1;
        } else {
            PoiImage.KeyImage = 0;
        }
        [self.PointOfInterest.Images addObject:PoiImage];
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
        
        controller.PointOfInterest = self.PointOfInterest;
        controller.PointOfInterest.name = self.TextFieldTitle.text;
        controller.gsradius = [self.TypeDistanceItems objectAtIndex:[self.PickerType selectedRowInComponent:0]];
    } 
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
    self.ViewSelectedKey.hidden = true;
    if (self.ViewBlurHeightConstraint.constant==60) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.ViewSelectedKey.hidden = showkeyview;
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=60;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.ViewSelectedKey.hidden = showkeyview;
        }];
    }
}

/*
 created date:      13/07/2018
 last modified:     13/07/2018
 remarks:
 */
- (void)updatePoiFromWikiActvity :(PoiNSO*)PointOfInterest {
    self.PointOfInterest = PointOfInterest;
}

- (void)didCreatePoiFromProject :(NSString*)Key {
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
 last modified:     15/07/2018
 remarks:
 */
- (void)didUpdatePoi :(bool)IsUpdated {
    
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
    
    self.PointOfInterest.Coordinates = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:self.PointOfInterest.Coordinates.latitude longitude:self.PointOfInterest.Coordinates.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
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
                self.PointOfInterest.lat = [NSNumber numberWithDouble:self.PointOfInterest.Coordinates.latitude];
                self.PointOfInterest.lon = [NSNumber numberWithDouble:self.PointOfInterest.Coordinates.longitude];
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

@end
