//
//  NavigationController.m
//  CycleTracker
//
//  Created by Phillip Sime on 11/22/14.
//  Copyright (c) 2014 Phil Sime. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@property (strong,nonatomic) NSMutableDictionary * viewDictionary;

@end

@implementation NavigationController

// When a pushing a view controller check to see if it already exists.
// If it does we do not want to create a new one, so just reuse the old one.
// This ensures the state is not lost between segues.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSLog(@"pushViewController with title %@", viewController.title);
    if(![_viewDictionary objectForKey:viewController.title]){
        [super pushViewController:viewController animated:animated];
    } else {
        [super pushViewController:[_viewDictionary objectForKey:viewController.title] animated:animated];
    }
}

// When a view controller is popped simply add the view to the dictionary
// by storing it under the view's title.
- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    NSLog(@"popViewController");
    UIViewController *view = [super popViewControllerAnimated:animated];
    [_viewDictionary setObject:view forKey:view.title];
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!_viewDictionary){
        _viewDictionary = [[NSMutableDictionary alloc] init];
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
