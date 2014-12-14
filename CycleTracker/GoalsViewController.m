//
//  GoalsViewController.m
//  CycleTracker
//
//  Created by Phillip Sime on 11/29/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import "GoalsViewController.h"

@interface GoalsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *cadenceLabel;
@property (strong, nonatomic) IBOutlet UIStepper *cadenceStepper;
@property (strong, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (strong, nonatomic) IBOutlet UIStepper *workoutTimeStepper;
@property (strong, nonatomic) NSNumber *workoutTime;
@property (strong, nonatomic) NSNumber *cadence;

@end

@implementation GoalsViewController

- (IBAction)workoutTimeChange:(id)sender {
    UIStepper *stepper = sender;
    _workoutTime = [NSNumber numberWithDouble:stepper.value];
    [_appDictionary setObject:_workoutTime forKey:@"WorkoutTimeGoal"];
    [self updateWorkoutTimeLabel];
}

- (void)updateWorkoutTimeLabel {
    _workoutTimeLabel.text = [NSString stringWithFormat:@"%@ minutes", _workoutTime];
}

- (IBAction)cadenceChange:(id)sender {
    UIStepper *stepper = sender;
    _cadence = [NSNumber numberWithInt:stepper.value];
    [_appDictionary setObject:_cadence forKey:@"CadenceGoal"];
    [self updateCadenceLabel];
}

- (void)updateCadenceLabel {
    _cadenceLabel.text = [NSString stringWithFormat:@"%@ RPM", _cadence];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"hill.png"]]];
    
    if([_appDictionary objectForKey:@"CadenceGoal"]){
        _cadence = (NSNumber *)[_appDictionary objectForKey:@"CadenceGoal"];
    } else {
        _cadence = [NSNumber numberWithInt:80];
        [_appDictionary setObject:_cadence forKey:@"CadenceGoal"];
    }
    
    _cadenceStepper.value = [_cadence doubleValue];
    
    if([_appDictionary objectForKey:@"WorkoutTimeGoal"]){
        _workoutTime = (NSNumber *)[_appDictionary objectForKey:@"WorkoutTimeGoal"];
        
    } else {
        _workoutTime = [NSNumber numberWithInt:5];
        [_appDictionary setObject:_workoutTime forKey:@"WorkoutTimeGoal"];
    }
    
    _workoutTimeStepper.value = [_workoutTime doubleValue];
    
    [self updateWorkoutTimeLabel];
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
