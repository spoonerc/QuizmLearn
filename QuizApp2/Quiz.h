//
//  Quiz.h
//  Quizm Teach
//
//  Created by Bruce Li on 2/17/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quiz : NSObject

@property (strong, nonatomic) NSString *course;
@property (strong, nonatomic) NSString *section;
@property (strong, nonatomic) NSString *quizName;
@property (strong, nonatomic) NSString *quizIdentifier;

@end
