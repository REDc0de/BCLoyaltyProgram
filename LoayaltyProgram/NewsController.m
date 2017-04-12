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

@interface NewsController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *news;
@property (strong, nonatomic) NSMutableArray *images;

@end

@implementation NewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.news = [[NSMutableArray alloc] init];
    self.images = [[NSMutableArray alloc] init];
    self.clearsSelectionOnViewWillAppear = YES;
    
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
    
    NSURL *url = [NSURL URLWithString:news.imageURL];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error){
            [self showAlertWithError:error];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.newsImageView.image = [UIImage imageWithData:data];
            [self.images addObject:[UIImage imageWithData:data]];
//            [self.tableView reloadData];
        });
    }] resume];

    
    return cell;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"newsToNewsInfo"]) {
        //if you need to pass data to the next controller do it here
        NewsInfoController *upcoming = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        News *news = [self.news objectAtIndex:indexPath.row];
        upcoming.news  = news;
       
        UIImage *image = [self.images objectAtIndex:indexPath.row];
        upcoming.newsImage = image;
    }
}


@end
