//
//  QuizViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 1/28/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportViewController.h"

@interface QuizViewController : UICollectionViewController

@property (strong, nonatomic) NSArray * questions;
@property (strong, nonatomic) NSString * quizIdentifier;

@end
