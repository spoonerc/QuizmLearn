//
//  QuestionViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 1/28/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "QuestionViewController.h"

@interface QuestionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *qContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *answerALabel;
@property (weak, nonatomic) IBOutlet UILabel *answerBLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerCLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerDLabel;



@end

@implementation QuestionViewController

@synthesize attempts;
@synthesize correctAnswer;
@synthesize buttonA;
@synthesize buttonB;
@synthesize buttonC;
@synthesize buttonD;

NSUInteger attemptsLeft;
NSArray *buttonArray;
NSMutableString *messageString;

//@synthesize attempts;

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
    NSLog(@"%@  %@", self.questionNumber, self.questionContent);
    
    buttonArray = [[NSArray alloc] initWithObjects:buttonA, buttonB, buttonC, buttonD,  nil];
    attemptsLeft = 4;
    
    self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %lu", (unsigned long)attemptsLeft];
//    if ([attempts isEqual:@0]) {
//        
//    }else {
//        
//    }
    
    self.qContentLabel.text = [NSString stringWithFormat:@"%@. %@", self.questionNumber, self.questionContent];
    self.answerALabel.text = [NSString stringWithFormat: @"%@", self.answerA];
    self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.answerB];
    self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.answerC];
    self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.answerD];
}


- (IBAction)clicked:(UIButton *)sender {
    
    [QuestionViewController disableButton:sender];
    attemptsLeft--;
    self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %lu", (unsigned long)attemptsLeft];

    if([sender.titleLabel.text isEqualToString:correctAnswer]) {
        for (int i = 0; i<4; i++) {
            [QuestionViewController disableButton:[buttonArray objectAtIndex:i]];
        }
        
        if ([sender.titleLabel.text isEqualToString:@"A"]) {
            _aImage.image = [UIImage imageNamed:@"ok-512.png"];
        }
        if ([sender.titleLabel.text isEqualToString:@"B"]) {
            _bImage.image = [UIImage imageNamed:@"ok-512.png"];
        }
        if ([sender.titleLabel.text isEqualToString:@"C"]) {
            _cImage.image = [UIImage imageNamed:@"ok-512.png"];
        }
        if ([sender.titleLabel.text isEqualToString:@"D"]) {
            _dImage.image = [UIImage imageNamed:@"ok-512.png"];
        }
    
        
    }else {
        if ([sender.titleLabel.text isEqualToString:@"A"]) {
            _aImage.image = [UIImage imageNamed:@"redX7.png"];
        }
        if ([sender.titleLabel.text isEqualToString:@"B"]) {
            _bImage.image = [UIImage imageNamed:@"redX7.png"];
        }
        if ([sender.titleLabel.text isEqualToString:@"C"]) {
            _cImage.image = [UIImage imageNamed:@"redX7.png"];
        }
        if ([sender.titleLabel.text isEqualToString:@"D"]) {
            _dImage.image = [UIImage imageNamed:@"redX7.png"];
        }

    }
        
}
    
+(void) disableButton:(UIButton *)sender {
    sender.enabled = NO;
    [sender setAlpha:0.5];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"attempted" object:messageString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
