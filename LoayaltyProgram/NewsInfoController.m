//
//  NewsInfoController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "NewsInfoController.h"

@interface NewsInfoController ()
@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;
@property (weak, nonatomic) IBOutlet UILabel *newsDateLabel;

@end

@implementation NewsInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleNewsSetup];
}

- (void)handleNewsSetup {
    self.newsTextView.text = self.news.info;
    self.newsTitleLabel.text = self.news.title;
    self.newsImageView.image = self.newsImage;
    
//    NSURL *url = [NSURL URLWithString:self.news.imageURL];
//    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        if (error){
//            [self showAlertWithError:error];
//            return;
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.newsImageView.image = [UIImage imageWithData:data];
//            
//        });
//    }] resume];
}
- (IBAction)handleActionButton:(id)sender {
    //  NSString *theMessage = @"Some promotional text we're sharing with an activity controller to BurgerMaster custoners";
    NSString *theMessage = self.newsTextView.text;
    
    UIImage *image = [[UIImage alloc] init];
    //  image = [UIImage imageNamed:@"burger_share"];
    image = self.newsImageView.image;
    NSArray *items = @[theMessage, image];
    
    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    
    // and present it
    [self presentActivityController:controller];
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
        } else {
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}

- (void)showAlertWithError:(NSError*)error {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:[error.userInfo objectForKey:@"error_name"]
                                 message:[error.userInfo objectForKey:@"NSLocalizedDescription"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
