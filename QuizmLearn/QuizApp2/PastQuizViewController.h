//
//  PastQuizViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 2/6/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuizTableViewController.h"
#import "ImportViewController.h"
#import "Quiz.h"

@interface PastQuizViewController : UITableViewController <UITableViewDelegate>

@property (strong, nonatomic) NSString * quizIdentifier;
@property (strong, nonatomic) NSMutableArray *listPastQuizzes;
//@property (strong, nonatomic) Quiz *quiz;

@end
