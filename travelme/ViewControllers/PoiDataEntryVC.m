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
    }
    self.CollectionViewPoiImages.dataSource = self;
    self.CollectionViewPoiImages.delegate = self;
    // Do any additional setup after loading the view.

    UIFont *font = [UIFont fontWithName:@".SFUIText-Medium" size:10];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.SegmentTypeOfPoi setTitleTextAttributes:attributes forState:UIControlStateNormal];
}


/*
 created date:      28/04/2018
 last modified:     28/04/2018
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
    
    [self.MapView addAnnotation:anno];
    [self.MapView selectAnnotation:anno animated:YES];
    [self.MapView setCenterCoordinate:coord animated:YES];
    
    /* load images from file - TODO make sure we locate them all */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (PoiImageNSO *imageitem in self.PointOfInterest.Images) {
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageitem.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        imageitem.Image = [UIImage imageWithData:pngData];
    }

    /* Text fields and Segment */
    self.TextViewNotes.text = self.PointOfInterest.privatenotes;
    self.SegmentTypeOfPoi.selectedSegmentIndex = [self.PointOfInterest.categoryid longValue];
    self.LabelPoiName.text = [NSString stringWithFormat:@"Point Of Interest: %@",self.PointOfInterest.name];
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
        cell.ImagePoi.image = [UIImage imageNamed:@"AddPoiImage"];
    } else {
        PoiImageNSO *img = [self.PointOfInterest.Images objectAtIndex:indexPath.row];
        cell.ImagePoi.image = img.Image;
    }
    return cell;
}


/*
 created date:      28/04/2018
 last modified:     28/04/2018
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
            // preview item - TODO, does not work yet.
            // PoiImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PoiImageId" forIndexPath:indexPath];
            PoiImageNSO *item = [self.PointOfInterest.Images objectAtIndex:indexPath.row];
            
            [self.ImagePicture setImage:item.Image];
            
        }
        
        /* we show the image in main view */
        //PoiImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PoiImageId" forIndexPath:indexPath];
        
    }
    
    
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed cancel");
                                                           }];
    
    
    
    [alert addAction:cameraAction];
    [alert addAction:photorollAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
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
 last modified:     28/04/2018
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextViewNotes endEditing:YES];
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
    
    self.PointOfInterest.privatenotes = self.TextViewNotes.text;
    self.PointOfInterest.categoryid = [NSNumber numberWithLong:self.SegmentTypeOfPoi.selectedSegmentIndex];
    
    [self.db InsertPoiItem :self.PointOfInterest];
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:  Not Working
 */
- (IBAction)UpdatePoiItemPressed:(id)sender {

    self.PointOfInterest.privatenotes = self.TextViewNotes.text;
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
    [self.db UpdatePoiItem :self.PointOfInterest];

    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
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
        self.LabelPoiName.hidden=false;
        
    } else if (segment.selectedSegmentIndex==1) {
        self.MapView.hidden=false;
        
        self.CollectionViewPoiImages.hidden=true;
        self.ImagePicture.hidden=true;
        
        self.LabelPrivateNotes.hidden=true;
        self.TextViewNotes.hidden=true;
        self.SegmentTypeOfPoi.hidden=true;
        self.LabelPoiName.hidden=true;
        
    } else {
        self.MapView.hidden=true;
        
        self.CollectionViewPoiImages.hidden=false;
        self.ImagePicture.hidden=false;
        
        self.LabelPrivateNotes.hidden=true;
        self.TextViewNotes.hidden=true;
        self.SegmentTypeOfPoi.hidden=true;
        self.LabelPoiName.hidden=true;
    }

}


@end
