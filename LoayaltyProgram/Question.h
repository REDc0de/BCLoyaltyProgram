//
//  Question.h
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 03.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *info;

- (instancetype)initWithTitle:(NSString*)title
                         info:(NSString*)info NS_DESIGNATED_INITIALIZER;

@end
