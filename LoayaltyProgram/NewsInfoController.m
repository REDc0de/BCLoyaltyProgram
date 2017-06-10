//
//  NewsInfoController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "NewsInfoController.h"
#import "UIViewController+Alerts.h"


@interface NewsInfoController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UITextView *newsTextView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsDateLabel;

@end

@implementation NewsInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleNewsSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setHeightConstraint:self.textViewHeight forTextView:self.newsTextView];
}

- (void)handleNewsSetup {
    self.newsTitleLabel.text = self.news.title;
    self.newsDateLabel.text = self.news.date;
    self.newsTextView.text = self.news.info;
    
    if (self.news.imageData){
        self.newsImageView.image = [UIImage imageWithData:self.news.imageData];
    } else{
        NSURL *url = [NSURL URLWithString:self.news.imageURL];
        [self setImageView:self.newsImageView usingImageWithContentsOfURL:url];
    }
}

- (void)setHeightConstraint:(NSLayoutConstraint*)constraint forTextView:(UITextView*)textView {
    [textView sizeToFit];
    constraint.constant = textView.contentSize.height;
}

- (void)setImageView:(UIImageView*)imageView usingImageWithContentsOfURL:(NSURL*)url {
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error){
            [self showMessagePrompt: error.localizedDescription];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = [UIImage imageWithData:data];
        });
    }] resume];
}


#pragma mark - Activity

- (IBAction)handleActionButton:(id)sender {
    NSString *theMessage = self.newsTextView.text;
    
    NSArray *items = @[theMessage, self.newsImageView.image];
    // Build an activity view controller.
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    // Present activity view controller.
    [self presentActivityController:controller];
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    // For iPad: make the presentation a Popover.
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    // Access the completion handler.
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // React to the completion.
        if (completed) {
            // User shared an item.
            NSLog(@"We used activity type%@", activityType);
        } else {
            // User cancelled.
            NSLog(@"We didn't want to share anything after all.");
        }
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}


@end
