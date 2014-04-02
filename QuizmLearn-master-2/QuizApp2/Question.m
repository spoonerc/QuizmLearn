//
//  Question.m
//  QuizApp2
//
//  Created by Bruce Li on 1/27/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//


#import "Question.h"

@interface Question()

@property BOOL initno;

@end

@implementation Question

- (void)insertObjectInButtonsPressed:(id)rightOrWrong AtLetterSpot:(NSString *)index{
    int i;
    if ([index isEqualToString:@"A"]) { i = 0; }
    else if ([index isEqualToString:@"B"]) { i = 1; }
    else if ([index isEqualToString:@"C"]) { i = 2; }
    else { i = 3; }
    [self.ButtonsPressed replaceObjectAtIndex:i withObject:rightOrWrong];
}



@end
//
//@synthesize questionNumber = _questionNumber;
//@synthesize questionContent = _questionContent;
//@synthesize answerA = _answerA;
//@synthesize answerB = _answerB;
//@synthesize answerC = _answerC;
//@synthesize answerD = _answerD;
//@synthesize correctAnswer = _correctAnswer;
//@synthesize qAttempts = _qAttempts;

