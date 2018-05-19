//
//  ProjectDataEntry.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectDataEntryVC.h"

@interface ProjectDataEntryVC ()

@end

@implementation ProjectDataEntryVC
@synthesize delegate;

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.newitem) {
        if (self.deleteitem) {
            [self.ButtonAction setTitle:@"Del" forState:UIControlStateNormal];
            
            UIImage *btnImage = [UIImage imageNamed:@"Delete"];
            [self.ButtonAction setImage:btnImage forState:UIControlStateNormal];
            [self.ButtonAction setTitle:@"" forState:UIControlStateNormal];
            //[self.ButtonAction setBackgroundColor:[UIColor clearColor]];
            
            self.ButtonEditImage.hidden = true;
            self.LabelInfo.hidden = false;
            self.LabelInfo.text = @"Confirm Deletion";
        } else {
            [self.ButtonAction setTitle:@"Upd" forState:UIControlStateNormal];
        }
        [self LoadExistingData];
        self.updatedimage = false;
    }
    self.TextFieldName.layer.cornerRadius=8.0f;
    self.TextFieldName.layer.masksToBounds=YES;
    self.TextFieldName.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextFieldName.layer.borderWidth= 1.0f;

    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    self.TextViewNotes.layer.borderColor=[[UIColor colorWithRed:246.0f/255.0f green:247.0f/255.0f blue:235.0f/255.0f alpha:1.0]CGColor];
    self.TextViewNotes.layer.borderWidth= 1.0f;
    
}

/*
 created date:      29/04/2018
 last modified:     02/05/2018
 remarks:
 */
-(void) LoadExistingData {
    self.TextFieldName.text = self.Project.name;
    self.TextViewNotes.text = self.Project.privatenotes;
    if (![self.Project.imagefilereference isEqualToString:@""]) {
        [self.ImageViewProject setImage:self.Project.Image];
    } else {
        [self.ImageViewProject setImage:[UIImage imageNamed:@"Project"]];
    }
}


/*
 created date:      29/04/2018
 last modified:     13/05/2018
 remarks:
 */
- (IBAction)ProjectActionPressed:(id)sender {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];

    if (self.newitem) {
    
        self.Project.key = [[NSUUID UUID] UUIDString];
        if (self.updatedimage) {
  
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Projects/%@",self.Project.key]];
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        
            NSData *imageData =  UIImagePNGRepresentation(self.Project.Image);
            NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
            [imageData writeToFile:filepathname atomically:YES];
            self.Project.imagefilereference = [NSString stringWithFormat:@"Projects/%@/image.png",self.Project.key];
        } else {
            self.Project.imagefilereference = @"";
        }
        
        self.Project.privatenotes = self.TextViewNotes.text;
        self.Project.name = self.TextFieldName.text;
    
        [AppDelegateDef.Db InsertProjectItem :self.Project];
    }
    else if (self.deleteitem) {
        [AppDelegateDef.Db DeleteProject:self.Project];
    }
    else
    {
        if ([self.Project.privatenotes isEqualToString:self.TextViewNotes.text] && [self.Project.name isEqualToString:self.TextFieldName.text] && !self.updatedimage) {
            // nothing to do
        } else {
            if (self.updatedimage) {
                NSData *imageData =  UIImagePNGRepresentation(self.Project.Image);
                NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Projects/%@",self.Project.key]];
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
                [imageData writeToFile:filepathname atomically:YES];
                self.Project.imagefilereference = [NSString stringWithFormat:@"Images/Projects/%@/image.png",self.Project.key];
            }
            self.Project.privatenotes = self.TextViewNotes.text;
            self.Project.name = self.TextFieldName.text;
            [AppDelegateDef.Db UpdateProjectItem :self.Project];
        }
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      29/04/2018
 last modified:     05/04/2018
 remarks:
 */
- (IBAction)EditImagePressed:(id)sender {
    
    NSString *titleMessage = @"How would you like to add a photo to your Project?";
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

                                        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                                               targetSize:self.ImageViewProject.frame.size
                                                                              contentMode:PHImageContentModeAspectFill
                                                                                  options:options
                                                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    
                                                                                    self.Project.Image = result;
                                                                                    self.ImageViewProject.image = result;
                                                                                    
                                                                                    if (!self.newitem) {
                                                                                        self.updatedimage = true;
                                                                                    }
                                                                                    
                                                                                });
                                                                            }];                                    
                                    }
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
    [alert addAction:lastphotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    chosenImage = [ToolBoxNSO imageWithImage:chosenImage scaledToSize:self.ImageViewProject.frame.size];
    self.Project.Image = chosenImage;
    self.ImageViewProject.image = chosenImage;
    
    if (!self.newitem) {
        self.updatedimage = true;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextViewNotes endEditing:YES];
    [self.TextFieldName endEditing:YES];
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
