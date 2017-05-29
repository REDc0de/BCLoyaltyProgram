//
//  User.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *profileImageURL;
@property (strong, nonatomic) NSData *profileImageData;
@property (assign, nonatomic) int points;

- (id) initWithUserName:(NSString*)name
                 gender:(NSString*)gender
               birthday:(NSString*)birtday
            phoneNumber:(NSString*)phoneNumber
                  email:(NSString*)email
        profileImageURL:(NSString*)profileImageURL
       profileImageData:(NSData*)profileImageData
                 points:(int)points
                    uid:(NSString*)uid NS_DESIGNATED_INITIALIZER;

@end
