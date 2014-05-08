//
//  OtherQuizzesTableViewController.h
//  Quizm Learn
//
//  Created by Bruce Li on 2014-03-28.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherQuizzesTableViewController : UITableViewController

@property (strong, nonatomic) NSString * quizIdentifier;
@property (strong, nonatomic) NSMutableArray *listPastQuizzes;

@end
