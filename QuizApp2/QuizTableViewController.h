//
//  QuizTableViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 2/5/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportViewController.h"
#import "QuestionViewController.h"
#import "QuestionSelectionDelegate.h"


@interface QuizTableViewController : UITableViewController

@property (strong, nonatomic) NSIndexPath *currentSelection;

//@property (strong, nonatomic) NSArray * questions;
@property (strong, nonatomic) NSString * quizIdentifier;
//@property (nonatomic) NSUInteger * quizLength;
@property (strong, nonatomic) QuestionViewController *questionViewController;

@property (strong, nonatomic) NSMutableArray *listOfQuestions;
- (NSUInteger *)giveQuizLength;
//@property (nonatomic, assign) id<QuestionSelectionDelegate> delegate;

- (void)loadQuizData;

@end
