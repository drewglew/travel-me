//
//  ActivityDiaryCell.m
//  trippo-app
//
//  Created by andrew glew on 20/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "ActivityDiaryCell.h"



@implementation ActivityDiaryCell

@synthesize TextFieldStartDt, TextFieldEndDt, datePickerStart, datePickerEnd, datePickerToolbar;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.datePickerStart = [[UIDatePicker alloc] init];
    self.datePickerStart.datePickerMode = UIDatePickerModeDateAndTime;
    //self.datePickerStart.date = self.activity.startdt;
    [self.datePickerStart addTarget:self action:@selector(datePickerStartValueChanged:) forControlEvents:UIControlEventValueChanged]; // method to respond to changes in the picker value
    
    self.datePickerEnd = [[UIDatePicker alloc] init];
    self.datePickerEnd.datePickerMode = UIDatePickerModeDateAndTime;
    //self.datePickerEnd.date = self.activity.enddt;
    [self.datePickerEnd addTarget:self action:@selector(datePickerEndValueChanged:) forControlEvents:UIControlEventValueChanged]; // method to respond to changes in the picker value

    self.datePickerToolbar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    [self.datePickerToolbar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissPicker:)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [ self.datePickerToolbar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    //self.TextFieldStartDt.delegate = self;
    self.TextFieldStartDt.inputView = self.datePickerStart;
    self.TextFieldStartDt.inputAccessoryView = self.datePickerToolbar;
    

    //self.TextFieldEndDt.delegate = self;
    self.TextFieldEndDt.inputView = self.datePickerEnd;
    self.TextFieldEndDt.inputAccessoryView = self.datePickerToolbar;
   
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected)
    {
        self.CellBorder.layer.cornerRadius = 10.0f;
        self.CellBorder.layer.borderWidth  = 2.5f;
        self.CellBorder.layer.masksToBounds = YES;
        self.CellBorder.layer.borderColor  = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0].CGColor;
    }
    else
    {
        self.CellBorder.layer.borderWidth  = 0.0f;
    }
    
}






/*
 created date:      22/02/2019
 last modified:     24/02/2019
 remarks:           Must stay on active line - due to validations.  TODO - resolve that!
                    Max/Min simply done, not taking into account things outside of Trip.
 */
-(void)dismissPicker:(id)sender{

    NSDate *startdt = self.datePickerStart.date;
    NSDate *enddt = self.datePickerEnd.date;

    RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey=%@ and state=%@",self.activity.tripkey, self.activity.state];
    
    if (activities.count==0) {
        
        [self.activity.realm beginWriteTransaction];
        self.activity.startdt = self.datePickerStart.date;
        self.activity.enddt = self.datePickerEnd.date;
        [self.activity.realm commitWriteTransaction];
        [self endEditing:YES];
        
    } else {
        
        NSString *AlertMessage = [[NSString alloc] init];
        
        bool ErrorInCurrentItem = false;
        for (ActivityRLM* activity in activities) {
            
            /* we do not want to waste comparing activity against itself */
            if (![self.activity.key isEqualToString:activity.key]) {
                NSDate *activitystartdt = activity.startdt;
                NSDate *activityenddt = activity.enddt;
                
                NSComparisonResult resultactivitystartdtstartdt = [activitystartdt compare:startdt];
                NSComparisonResult resultactivitystartdtenddt = [activitystartdt compare:enddt];
                NSComparisonResult resultactivityenddtstartdt = [activityenddt compare:startdt];
                NSComparisonResult resultactivityenddtenddt = [activityenddt compare:enddt];
                
                //whats bad??
                if ((resultactivitystartdtstartdt == NSOrderedAscending && resultactivitystartdtenddt == NSOrderedDescending && resultactivityenddtenddt == NSOrderedDescending) ||
                    (resultactivityenddtstartdt == NSOrderedDescending && resultactivityenddtenddt == NSOrderedAscending && resultactivitystartdtstartdt ==  NSOrderedAscending)) {
                    ErrorInCurrentItem = true;
                    NSString *prettystartdt = [ToolBoxNSO FormatPrettyDate :activity.startdt];
                    NSString *prettyenddt = [ToolBoxNSO FormatPrettyDate :activity.enddt];
                    AlertMessage = [NSString stringWithFormat:@"This activity must be contained within the date range %@ and %@ found in activity %@ or outside these bounds.  Please modify and correct before updating.", prettystartdt, prettyenddt, activity.name];
                    break;
                }
            }
        }
        if (ErrorInCurrentItem) {
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Error in date range"
                                         message:AlertMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self.datePickerStart resignFirstResponder];
                                           [self.datePickerEnd resignFirstResponder];
                                       }];
            
            [alert addAction:okButton];
            
            UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            if ( viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed ) {
                viewController = viewController.presentedViewController;
            }
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint
                                              constraintWithItem:alert.view
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                              toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                              multiplier:1
                                              constant:viewController.view.frame.size.height*2.0f];
            
            [alert.view addConstraint:constraint];
            [viewController presentViewController:alert animated:YES completion:^{}];

        } else  {
            [self.activity.realm beginWriteTransaction];
            self.activity.startdt = self.datePickerStart.date;
            self.activity.enddt = self.datePickerEnd.date;
            [self.activity.realm commitWriteTransaction];
            [self endEditing:YES];
        }
    }
}

/*
 created date:      22/02/2019
 last modified:     22/02/2019
 remarks:
 */
- (void)datePickerStartValueChanged:(id)sender{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    UIDatePicker *datePickerStart = (UIDatePicker*)sender;
    [self.TextFieldStartDt setText:[df stringFromDate:datePickerStart.date]];
}

/*
 created date:      22/02/2019
 last modified:     22/02/2019
 remarks:
 */
- (void)datePickerEndValueChanged:(id)sender{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    UIDatePicker *datePickerEnd = (UIDatePicker*)sender;
    [self.TextFieldEndDt setText:[df stringFromDate:datePickerEnd.date]];
}



@end
