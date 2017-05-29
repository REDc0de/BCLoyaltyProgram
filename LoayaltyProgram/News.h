//
//  News.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 12.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSData *imageData;

- (id)initWithTitle:(NSString*)title
           imageURL:(NSString*)imageURL
          imageData:(NSData*)imageData
               info:(NSString*)info
               date:(NSString*)date NS_DESIGNATED_INITIALIZER;

@end
