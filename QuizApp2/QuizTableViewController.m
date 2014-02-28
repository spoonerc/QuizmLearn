//
//  QuizTableViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 2/5/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <Parse/Parse.h>
#import "Question.h"
#import "QuizTableViewController.h"


@interface QuizTableViewController ()

@end

@implementation QuizTableViewController
{
    NSUInteger displayQuestion;
}


NSMutableArray *quiz ; //ofQuestions
NSMutableArray *attemptsArray;
NSUInteger questionsViewed;
NSIndexPath *indexPath2;
NSNumber *indexNum;
NSNumber *attemptsUsed;
//NSIndexPath *currentSelection;


- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Quiz Table view loaded");
    
    //[self.tableView setDelegate:self];

}

- (void)loadQuizData{
    
    if (!quiz){
        NSLog(@"The quiz identifier in master is %@", self.quizIdentifier);
        
        PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@",self.quizIdentifier]];
        
        [query selectKeys: @[@"questionNumber", @"questionContent", @"answerA", @"answerB", @"answerC", @"answerD", @"correctAnswer", @"questionType"]];
        [query orderByAscending:@"questionNumber"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error) {
            if (!error) {
                
                NSLog(@"Successfully retrieved %lu Questions.", (unsigned long)questions.count);
                
                quiz = [[NSMutableArray alloc] init];
                
                [self initializeQuizArrayWithThisNumber:[questions count]];
                
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
                    _question.qtype = question[@"questionType"];
                    
                    
                    
                    
                    [quiz replaceObjectAtIndex:[_question.questionNumber integerValue] withObject:_question];
                    
                    //[quiz insertObject:_question atIndex:[_question.questionNumber integerValue]];
                    
                    //[quiz addObject:_question];
                    
                    Question *tempq = [quiz objectAtIndex:[_question.questionNumber integerValue] ];
                    
                    NSLog(@"Successfully retrieved Question %@ and placed it at index %ld", question[@"questionNumber"], (long)[_question.questionNumber integerValue]);
                    //NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:11 inSection:0];
                    //NSLog(@"The object where question 12 should be is %@", [quiz objectAtIndex:tempIndex.row]);
                }
                
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];        
        
    }
    
   // NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:11 inSection:0];
    //NSLog(@"The object where question 12 should be is %@", [quiz objectAtIndex:tempIndex.row]);

}


- (void)displayFirstQuestion{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}


- (NSUInteger *)giveQuizLength{
    NSLog(@"qtvc gave quiz count %d", [quiz count]);
    return [quiz count];
    
}


- (void)initializeQuizArrayWithThisNumber:(NSUInteger)count{
    NSLog(@"The quiz array is being intialized with %d spots", count);
    for (int i = 0; i <= count; i++)
    {
        [quiz addObject:@0];
    }
    
    NSLog(@"The quiz array has %d spots", [quiz count]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [quiz count]-1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (quiz){
        Question *q = [quiz objectAtIndex:indexPath.row+1];
        NSLog(@"CellForRowAtIndex path has question %d", [q.questionNumber integerValue]);
        NSLog(@"Attempts are %d", [q.qAttempts integerValue]);
    
        cell.textLabel.text = [NSString stringWithFormat:@"Question %ld ", indexPath.row+1];
        cell.detailTextLabel.text = q.questionContent;
        
        //[self updateTableImage:indexPath.row+1 withAttempts:q.qAttempts];
        if([q.qtype isEqualToString:@"Normal"]){
            if (!q.qAttempts) {
                    cell.imageView.image = [UIImage imageNamed:@"0.png"];
            }else{
                cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
            }
        } else {
            if (!q.qAttempts) {
                cell.imageView.image = [UIImage imageNamed:@"6.png"];
            }else{
                cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.reportButtonChoice]];
            }
        }
    }
    return cell;
}

//- (void)updateTableImage:(NSInteger *)row withAttempts:(NSString)attempts{
//    
//    if (!q.qAttempts) {
//        cell.imageView.image = [UIImage imageNamed:@"0.png"];
//    }else{
//        cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
//    }
//
//}



/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation



-(void)prepareQuestionViewController:(QuestionViewController *)qvc toDisplayQuestionAtRow:(NSInteger)row
{
    Question *q = [quiz objectAtIndex:row];

    qvc.detailItem = q;
    qvc.navigationItem.title = [NSString stringWithFormat:@"Question %@", q.questionNumber];
    displayQuestion = [q.questionNumber integerValue];
}

#pragma mark - UITableViewDelagate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailnav = self.splitViewController.viewControllers[1];
    
    id detail = [detailnav topViewController];
    
    if ([detail isKindOfClass:[QuestionViewController class]]){
        NSLog(@"about to prepare question %ld", (long)indexPath.row+1);
        [self prepareQuestionViewController:detail toDisplayQuestionAtRow:indexPath.row+1];
        [detail switchQuestion];
    } else {
        NSLog(@"Didnt enter didselectrow");
    }
   
}

//The below code was unnecesarry bc questions in quiz are being manipulated directly from question view controller

//- (void)updateImage:(QuestionViewController *)qvc forCell:(NSIndexPath *)indexPath{
//    
//    int numAttemptsForPic = qvc.detailItem.qAttempts;
//    
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", numAttemptsForPic]];
//}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.tableView reloadData];
//    id detailnav = self.splitViewController.viewControllers[1];
//    
//    id detail = [detailnav topViewController];
//    
//    if ([detail isKindOfClass:[QuestionViewController class]]){
//        [self updateImage:detail forCell:indexPath];
//    }
//}

@end
