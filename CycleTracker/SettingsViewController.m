//
//  SettingsViewController.m
//  CycleTracker
//
//  Created by Phillip Sime on 11/7/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *weightTextField;
@property (strong, nonatomic) IBOutlet UISwitch *workoutSaveToggle;

@end

@implementation SettingsViewController

- (IBAction)nameModified:(id)sender {
    [_appDictionary setObject:_nameTextField.text forKey:@"NameOfUser"];
}

- (IBAction)weightModified:(id)sender {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *weight = [f numberFromString:_weightTextField.text];
    [_appDictionary setObject:weight forKey:@"WeightOfUser"];
}

- (IBAction)saveWorkoutModified:(id)sender {
    NSNumber *n = [NSNumber numberWithBool:_workoutSaveToggle.on];
    [_appDictionary setObject:n forKey:@"WorkoutToggleStatus"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"hill.png"]]];
    
    // Set values if already set in app dictionary
    if ([_appDictionary objectForKey:@"NameOfUser"]) {
        _nameTextField.text = [_appDictionary objectForKey:@"NameOfUser"];
    }
    
    if ([_appDictionary objectForKey:@"WeightOfUser"]) {
        _weightTextField.text = [_appDictionary objectForKey:@"WeightOfUser"];
    }
    
    if ([_appDictionary objectForKey:@"WorkoutToggleStatus"]) {
        NSNumber *n = [_appDictionary objectForKey:@"WorkoutToggleStatus"];
        [_workoutSaveToggle setOn:[n boolValue]];
    }
    
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
