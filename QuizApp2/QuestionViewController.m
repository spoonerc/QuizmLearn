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
#import "BigButtonViewController.h"

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightGesture;

@property (weak, nonatomic) IBOutlet UILabel *qContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *answerALabel;
@property (weak, nonatomic) IBOutlet UILabel *answerBLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerCLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerDLabel;

@property (weak, nonatomic) IBOutlet UIButton *reportButton;
//@property (weak, nonatomic) IBOutlet UIButton *reportButton;

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
    BOOL firstQuestionDisplayed;
    NSString *messagestring;
    NSString *groupName;
    NSUInteger *quizLength;
    NSArray *buttonArray;
   // NSArray *bigButtonArray;
    NSArray *imageArray;
    NSString *resultsArrayID;
    NSTimer *buttonTimer;
    NSString *currentButton;
}

@synthesize nextButton;
@synthesize swipeRightGesture;
@synthesize buttonA;
@synthesize buttonB;
@synthesize buttonC;
@synthesize buttonD;
@synthesize reportButton;
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
    
   // bigButtonArray = [[NSArray alloc] initWithObjects:bigButtonA, bigButtonB, bigButtonC, bigButtonD, nil];
    
    imageArray = [[NSArray alloc] initWithObjects:_aImage,_bImage,_cImage,_dImage, nil];
    
   // DISABLE LOGIN
   // loggedIn = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    
    if (!loggedIn) {
        [super viewWillAppear:animated];
        //NSLog(@"Not logged in");
        //self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
    }
}

+(void) shouldDisableButton:(UIButton *)sender should:(BOOL)state {
    NSSet *buttonStrings = [NSSet setWithObjects:@"A", @"B", @"C",@"D",
                             nil];
    sender.enabled = !state;
    
    if (![buttonStrings containsObject:sender.titleLabel.text] ){
        [sender setTitle:@"" forState:UIControlStateDisabled];
        [sender setTitle:@"Report Choice" forState:UIControlStateNormal];
    } else {
        //[sender setTitle:@"Report%@"
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
        
        
    } else if (!firstQuestionDisplayed){
        // Because it was iffy whether the master table view finished indexing all the questions before the detail view loaded, have a small delay of 0.2 seconds before reloading the table view and displaying the first question.
        [self performSelector:@selector(viewDidLoadDelayedLoading) withObject:self afterDelay:0.2];
    }
}

- (void)viewDidLoadDelayedLoading{
    firstQuestionDisplayed = YES;
    id masternav = self.splitViewController.viewControllers[0];
    QuizTableViewController *master = [masternav topViewController];
    if ([master isKindOfClass:[QuizTableViewController class]]){
        [master displayFirstQuestion];
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
            [master.tableView reloadData];
        }
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
    } else if ([segue.identifier isEqualToString: @"goToBigButton"]){
        
        BigButtonViewController *destViewC = [segue destinationViewController];
        destViewC.currentButton = currentButton;
        
    }
}


-(BOOL)qIsTypeNormal{
    if ([self.detailItem.qtype isEqualToString:@"Normal"]){
        return YES;
    } else {
        return NO;
    }
}

- (void)switchQuestion{
    
    NSLog(@"%@  %@", self.detailItem.questionNumber, self.detailItem.questionContent);
    
    self.qContentLabel.text = [NSString stringWithFormat:@"%@. %@", self.detailItem.questionNumber, self.detailItem.questionContent];
    self.answerALabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerA];
    self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
    self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
    self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerD];
    
    
    NSLog(@"The question number is %d, quiz length is %d", [self.detailItem.questionNumber integerValue], (int)quizLength  );
    
    self.fakeNavBar.title = [NSString stringWithFormat:@"Question %@", self.detailItem.questionNumber ];
    
    //Uncomment when the property in Question "qtype" is shown
    if ([self qIsTypeNormal]){
        
        //disable all the bigButtons
//        for(int index = 0; index < 4; index++)
//        {
//            [QuestionViewController shouldDisableButton:[bigButtonArray objectAtIndex:index] should:YES];
//        }
        
        [QuestionViewController shouldDisableButton:reportButton should:YES];
        
        if (!self.detailItem.qAttempts) { //If buttons pressed is still Null
            self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, nil];
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: 4"];
        } else { //Question has been attempted, enable buttons according to Buttons Pressed
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", 4 - [self.detailItem.qAttempts integerValue]];
        }
        
        nextButton.enabled = NO;
        [self EnableButtonsAccordingToButtonsPressed];
        [self SetImagesAccordingToButtonsPressed];
    } else { // else, it is a report question!
        // No images to set or change for a Report question
        self.attemptsLabel.text = [NSString stringWithFormat:@"(Report Question)"];
        [self EnableReportButtons];
    }
}

- (void)EnableReportButtons{
    // Make sure you disable all the check marks and x's
    _aImage.image = nil;
    _bImage.image = nil;
    _cImage.image = nil;
    _dImage.image = nil;
    _resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"0bar.png"]];
    
    reportButton.enabled = NO;
    
    for(int index = 0; index < 4; index++) // enable AAAALLLL da buttons
    {
       // [QuestionViewController shouldDisableButton:[bigButtonArray objectAtIndex:index] should:NO];
        [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:NO];
    }
    
}

- (void)EnableButtonsAccordingToButtonsPressed{
    
    
    if(self.detailItem.questionFinished ){
        
        for(int index = 0; index < 4; index++)
        {
            [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
        }
        
        if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1 ){
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
    
    if ([self qIsTypeNormal]){
        
        // Set the lower progress bar image for the first time
        if (!self.detailItem.qAttempts){
            _resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"0bar.png"]];
            _resultImage.alpha = 0.5;
        } else if (self.detailItem.questionFinished){ //question is finished, display qattempts-1 as progress bar
            int tempint = [self.detailItem.qAttempts integerValue]-1;
            NSString *tempstring = [NSString stringWithFormat:@"%d", tempint];
            _resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@bar.png", tempstring]];
        } else { // question is not finished, display attempts qattempts as progress bar
            _resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@bar.png", self.detailItem.qAttempts]];
        }
        
    #warning This is sloppy, for through for loop and check index each time?
        
        // Set the check mark and x images
        for(int index = 0; index < 4; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@1]){
                flag = true;
                if (index == 0){ _aImage.image = [UIImage imageNamed:@"redX7.png"]; }
                else if (index == 1){ _bImage.image = [UIImage imageNamed:@"redX7.png"]; }
                else if (index == 2){ _cImage.image = [UIImage imageNamed:@"redX7.png"]; }
                else if (index == 3){ _dImage.image = [UIImage imageNamed:@"redX7.png"]; }
            } else if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@2]){
                // Dont change the progress bar pic
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
    
    
    // stuff below here applies to both types of questions
    if (( UIDeviceOrientationIsLandscape(self.interfaceOrientation) && flag ) || ![self qIsTypeNormal]){
        // Device is in landscape, so we need to update the table image as soon as the button is pressed. Only do this if a button has been pressed (flag will be yes)
        // If it is a report question, this will only be called once, so update it everytime
        id masternav = self.splitViewController.viewControllers[0];
        QuizTableViewController *master = [masternav topViewController];
        
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:[self.detailItem.questionNumber integerValue]-1 inSection:0], nil];

       [master.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        NSLog(@"Reloading data for row %d", [self.detailItem.questionNumber integerValue]-1);
    }
    
}

- (void)assignQuizLengthFromMaster:(QuizTableViewController *)qtvc{
    quizLength = [qtvc giveQuizLength];
    NSLog(@"QuestionViewControlle thinks there are %d questions", (int)quizLength);
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

- (void)sendAttemptsToParse
{

    if (!self.attempts){  //if the attempts array hasnt been made
        
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
    
    if ([self qIsTypeNormal]){
        messagestring = self.detailItem.qAttempts;
    } else {
        messagestring = currentButton;
    }
    
    
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

//- (IBAction)touchedDown:(UIButton *)sender {
//    NSLog(@"entered touch down");
//    //buttonTimer =
//    if ( ![buttonTimer isValid]) {
//        currentButton = sender.titleLabel.text;
//        buttonTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
//                                                       target:self
//                                                     selector:@selector(showBigLetter:)
//                                                     userInfo:nil
//                                                      repeats:NO];
//    } else {
//        NSLog(@"Timer already started!");
//    }
//    
//}

//- (void)showBigLetter: (UIButton *)sender{
//    //NSLog(@"Timer worked");
//    [self performSegueWithIdentifier: @"goToBigButton" sender: self];
//}

- (IBAction)reportButtonSelected:(UIButton *)sender {
    //currentButton = sender.titleLabel.text;
    [self performSegueWithIdentifier: @"goToBigButton" sender: self];
}

- (IBAction)clicked:(UIButton *)sender {
    
    // The commented code is for the hold down feature
    
//    if ( ![buttonTimer isValid] ){
//        NSLog(@"Long click, dont execute normal button press tasks");
//    } else {
//        
//    [buttonTimer invalidate];
//    buttonTimer = nil;

    currentButton = sender.titleLabel.text; // This is to send to BigButtonController and to use in the message string to parse
    
    
    
    if (!self.detailItem.qAttempts) // if its null
    {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%d", 1];
    } else {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%d", [self.detailItem.qAttempts integerValue] +1];
    }
    
    if ([self qIsTypeNormal]){
        
        [QuestionViewController shouldDisableButton:sender should:YES];
        
        if ([sender.titleLabel.text isEqualToString:self.detailItem.correctAnswer]) {
            self.detailItem.questionFinished = YES;
            self.attemptsLabel.text = [NSString stringWithFormat:@"No more Attempts!"];
            //#warning disabled sending attempts to parse
            [self sendAttemptsToParse];
            [self.detailItem insertObjectInButtonsPressed:@2 AtLetterSpot:sender.titleLabel.text];
            
        } else {
            [self.detailItem insertObjectInButtonsPressed:@1 AtLetterSpot:sender.titleLabel.text];
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", 4 - [self.detailItem.qAttempts integerValue]];
        }
        
        //[self EnableButtonsAccordingToButtonsPressed];
        
        //[self SetImagesAccordingToButtonsPressed];
        
    } else {
        [self sendAttemptsToParse]; // This will send the button selected to parse
        self.detailItem.questionFinished = YES; // This will turn off all the buttons when calling EnableButtonsAccordingToButtonsPressed
        reportButton.enabled = YES;
        
        // This is to send to current button to the master for when it updates the picture
//        id masternav = self.splitViewController.viewControllers[0];
//        QuizTableViewController *master = [masternav topViewController];
//        master.currentButtonSelected = currentButton;
        
        self.detailItem.reportButtonChoice = currentButton;
    }
    
    [self EnableButtonsAccordingToButtonsPressed]; // Both types of questions use EnableButtons  Method
    [self SetImagesAccordingToButtonsPressed];
        

}

//}
    
    
- (BOOL *)shouldUpdatePhoto{
    return (self.detailItem.questionFinished);
}



- (IBAction)nextQuestion:(id)sender {
    [self goToNextQuestion];
}

- (IBAction)swipedRight:(id)sender {
    
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1){
        NSLog(@"The question number is %d", [self.detailItem.questionNumber integerValue]);
        [self goToNextQuestion];
    }
}

- (void)goToNextQuestion{
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



//- (IBAction)handleSingleTap:(id)sender
//{
//    // need to recognize the called object from here (sender)
//    if ([sender isKindOfClass:[UIGestureRecognizer self]]) {
//        // it's a gesture recognizer.  we can cast it and use it like this
//        UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
//        NSLog(@"the sending view is %@", tapGR.view);
//    } else if ([sender isKindOfClass:[UIButton self]]) {
//        // it's a button
//        UIButton *button = (UIButton *)sender;
//        button.selected = YES;
//    }
//    // and so on ...
//}

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
    
    //[RKiOS7Loading showHUDAddedTo:self.view animated:YES];
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
