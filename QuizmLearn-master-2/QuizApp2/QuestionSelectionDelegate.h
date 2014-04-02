//
//  QuestionSelectionDelegate.h
//  QuizApp2
//
//  Created by Bruce Li on 2/5/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Question;
@protocol QuestionSelectionDelegate <NSObject>
@required
-(void)selectedQuestion:(Question *)newQuestion;
@end
