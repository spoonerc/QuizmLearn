//
//  PastQuizViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 2/6/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "PastQuizViewController.h"
#import <Parse/Parse.h>
#import "Question.h"
#import "Quiz.h"


@interface PastQuizViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *pastQuizCell;

@end

@implementation PastQuizViewController
{
    // NSMutableArray *listPastQuizzes;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Quizzes"];
    
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    [self refresh];
}

-(void)refresh {
    
    PFQuery *queryUser = [PFUser query];
    [queryUser whereKey:@"username" equalTo:[PFUser currentUser].username];
    
    PFObject *user = [queryUser getFirstObject];
    
    NSString *courseName = user[@"StudentCourse"];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"ImportedQuizzes"];
    [query selectKeys: @[@"QuizIdentifier", @"Course", @"QuizName"]];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pQuiz, NSError *error) {
        if (!error) {
            
            self.listPastQuizzes = [[NSMutableArray alloc]init];
            
            for (PFObject *quiz in pQuiz) {
                
                if ([quiz[@"Course"] isEqualToString:courseName]){
                    Quiz *_quiz = [[Quiz alloc]init];
                    _quiz.course = quiz[@"Course"];
                    //_quiz.section = quiz[@"Section"];
                    _quiz.quizName = quiz[@"QuizName"];
                    _quiz.quizIdentifier = quiz[@"QuizIdentifier"];
                    //NSString *quizName = quiz[@"QuizName"];
                    [self.listPastQuizzes addObject:_quiz];
                }
                
            }
            [self.tableView reloadData];
        }
    }];
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
    
}

- (void)stopRefresh{
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.listPastQuizzes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (self.listPastQuizzes == nil) {
        return cell;
    } else {
        
        Quiz *quiz = [self.listPastQuizzes objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", quiz.course, quiz.quizName];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

#pragma mark - Table View Delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Quiz *quiz = [self.listPastQuizzes objectAtIndex:indexPath.row];
//    self.quizIdentifier = quiz.quizIdentifier;
//
//    NSLog(@"The quiz Identifier for for past quiz view is %@", self.quizIdentifier);
//
//    //send notification with quiz identifier to Question view controller
//
//     //[self dismissViewControllerAnimated:YES completion:nil];
//}

//-(void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"quizIdentifier" object:self.quizIdentifier];
//
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"unwindToQuestion"]){
        NSLog(@"Entered Unwind Segue");
        
        NSIndexPath *index = [self.tableView indexPathForCell:sender];
        
        Quiz *quiz = [self.listPastQuizzes objectAtIndex:index.row];
        self.quizIdentifier = quiz.quizIdentifier;
        
        
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        //
        //        Impo
        //        rtViewController *destViewC = [segue destinationViewController];
        //
        //        destViewC.quizIdentifier = self.quizIdentifier;
        //        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}


@end
