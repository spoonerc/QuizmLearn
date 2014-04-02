//
//  questionViewController.h
//  quizCard
//
//  Created by cisdev1 on 2013-08-24.
//  Copyright (c) 2013 cisdev1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface questionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonA; //this was not set to uibutton in report!!! and connections were messed up
@property (weak, nonatomic) IBOutlet UIButton *buttonB;
@property (weak, nonatomic) IBOutlet UIButton *buttonC;
@property (weak, nonatomic) IBOutlet UIButton *buttonD;

@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImage;
@property (weak, nonatomic) IBOutlet UILabel *attemptsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *resultImage;

@property (weak, nonatomic) NSNumber *attempts; //added this
@property (weak, nonatomic) NSString *correct; //and this

+(void)disableButton:(UIButton *)sender;

-(IBAction)clicked:(UIButton *)sender;

@end
