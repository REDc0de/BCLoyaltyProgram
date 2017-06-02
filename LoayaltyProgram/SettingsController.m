//
//  SettingsController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 02.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "SettingsController.h"
#import <MapKit/MapKit.h>
#import "UIViewController+Alerts.h"

@interface SettingsController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *locationStatusLabel;

@end

@implementation SettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    switch (status) {
        case 0:
            // The user has not yet made a choice regarding whether this app can use location services.
           self.locationStatusLabel.text = @"Not determined";
            break;
        case 1:
            //This app is not authorized to use location services. The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            self.locationStatusLabel.text = @"Restricted";
            break;
        case 2:
           // The user explicitly denied the use of location services for this app or location services are currently disabled in Settings.
            if ([CLLocationManager locationServicesEnabled]){
                // The user explicitly denied the use of location services for this app.
                self.locationStatusLabel.text = @"Never";
            } else {
                // Location services are currently disabled in Settings.
                self.locationStatusLabel.text = @"Disabled";
            }
            break;
        case 3:
            // This app is authorized to start location services at any time. This authorization allows you to use all location services, including those for monitoring regions and significant location changes.
            self.locationStatusLabel.text = @"Always";
            break;
        case 4:
            // This app is authorized to start most location services while running in the foreground. This authorization does not allow you to use APIs that could launch your app in response to an event, such as region monitoring and the significant location change services.
            self.locationStatusLabel.text = @"While using";
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==1 && indexPath.row == 0) {
        
        if ([CLLocationManager locationServicesEnabled]){
            // Location Services Enabled
            if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
                // Premission denied.
                UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"App Permission Denied"
                                                                                 message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                           }];
                UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * action) {
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                               }];
                
                [alert addAction:cancel];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                // While using premission.
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        } else {
            // Location Services disabled.
            UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Location Services Disabled"
                                                                             message:@"To re-enable, please go to \"Settings\"->\"Privacy\"->\"Location Services\" and turn on Location Services."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                    }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//
//- (void)updateSwitchValueAnimated:(BOOL)animated {
//    
//    
//    
////    if ([CLLocationManager locationServicesEnabled] == YES){
////        [self.locationSwitch setOn:YES animated:animated];
////    } else{
////        [self.locationSwitch setOn:NO animated:animated];
////    }
//}
//
//- (IBAction)locationSwitchToggled:(id)sender {
//    if ([self.locationSwitch isOn]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        NSLog(@"its on! %d",[CLLocationManager locationServicesEnabled]);
//
//        [self.locationManager startUpdatingLocation];
//        [self updateSwitchValueAnimated:YES];
//    } else {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        NSLog(@"its off! %d",[CLLocationManager locationServicesEnabled]);
//        [self.locationManager stopMonitoringSignificantLocationChanges];
//        [self.locationManager stopUpdatingHeading];
//        [self.locationManager stopUpdatingLocation];
//        self.locationManager.delegate = nil;
//        self.locationManager = nil;
//        [self updateSwitchValueAnimated:YES];
//
//    }
//}


@end
