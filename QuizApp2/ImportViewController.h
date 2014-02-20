//
//  ImportViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 1/30/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+ParsingExtensions.h"
#import <Parse/Parse.h>

@interface ImportViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

- (void) handleOpenURL: (NSURL *) url;

@property (strong, nonatomic) NSArray *importedRows;
@property (strong, nonatomic) NSArray * questions;
- (NSArray *) getQuestions;

@property (strong, nonatomic) NSString *quizIdentifier;

@property NSString *groupName;

@end
