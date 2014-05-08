//
//  QuestionViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 1/28/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *attemptsLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonA;
@property (weak, nonatomic) IBOutlet UIButton *buttonB;
@property (weak, nonatomic) IBOutlet UIButton *buttonC;
@property (weak, nonatomic) IBOutlet UIButton *buttonD;

@property (weak, nonatomic) NSNumber *attempts;

@property (weak, nonatomic) NSString *questionNumber;
@property (weak, nonatomic) NSString *questionContent;

@property (weak, nonatomic) NSString *answerA;
@property (weak, nonatomic) NSString *answerB;
@property (weak, nonatomic) NSString *answerC;
@property (weak, nonatomic) NSString *answerD;

@property (weak, nonatomic) NSString *correctAnswer;

@property (weak, nonatomic) IBOutlet UIImageView *aImage;
@property (weak, nonatomic) IBOutlet UIImageView *bImage;
@property (weak, nonatomic) IBOutlet UIImageView *cImage;
@property (weak, nonatomic) IBOutlet UIImageView *dImage;

+(void)disableButton:(UIButton *)sender;

-(IBAction)clicked:(id)sender;

@end
