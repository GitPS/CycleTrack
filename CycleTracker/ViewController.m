//
//  ViewController.m
//  CycleTracker
//
//  Created by Phillip Sime on 11/7/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong,nonatomic) NSMutableDictionary * workoutDictionary;

@end

@implementation ViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue id = %@", segue.identifier);
    if([segue.identifier  isEqual: @"workoutSegue"]){
        WorkoutViewController *workoutView = (WorkoutViewController *)[segue destinationViewController];
        workoutView.workoutDictionary = self.workoutDictionary;
    }
}

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"hill.png"]]];
    if(!_workoutDictionary){
        _workoutDictionary = [[NSMutableDictionary alloc] init];
        [_workoutDictionary setObject:@"Test" forKey:@"test"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
