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
    if (![self.PointOfInterest.name isEqualToString:@""]) {
        self.TextFieldTitle.text = self.PointOfInterest.name;
    }
    self.CollectionViewPoiImages.dataSource = self;
    self.CollectionViewPoiImages.delegate = self;
    // Do any additional setup after loading the view.
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
        cell.ImagePoi.image = [self.PointOfInterest.Images objectAtIndex:indexPath.row];
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
                                                                   picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                                                                   
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
    
    
    [self.PointOfInterest.Images addObject:chosenImage];
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
    /* save Poi and its images to the database! */
    /*
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     
     NSData *imageData =  UIImagePNGRepresentation(chosenImage);
     [imageData writeToFile:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"image.png"] atomically:YES];
     */
    
    
    
    
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



@end
