//
//  WorkoutViewController.m
//  CycleTracker
//
//  Created by Phillip Sime on 11/8/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import "WorkoutViewController.h"

@interface WorkoutViewController ()
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSTimer * timer;
@property int timerValue;

@end

@implementation WorkoutViewController

# pragma mark Timer

- (void) incrementTimer {
    NSLog(@"incrementTimer");
    _timerLabel.text = [NSString stringWithFormat:@"%d", ++_timerValue];
}

- (void) resetTimer {
    NSLog(@"resetTimer");
    _timerValue = 0;
    _timerLabel.text = [NSString stringWithFormat:@"%d", _timerValue];
}

# pragma mark Buttons

- (IBAction)startWorkout:(id)sender {
    NSLog(@"startWorkout");
    
    // If the timer is already running don't do anything
    if(_timer) return;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector: @selector(incrementTimer) userInfo:NULL repeats:YES];
}

- (IBAction)pauseWorkout:(id)sender {
    NSLog(@"pauseWorkout");
    NSString *title = [_pauseButton titleForState:UIControlStateNormal];
    
    // If the timer is not running and not paused don't do anything
    if(!_timer) return;
    
    if([title isEqualToString:@"Pause"]) {
        [_timer invalidate];
        [_pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
    } else {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector: @selector(incrementTimer) userInfo:NULL repeats:YES];
        [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)stopWorkout:(id)sender {
    NSLog(@"stopWorkout");
    if(_timer) {
        [_timer invalidate];
        _timer = NULL;
        _timerLabel.text = @"0";
        _timerValue = 0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
