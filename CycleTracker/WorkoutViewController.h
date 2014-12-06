//
//  WorkoutViewController.h
//  CycleTracker
//
//  Created by Phillip Sime on 11/8/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <WFConnector/WFHardwareConnector.h>
#import <WFConnector/WFConnector.h>

@interface WorkoutViewController : UIViewController {    
    WFHardwareConnector* hardwareConnector;
    
    UILabel* sensorTypeLabel;
    UILabel* networksLabel;
    UITableView* discoveredTable;
    
    NSMutableArray* discoveredSensors;
    UCHAR ucDiscoveryCount;
}

@property (strong,nonatomic) NSMutableDictionary * appDictionary;


@end
