//
//  FirstDetailViewController.m
//  HW7sbadrina
//
//  Created by Shrinath on 7/13/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirstDetailViewController.h"
#import "Reachability.h"

@interface FirstDetailViewController ()

@end

@implementation FirstDetailViewController {
    NSString *address;
    NSString *stringToTweet;
    NSString *stopSubString;
    NSString *startSubString;
    NSArray *splitter;
    long output;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventLabel.text = self.eventName;
    self.startLabel.text = self.eventStartTime;
    self.stopLabel.text = self.eventStopTime;
    self.locationLabel.text = self.eventLocation;
    address = self.eventLocation;
    [_eventLabel sizeToFit];
    [_locationLabel sizeToFit];
    
    splitter = [self.eventStopTime componentsSeparatedByString:@", "];
    stopSubString = splitter[1];
    
    splitter = [self.eventStartTime componentsSeparatedByString:@","];
    startSubString = splitter[0];
    startSubString =[startSubString substringToIndex:(startSubString.length - 3)];
    startSubString = [startSubString stringByAppendingString: splitter[1]];
    
    stringToTweet = nil;

    stringToTweet = [@"@MobileApp4 sbadrina " stringByAppendingString: self.eventName];
    stringToTweet = [stringToTweet stringByAppendingString: @" "];
    stringToTweet = [stringToTweet stringByAppendingString: startSubString];
    stringToTweet = [stringToTweet stringByAppendingString: @"-"];
    stringToTweet = [stringToTweet stringByAppendingString: stopSubString];
    stringToTweet = [stringToTweet stringByAppendingString: @" "];
    stringToTweet = [stringToTweet stringByAppendingString: self.eventLocation];
    
    self.title = self.eventName;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
                         MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
                         
                        // MKCoordinateRegion region = self.mapView.region;
                         region.center = [(CLCircularRegion *)placemark.region center];
                         region.span.longitudeDelta /= 100.0;
                         region.span.latitudeDelta /= 100.0;
                         
                         [self.mapView setRegion:region animated:YES];
                         [self.mapView addAnnotation:placemark];
                         
                         
                        
                     }
                 }
     ];
    
    _mapView.showsUserLocation = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        return nil;
    }
    
    static NSString *reuseId = @"pin";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        pinView.tintColor = [UIColor orangeColor];
    }
    
    else {
        pinView.annotation = annotation;
    }
    
    return pinView;
    
}


- (IBAction)pushToTweet:(id)sender {
    
    ACAccountStore *twitterAccount = [[ACAccountStore alloc] init];
    
    ACAccountType *twitterAccountType = [twitterAccount accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSLog(@"%@", stringToTweet);
    
    [twitterAccount requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
     {
         //NSLog(@"%@",error);
         
         NSArray *accountArray = [twitterAccount accountsWithAccountType:twitterAccountType];
         
         Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
         NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
         if (networkStatus == NotReachable) {
             NSLog(@"Network connection not available");
             UIAlertView *noAccountAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                                      message:@"Network connection is not available. Check your internet settings."
                                                                     delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
             
             [noAccountAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
             
         } //no network
         
         
         else {
             
             
             if(granted)
             {
                 if([accountArray count] == 0)
                 {
                     NSLog(@"No Twitter Account setup.");
                     UIAlertView *noAccountAlert = [[UIAlertView alloc] initWithTitle:@"Setup Twitter Account"
                                                                              message:@"You need to setup atleast one Twitter account in your Settings menu."
                                                                             delegate:self
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                     
                     [noAccountAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                 }
                 
                 else if([accountArray count] > 0)
                 {
                     
                     ACAccount *twitterAccounts = [accountArray lastObject];
                     
                     NSDictionary *post = @{@"status": stringToTweet};
                     
                     NSURL *requestURL = [NSURL
                                          URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
                     
                     SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:post];
                     
                     postRequest.account = twitterAccounts;
                     
                     [postRequest
                      performRequestWithHandler:^(NSData *responseData,
                                                  NSHTTPURLResponse *urlResponse, NSError *error)
                      {
                          NSLog(@"Twitter HTTP response: %li",
                                (long)[urlResponse statusCode]);
                          output = [urlResponse statusCode];
                          
                          if(output == 200)
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweeted"
                                                                              message:@"Your tweet has been posted."
                                                                             delegate:self
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                              
                              [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                          }
                          
                          if(output == 403)
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"403 Forbidden"
                                                                              message:@"You cannot post the same tweet again (or) your post is more than 140 chars!"
                                                                             delegate:self
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                              
                              [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                          }
                          
                          if(output == 401)
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unauthorized"
                                                                              message:@"Unauthorized - incorrect or missing credentials."
                                                                             delegate:self
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                              
                              [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                          }
                          
                          if(output == 500)
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                              message:@"Internal Server Error"
                                                                             delegate:self
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                              
                              [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                          }
                          
                          
                          
                          
                      }];
                     
                 }//else if
             }//if granted
             
             else
             {   NSLog(@"Permission not granted!");
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                 message:@"You have denied permission for this app to access your Twitter. Change this in the Settings menu."
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 
                 [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
             }//else
             
         } // if network
     } ];
    
}//pushToTweet


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

