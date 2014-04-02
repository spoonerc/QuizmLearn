//
//  ImportViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 1/30/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "ImportViewController.h"
#import "Question.h"
#import "QuizViewController.h"

@interface ImportViewController ()
@property (weak, nonatomic) IBOutlet UITextField *quizName;
@property (weak, nonatomic) IBOutlet UITextField *instructor;
@property (weak, nonatomic) IBOutlet UITextField *course;
@property (weak, nonatomic) IBOutlet UITextField *section;
@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UITextField *timer;



@end

@implementation ImportViewController

NSArray * questions;

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
	// Do any additional setup after loading the view.
}

- (NSArray *) csvArray2QuestionsArray: (NSArray *)csvArray {
    int i = 0;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSMutableArray *ma = [[NSMutableArray alloc] init];
    
    for (NSArray *row in csvArray) {
        if (i >0) {
            Question *_question = [[Question alloc] init];
            
            _question.questionNumber = [row objectAtIndex:0];
            _question.questionContent = [row objectAtIndex:1];
            _question.answerA = [row objectAtIndex:2];
            _question.answerB = [row objectAtIndex:3];
            _question.answerC = [row objectAtIndex:4];
            _question.answerD = [row objectAtIndex:5];
            _question.correctAnswer = [row objectAtIndex:6];
            
            NSLog(@"Parsed Question %@ in ImportViewController", _question.questionNumber);
            
            [ma addObject:_question];
//            PFObject *pQuestion = [PFObject objectWithClassName:@"Question"];
//            NSLog(@"Parsed Question Number %@", _question.questionNumber );
//            pQuestion[@"questionNumber"] = _question.questionNumber;
//            pQuestion[@"questionContent"] = _question.questionContent;
//            pQuestion[@"answerA"] = _question.answerA;
//            pQuestion[@"answerB"] = _question.answerB;
//            pQuestion[@"answerC"] = _question.answerC;
//            pQuestion[@"answerD"] = _question.answerD;
//            pQuestion[@"correctAnswer"] = _question.correctAnswer;
//            
//            [pQuestion saveInBackground];
            
        }
        i++;
    }
    
    questions = ma;
    NSLog(@"ma has %lu questions", [ma count]);
    return (NSArray *) ma;
}



- (void) handleOpenURL:(NSURL *) url {
    NSError *outError;
    NSString *fileString = [NSString stringWithContentsOfURL:url
                                                    encoding:NSUTF8StringEncoding error:&outError];
    if (fileString != nil) {
        self.importedRows = [self csvArray2QuestionsArray:[fileString csvRows]];
           NSLog(@"Quiz Data has been locally parsed!");
        NSLog(@"import %lu rows inside if statement", (unsigned long)[questions count]);
        //self.fileURL = [parse:fileString];
    }
    NSLog(@"import %lu rows outside of if statement", (unsigned long)[questions count]);
    NSLog(@"import %lu rows outside of if statement", (unsigned long)[self.importedRows count]);
//    
    //[self.tableView reloadData];
}

- (NSArray *) getQuestions {
    NSLog(@"getQuestions returns %lu questions", [questions count]);
    return questions;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"goToQuiz"]) {
        
    
        
         QuizViewController *destQuizViewC = segue.destinationViewController;

        
//        for (int i = 0; i<[self.questions count]; i++) {
//            Question *q = [[Question alloc] init];
//            q = self.questions[i];
//            NSLog(@"preparing question %@", q.questionNumber);
//            [destQuizViewC.questions addObject:q];
//        }
        destQuizViewC.questions = [self getQuestions];
        NSLog(@"import %lu rows", (unsigned long)[destQuizViewC.questions count]);
        //destQuizViewC.questions = self.importedRows;
        destQuizViewC.navigationItem.title = [NSString stringWithFormat:@"%@-%@ %@", _course.text, _section.text, _quizName.text];
        destQuizViewC.quizIdentifier = [NSString stringWithFormat:@"%@_%@_%@", _course.text, _section.text, _quizName.text];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
