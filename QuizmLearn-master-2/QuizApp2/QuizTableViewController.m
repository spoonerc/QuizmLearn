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
#import "OtherQuizzesTableViewController.h"


@interface QuizTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *otherQuizzesButton;
@property (strong, nonatomic) UIPopoverController *popoverController;
@end

@implementation QuizTableViewController

@synthesize popoverController;

    NSUInteger displayQuestion;



NSMutableArray *quiz ; //ofQuestions
NSMutableArray *attemptsArray;
NSUInteger questionsViewed;
NSIndexPath *indexPath2;
NSNumber *indexNum;
NSNumber *attemptsUsed;
//NSIndexPath *currentSelection;
NSMutableArray *colours;

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

- (IBAction)otherQuizzesClicked:(id)sender {
    
    
    OtherQuizzesTableViewController *otherQuizPopover = [[OtherQuizzesTableViewController alloc] init];
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:otherQuizPopover];
    
    [self.popoverController setPopoverContentSize:CGSizeMake(310, 170)];
    
    [self.popoverController presentPopoverFromBarButtonItem:self.otherQuizzesButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    
    
}

- (IBAction)unwindFromOtherQuizzes:(UIStoryboardSegue *)segue {
    
    OtherQuizzesTableViewController *source = [segue sourceViewController];
    self.quizIdentifier = source.quizIdentifier;
    
    QuestionViewController *qvc = (QuestionViewController *)[self.splitViewController.viewControllers[1] topViewController];
    
    qvc.quizIdentifier = source.quizIdentifier;
    
    [self loadQuizData];
    
    
    
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
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Quiz"];
    
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    //[self refresh];

    
    //[self.tableView setDelegate:self];

}

-(void)refresh {
    
    NSLog(@"does this happen on launch?");
    
    
    [self checkForRelease];
    //[self.tableView reloadData];
    //[self performSelector:@selector(retrieveQuestionsFromParse) withObject:nil];
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
    
}

- (void)stopRefresh{
    [self.refreshControl endRefreshing];
}


- (void)loadQuizData{
    
    //if (!quiz){
        NSLog(@"The quiz identifier in master is %@", self.quizIdentifier);
        
        self.navigationItem.title = self.quizIdentifier;
        
        PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@",self.quizIdentifier]];
        
        [query selectKeys: @[@"questionNumber", @"questionContent", @"answerA", @"answerB", @"answerC", @"answerD", @"correctAnswer", @"questionType", @"questionRelease"]];
        [query orderByAscending:@"questionNumber"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error) {
            if (!error) {
                
                NSLog(@"Successfully retrieved %lu Questions.", (unsigned long)questions.count);
                
                quiz = [[NSMutableArray alloc] init];
                
                [self initializeQuizArrayWithThisNumber:[questions count]];
                
                //retrieving questions from Parse
                for (PFObject *question in questions) {
                    
                    //if ([question[@"questionRelease"] isEqualToString:@"1"]){
                    
                    Question *_question = [[Question alloc] init];
                    
                    _question.questionNumber = question[@"questionNumber"];
                    _question.questionContent = question[@"questionContent"];
                    _question.answerA = question[@"answerA"];
                    _question.answerB = question[@"answerB"];
                    _question.answerC = question[@"answerC"];
                    _question.answerD = question[@"answerD"];
                    _question.correctAnswer = question[@"correctAnswer"];
                    _question.qtype = question[@"questionType"];
                    _question.questionRelease = question[@"questionRelease"];
                    
                    
                    
                    
                    [quiz replaceObjectAtIndex:[_question.questionNumber integerValue] withObject:_question];
                    
                    //[quiz insertObject:_question atIndex:[_question.questionNumber integerValue]];
                    
                    //[quiz addObject:_question];
                    
                   // Question *tempq = [quiz objectAtIndex:[_question.questionNumber integerValue] ];
                    
                    NSLog(@"Successfully retrieved Question %@ and placed it at index %ld", question[@"questionNumber"], (long)[_question.questionNumber integerValue]);
                    //NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:11 inSection:0];
                    //NSLog(@"The object where question 12 should be is %@", [quiz objectAtIndex:tempIndex.row]);
                        
                   // }
                
                }
            }else{
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
                
            
        }];
        
    //}
    
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
    
    
    
   // NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:11 inSection:0];
    //NSLog(@"The object where question 12 should be is %@", [quiz objectAtIndex:tempIndex.row]);

}

-(void) reloadData {
    [self.tableView reloadData];
}

- (void) checkForRelease{
    
    
    PFQuery *releaseQuery = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@", self.quizIdentifier]];
    
    [releaseQuery selectKeys:@[@"questionRelease", @"questionNumber"]];
    [releaseQuery findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error) {
        
        for (PFObject *question in questions) {
            
            Question *q = [quiz objectAtIndex:[question[@"questionNumber"]integerValue]];
            
            if ([q.questionRelease isEqualToString:@"0"]){
                q.questionRelease = question[@"questionRelease"];
                NSLog(@"got newly released question %@", question[@"questionNumber"]);
            }
        }
        
    }];
    
     [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
}


- (void)displayFirstQuestion{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}


- (NSUInteger *)giveQuizLength{
  //  NSLog(@"qtvc gave quiz count %d", [quiz count]);
    return [quiz count];
    
}


- (void)initializeQuizArrayWithThisNumber:(NSUInteger)count{
    NSLog(@"The quiz array is being intialized with %lu spots", (unsigned long)count);
    for (int i = 0; i <= count; i++)
    {
        [quiz addObject:@0];
    }
    
    NSLog(@"The quiz array has %lu spots", (unsigned long)[quiz count]);
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

        cell.textLabel.text = [NSString stringWithFormat:@"Question %d ", indexPath.row+1];
        
        if ([q.questionRelease isEqualToString:@"0"]){
            cell.detailTextLabel.text = @"Question Not Released";
            cell.imageView.alpha = 0.2;
        }
        else if ([q.questionRelease isEqualToString:@"1"]){
            cell.detailTextLabel.text = q.questionContent;
            cell.imageView.alpha = 1;
        }
        
        //[self updateTableImage:indexPath.row+1 withAttempts:q.qAttempts];
        if([q.qtype isEqualToString:@"0"]){
            if (!q.qAttempts) {
                    cell.imageView.image = [UIImage imageNamed:@"0normal.png"];
            }else{
                cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", q.qAttempts]];
            }
        } else if ([q.qtype isEqualToString:@"1"]){
            if (!q.qAttempts) {
                cell.imageView.image = [UIImage imageNamed:@"0report.png"];
            }else{
                cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"1%@.png", q.reportButtonChoice]];
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
    
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]){
        detail = [detail topViewController];
    }
    
    UIViewController *realDetail = detail;
    
        id mostRecentSubview = realDetail.view.subviews[[realDetail.view.subviews count]-1];
    
    if ([q.questionRelease isEqualToString:@"0"]){

    
    // If the last subview isnt a translucent view, make it one!
    
    if (![mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:screenRect];
        //that's it :)
        
        //optional:
        translucentView.translucentAlpha = 1;
        translucentView.translucentStyle = UIBarStyleDefault;
        translucentView.translucentTintColor = [UIColor clearColor];
        translucentView.backgroundColor = [UIColor clearColor];
        
        
        
        CGRect rect = CGRectMake(370, 200, 700, 100);
        
        //realDetail.navigationItem.title = @"Welcome";
        UILabel *textLabel = [[UILabel alloc]initWithFrame:rect];
        
        textLabel.center = realDetail.view.center;
        textLabel.text = @"This Question has not been released by the instructor yet";
        
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24]];
        textLabel.numberOfLines = 3;
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        textLabel.textColor = [UIColor blackColor];
        [translucentView addSubview:textLabel];
        [realDetail.view addSubview:translucentView];
        [UIView transitionWithView:realDetail.view duration:0.37 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
        }completion:nil];
    }
        
    }else if ([q.questionRelease isEqualToString:@"1"]){
        
        if ([mostRecentSubview isKindOfClass:[ILTranslucentView class]]){
            [[realDetail.view.subviews objectAtIndex:[realDetail.view.subviews count]-1]removeFromSuperview];
        }
    }
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
