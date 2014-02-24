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

- (void)viewWillAppear:(BOOL)animated
{
    _bigButtonImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"bigButtonImage%@", self.currentButton]];
}

- (IBAction)didTapImage:(UITapGestureRecognizer *)sender {
    NSLog(@"Button was tapped");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
