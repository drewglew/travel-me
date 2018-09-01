//
//  ProjectDataEntry.h
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ProjectNSO.h"
#import "AppDelegate.h"
#import "ToolBoxNSO.h"
#import <Realm/Realm.h>
#import "TripRLM.h"
#import "ImageCollectionRLM.h"

@protocol ProjectDataEntryDelegate <NSObject>
@end

@interface ProjectDataEntryVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) ProjectNSO *Project;
@property TripRLM *Trip;

@property (weak, nonatomic) IBOutlet UIView *ViewProjectImage;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewProject;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldName;
@property (assign) bool newitem;
@property (assign) bool deleteitem;
@property (assign) bool updatedimage;
@property RLMRealm *realm;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAction;
@property (weak, nonatomic) IBOutlet UIButton *ButtonEditImage;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfo;
@property (weak, nonatomic) IBOutlet UIView *ViewNotes;
@property (weak, nonatomic) IBOutlet UIView *ViewMain;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;



@property (nonatomic, weak) id <ProjectDataEntryDelegate> delegate;
@end
