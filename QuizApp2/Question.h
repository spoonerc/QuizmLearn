//
//  Question.h
//  QuizApp2
//
//  Created by Bruce Li on 1/27/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (strong, nonatomic) NSString *questionNumber;
@property (strong, nonatomic) NSString *questionContent;
@property (strong, nonatomic) NSString *answerA;
@property (strong, nonatomic) NSString *answerB;
@property (strong, nonatomic) NSString *answerC;
@property (strong, nonatomic) NSString *answerD;
@property (strong, nonatomic) NSString *correctAnswer;
@property (strong, nonatomic) NSString *qtype;
@property (strong, nonatomic) NSMutableArray *ButtonsPressed;
@property (strong, nonatomic) NSString *reportButtonChoice; // This will only be updated in report questions, so the qtvc will know what image to display

- (void)insertObjectInButtonsPressed:(id)rightOrWrong AtLetterSpot:(NSString *)index;

@property (strong, nonatomic) NSString *qAttempts;
@property (nonatomic) BOOL *questionFinished;
//-(NSString *) description;

@end

