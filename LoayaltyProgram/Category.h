//
//  Category.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 29.05.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *uid;

- (instancetype)initWithName:(NSString*)name
                    imageURL:(NSString*)imageURL
                   imageData:(NSData*)imageData
                        info:(NSString*)info
                       items:(NSMutableArray*)items
                         uid:(NSString*)uid NS_DESIGNATED_INITIALIZER;


@end
