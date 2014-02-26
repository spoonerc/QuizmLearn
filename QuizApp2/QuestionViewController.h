//
//  QuestionViewController.h
//  QuizApp2
//
//  Created by Bruce Li on 1/28/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionSelectionDelegate.h"
#import <Parse/Parse.h>
#import "RKiOS7Loading.h"

@interface QuestionViewController : UIViewController <UISplitViewControllerDelegate,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{
    UIPopoverController *popoverController;
}

@property (retain, nonatomic) UIPopoverController *popoverController;


@property (weak, nonatomic) IBOutlet UILabel *attemptsLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonA;
@property (weak, nonatomic) IBOutlet UIButton *buttonB;
@property (weak, nonatomic) IBOutlet UIButton *buttonC;
@property (weak, nonatomic) IBOutlet UIButton *buttonD;

@property (strong, nonatomic) Question *detailItem;

@property (strong, nonatomic) NSString * quizIdentifier;

@property (weak, nonatomic) IBOutlet UIImageView *bigButtonImage;

@property (weak, nonatomic) IBOutlet UIImageView *aImage;
@property (weak, nonatomic) IBOutlet UIImageView *bImage;
@property (weak, nonatomic) IBOutlet UIImageView *cImage;
@property (weak, nonatomic) IBOutlet UIImageView *dImage;
@property (weak, nonatomic) IBOutlet UIImageView *resultImage;

- (void)switchQuestion;

- (BOOL *)shouldUpdatePhoto;

-(IBAction)clicked:(id)sender;

- (IBAction)logOutButtonTapAction:(id)sender;

@end
