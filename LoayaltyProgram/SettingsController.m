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
#import <MessageUI/MessageUI.h>
#import "Firebase.h"
#import "Company.h"
#import "AboutUsController.h"

@interface SettingsController () <CLLocationManagerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *locationStatusLabel;
@property (strong, nonatomic) Company *company;

@end

@implementation SettingsController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    self.company = [[Company alloc] init];

    self.clearsSelectionOnViewWillAppear = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [[self.reference child:@"company"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.company.name = snapshot.value[@"name"];
        self.company.imageURL = snapshot.value[@"imageURL"];
        self.company.tel = snapshot.value[@"tel"];
        self.company.contactEmail = snapshot.value[@"contactEmail"];
        self.company.feedbackEmail = snapshot.value[@"feedbackEmail"];
        self.company.info = snapshot.value[@"info"];
        
        NSURL *url = [NSURL URLWithString:self.company.imageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showMessagePrompt: error.localizedDescription];
                return;
            }
            if (self.company.imageData != data) {
                self.company.imageData = data;
            }
        }] resume];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        if (error){
            [self showMessagePrompt: error.localizedDescription];
            return;
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        // The user want to setup location.
        [self setupLocationPremission];
    }
    else if (indexPath.section == 2 && indexPath.row == 1) {
        // The user want to send feedback.
        NSString *subject =[NSString stringWithFormat:@"%@ Feedback", self.company.name];
        NSString *message = [NSString stringWithFormat:@"Device: %@\n System: %@ %@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
        NSString *recipient = self.company.feedbackEmail;
        [self sendMailWithSubject:subject message:message toRecipient:recipient];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Location Manager Delegate

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


#pragma mark - Location Services

- (void)setupLocationPremission {
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


#pragma mark - Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendMailWithSubject:(NSString*)subject message:(NSString*)message toRecipient:(NSString*)recipient {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subject];
        [mail setMessageBody:message isHTML:NO];
        [mail setToRecipients:@[recipient]];
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else {
        [self showMessagePrompt:@"This device cannot send email"];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"settingsToAboutUs"]) {
        AboutUsController *upcoming = segue.destinationViewController;
        upcoming.company = self.company;
    }
}


@end
