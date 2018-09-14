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
 last modified:     09/09/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Do any additional setup after loading the view.
    if (!self.newitem) {
        if (self.deleteitem) {
            self.ButtonAction.backgroundColor = [UIColor redColor];
            UIImage *btnImage = [UIImage imageNamed:@"Delete"];
            [self.ButtonAction setImage:btnImage forState:UIControlStateNormal];
            [self.ButtonAction setTitle:@"" forState:UIControlStateNormal];
            
            self.ButtonEditImage.hidden = true;
            self.LabelInfo.hidden = false;
            self.LabelInfo.text = @"Confirm Deletion";
        } else {
            [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
        }
        [self LoadExistingData];
        self.updatedimage = false;
    }

     
    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    self.TextViewNotes.delegate = self;
    self.TextFieldName.delegate = self;
    
    self.ButtonBack.layer.cornerRadius = 25;
    self.ButtonBack.clipsToBounds = YES;
    self.ButtonBack.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonUploadImage.layer.cornerRadius = 25;
    self.ButtonUploadImage.clipsToBounds = YES;
    self.ButtonUploadImage.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonAction.layer.cornerRadius = 25;
    self.ButtonAction.clipsToBounds = YES;
    self.ButtonAction.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
}

/*
 created date:      29/04/2018
 last modified:     29/08/2018
 remarks:
 */
-(void) LoadExistingData {
    
    self.TextFieldName.text = self.Trip.name;
    self.TextViewNotes.text = self.Trip.privatenotes;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    ImageCollectionRLM *image = [self.Trip.images firstObject];
    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    if (pngData!=nil) {
        self.ImageViewProject.image = [UIImage imageWithData:pngData];
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

        self.Trip.key = [[NSUUID UUID] UUIDString];
        if (self.updatedimage) {
  
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@",self.Trip.key]];
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        
            //ImageCollectionRLM *image = [self.Trip.images firstObject];
            
            NSData *imageData =  UIImagePNGRepresentation(self.ImageViewProject.image);
            
            NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
            [imageData writeToFile:filepathname atomically:YES];
            
            ImageCollectionRLM *image = [[ImageCollectionRLM alloc] init];
            image.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
            [self.Trip.images addObject:image];
            
        } else {
            ImageCollectionRLM *image = [[ImageCollectionRLM alloc] init];
            image.ImageFileReference = @"";
            [self.Trip.images addObject:image];
        }
        
        
        self.Trip.name = self.TextFieldName.text;
        self.Trip.privatenotes = self.TextViewNotes.text;
        self.Trip.modifieddt = [NSDate date];
        self.Trip.createddt = [NSDate date];
        
        [self.realm beginWriteTransaction];
        [self.realm addObject:self.Trip];
        [self.realm commitWriteTransaction];
        
        //[AppDelegateDef.Db InsertProjectItem :self.Project];
    }
    else if (self.deleteitem) {
        /* TODO - are you sure?? */
        [self.realm beginWriteTransaction];
        RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey=%@",self.Trip.key];
        [self.realm deleteObjects:activities];
        [self.realm deleteObject:self.Trip];
        [self.realm commitWriteTransaction];
        
        //[AppDelegateDef.Db DeleteProject:self.Project];
    }
    else
    {
        if ([self.Trip.privatenotes isEqualToString:self.TextViewNotes.text] && [self.Trip.name isEqualToString:self.TextFieldName.text] && !self.updatedimage) {
            // nothing to do
        } else {
            [self.Trip.realm beginWriteTransaction];
            if (self.updatedimage) {
                NSData *imageData =  UIImagePNGRepresentation(self.ImageViewProject.image);
                NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@",self.Trip.key]];
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
                [imageData writeToFile:filepathname atomically:YES];
                ImageCollectionRLM *image = [self.Trip.images firstObject];
                image.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
            }
            
            self.Trip.privatenotes = self.TextViewNotes.text;
            self.Trip.name = self.TextFieldName.text;
            self.Trip.modifieddt = [NSDate date];
            [self.Trip.realm commitWriteTransaction];

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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.TextViewNotes = textView;
}

-(void)doneButtonClickedDismissKeyboard
{
    [self.TextViewNotes resignFirstResponder];
}


/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
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
- (IBAction)SegmentViewChanged:(id)sender {
    UISegmentedControl *segment = sender;
    if (segment.selectedSegmentIndex==0) {
        self.ViewMain.hidden = false;
        self.ViewNotes.hidden = true;
    } else {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = false;
    }
    
}

/*
 created date:      09/09/2018
 last modified:     09/09/2018
 remarks:
 */
- (IBAction)UploadImagePressed:(id)sender {
    NSData *dataImage = UIImagePNGRepresentation(self.ImageViewProject.image);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:0];
    
    NSString *ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
    
    NSString *ImageFileDirectory = [NSString stringWithFormat:@"Images/Trips/%@",self.Trip.key];
    
    NSDictionary* dataJSON = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Trip",
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
    url = [url URLByAppendingPathComponent:@"Trip.trippo"];
    
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


@end