//
//  HistoryTableTableViewController.h
//  CycleTracker
//
//  Created by Phillip Sime on 12/14/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableTableViewController : UITableViewController

@property (strong,nonatomic) NSMutableDictionary * appDictionary;
@property (strong,nonatomic) NSMutableArray * historyArray;

@end