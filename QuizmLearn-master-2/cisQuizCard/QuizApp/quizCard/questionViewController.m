//
//  questionViewController.m
//  quizCard
//
//  Created by cisdev1 on 2013-08-24.
//  Copyright (c) 2013 cisdev1. All rights reserved.
//

#import "questionViewController.h"

@implementation questionViewController
{
    //vars here
    NSArray *buttonArray;
    NSUInteger attemptsLeft;
    NSMutableString *messageString;
}

//fdont forget to synthesize
@synthesize buttonA;
@synthesize buttonB;
@synthesize buttonC;
@synthesize buttonD;

@synthesize checkBoxImage;
@synthesize attemptsLabel;
@synthesize resultImage;

@synthesize attempts;
@synthesize correct;


//missing initywith nibname it is in squares 2 but purpose not clear
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //comment
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    buttonArray = [[NSArray alloc]initWithObjects:buttonA, buttonB, buttonC, buttonD, nil];
    attemptsLeft = 4;
    
    if ([attempts isEqual:@0]) {                            //question not previously attempted
        attemptsLabel.text = [NSString stringWithFormat:@"%d", attemptsLeft];
        messageString = [NSString stringWithFormat:@"4"];
    }else{
        //disable buttons
        for(int index = 0; index < 4; index++)
        {
            [questionViewController disableButton:[buttonArray objectAtIndex:index]];
        }
        //display correct image
        resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",attempts]];
        messageString = [NSString stringWithFormat:@"%@",attempts];
        //show no attempts
        attemptsLabel.text = [NSString stringWithFormat:@"0"];
    }
}
-(IBAction)clicked:(UIButton *)sender
{
   //NSLog(@"hello there!");
    [questionViewController disableButton:sender];          //disable button and set opacity to 0.5
    attemptsLeft--;                                         //update ans display number of attempts
    attemptsLabel.text = [NSString stringWithFormat:@"%d", attemptsLeft];
    
    //if correct answer
    if([sender.titleLabel.text isEqualToString:correct]){   //correct is set acc. to segue-delivered string
        
        for(int index = 0; index < 4; index++)
        {
            [questionViewController disableButton:[buttonArray objectAtIndex:index]];
        }
        
        resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", (4-attemptsLeft)]];
        checkBoxImage.image = [UIImage imageNamed:@"check.gif"];
        
        messageString = [NSString stringWithFormat:@"%d", 4-attemptsLeft];
    }else{
        checkBoxImage.image = [UIImage imageNamed:@"redX.png"];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //this is where we send info back to th quiz view (the number of attempts used)
    [[NSNotificationCenter defaultCenter]postNotificationName:@"attempted" object:messageString];
}

+(void)disableButton:(UIButton *)sender
{
    sender.enabled = NO;
    [sender setAlpha:0.5];
}
@end
