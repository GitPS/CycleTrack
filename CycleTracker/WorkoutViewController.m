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
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *cadenceLabel;
@property (strong, nonatomic) NSTimer * timer;
@property double timerValue;
@property BOOL isWorkoutInProgress;
@property (strong, nonatomic) IBOutlet UIButton *connectDisconnectButton;

@property (nonatomic, retain) WFSensorConnection* sensorConnection;

@end

@implementation WorkoutViewController

# pragma mark Timer

- (void) incrementTimer {
    _timerValue += 0.1;
    double seconds = fmod(_timerValue, 60.0);
    double minutes = fmod(trunc(_timerValue / 60.0), 60.0);
    double hours = trunc(_timerValue / 3600.0);
    self.timerLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
    
    // Update dictionary with timer value
    [_appDictionary setObject:[NSNumber numberWithDouble:_timerValue] forKey:@"TimerValue"];
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
    
    _isWorkoutInProgress = YES;
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
    } else {
        UIColor *color = [UIColor greenColor];
        self.cadenceLabel.textColor = color;
        self.cadenceLabel.text = [NSString stringWithFormat:@"%d RPM", cadence];
    }
}

- (void) updateData
{
    bool isValid = NO;
    
    if([self.sensorConnection isKindOfClass:[WFBikeSpeedCadenceConnection class]])
    {
        WFBikeSpeedCadenceConnection* bikeSCConnection = (WFBikeSpeedCadenceConnection*)self.sensorConnection;
        
        if(bikeSCConnection.connectionStatus == WF_SENSOR_CONNECTION_STATUS_CONNECTED)
        {
            isValid=YES;
            WFBikeSpeedCadenceData *data = [bikeSCConnection getBikeSpeedCadenceData];
            if ([data formattedCadence:NO] != NULL) {
                [self updateCadenceLabel:[[data formattedCadence:NO] intValue]];
            } else {
                [self updateCadenceLabel:0];
            }
            NSLog(@"Data receieved...");
            NSLog(@"Current cadence = %@", [[bikeSCConnection getBikeSpeedCadenceData] formattedCadence:YES]);
        }
    }
    
    if(!isValid)
    {
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
    NSLog(@"viewDidLoad = %@", self.view.description);
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
    
    NSLog(@"API VERSION:  %@", hardwareConnector.apiVersion);
    NSLog(@"Has BTLE: %@", hardwareConnector.hasBTLESupport ? @"YES" : @"NO");
}

- (void)toggleConnection {
        //--------------------------------------------------------------------
        // Sensor Type
        WFSensorType_t sensorType = WF_SENSORTYPE_BIKE_SPEED_CADENCE;
        
        //--------------------------------------------------------------------
        // Current Connection Status
        WFSensorConnectionStatus_t connState = WF_SENSOR_CONNECTION_STATUS_IDLE;
        
        if ( self.sensorConnection != nil )
        {
            connState = self.sensorConnection.connectionStatus;
        }
        
        //--------------------------------------------------------------------
        // Toggle Connection
        switch (connState)
        {
            case WF_SENSOR_CONNECTION_STATUS_IDLE:
            {
                WFConnectionParams* params = NULL;
                params = [hardwareConnector.settings connectionParamsForSensorType:sensorType];
                
                if ( params != NULL)
                {
                    NSError* error = NULL;
                    self.sensorConnection = [hardwareConnector requestSensorConnection:params];
                    
                    if(error!=nil)
                    {
                        NSLog(@"ERROR: %@", error);
                    }
                    
                    // set delegate to receive connection status changes.
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

- (void) updateConnectButton
{
    // get the current connection status.
    WFSensorConnectionStatus_t connState = WF_SENSOR_CONNECTION_STATUS_IDLE;
    if ( self.sensorConnection != nil )
    {
        connState = self.sensorConnection.connectionStatus;
    }
    
    // set the button state based on the connection state.
    switch (connState)
    {
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

//--------------------------------------------------------------------------------
- (void)hardwareConnectorHasData
{
    [self updateData];
}

#pragma mark -
#pragma mark WFSensorConnectionDelegate Implementation

//--------------------------------------------------------------------------------
- (void)connection:(WFSensorConnection*)connectionInfo stateChanged:(WFSensorConnectionStatus_t)connState
{
    // check for a valid connection.
    if (connectionInfo.isValid)
    {
        // update the stored connection settings.
        [[WFHardwareConnector sharedConnector].settings saveConnectionInfo:connectionInfo];
        
        // update the display.
        [self updateData];
    }
    
    // check for disconnected sensor.
    else if ( connState == WF_SENSOR_CONNECTION_STATUS_IDLE )
    {
        // reset the display.
    }
    
    [self updateConnectButton];
}

@end


