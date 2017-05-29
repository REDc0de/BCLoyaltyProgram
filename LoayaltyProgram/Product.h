//
//  Product.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 29.05.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *info;
@property (assign, nonatomic) int points;
@property (assign, nonatomic) float price;


- (instancetype)initWithName:(NSString*)name
                    imageURL:(NSString*)imageURL
                   imageData:(NSData*)imageData
                        info:(NSString*)info
                       points:(int)points
                       price:(float)price NS_DESIGNATED_INITIALIZER;


@end
