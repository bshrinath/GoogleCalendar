//
//  FirstViewController.h
//  HW7sbadrina
//
//  Created by Shrinath on 7/11/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLCalendar.h"

@class FirstDetailViewController;

@interface FirstViewController : UITableViewController

@property (strong, nonatomic) FirstDetailViewController *detailViewController;

@property (nonatomic, strong) GTLServiceCalendar *service;
@property (nonatomic, strong) UITextView *output;
@end
