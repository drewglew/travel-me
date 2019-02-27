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
#import "ActivityRLM.h"
#import "ImageCollectionRLM.h"
#import "TextFieldDatePicker.h"

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
@property (weak, nonatomic) IBOutlet UIButton *ButtonUploadImage;
@property (weak, nonatomic) IBOutlet UILabel *LabelFlags;
@property (weak, nonatomic) IBOutlet UILabel *LabelEstCalcTitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelActCalcTitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelEstCalcDist;
@property (weak, nonatomic) IBOutlet UILabel *LabelActCalcDist;
@property (weak, nonatomic) IBOutlet UILabel *LabelEstCalcTravelTime;
@property (weak, nonatomic) IBOutlet UILabel *LabelActCalcTravelTime;
@property (nonatomic, strong)IBOutlet UIDatePicker *datePickerStart;
@property (nonatomic, strong)IBOutlet UIDatePicker *datePickerEnd;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldStartDt;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldEndDt;


@property (nonatomic, weak) id <ProjectDataEntryDelegate> delegate;
@end
