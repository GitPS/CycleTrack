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
@property (strong, nonatomic) IBOutlet UILabel *cadenceLabel;
@property (strong, nonatomic) NSTimer * timer;
@property int count;
@property double timerValue;

@end

@implementation WorkoutViewController

# pragma mark Timer

//- (void) incrementTimer {
//    NSLog(@"incrementTimer");
//    _timerLabel.text = [NSString stringWithFormat:@"%d", ++_timerValue];
//}

- (void) incrementTimer {
    _timerValue += 0.1;
    double seconds = fmod(_timerValue, 60.0);
    double minutes = fmod(trunc(_timerValue / 60.0), 60.0);
    double hours = trunc(_timerValue / 3600.0);
    self.timerLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
}

- (void) resetTimer {
    NSLog(@"resetTimer");
    _timerValue = 0;
    _timerLabel.text = @"00:00:00:0";
}

# pragma mark Buttons

- (IBAction)startWorkout:(id)sender {
    NSLog(@"startWorkout");
    
    // If the timer is already running don't do anything
    if(_timer) return;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector: @selector(incrementTimer) userInfo:NULL repeats:YES];
}

- (IBAction)pauseWorkout:(id)sender {
    NSLog(@"pauseWorkout");
    NSString *title = [_pauseButton titleForState:UIControlStateNormal];
    
    // If the timer is not yet created don't do anything
    if(!_timer) return;
    
    if([title isEqualToString:@"Pause"]) {
        [_timer invalidate];
        [_pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
    } else {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector: @selector(incrementTimer) userInfo:NULL repeats:YES];
        [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)stopWorkout:(id)sender {
    NSLog(@"stopWorkout");
    if(_timer) {
        [_timer invalidate];
        _timer = NULL;
        _timerLabel.text = @"00:00:00:0";
        _timerValue = 0;
        // Ensure the pause button is reset
        [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        // Ensure the cadence label is reset
        [self updateCadenceLabel:0];
    }
}

# pragma mark Cadence Logic

- (void)updateCadenceLabel:(int)cadence {
    int goalCadence = 80;
    if(cadence < goalCadence) {
        UIColor *color = [UIColor redColor];
        self.cadenceLabel.textColor = color;
        self.cadenceLabel.text = [NSString stringWithFormat:@"%d RPM", cadence];
    } else {
        UIColor *color = [UIColor greenColor];
        self.cadenceLabel.textColor = color;
        self.cadenceLabel.text = [NSString stringWithFormat:@"%d RPM", cadence];
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
