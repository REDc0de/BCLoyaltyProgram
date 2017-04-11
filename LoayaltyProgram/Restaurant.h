//
//  Restaurant.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *imageURL;
@property (weak, nonatomic) NSString *info;
@property (weak, nonatomic) NSString *address;
@property (weak, nonatomic) NSString *telNumber;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

- (id)initWithName:(NSString*)name
          imageURL:(NSString*)imageURL
              info:(NSString*)info
           address:(NSString*)address
         telNumber:(NSString*)telNumber
          latitude:(float)latitude
         longitude:(float)longitude;

@end
