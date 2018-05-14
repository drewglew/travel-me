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
 last modified:     28/04/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.newitem) {
        if (![self.PointOfInterest.name isEqualToString:@""]) {
            self.TextFieldTitle.text = self.PointOfInterest.name;
        }
    } else {
        [self LoadExistingData];
        if (self.readonlyitem) {
            self.TextFieldTitle.enabled = false;
            [self.TextViewNotes setEditable:false];
            self.SegmentTypeOfPoi.enabled = false;
            [self.CollectionViewPoiImages setUserInteractionEnabled:false];
            self.CollectionViewPoiImages.scrollEnabled = true;
        }
    }
    self.CollectionViewPoiImages.dataSource = self;
    self.CollectionViewPoiImages.delegate = self;
    // Do any additional setup after loading the view.

    
    self.LabelPoi.text = [self GetPoiLabelWithType:[NSNumber numberWithLong:self.SegmentTypeOfPoi.selectedSegmentIndex]];
    
    
    
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Airport"] forSegmentAtIndex:0];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Scenary"] forSegmentAtIndex:1];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Historic"] forSegmentAtIndex:2];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Museum"] forSegmentAtIndex:3];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Restaurant"] forSegmentAtIndex:4];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Accomodation"] forSegmentAtIndex:5];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"City"] forSegmentAtIndex:6];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Venue"] forSegmentAtIndex:7];
    [self.SegmentTypeOfPoi setImage:[UIImage imageNamed:@"Misc"] forSegmentAtIndex:8];
    
    self.TextFieldTitle.layer.cornerRadius=8.0f;
    self.TextFieldTitle.layer.masksToBounds=YES;
    self.TextFieldTitle.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextFieldTitle.layer.borderWidth= 1.0f;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextViewNotes.layer.borderWidth= 1.0f;
    
}


/*
 created date:      28/04/2018
 last modified:     29/04/2018
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
    for (PoiImageNSO *imageitem in self.PointOfInterest.Images) {
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageitem.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        imageitem.Image = [UIImage imageWithData:pngData];
        if (imageitem.KeyImage) {
            [self.ImagePicture setImage:imageitem.Image];
            [self.ImageViewKey setImage:imageitem.Image];
        }
    }

    /* Text fields and Segment */
    self.TextViewNotes.text = self.PointOfInterest.privatenotes;
    self.SegmentTypeOfPoi.selectedSegmentIndex = [self.PointOfInterest.categoryid longValue];
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
    return self.PointOfInterest.Images.count + 1;
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
 last modified:     29/04/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */
    NSInteger NumberOfItems = self.PointOfInterest.Images.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        /* insert item */
        [self InsertPoiImage];
        
    } else {
        
        if (!self.newitem) {
            PoiImageNSO *item = [self.PointOfInterest.Images objectAtIndex:indexPath.row];
            
            [self.ImagePicture setImage:item.Image];
            
        }
    }
}

/*
 created date:      28/04/2018
 last modified:     05/04/2018
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
                                                    PoiImageNSO *img = [[PoiImageNSO alloc] init];
                                                    img.Image = [ToolBoxNSO imageWithImage:result scaledToSize:size];;
                                                    img.KeyImage = 1;
                                                    [self.PointOfInterest.Images addObject:img];
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
    PoiImageNSO *img = [[PoiImageNSO alloc] init];
    img.Image = chosenImage;
    img.KeyImage = 1;
    [self.PointOfInterest.Images addObject:img];
    [self.CollectionViewPoiImages reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
 last modified:     28/04/2018
 remarks:
 */
- (IBAction)AddPoiItemPressed:(id)sender {
    
    /* manage the images if any exist */
    if (self.PointOfInterest.Images.count>0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];

        NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",self.PointOfInterest.key]];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

        int counter = 1;
        for (PoiImageNSO *imageitem in self.PointOfInterest.Images) {
            if (counter==1) {
                imageitem.KeyImage = 1;
            } else {
                imageitem.KeyImage = 0;
            }
           
            
            
            NSData *imageData =  UIImagePNGRepresentation(imageitem.Image);
            NSString *filename = [NSString stringWithFormat:@"image_%03d.png",counter];
            NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
            
            
            
            [imageData writeToFile:filepathname atomically:YES];
            imageitem.NewImage = true;
            imageitem.ImageFileReference = [NSString stringWithFormat:@"%@/%@",self.PointOfInterest.key,filename];
            counter++;
        }
    }
    
    self.PointOfInterest.name = self.TextFieldTitle.text;
    self.PointOfInterest.privatenotes = self.TextViewNotes.text;
    self.PointOfInterest.categoryid = [NSNumber numberWithLong:self.SegmentTypeOfPoi.selectedSegmentIndex];
    
    [AppDelegateDef.Db InsertPoiItem :self.PointOfInterest];
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



/*
 created date:      28/04/2018
 last modified:     03/04/2018
 remarks:
 */
- (IBAction)UpdatePoiItemPressed:(id)sender {

    self.PointOfInterest.name = self.TextFieldTitle.text;
    self.PointOfInterest.privatenotes = self.TextViewNotes.text;
    
    if ([self.PointOfInterest.privatenotes isEqualToString:@""]) {
        self.PointOfInterest.privatenotes = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@", self.PointOfInterest.name, self.PointOfInterest.fullthoroughfare, self.PointOfInterest.administrativearea, self.PointOfInterest.subadministrativearea,  self.PointOfInterest.locality, self.PointOfInterest.sublocality, self.PointOfInterest.postcode];
        
    }
    
    self.PointOfInterest.categoryid = [NSNumber numberWithLong:self.SegmentTypeOfPoi.selectedSegmentIndex];

    if (self.PointOfInterest.Images.count>0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
    
        NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",self.PointOfInterest.key]];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
    
        int counter = 1;
        for (PoiImageNSO *imageitem in self.PointOfInterest.Images) {

            if ([imageitem.ImageFileReference isEqualToString:@""] || imageitem.ImageFileReference==nil) {
                if (counter==1) {
                    imageitem.KeyImage = 1;
                } else {
                    imageitem.KeyImage = 0;
                }
                imageitem.NewImage = true;
                
                NSData *imageData =  UIImagePNGRepresentation(imageitem.Image);
                NSString *filename = [NSString stringWithFormat:@"image_%03d.png",counter];
                NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                [imageData writeToFile:filepathname atomically:YES];
                imageitem.ImageFileReference = [NSString stringWithFormat:@"%@/%@",self.PointOfInterest.key,filename];
                NSLog(@"new image");
            }
            counter++;
        }
    }
    [AppDelegateDef.Db UpdatePoiItem :self.PointOfInterest];

    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(IBAction)SegmentOptionChanged:(id)sender {
    
    UISegmentedControl *segment = sender;
    if (segment.selectedSegmentIndex==0) {
        self.MapView.hidden=true;
        
        self.CollectionViewPoiImages.hidden=true;
        self.ImagePicture.hidden=true;
        
        self.LabelPrivateNotes.hidden=false;
        self.TextViewNotes.hidden=false;
        self.SegmentTypeOfPoi.hidden=false;
        self.TextFieldTitle.hidden=false;
        self.ImageViewKey.hidden=false;
        self.LabelPoi.hidden=false;
        
    } else if (segment.selectedSegmentIndex==1) {
        self.MapView.hidden=false;
        
        self.CollectionViewPoiImages.hidden=true;
        self.ImagePicture.hidden=true;
        
        self.LabelPrivateNotes.hidden=true;
        self.TextViewNotes.hidden=true;
        self.SegmentTypeOfPoi.hidden=true;
        self.TextFieldTitle.hidden=true;
        self.ImageViewKey.hidden=true;
        self.LabelPoi.hidden=true;
        
    } else {
        self.MapView.hidden=true;
        
        self.CollectionViewPoiImages.hidden=false;
        self.ImagePicture.hidden=false;
        
        self.LabelPrivateNotes.hidden=true;
        self.TextViewNotes.hidden=true;
        self.SegmentTypeOfPoi.hidden=true;
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



- (IBAction)SegmentTypeChanged:(id)sender {
    
    self.LabelPoi.text = [self GetPoiLabelWithType:[NSNumber numberWithLong:self.SegmentTypeOfPoi.selectedSegmentIndex]];
    
}


@end
