//
//  QuizViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 1/28/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "QuizViewController.h"
#import "ImportViewController.h"
#import "QuestionViewController.h"
#import <Parse/Parse.h>
#import "Question.h"

@interface QuizViewController ()

@end

@implementation QuizViewController

//NSMutableArray *listQuestionNumbers;
//NSMutableArray *listQuestionContent;
NSMutableArray *quiz ;
NSMutableArray *attemptsArray;
NSUInteger questionsViewed;
NSIndexPath *indexPath2;
NSNumber *indexNum;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad


{
    
     [super viewDidLoad];
    
    for (Question *q in self.questions) {
    
        PFObject *pQuestion = [PFObject objectWithClassName:[NSString stringWithFormat:@"%@",self.quizIdentifier]];
                NSLog(@"Parsed Question Number %@", q.questionNumber );
                pQuestion[@"questionNumber"] = q.questionNumber;
                pQuestion[@"questionContent"] = q.questionContent;
                pQuestion[@"answerA"] = q.answerA;
                pQuestion[@"answerB"] = q.answerB;
                pQuestion[@"answerC"] = q.answerC;
                pQuestion[@"answerD"] = q.answerD;
                pQuestion[@"correctAnswer"] = q.correctAnswer;
    
               [pQuestion saveInBackground];
    }
    
       PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@",self.quizIdentifier]];
    //PFQuery *query = [Question query];
    
    
    
    
    
    [query selectKeys: @[@"questionNumber", @"questionContent", @"answerA", @"answerB", @"answerC", @"answerD", @"correctAnswer"]];
    [query orderByAscending:@"questionNumber"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error) {
        if (!error) {
            
            NSLog(@"Successfully retrieved %lu Questions.", (unsigned long)questions.count);

            quiz = [[NSMutableArray alloc] init];
            
            
            //retrieving questions from Parse
            for (PFObject *question in questions) {
                
                Question *_question = [[Question alloc] init];
                
                _question.questionNumber = question[@"questionNumber"];
                _question.questionContent = question[@"questionContent"];
                _question.answerA = question[@"answerA"];
                _question.answerB = question[@"answerB"];
                _question.answerC = question[@"answerC"];
                _question.answerD = question[@"answerD"];
                _question.correctAnswer = question[@"correctAnswer"];
                
                
                [quiz addObject:_question];
                NSLog(@"Successfully retrieved Question %@.", question[@"questionNumber"]);
            }

            
        }else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
//                for (Question *q in quiz) {
//    
//                NSLog(@"Question %@: %@  A: %@  B: %@  C: %@  D: %@", q.questionNumber, q.questionContent, q.answerA, q.answerB, q.answerC, q.answerD);
//                }
    
    questionsViewed = 0;
    
    UICollectionViewFlowLayout *collectViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectViewLayout.sectionInset = (UIEdgeInsetsMake(90, 140, 0, 90));
    

	// Do any additional setup after loading the view.
}


-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [quiz count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *squareImage = (UIImageView *)[cell viewWithTag:100];
    UILabel *questionLabel = (UILabel *)[cell viewWithTag:10];
    
    questionLabel.text= [NSString stringWithFormat:@"%ld", (long)indexPath.row+1];
    
    squareImage.image = [UIImage imageNamed:@"iosBlueStarIcon.png"];
                         
    return cell;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //this function is used to pass data using the navigation segue
    if ([segue.identifier isEqual:@"goToQuestion"]) {
        
        questionsViewed++;  //add one to the number of questions viewed
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        QuestionViewController *destViewC = segue.destinationViewController;
        
        indexPath2 = [indexPaths objectAtIndex:0];
        
        
//        destViewC.questionNumber = [NSString stringWithFormat:@"%ld", (long)indexPath2.row+1];
        
        Question *q = [[Question alloc] init];
        
        for (q in quiz) {
            for (int i = 1; i < ([quiz count]+1); i++) {
                
                if ([q.questionNumber isEqualToString:[NSString stringWithFormat:@"%ld",(long)indexPath2.row+1]]){
                    destViewC.questionNumber = q.questionNumber;
                    destViewC.questionContent = q.questionContent;
                    destViewC.answerA = q.answerA;
                    destViewC.answerB = q.answerB;
                    destViewC.answerC = q.answerC;
                    destViewC.answerD = q.answerD;
                    destViewC.correctAnswer = q.correctAnswer;
                    destViewC.navigationItem.title = [NSString stringWithFormat:@"Question %@", q.questionNumber];
                }
            }
        }
        
        
        
       // destViewC.questionContent = [quiz objectAtIndex:indexPath2.row];
        
        //this is where the action happens; send info to the question view
        destViewC.attempts = [attemptsArray objectAtIndex:indexPath2.row];  //to decide if question should be available
        //destViewC.correct = [theList objectAtIndex:indexPath2.row];         //to determine correct ans
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(questionViewed:) name:@"attempted" object:nil];
        //NSLog(@"%@", [quiz objectAtIndex:indexPath2.row]);
    }
}

-(void)questionViewed:(NSNotification *)notification {
    [attemptsArray replaceObjectAtIndex:indexPath2.row withObject:[notification object]];
}


-(void)viewDidAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
