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
        [self.ButtonAction setTitle:@"Upd" forState:UIControlStateNormal];
        [self LoadExistingData];
        self.updatedimage = false;
    }
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(void) LoadExistingData {
    self.TextFieldName.text = self.Project.name;
    self.TextViewNotes.text = self.Project.privatenotes;
    [self.ImageViewProject setImage:self.Project.Image];
}


/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (IBAction)ProjectActionPressed:(id)sender {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];

    if (self.newitem) {
    
        self.Project.key = [[NSUUID UUID] UUIDString];
        NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Projects/%@",self.Project.key]];
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSData *imageData =  UIImagePNGRepresentation(self.Project.Image);
        NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
        [imageData writeToFile:filepathname atomically:YES];
        self.Project.imagefilereference = [NSString stringWithFormat:@"Projects/%@/image.png",self.Project.key];
    
        self.Project.privatenotes = self.TextViewNotes.text;
        self.Project.name = self.TextFieldName.text;
    
        [self.db InsertProjectItem :self.Project];
    }
    else {
        if ([self.Project.privatenotes isEqualToString:self.TextViewNotes.text] && [self.Project.name isEqualToString:self.TextFieldName.text] && !self.updatedimage) {
            // nothing to do
        } else {
            if (self.updatedimage) {
                NSData *imageData =  UIImagePNGRepresentation(self.Project.Image);
                NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Projects/%@",self.Project.key]];
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
                [imageData writeToFile:filepathname atomically:YES];
            }
            self.Project.privatenotes = self.TextViewNotes.text;
            self.Project.name = self.TextFieldName.text;
            [self.db UpdateProjectItem :self.Project];
        }
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
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
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
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
