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
@property (weak, nonatomic) IBOutlet UILabel *newsDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;

@end

@implementation NewsInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleNewsSetup];
}

- (void)handleNewsSetup {
    self.newsTitleLabel.text = self.news.title;
    self.newsDateLabel.text = self.news.date;
    self.newsTextView.text = self.news.info;
    
    if (self.news.imageData){
        self.newsImageView.image = [UIImage imageWithData:self.news.imageData];
    } else{
        NSURL *url = [NSURL URLWithString:self.news.imageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showAlertWithError:error];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.newsImageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
}

#pragma mark - Activity

- (IBAction)handleActionButton:(id)sender {
    NSString *theMessage = self.newsTextView.text;
    
    UIImage *image = [[UIImage alloc] init];
    image = self.newsImageView.image;
    
    NSArray *items = @[theMessage, image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
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
            NSLog(@"User used activity type%@", activityType);
        } else {
            // user cancelled
            NSLog(@"User didn't want to share anything after all.");
        }
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}


#pragma mark - Alert

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
