//
//  DatePickerRangeVC.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "DatePickerRangeVC.h"

@interface DatePickerRangeVC ()

@end

@implementation DatePickerRangeVC
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.DatePickerStart.date = self.Activity.startdt;
    self.DatePickerEnd.date = self.Activity.enddt;
    

}


- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)StartDateAdjusted:(id)sender {
    if (self.DatePickerStart.date > self.DatePickerEnd.date) {
        self.ButtonAcceptDates.alpha = 0.5f;
        self.ButtonAcceptDates.enabled = false;
    } else {
        self.ButtonAcceptDates.alpha = 1.0f;
        self.ButtonAcceptDates.enabled = true;
    }
}


- (IBAction)EndDateAdjusted:(id)sender {
    if (self.DatePickerStart.date > self.DatePickerEnd.date) {
        self.ButtonAcceptDates.alpha = 0.5f;
        self.ButtonAcceptDates.enabled = false;
    } else {
        self.ButtonAcceptDates.alpha = 1.0f;
        self.ButtonAcceptDates.enabled = true;
    }
}

- (IBAction)AcceptDatesPressed:(id)sender {
    [self.delegate didPickDateSelection :self.DatePickerStart.date :self.DatePickerEnd.date];
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}
- (void)didPickDateSelection :(NSDate*)Start :(NSDate*)End {
    
}


@end
