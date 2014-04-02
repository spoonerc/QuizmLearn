//
//  Question.m
//  QuizApp2
//
//  Created by Bruce Li on 1/27/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//


#import "Question.h"


@implementation Question

//-(NSString *) description {
//        NSString *descrip;
//    descrip = [NSString stringWithFormat:@"QuestionNumber:%@ QuestionContent%@ AnswerA:%@ AnswerB:%@ AnswerC:%@ AnswerD:%@",
//               self.questionNumber, self.questionContent, self.answerA, self.answerB, self.answerC, self.answerD];
//
//    return descrip;
//    }

//-(id)initWithQuestionNumber:(NSString *)aQuestionNumber
//            QuestionContent:(NSString *)aQuestionContent
//                    AnswerA:(NSString *)aAnswerA
//                    AnswerB:(NSString *)aAnswerB
//                    AnswerC:(NSString *)aAnswerC
//                    AnswerD:(NSString *)aAnswerD
//{
//    if (self = [super init]) {
//        _questionNumber = aQuestionNumber;
//        _questionContent = aQuestionContent;
//        _answerA = aAnswerA;
//        _answerB = aAnswerB;
//        _answerC = aAnswerC;
//        _answerD = aAnswerD;
//    }
//    return self;
//}


@synthesize questionNumber = _questionNumber;
@synthesize questionContent = _questionContent;
@synthesize answerA = _answerA;
@synthesize answerB = _answerB;
@synthesize answerC = _answerC;
@synthesize answerD = _answerD;
@synthesize correctAnswer = _correctAnswer;


@end
