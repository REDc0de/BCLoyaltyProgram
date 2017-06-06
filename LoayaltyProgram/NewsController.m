//
//  NewsController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "NewsController.h"
#import "NewsCell.h"
#import "Firebase.h"
#import "News.h"
#import "NewsInfoController.h"
#import "UIViewController+Alerts.h"


@interface NewsController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *news;

@end

@implementation NewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.news = [[NSMutableArray alloc] init];
    [self observeFIRData];
    self.clearsSelectionOnViewWillAppear = YES;
 }

- (void)observeFIRData {
    [[self.ref child:@"news"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *dictionary = snapshot.value;
        News *news = [[News alloc] init];
        [news setValuesForKeysWithDictionary:dictionary];
        [self.news addObject:news];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.news.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        News *news = [self.news objectAtIndex:indexPath.row];
        NSString *infoText = [NSString stringWithFormat:@"%@",news.info];
        NSString *titleText = [NSString stringWithFormat:@"%@",news.title];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.newsTitle.text = titleText;
            cell.newsTextView.text = infoText;
        });
        
        if (news.imageData){
            UIImage *image = [UIImage imageWithData:news.imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.newsImageView.image = image;
            });
        } else{
            NSURL *url = [NSURL URLWithString:news.imageURL];
            [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error){
                    [self showMessagePrompt: error.localizedDescription];
                    return;
                }
                news.imageData = data;
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.newsImageView.image = image;
                });
            }] resume];
        }
    });
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(NewsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *image = [UIImage imageNamed:@"imagePlaceholder"];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.newsImageView.image = image;
        });
    });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"newsToNewsInfo"]) {
        NewsInfoController *upcoming = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        News *news = [self.news objectAtIndex:indexPath.row];
        upcoming.news  = news;
    }
}


@end
