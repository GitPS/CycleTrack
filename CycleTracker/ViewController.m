//
//  ViewController.m
//  CycleTracker
//
//  Created by Phillip Sime on 11/7/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong,nonatomic) NSMutableDictionary * appDictionary;
@property (strong,nonatomic) NSMutableArray * historyArray;

@end

@implementation ViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier  isEqual: @"workoutSegue"]){
        WorkoutViewController *workoutView = (WorkoutViewController *)[segue destinationViewController];
        workoutView.appDictionary = self.appDictionary;
        workoutView.historyArray = self.historyArray;
    } else if ([segue.identifier isEqual:@"goalSegue"]){
        GoalsViewController *goalView = (GoalsViewController *)[segue destinationViewController];
        goalView.appDictionary = self.appDictionary;
    } else if ([segue.identifier isEqual:@"settingsSegue"]){
        SettingsViewController *settingsView = (SettingsViewController *)[segue destinationViewController];
        settingsView.appDictionary = self.appDictionary;
    } else if ([segue.identifier isEqual:@"historySegue"]){
        HistoryTableTableViewController *historyView = (HistoryTableTableViewController *)[segue destinationViewController];
        historyView.appDictionary = self.appDictionary;
        historyView.historyArray = self.historyArray;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"hill.png"]]];
    if(!_appDictionary){
        _appDictionary = [[NSMutableDictionary alloc] init];
        
        // Set defaults
        [_appDictionary setObject:[NSNumber numberWithInt:80] forKey:@"CadenceGoal"];
        [_appDictionary setObject:[NSNumber numberWithInt:60] forKey:@"WorkoutTimeGoal"];
        [_appDictionary setObject:[NSNumber numberWithInt:175] forKey:@"WeightOfUser"];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [_appDictionary setObject:array forKey:@"CurrentSession"];
    }
    if (!_historyArray) {
        _historyArray = [[NSMutableArray alloc] init];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
