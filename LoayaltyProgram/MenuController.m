//
//  MenuController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "MenuController.h"
#import "MenuCell.h"
#import "Firebase.h"
#import "Category.h"
#import "CategoryController.h"
#import "Product.h"
#import "UIViewController+Alerts.h"


@interface MenuController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSMutableArray *products;

@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.ref = [[FIRDatabase database] reference];
    self.categories = [[NSMutableArray alloc] init];
    self.products = [[NSMutableArray alloc] init];
    
    [[self.ref child:@"menu"]  observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {

        Category *category = [[Category alloc] init];
        category.name = snapshot.value[@"name"];
        category.info = snapshot.value[@"info"];
        category.imageURL = snapshot.value[@"imageURL"];
        category.uid = snapshot.value[@"uid"];
        [self.categories addObject:category];
        [self updateItemsArrayForCategory:category];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)updateItemsArrayForCategory:(Category*)category{
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    
    [[[[self.ref child:@"menu"] child:category.uid] child:@"items"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        Product *product = [[Product alloc] init];
        product.name = snapshot.value[@"name"];
        product.info = snapshot.value[@"info"];
        product.imageURL = snapshot.value[@"imageURL"];
        product.price = [snapshot.value[@"price"] floatValue];
        product.points = [snapshot.value[@"price"] intValue];
       
        [products addObject:product];
        category.items = products;
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    cell.categoryNameLabel.text = category.name;
    cell.categoryInfoLabel.text = category.info;
    
    if (category.imageData){
        cell.categoryImageView.image = [UIImage imageWithData:category.imageData];
    } else{
        NSURL *url = [NSURL URLWithString:category.imageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showMessagePrompt: error.localizedDescription];
                return;
            }
            category.imageData = data;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.categoryImageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
    return cell;
}

//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(MenuCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    cell.categoryImageView.image = [UIImage imageNamed:@"imagePlaceholder"];
//}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"menuToProducts"]) {
        CategoryController *upcoming = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Category *category = [self.categories objectAtIndex:indexPath.row];
        upcoming.category  = category;
    }
}


@end
