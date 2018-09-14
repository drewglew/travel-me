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
    
    [self.DatePickerStart setValue:[UIColor colorWithRed:11.0f/255.0f green:110.0f/255.0f blue:79.0f/255.0f alpha:1.0] forKey:@"textColor"];
    [self.DatePickerEnd setValue:[UIColor colorWithRed:11.0f/255.0f green:110.0f/255.0f blue:79.0f/255.0f alpha:1.0] forKey:@"textColor"];
}


- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)StartDateAdjusted:(id)sender {
    if ([self.DatePickerStart.date compare: self.DatePickerEnd.date] == NSOrderedDescending) {
        self.ButtonAcceptDates.alpha = 0.5f;
        self.ButtonAcceptDates.enabled = false;
        self.DatePickerEnd.date = self.DatePickerStart.date;
    } else {
        self.ButtonAcceptDates.alpha = 1.0f;
        self.ButtonAcceptDates.enabled = true;
    }
}


- (IBAction)EndDateAdjusted:(id)sender {
    if ([self.DatePickerStart.date compare: self.DatePickerEnd.date] == NSOrderedDescending) {
        self.ButtonAcceptDates.alpha = 0.5f;
        self.ButtonAcceptDates.enabled = false;
         self.DatePickerStart.date = self.DatePickerEnd.date;
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
