//
//  Company.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 03.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *tel;
@property (strong, nonatomic) NSString *contactEmail;
@property (strong, nonatomic) NSString *feedbackEmail;
@property (strong, nonatomic) NSData *imageData;

- (instancetype)initWithName:(NSString*)name
                     imageURL:(NSString*)imageURL
                    imageData:(NSData*)imageData
                         tel:(NSString*)tel
                contactEmail:(NSString*)contactEmail
               feedbackEmail:(NSString*)feedbackEmail
                         info:(NSString*)info NS_DESIGNATED_INITIALIZER;

@end
