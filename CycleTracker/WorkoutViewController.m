//
//  WorkoutViewController.m
//  CycleTracker
//
//  Created by Phillip Sime on 11/8/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import "WorkoutViewController.h"

@interface WorkoutViewController () <WFHardwareConnectorDelegate,WFSensorConnectionDelegate>

@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *connectDisconnectButton;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *cadenceLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (strong, nonatomic) NSTimer * timer;

@property double timerValue;
@property BOOL isWorkoutInProgress;
@property double caloriesBurned;
@property int lastValidCadence;

@property (nonatomic, retain) WFSensorConnection* sensorConnection;

@end

@implementation WorkoutViewController

# pragma mark Timer

- (void) incrementTimer {
    _timerValue += 0.1;
    double seconds = fmod(_timerValue, 60.0);
    double minutes = fmod(trunc(_timerValue / 60.0), 60.0);
    double hours = trunc(_timerValue / 3600.0);
    
    // Determine color of label based on workouttime goal
    if ((_timerValue / 60) > [[_appDictionary objectForKey:@"WorkoutTimeGoal"] doubleValue] ) {
        self.timerLabel.textColor = [UIColor redColor];
    } else {
        self.timerLabel.textColor = [UIColor cyanColor];
    }
    
    self.timerLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
    
    // Update progress bar
    [self updateProgressBar];
    
    // Update history and calories burned every 10 seconds
    if (fmod(seconds, 10) < 0.1){
        [self updateCaloriesBurned];
        [self updateHistory:hours withMinutes:minutes andSeconds:seconds];
    }
    
    // Update dictionary with timer value
    [_appDictionary setObject:[NSNumber numberWithDouble:_timerValue] forKey:@"TimerValue"];
}

- (void) updateProgressBar {
    double goalTime = [[_appDictionary objectForKey:@"WorkoutTimeGoal"] doubleValue];
    double currentTime = (_timerValue / 60);
    FLOAT percentComplete = currentTime / goalTime;
    [_progressBar setProgress:percentComplete];
}

- (void) updateCaloriesBurned {
    int weightInKG = [self getUserWeight] / 2.2;
    double met = [self getMETValue:_lastValidCadence];
    double caloriesForPeriod = met * weightInKG / 60.0 / 6.0;
    _caloriesBurned = _caloriesBurned + caloriesForPeriod;
    [self updateCaloriesBunred:_caloriesBurned];
}

- (void) updateCaloriesBunred:(double)calories {
    _caloriesLabel.text = [NSString stringWithFormat:@"%.1f Calories", calories];
}

- (void) resetTimer {
    NSLog(@"resetTimer");
    _timerValue = 0;
    _timerLabel.text = @"00:00:00:0";
}

- (void) updateHistory:(double)hours withMinutes:(double)minutes andSeconds:(double)seconds {
    if ([self getShouldLogWorkout]) {
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"dd-MM-YYYY hh:mm"];
        NSString *timeStamp = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
        NSString *workoutString = [NSString stringWithFormat:@"%@ \nWorkout Time: %@ \nCalories Burned: %.1f \nCadence: %d", [DateFormatter stringFromDate:[NSDate date]], timeStamp, _caloriesBurned, _lastValidCadence];
        NSMutableArray *array = [self getCurrentSession];
        [array addObject:workoutString];
    }
}

# pragma mark Helpers

- (int) getUserWeight {
    NSNumber *weight = [_appDictionary objectForKey:@"WeightOfUser"];
    
    // If no weight use 175 as an average weight
    if (!weight) {
        weight = [NSNumber numberWithInteger:175];
    }
    
    return [weight intValue];
}

- (int) getCadenceGoal {
    return [(NSNumber *)[_appDictionary objectForKey:@"CadenceGoal"] intValue];
}

- (BOOL) getShouldLogWorkout {
    NSNumber *n = [_appDictionary objectForKey:@"WorkoutToggleStatus"];
    if(!n){
        n = [NSNumber numberWithBool:NO];
    }
    return [n boolValue];
}

- (double) getMETValue:(int)cadence {
    int met;
    if (cadence < 60) {
        met = 7.50;
    } else if (cadence < 80) {
        met = 8.00;
    } else if (cadence < 100) {
        met = 8.50;
    } else {
        met = 9.00;
    }
    return met;
}

- (NSMutableArray *) getCurrentSession {
    NSMutableArray *array = [_appDictionary objectForKey:@"CurrentSession"];
    if (!array) {
        array = [[NSMutableArray alloc] init];
    }
    return array;
}

# pragma mark Buttons

- (IBAction)startWorkout:(id)sender {
    // If the timer is already running don't do anything
    if(_timer) return;
    
    _isWorkoutInProgress = YES;
    _caloriesBurned = 0;
    _lastValidCadence = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector: @selector(incrementTimer) userInfo:NULL repeats:YES];
}

- (IBAction)pauseWorkout:(id)sender {
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
    if(_timer) {
        [_timer invalidate];
        _timer = NULL;
        _timerLabel.text = @"00:00:00:0";
        _timerValue = 0;
        
        // Ensure the pause button is reset
        [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
        // Ensure the cadence label is reset
        [self updateCadenceLabel:0];
        
        // Ensure the calories label is reset
        [self updateCaloriesBunred:0.0];
        
        // Set timer color back to default if not already
        self.timerLabel.textColor = [UIColor cyanColor];
    }
    
    // Remove timer to prevent session from restarting during navigation
    [_appDictionary removeObjectForKey:@"TimerValue"];
    
    // Update progress bar
    [self updateProgressBar];
    
    // Store ended session into history array
    NSMutableArray *array = [_appDictionary objectForKey:@"CurrentSession"];
    [_historyArray addObject:array];
    
    // Reset history array
    array = [[NSMutableArray alloc] init];
    [_appDictionary setObject:array forKey:@"CurrentSession"];
    
    _isWorkoutInProgress = NO;
}

# pragma mark Cadence Logic

- (void)updateCadenceLabel:(int)cadence {
    int goalCadence = [(NSNumber *)[_appDictionary objectForKey:@"CadenceGoal"] intValue];
    if(cadence == 0){
        self.cadenceLabel.text = @"--";
    } else if(cadence < goalCadence) {
        UIColor *color = [UIColor redColor];
        self.cadenceLabel.textColor = color;
        self.cadenceLabel.text = [NSString stringWithFormat:@"%d RPM", cadence];
        _lastValidCadence = cadence;
    } else {
        UIColor *color = [UIColor greenColor];
        self.cadenceLabel.textColor = color;
        self.cadenceLabel.text = [NSString stringWithFormat:@"%d RPM", cadence];
        _lastValidCadence = cadence;
    }
}

- (void) updateData
{
    bool isValid = NO;
    
    if([self.sensorConnection isKindOfClass:[WFBikeSpeedCadenceConnection class]]) {
        WFBikeSpeedCadenceConnection* bikeSCConnection = (WFBikeSpeedCadenceConnection*)self.sensorConnection;
        
        if(bikeSCConnection.connectionStatus == WF_SENSOR_CONNECTION_STATUS_CONNECTED) {
            isValid=YES;
            WFBikeSpeedCadenceData *data = [bikeSCConnection getBikeSpeedCadenceData];
            if ([data formattedCadence:NO] != NULL) {
                [self updateCadenceLabel:[[data formattedCadence:NO] intValue]];
            } else {
                [self updateCadenceLabel:0];
            }
        }
    }
    
    if(!isValid) {
        [self updateCadenceLabel:0];
    }
}

- (IBAction)connectDisconnectButton:(id)sender {
    [self toggleConnection];
}

# pragma mark Return to active session

-(void)returnToActiveSession {
    if (_timerValue > 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector: @selector(incrementTimer) userInfo:NULL repeats:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if ([_appDictionary objectForKey:@"TimerValue"]) {
        _timerValue = [(NSNumber *)[_appDictionary objectForKey:@"TimerValue"] doubleValue];
        [self returnToActiveSession];
    }
    
    // Set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"hill.png"]]];
    
    // Setup Hardware
    [self setupHardware];
    
    // Connect
    [self updateConnectButton];
    [self updateData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupHardware {
    hardwareConnector = [WFHardwareConnector sharedConnector];
    hardwareConnector.delegate = self;
    [hardwareConnector setSampleTimerDataCheck:FALSE];
    [hardwareConnector setSampleRate:1.0];
    [hardwareConnector enableBTLE:YES];
}

- (void)toggleConnection {
        WFSensorType_t sensorType = WF_SENSORTYPE_BIKE_SPEED_CADENCE;
        WFSensorConnectionStatus_t connState = WF_SENSOR_CONNECTION_STATUS_IDLE;
        
        if ( self.sensorConnection != nil ) {
            connState = self.sensorConnection.connectionStatus;
        }
    
        switch (connState) {
            case WF_SENSOR_CONNECTION_STATUS_IDLE: {
                WFConnectionParams* params = NULL;
                params = [hardwareConnector.settings connectionParamsForSensorType:sensorType];
                
                if ( params != NULL) {
                    NSError* error = NULL;
                    self.sensorConnection = [hardwareConnector requestSensorConnection:params];
                    
                    if(error!=nil) {
                        NSLog(@"ERROR: %@", error);
                    }
                    self.sensorConnection.delegate = self;
                }
                break;
            }
                
            case WF_SENSOR_CONNECTION_STATUS_CONNECTING:
            case WF_SENSOR_CONNECTION_STATUS_CONNECTED:
                // disconnect the sensor.
                NSLog(@"Disconnecting sensor connection");
                [self.sensorConnection disconnect];
                break;
                
            case WF_SENSOR_CONNECTION_STATUS_DISCONNECTING:
            case WF_SENSOR_CONNECTION_STATUS_INTERRUPTED:
                // do nothing.
                break;
        }
    
    [self updateConnectButton];
}

- (void) updateConnectButton {
    // get the current connection status.
    WFSensorConnectionStatus_t connState = WF_SENSOR_CONNECTION_STATUS_IDLE;
    if ( self.sensorConnection != nil ) {
        connState = self.sensorConnection.connectionStatus;
    }
    
    // set the button state based on the connection state.
    switch (connState) {
        case WF_SENSOR_CONNECTION_STATUS_IDLE:
            [self.connectDisconnectButton setTitle:@"Connect to Cadence Monitor" forState:UIControlStateNormal];
            break;
        case WF_SENSOR_CONNECTION_STATUS_CONNECTING:
            [self.connectDisconnectButton setTitle:@"Connecting..." forState:UIControlStateNormal];
            break;
        case WF_SENSOR_CONNECTION_STATUS_CONNECTED:
            [self.connectDisconnectButton setTitle:@"Disconnect from Cadence Monitor" forState:UIControlStateNormal];
            break;
        case WF_SENSOR_CONNECTION_STATUS_DISCONNECTING:
            [self.connectDisconnectButton setTitle:@"Disconnecting..." forState:UIControlStateNormal];
            break;
        case WF_SENSOR_CONNECTION_STATUS_INTERRUPTED:
            [self.connectDisconnectButton setTitle:@"Interrupted!" forState:UIControlStateNormal];
            break;
    }
    
}

- (void)hardwareConnectorHasData {
    [self updateData];
}

#pragma mark -
#pragma mark WFSensorConnectionDelegate Implementation

- (void)connection:(WFSensorConnection*)connectionInfo stateChanged:(WFSensorConnectionStatus_t)connState {
    if (connectionInfo.isValid) {
        [[WFHardwareConnector sharedConnector].settings saveConnectionInfo:connectionInfo];
    }
    
    [self updateData];
    [self updateConnectButton];
}

@end


