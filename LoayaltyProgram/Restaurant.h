//
//  Restaurant.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *tel;
@property (assign, nonatomic) float latitude;
@property (assign, nonatomic) float longitude;

- (instancetype)initWithName:(NSString*)name
          imageURL:(NSString*)imageURL
              info:(NSString*)info
           address:(NSString*)address
               tel:(NSString*)tel
          latitude:(float)latitude
         longitude:(float)longitude NS_DESIGNATED_INITIALIZER;

@end
