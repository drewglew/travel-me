//
//  PoiDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiDataEntryVC.h"

@interface PoiDataEntryVC () <PoiDataEntryDelegate>

@end

@implementation PoiDataEntryVC
@synthesize delegate;

/*
 created date:      28/04/2018
 last modified:     21/05/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.newitem) {
        if (![self.PointOfInterest.name isEqualToString:@""]) {
            self.TextFieldTitle.text = self.PointOfInterest.name;
        }
    } else {
        if (self.readonlyitem) {
            self.TextFieldTitle.enabled = false;
            [self.TextViewNotes setEditable:false];
            self.PointOfInterest.Images = [NSMutableArray arrayWithArray:[AppDelegateDef.Db GetImagesForSelectedPoi:self.PointOfInterest.key]];
            
            //[self.CollectionViewPoiImages setUserInteractionEnabled:false];
            self.CollectionViewPoiImages.scrollEnabled = true;
        }
        [self LoadExistingData];
        
    }
    self.CollectionViewPoiImages.dataSource = self;
    self.CollectionViewPoiImages.delegate = self;
    // Do any additional setup after loading the view.

    
    self.LabelPoi.text = [self GetPoiLabelWithType:[NSNumber numberWithLong:[self.PointOfInterest.categoryid integerValue]]];
    
    self.PickerType.delegate = self;
    self.PickerType.dataSource = self;
    

    self.TypeItems = @[@"Airport",@"Scenary",@"Historic",@"Museum",@"Restaurant",@"Accomodation",@"City",@"Venue",@"Misc"];
    
    [self.PickerType selectRow:[self.PointOfInterest.categoryid integerValue] inComponent:0 animated:YES];
    
    
    
    self.TextFieldTitle.layer.cornerRadius=8.0f;
    self.TextFieldTitle.layer.masksToBounds=YES;
    self.TextFieldTitle.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextFieldTitle.layer.borderWidth= 1.0f;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextViewNotes.layer.borderWidth= 1.0f;
    
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
    [myIcon setFrame:CGRectMake(0, 5, 60, 60)];
    [pickerCustomView addSubview:myIcon];
    return pickerCustomView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 70;
}

/*
 created date:      28/04/2018
 last modified:     21/05/2018
 remarks:
 */
-(void) LoadExistingData {
    
    /* set map */
    self.MapView.delegate = self;
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.PointOfInterest.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.PointOfInterest.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    anno.coordinate = coord;
    
    [self.MapView setCenterCoordinate:coord animated:YES];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
    [self.MapView setRegion:adjustedRegion animated:YES];
    [self.MapView addAnnotation:anno];
    [self.MapView selectAnnotation:anno animated:YES];
    
    
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
            UIImage *btnImage = [UIImage imageNamed:@"Key"];
            [self.ButtonKey setImage:btnImage forState:UIControlStateNormal];
            [self.ImagePicture setImage:imageitem.Image];
            [self.ImageViewKey setImage:imageitem.Image];
        }
        ImageIndex ++;
    }

    /* Text fields and Segment */
    self.TextViewNotes.text = self.PointOfInterest.privatenotes;
    [self.PickerType selectRow:[self.PointOfInterest.categoryid integerValue] inComponent:0 animated:YES];
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
    if (self.readonlyitem) {
        return self.PointOfInterest.Images.count;
    } else {
        return self.PointOfInterest.Images.count + 1;
    }
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
 last modified:     21/05/2018
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
                UIImage *btnImage = [UIImage imageNamed:@"Key-Off"];
                [self.ButtonKey setImage:btnImage forState:UIControlStateNormal];
            } else {
                UIImage *btnImage = [UIImage imageNamed:@"Key"];
                [self.ButtonKey setImage:btnImage forState:UIControlStateNormal];
            }
            [self.ImagePicture setImage:item.Image];
        }
    }
}

/*
 created date:      28/04/2018
 last modified:     21/05/2018
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
                                        CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width, self.TextViewNotes.frame.size.width);
                                        
                                        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                            targetSize:size
                                            contentMode:PHImageContentModeAspectFill
                                            options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                                                  
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                     
                                                    CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width, self.TextViewNotes.frame.size.width);

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
 last modified:     28/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}




/*
 created date:      28/04/2018
 last modified:     26/05/2018
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
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
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
        [AppDelegateDef.Db UpdatePoiItem :self.PointOfInterest];
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
        self.ImagePicture.hidden=true;
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
        self.ImagePicture.hidden=true;
        self.SwitchViewPhotoOptions.hidden=true;
        self.ViewBlurImageOptionPanel.hidden=true;
        self.LabelPrivateNotes.hidden=true;
        self.TextViewNotes.hidden=true;
        self.PickerType.hidden=true;
        self.TextFieldTitle.hidden=true;
        self.ImageViewKey.hidden=true;
        self.LabelPoi.hidden=true;
        
    } else {
        self.MapView.hidden=true;
        if (self.PointOfInterest.Images.count > 0 && !self.readonlyitem) {
            //self.ViewBlurHeightConstraint.constant = 0;
            self.ViewBlurImageOptionPanel.hidden=false;
            self.SwitchViewPhotoOptions.hidden=false;
        }
        self.CollectionViewPoiImages.hidden=false;
        self.ImagePicture.hidden=false;
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
    
    switch ([PoiType intValue])
    
    {
        case 0:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Service"];
            break;
        case 1:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Scenary"];
            break;
        case 2:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Historic"];
            break;
        case 3:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Museum"];
            break;
        case 4:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Restaurant"];
            break;
        case 5:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Accomodation"];
            break;
        case 6:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"City/Town"];
            break;
        case 7:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Venue"];
            break;
        case 8:
            LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",@"Miscellaneous"];
            break;
        default:
            LabelText = @"Point Of Interest";
            break;
    }

    return LabelText;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.LabelPoi.text = [self GetPoiLabelWithType:[NSNumber numberWithInteger:row]];
    
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
 last modified:     23/05/2018
 remarks:
 */
- (IBAction)ButtonImageKeyPressed:(id)sender {

    if (self.PointOfInterest.Images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else if (self.PointOfInterest.Images.count==1) {
        
    } else {
        for (PoiImageNSO *item in self.PointOfInterest.Images) {
            if ([item.ImageFileReference isEqualToString:self.SelectedImageReference]) {
                if (item.KeyImage==0) {
                    UIImage *btnImage = [UIImage imageNamed:@"Key"];
                    [self.ButtonKey setImage:btnImage forState:UIControlStateNormal];
                    item.KeyImage = 1;
                    item.UpdateImage = true;
                } else {
                    UIImage *btnImage = [UIImage imageNamed:@"Key-Off"];
                    [self.ButtonKey setImage:btnImage forState:UIControlStateNormal];
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
}
/*
 created date:      23/05/2018
 last modified:     23/05/2018
 remarks:
 */
- (IBAction)ButtonImageEditPressed:(id)sender {
    self.imagestate = 2;
    [self InsertPoiImage];
}

- (IBAction)SwitchViewPhotoOptionsChanged:(id)sender {
    [self.view layoutIfNeeded];
    if (self.ViewBlurHeightConstraint.constant==60) {
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=60;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}



@end
