//
//  FirstDetailViewController.h
//  HW7sbadrina
//
//  Created by Shrinath on 7/13/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface FirstDetailViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locManager;

@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSString *eventStartTime;
@property (strong, nonatomic) NSString *eventStopTime;
@property (strong, nonatomic) NSString *eventLocation;

@end
