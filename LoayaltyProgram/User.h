//
//  User.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *email;
@property (weak, nonatomic) NSString *profileImageURL;

- (id) initWithUserName:(NSString*)name email:(NSString*)email profileImageURL:(NSString*)profileImageURL;

@end
