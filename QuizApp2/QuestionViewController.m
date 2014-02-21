//
//  QuestionViewController.m
//  QuizApp2
//
//  Created by Bruce Li on 1/28/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "QuestionViewController.h"
#import <Parse/Parse.h>
#import "ImportViewController.h"
#import "PastQuizViewController.h"
#import "Question.h"
#import "MyLoginViewController.h"

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UILabel *qContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *answerALabel;
@property (weak, nonatomic) IBOutlet UILabel *answerBLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerCLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerDLabel;

@property (weak, nonatomic) IBOutlet UINavigationItem *fakeNavBar;

@property BOOL *questionFinished;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (weak, nonatomic) IBOutlet UIImageView *navBarColor;

@property (strong, nonatomic) NSArray * questions;

@property (strong, nonatomic) NSMutableArray *attempts;

@end

@implementation QuestionViewController
{
    BOOL loggedIn;
    BOOL quizImported;
    BOOL logOutFlag;
    BOOL startedQuiz;
    NSString *messagestring;
    NSString *groupName;
    NSUInteger *quizLength;
    NSArray *buttonArray;
    NSArray *imageArray;
    NSString *resultsArrayID;
}

@synthesize nextButton;
@synthesize buttonA;
@synthesize buttonB;
@synthesize buttonC;
@synthesize buttonD;
@synthesize popoverController;



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
    
    self.navBarColor.image = [UIImage imageNamed:@"navBarColor.png"];
    
    buttonArray = [[NSArray alloc] initWithObjects:buttonA, buttonB, buttonC, buttonD,  nil];
    
    imageArray = [[NSArray alloc] initWithObjects:_aImage,_bImage,_cImage,_dImage, nil];
    
   // DISABLE LOGIN
    //loggedIn = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    
    if (!loggedIn) {
        [super viewWillAppear:animated];
        //NSLog(@"Not logged in");
        //self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"View Appeared");
    
    //[self logInAndImport];
    
    if (!loggedIn){
        // Create the log in view controller
        MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsLogInButton;
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    
    else if (!quizImported){
        [self performSegueWithIdentifier: @"goToWelcome" sender: self];
        quizImported = YES;
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue destinationViewController] isKindOfClass:[ImportViewController class]])
    {
        NSLog(@"Entered prepare for segue");
        if (groupName){
             NSLog(@"Groupname is not null");
            ImportViewController *destView = [segue destinationViewController];
            destView.groupName = groupName;
        }
    }
}

//- (void)logInAndImport{
//    if (!loggedIn){
//        // Create the log in view controller
//        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
//        [logInViewController setDelegate:self]; // Set ourselves as the delegate
//        
//        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsLogInButton;
//        
//        // Create the sign up view controller
//        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
//        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
//        
//        // Assign our sign up controller to be displayed from the login controller
//        [logInViewController setSignUpController:signUpViewController];
//        
//        
//        [self presentViewController:logInViewController animated:YES completion:NULL];
//    }
//    
//    else if (!quizImported){
//        [self performSegueWithIdentifier: @"goToWelcome" sender: self];
//        quizImported = YES;
//        
//    }
//}

- (void)switchQuestion{
  
    NSLog(@"%@  %@", self.detailItem.questionNumber, self.detailItem.questionContent);
    
    self.qContentLabel.text = [NSString stringWithFormat:@"%@. %@", self.detailItem.questionNumber, self.detailItem.questionContent];
    self.answerALabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerA];
    self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
    self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
    self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerD];
    
    
    self.fakeNavBar.title = [NSString stringWithFormat:@"Question %@", self.detailItem.questionNumber];
    
    if (!self.detailItem.qAttempts) {//If buttons pressed is still Null
        
        self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, nil];
        self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: 4"];
    } else { //Question has been attempted, enable buttons according to Buttons Pressed
        
        self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", 4 - [self.detailItem.qAttempts integerValue]];
    }
    
    nextButton.enabled = NO;
    
    [self EnableButtonsAccordingToButtonsPressed];
    [self SetImagesAccordingToButtonsPressed];
}

- (void)EnableButtonsAccordingToButtonsPressed{
    
    if(self.detailItem.questionFinished){
        self.attemptsLabel.text = [NSString stringWithFormat:@"No more Attempts!"];
        for(int index = 0; index < 4; index++)
        {
            [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
        }
        
        if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1){
            nextButton.enabled = YES;
        }
       // [nextButton setTitle:@"Next Question" forState:UIControlStateNormal];
    }
    
    else {
        
        for(int index = 0; index < 4; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@0]){
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:NO];
            } else {
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
            }
        }
    }
}

- (void)SetImagesAccordingToButtonsPressed{
    
    bool flag = false;
    //UIImage *tempimage;
#warning This is sloppy, for through for loop and check index each time?
    for(int index = 0; index < 4; index++)
    {
        if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@1]){
            flag = true;

            if (index == 0){ _aImage.image = [UIImage imageNamed:@"redX7.png"]; }
            else if (index == 1){ _bImage.image = [UIImage imageNamed:@"redX7.png"]; }
            else if (index == 2){ _cImage.image = [UIImage imageNamed:@"redX7.png"]; }
            else if (index == 3){ _dImage.image = [UIImage imageNamed:@"redX7.png"]; }
        } else if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@2]){
            flag = true;
            if (index == 0){ _aImage.image = [UIImage imageNamed:@"ok-512.png"]; }
            else if (index == 1){ _bImage.image = [UIImage imageNamed:@"ok-512.png"]; }
            else if (index == 2){ _cImage.image = [UIImage imageNamed:@"ok-512.png"]; }
            else if (index == 3){ _dImage.image = [UIImage imageNamed:@"ok-512.png"]; }
        } else if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@0]){
            if (index == 0){ _aImage.image = nil; }
            else if (index == 1){ _bImage.image = nil; }
            else if (index == 2){ _cImage.image = nil; }
            else if (index == 3){ _dImage.image = nil; }
            
        }
    }
    
    if(!flag){
            _aImage.image = nil;
            _bImage.image = nil;
            _cImage.image = nil;
            _dImage.image = nil;
    }

}

- (void)assignQuizLengthFromMaster:(QuizTableViewController *)qtvc{
    quizLength = [qtvc giveQuizLength];
    NSLog(@"QuestionViewControlle thinks there are %d questions", (int)quizLength);
}

- (void)sendAttemptsToParse
{
    
    if (!self.attempts){ //if the attempts array hasnt been made
        
        id masternav = self.splitViewController.viewControllers[0];
        id master = [masternav topViewController];
        if ([master isKindOfClass:[QuizTableViewController class]]){
            [self assignQuizLengthFromMaster:master];
    }
        
    self.attempts = [[NSMutableArray alloc] init];
    for (int i = 0; i <= (int)quizLength; i++ ){
        [self.attempts insertObject:@0 atIndex:i];
    }
        
        
    if (!startedQuiz){
            startedQuiz = YES;
            
            PFUser *startQuiz = [PFUser currentUser];
            [startQuiz setObject:@"YES" forKey:@"startedQuiz"];
            [startQuiz saveInBackground];
            
            PFObject *resultArray = [PFObject objectWithClassName:[NSString stringWithFormat:@"%@_Results",self.quizIdentifier]];
            resultArray [[NSString stringWithFormat:@"%@", groupName]] = self.attempts;
            
            [resultArray save];
            
            resultsArrayID = [resultArray objectId];
            NSLog(@"Result Array ID: %@", [resultArray objectId]);
        }
        
    }
    
    messagestring = self.detailItem.qAttempts;
    
    [self.attempts replaceObjectAtIndex:[self.detailItem.questionNumber integerValue] withObject:messagestring];
    
    PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@_Results",self.quizIdentifier]];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:[NSString stringWithFormat:@"%@",resultsArrayID] block:^(PFObject *resultArrayUpdate, NSError *error) {
        
        
        resultArrayUpdate [[NSString stringWithFormat:@"%@", groupName]] = self.attempts;
        
        [resultArrayUpdate saveInBackground];
        
        }];
}

//- (void)sendAttemptsToParse
//{
//    if (!startedQuiz){
//        startedQuiz = YES;
//        
//        PFUser *startQuiz = [PFUser currentUser];
//        [startQuiz setObject:@"YES" forKey:@"startedQuiz"];
//        [startQuiz saveInBackground];
//        
//        id masternav = self.splitViewController.viewControllers[0];
//        id master = [masternav topViewController];
//        if ([master isKindOfClass:[QuizTableViewController class]]){
//            [self assignQuizLengthFromMaster:master];
//        }
//    }
//    if (!self.attempts){  //if the attempts array hasnt been made
//        self.attempts = [[NSMutableArray alloc] init];
//        for (int i = 0; i < (int)quizLength; i++ ){
//            [self.attempts insertObject:@0 atIndex:i];
//        }
//    }
//    
//    messagestring = self.detailItem.qAttempts;
//    
//    [self.attempts replaceObjectAtIndex:[self.detailItem.questionNumber integerValue] withObject:messagestring];
//    
//    PFObject *result = [PFObject objectWithClassName:[NSString stringWithFormat:@"%@_Results",self.quizIdentifier]];
//   // NSLog(@"The group %@ is sending the array %@", groupName, self.attempts);
//    result[[NSString stringWithFormat:@"%@", groupName]] = self.attempts;
//    
//    [result saveInBackground];
//}

//}

#pragma mark - ()

- (IBAction)logOutButtonTapAction:(id)sender {
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil) message:NSLocalizedString(@"Logging out will finish your quiz", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"I'm Sure", nil) otherButtonTitles:NSLocalizedString(@"Go Back",nil), nil] show];
    
//    NSMutableArray *sneakyLogout = [[NSMutableArray alloc] initWithObjects:@[@0], nil];
//    NSLog(@"%@", sneakyLogout[2]);

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        NSMutableArray *sneakyLogout = [[NSMutableArray alloc] initWithObjects:@[@0], nil];
        NSLog(@"%@", sneakyLogout[2]);
    }
}

- (IBAction)clicked:(UIButton *)sender {
    
    [QuestionViewController shouldDisableButton:sender should:YES];
    
    if (!self.detailItem.qAttempts) // if its null
    {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%d", 1];
    } else {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%d", [self.detailItem.qAttempts integerValue] +1];
    }
    
    if ([sender.titleLabel.text isEqualToString:self.detailItem.correctAnswer]) {
        self.detailItem.questionFinished = YES;
        [self sendAttemptsToParse];
        //self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, nil];
        [self.detailItem insertObjectInButtonsPressed:@2 AtLetterSpot:sender.titleLabel.text];
        
    } else {
        [self.detailItem insertObjectInButtonsPressed:@1 AtLetterSpot:sender.titleLabel.text];
        self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", 4 - [self.detailItem.qAttempts integerValue]];
    }
    
    [self EnableButtonsAccordingToButtonsPressed];
    [self SetImagesAccordingToButtonsPressed];
    
}
- (BOOL *)shouldUpdatePhoto{
    return (self.detailItem.questionFinished);
}

+(void) shouldDisableButton:(UIButton *)sender should:(BOOL)state {
    sender.enabled = !state;
}

- (IBAction)nextQuestion:(UIButton *)sender {
    
    id masternav = self.splitViewController.viewControllers[0];
    id master = [masternav topViewController];
    
    id detailnav = self.splitViewController.viewControllers[1];
    id detail = [detailnav topViewController];
    
    if ([master isKindOfClass:[QuizTableViewController class]]){
        NSInteger currentrow = [self.detailItem.questionNumber integerValue];
        [master prepareQuestionViewController:detail toDisplayQuestionAtRow:currentrow+1];
        [self switchQuestion];
    }
}


//-(void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    //if(attemptsLeft != 4){
//        
////        messageString = [NSMutableString stringWithFormat:@"%lu", 4-attemptsLeft];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"attempted" object:messageString];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"questionNumber" object:self.questionNumber];
//    
//    NSLog(@"QuestionView is sending msgstr %@ to the QuizTableView", messageString);
//    }

// Use this method to import all of the data from import view controller and then perform the same replace master segue to QuizTableController that import view controller used to do
// After you get that working, try to make "didSelectRowAtIndexPath" to do everything the replace segue did, and disable the replace segue


- (void)sendQuizIDto:(QuizTableViewController *)qtvc withidentifier:(NSString *)identifier {
    qtvc.quizIdentifier = identifier;
    [qtvc loadQuizData];
}

- (IBAction)unwindToQuestion:(UIStoryboardSegue *)segue
{
    
    PastQuizViewController *source = [segue sourceViewController];
    
    if (source.quizIdentifier != nil) {
        self.quizIdentifier = source.quizIdentifier;
    }
    NSLog(@"The quiz identifier in question view is %@", self.quizIdentifier);
    
    id masternav = self.splitViewController.viewControllers[0];
    id master = [masternav topViewController];
    
    if ([master isKindOfClass:[QuizTableViewController class]]){
        [self sendQuizIDto:master withidentifier:self.quizIdentifier];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"See Quiz", @"See Quiz");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"User logged in");
    
    groupName = user.username;
    loggedIn = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid login credentials!", nil) message:NSLocalizedString(@"Please check and re-enter your username and password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Will do", nil) otherButtonTitles:nil] show];
    
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end
