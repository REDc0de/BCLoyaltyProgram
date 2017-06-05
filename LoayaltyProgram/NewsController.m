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
    News *news = [self.news objectAtIndex:indexPath.row];
    
    cell.newsTitle.text = news.title;
    cell.newsTextView.text = news.info;
    
    if (news.imageData){
        cell.newsImageView.image = [UIImage imageWithData:news.imageData];
    } else{
        NSURL *url = [NSURL URLWithString:news.imageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showMessagePrompt: error.localizedDescription];
                return;
            }
            news.imageData = data;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.newsImageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(NewsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.newsImageView.image = [UIImage imageNamed:@"imagePlaceholder"];
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
