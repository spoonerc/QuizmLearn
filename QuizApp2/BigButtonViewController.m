//
//  BigButtonViewController.m
//  QuizApp2-7
//
//  Created by cisdev2 on 2/22/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "BigButtonViewController.h"

@interface BigButtonViewController ()

@end

@implementation BigButtonViewController

BOOL isPortrait;
BOOL isLandscape;
BOOL isValid;

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
    
    isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    isLandscape = UIDeviceOrientationIsLandscape(self.interfaceOrientation);
    isValid = UIDeviceOrientationIsValidInterfaceOrientation(self.interfaceOrientation);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"big%@.png", self.currentButton]]]];
    
   // _bigButtonImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"big%@", self.currentButton]];
}

- (IBAction)didTapImage:(UITapGestureRecognizer *)sender {
    NSLog(@"Button was tapped");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if(isPortrait) {
           [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"big%@.png", self.currentButton]]]];
    } else if (isLandscape){
          [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"bigP%@.png", self.currentButton]]]];
    }
}




- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        isPortrait = YES;
        isLandscape = NO;
    }else{
        isPortrait = NO;
        isLandscape = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
