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
@property (weak, nonatomic) IBOutlet UITextView *qContentLabel;

@property (weak, nonatomic) IBOutlet UITextView *answerALabel;
@property (weak, nonatomic) IBOutlet UITextView *answerBLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerCLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerDLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerELabel;

@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property BOOL *questionFinished;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray * questions;
@property (strong, nonatomic) NSMutableArray *attempts;


@end

@implementation QuestionViewController
{
    CGPoint resultImageStartPoint;
    BOOL loggedIn;
    BOOL quizImported;
    BOOL logOutFlag;
    BOOL startedQuiz;
    BOOL firstQuestionDisplayed;
    NSString *messagestring;
    NSString *groupName;
    NSUInteger *quizLength;
    NSArray *buttonArray;
    NSArray *imageArray;
    NSArray *startpointsArray;
    NSString *resultsArrayID;
    NSTimer *buttonTimer;
    NSString *currentButton;
    NSMutableArray *colours;
}

@synthesize nextButton;
@synthesize swipeRightGesture;
@synthesize buttonA;
@synthesize buttonB;
@synthesize buttonC;
@synthesize buttonD;
@synthesize buttonE;
@synthesize reportButton;
@synthesize popoverController;

# pragma mark - initial startup stuff

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(704, 1400)];
    //self.scrollView.contentSize = CGSizeMake(768, 1024);
   self.navigationItem.title = ( [self.detailItem.qtype isEqualToString:@"0"] ? [NSString stringWithFormat:@"Question %d", self.detailItem.sortedQNumber] :[NSString stringWithFormat:@"Application %d", self.detailItem.sortedQNumber ]);
    
//    [self.qContentLabel sizeToFit];
//    [self.answerALabel sizeToFit];
//    [self.answerBLabel sizeToFit];
//    [self.answerCLabel sizeToFit];
//    [self.answerDLabel sizeToFit];
    
    buttonArray = [[NSArray alloc] initWithObjects:buttonA, buttonB, buttonC, buttonD, buttonE, nil];
    
    imageArray = [[NSArray alloc] initWithObjects:_aImage,_bImage,_cImage,_dImage, _eImage, nil];
    
    _resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"0bar.png"]];
    _resultImage.alpha = 0.5;
    resultImageStartPoint = _resultImage.center;
    
    // Also create an array of startpoints so the controller knows where the bar should be upon returning to a question
    // Make it an array of values corresponding to the CGPoints, and when you access it, get CGPoint value
    startpointsArray = [[NSArray alloc] initWithObjects:[NSValue valueWithCGPoint:resultImageStartPoint], [NSValue valueWithCGPoint:CGPointMake(resultImageStartPoint.x - 200, resultImageStartPoint.y)], [NSValue valueWithCGPoint:CGPointMake(resultImageStartPoint.x - 400, resultImageStartPoint.y)], [NSValue valueWithCGPoint:CGPointMake(resultImageStartPoint.x - 600, resultImageStartPoint.y)], nil] ;
    
    [self.qContentLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    
   // DISABLE LOGIN
   //loggedIn = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    

    [super viewWillAppear:animated];
    
    // The first time the view loads, launch the login
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
        
        
        [self presentViewController:logInViewController animated:NO completion:NULL];
    } else if (!quizImported){
        [self performSelector:@selector(goToWelcomeMethod) withObject:nil afterDelay:0.001];

        quizImported = YES;
        
        // The third time the view loads, display the first question!
    } else if (!firstQuestionDisplayed){
        // Need a starting point for the image
        
        //        NSLog(@"The start point is %@", resultImageStartPoint);
        
        // Because it was iffy whether the master table view finished indexing all the questions before the detail view loaded, have a small delay of 0.2 seconds before reloading the table view and displaying the first question.
        [self performSelector:@selector(viewDidLoadDelayedLoading) withObject:self afterDelay:0.4];
    }

    
    
}



- (void)goToWelcomeMethod{
    [self performSegueWithIdentifier: @"goToWelcome" sender: self];
}

// This method conrols the Login, launching the welcome view (import view), and launching the first question.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

// Called from view did load to display first question
- (void)viewDidLoadDelayedLoading{
    firstQuestionDisplayed = YES;
    id masternav = self.splitViewController.viewControllers[0];
    QuizTableViewController *master = [masternav topViewController];
    if ([master isKindOfClass:[QuizTableViewController class]]){
        [master displayFirstQuestion];
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
            [master.tableView reloadData];
        } else { // It's in portriat
            [self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem afterDelay:0.5];
        }
    }
    
    [self getColoursFromParse];
    //Get the colours
    
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender.contentOffset.x != 0) {
        CGPoint offset = sender.contentOffset;
        offset.x = 0;
        sender.contentOffset = offset;
    }
}

-(void) getColoursFromParse{
    PFQuery *queryStudent = [PFUser query];
    [queryStudent whereKey:@"username" equalTo:[PFUser currentUser].username];
    PFObject *student = [queryStudent getFirstObject];
    
    NSString *course = student[@"StudentCourse"];
    
    PFQuery *queryColours = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@_Info", course]];
    PFObject *classInfo = [queryColours getFirstObject];
    
    colours = [[NSMutableArray alloc] init];
    colours = classInfo[@"ColourArray"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - small methods

// This method is called often, whenever a button has to be enabled or disabled. It has the benefit that it does different things for regular buttons and the report button.
+(void) shouldDisableButton:(UIButton *)sender should:(BOOL)state {
    
    NSSet *normalbuttonStrings = [NSSet setWithObjects:@"A", @"B", @"C",@"D", @"E", nil];
    sender.enabled = !state;
    
    // If it's a report button set the appropriate label text and background image
    if (![normalbuttonStrings containsObject:sender.titleLabel.text] ){
        [sender setTitle:@"" forState:UIControlStateDisabled];
        [sender setBackgroundImage:[UIImage imageWithCGImage:(__bridge CGImageRef)([UIColor colorWithWhite:1.0 alpha:1])] forState:UIControlStateDisabled];
        [sender setTitle:@"Report Choice" forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
        [sender setAlpha:0.8];
    }
}

// Public method so that the master knows if it should update the tableview cell image
- (BOOL *)shouldUpdatePhoto {
    return (self.detailItem.questionFinished);
}

// There is many times it is needed to check what kind of question it is.
-(BOOL)qIsTypeNormal{
    if ([self.detailItem.qtype isEqualToString:@"0"]){
        return YES;
    } else {
        return NO;
    }
}

// Called from sendAttempts to parse, needed to create the attempts array
- (void)assignQuizLengthFromMaster:(QuizTableViewController *)qtvc{
    quizLength = [qtvc giveQuizLength];
    NSLog(@"QuestionViewControlle thinks there are %d questions", (int)quizLength);
}

# pragma mark - main stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Entered prepareForSegue");
    if ([[segue destinationViewController] isKindOfClass:[ImportViewController class]])
    {
        if (groupName){ // Send the groupname to importview controller to display in the welcome label
            ImportViewController *destView = [segue destinationViewController];
            destView.groupName = groupName;
        }
    } else if ([segue.identifier isEqualToString: @"goToBigButton"]){
        // Send the BigButton view the button that was assigned to the report question in buttonpressed
        BigButtonViewController *destViewC = [segue destinationViewController];
        destViewC.currentButton = currentButton;
        destViewC.colours = colours;
        
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath   ofObject:(id)object   change:(NSDictionary *)change   context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])  / 2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

// Called from the master when a new question is pushed, also called for nextbutton. It manages updating all the labels, and calls the neccesarry methods to update the images and buttons
- (void)switchQuestion{
    
    
    
    
    NSLog(@"%@  %@", self.detailItem.questionNumber, self.detailItem.questionContent);
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.qContentLabel.text = [NSString stringWithFormat:@"%@. %@", self.detailItem.questionNumber, self.detailItem.questionContent];
        self.qContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        
        
        [self.qContentLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
        self.qContentLabel.textAlignment = NSTextAlignmentCenter;
        
        
        
        
        
        self.answerALabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerA];
        self.answerALabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerALabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
        
        if (self.detailItem.numberOfAnswers == 2) {
        
        self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
        self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            //NO C, D, E
            self.answerCLabel.hidden = YES;
            self.buttonC.alpha = 0;
            
            self.answerDLabel.hidden = YES;
            self.buttonD.alpha = 0;
            
            self.answerELabel.hidden = YES;
            self.buttonE.alpha = 0;
        
        }
        
        
        
        if (self.detailItem.numberOfAnswers == 3){
            
            
            self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
            self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            self.answerCLabel.hidden = NO;
            self.buttonC.alpha = 1;
        
        self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
        self.answerCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerCLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            
            self.answerDLabel.hidden = YES;
            self.buttonD.alpha = 0;
            
            self.answerELabel.hidden = YES;
            self.buttonE.alpha = 0;
        
        }
        
        
        if (self.detailItem.numberOfAnswers == 4){
            
            self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
            self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            self.answerCLabel.hidden = NO;
            self.buttonC.alpha = 1;
            
            self.answerDLabel.hidden = NO;
            self.buttonD.alpha = 1;
            
            self.answerELabel.hidden = YES;
            self.buttonE.alpha = 0;
            
            
            self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
            self.answerCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerCLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerD];
            self.answerDLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerDLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            
        }
        
        if (self.detailItem.numberOfAnswers == 5){
            
            self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
            self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            self.answerCLabel.hidden = NO;
            self.buttonC.alpha = 1;
            
            self.answerDLabel.hidden = NO;
            self.buttonD.alpha = 1;
            
            self.answerELabel.hidden = NO;
            self.buttonE.alpha = 1;
            
            self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
            self.answerCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerCLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
            self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerD];
            self.answerDLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerDLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];

    
        self.answerELabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerE];
        self.answerELabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerELabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
                    
        }
     

    }completion:nil];
    
    if ([self qIsTypeNormal]){
        [QuestionViewController shouldDisableButton:reportButton should:YES];
        if (!self.detailItem.qAttempts) { //If buttons pressed is still Null, create it.
            self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, @0, nil];
            
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: 4"];
        } else { //Question has been attempted
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", 4 - [self.detailItem.qAttempts integerValue]];
        }
        nextButton.enabled = NO;
    } else { // else, it is a report question!
        if (!self.detailItem.qAttempts) { //If buttons pressed is still Null
            self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, @0, nil];
        }
        self.attemptsLabel.text = [NSString stringWithFormat:@"(Report Question)"];
    }
    // These handle all the logistics for enabling buttons and setting images.
    [self EnableButtonsAccordingToButtonsPressed];
    [self SetImagesAccordingToButtonsPressed];
}

// Handles all the logistics for enabling buttons, for both kinds of questions
- (void)EnableButtonsAccordingToButtonsPressed{
    
    if(self.detailItem.questionFinished ){
        // If the question is done, both types of questions need all the buttons disabled, and need a restriction on the next button
        for(int index = 0; index < 5; index++)
        {
            [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
        }
        
        // Prevents enabled next button on the last question
        if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1 ){
            nextButton.enabled = YES;
        }
        
        // if it is a report question, AND the question is finished, you need to enable the report choice button and make sure that the current reportChoicebutton is correct.
        if (![self qIsTypeNormal]){
            [QuestionViewController shouldDisableButton:reportButton should:NO];
            currentButton = self.detailItem.reportButtonChoice;
        }
    } else {
        // Question isnt finished, disable buttons if theyve been pressed, dont if they havent been
        [QuestionViewController shouldDisableButton:reportButton should:YES];
        for(int index = 0; index < 5; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@0]){
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:NO];
            } else {
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
            }
        }
    }
}

// Handles all the logistics for setting the images (checkmarks and x's, progress bars, and background of button)
- (void)SetImagesAccordingToButtonsPressed{
    
    // This is needed to tell if a button has been pressed at all. If the table tries to update before a button is pressed, it will crash
    bool flag = false;
    
    if ([self qIsTypeNormal]){
        
        [buttonA setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonB setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonC setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonD setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonE setBackgroundImage:nil forState:UIControlStateNormal];
        

        // Set the lower progress bar image for the first time
        if (!self.detailItem.qAttempts)
        {
            _resultImage.center = resultImageStartPoint;
        }
        else if (self.detailItem.questionFinished) //question is finished, display qattempts-1 as progress bar
        {
           _resultImage.center = [[startpointsArray objectAtIndex:[self.detailItem.qAttempts integerValue]-1] CGPointValue];
        }
        else // question is not finished, move bar to the left 200 pixels
        {
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{ _resultImage.center = CGPointMake(_resultImage.center.x-200, _resultImage.center.y); } completion:^ (BOOL fin){ }];
        }
        
        // Set the check mark and x images
        for(int index = 0; index < 5; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@1]){
                flag = true;
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                tempimage.image = [UIImage imageNamed:@"redX7.png"];
            } else if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@2]){
                flag = true;
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                tempimage.image = [UIImage imageNamed:@"ok-512.png"];
                
                
                // If you decide to animate the presentation of the correct answer image some starter code is below
                
//                [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//                    
//                    [tempimage setFrame:CGRectMake(tempimage.center.x, tempimage.center.y, 110.0f, 110.0f)];
//                } completion:^ (BOOL fin){ }];
            } else if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@0]){
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                tempimage.image = nil;
            }
        }

    } else { // it's a report question, need to set the background image to show its been selected, and make sure all other images are nil
        _aImage.image = nil;
        _bImage.image = nil;
        _cImage.image = nil;
        _dImage.image = nil;
        _eImage.image = nil;
        [buttonA setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonB setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonC setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonD setBackgroundImage:nil forState:UIControlStateNormal];
        [buttonE setBackgroundImage:nil forState:UIControlStateNormal];
        
        _resultImage.center = resultImageStartPoint;
        
        // The @3 in the index of buttonspressed means it was chosen as a report question answer
        for(int index = 0; index < 5; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@3]){
                UIButton *tempButton = [buttonArray objectAtIndex:index];
                [tempButton setBackgroundImage:[UIImage imageNamed:@"0square.png"] forState:UIControlStateNormal];
            }
        }
    }
    
    // stuff below here applies to both types of questions
    if (( UIDeviceOrientationIsLandscape(self.interfaceOrientation) && flag ) || (( UIDeviceOrientationIsLandscape(self.interfaceOrientation)) &&![self qIsTypeNormal])){
        // Device is in landscape, so we need to update the table image as soon as the button is pressed. Only do this if a button has been pressed (flag will be yes)
        // If it is a report question, only update it the first time.
        id masternav = self.splitViewController.viewControllers[0];
        QuizTableViewController *master = [masternav topViewController];
        
        
        NSArray *indexPaths;
        if ([self.detailItem.qtype isEqualToString:@"0"]){
        
        indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.detailItem.sortedQNumber-1 inSection:0], nil];
        }else if ([self.detailItem.qtype isEqualToString:@"1"]){
            indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.detailItem.sortedQNumber-1 inSection:1], nil];
        }

       [master.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Called when a correct answer is pressed or anytime a report answer is chosen
- (void)sendAttemptsToParse
{
    if (!self.attempts){  //if the attempts array hasnt been made
        
        id masternav = self.splitViewController.viewControllers[0];
        id master = [masternav topViewController];
        if ([master isKindOfClass:[QuizTableViewController class]]){
            [self assignQuizLengthFromMaster:master];
        }
        
        self.attempts = [[NSMutableArray alloc] init];
        for (int i = 0; i < (int)quizLength; i++ ){
            [self.attempts insertObject:@0 atIndex:i];
        }
        NSLog(@"The legth of attempts array: %d\nThe number of questions: %d", [self.attempts count], quizLength);
        
    // This is needed so the instructor doesnt try and pull stuff from you when you havent started the quiz
    if (!startedQuiz){
            startedQuiz = YES;
        
            PFUser *startQuiz = [PFUser currentUser];
            [startQuiz setObject:@"YES" forKey:@"startedQuiz"];
            [startQuiz saveInBackground];
        
            // This put your results array on parse!
            PFObject *resultArray = [PFObject objectWithClassName:[NSString stringWithFormat:@"%@_Results",self.quizIdentifier]];
            resultArray [[NSString stringWithFormat:@"%@", groupName]] = self.attempts;
            
            [resultArray save];
        
            // Bruce knows what this does
            resultsArrayID = [resultArray objectId];
            NSLog(@"Result Array ID: %@", [resultArray objectId]);
        }
    }
    
    // Assign number or letter as 'messagestring' depending on the question
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



- (IBAction)clicked:(UIButton *)sender {
    
    currentButton = sender.titleLabel.text; // This is to send to BigButtonController and to use in the message string to parse
    
    if (!self.detailItem.qAttempts) // if its null
    {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%d", 1];
    } else {
        self.detailItem.qAttempts = [NSString stringWithFormat:@"%ld", [self.detailItem.qAttempts integerValue] +1];
    }
    
    if ([self qIsTypeNormal]){
        
        [QuestionViewController shouldDisableButton:sender should:YES];
        
        // Buttons pressed is an array where index 0 - 3 corresponds to buttons A - D. The array is initialized to all 0's. When a button is pressed, a 1 will be entered in the corresponing index for that button if it is wrong, and a 2 if it is right. This array is the key to being able to display the proper images and enable the proper buttons when re-entering a question.
        // I am now also going to add a 3 in the array if it is a report question, so we know which button to add the "selected" background image to.
        
        if ([sender.titleLabel.text isEqualToString:self.detailItem.correctAnswer]) {
            self.detailItem.questionFinished = YES;
            self.attemptsLabel.text = [NSString stringWithFormat:@"No more Attempts!"];
            //#warning disabled sending attempts to parse
            // I give it a 0.1 second delay so that the button wont "stay stuck down" while the attempts are being send to parse, because with a slow internet connection that may take a long time.
            [self performSelectorInBackground:@selector(sendAttemptsToParse) withObject:nil];
            //[self performSelector:@selector(sendAttemptsToParse) withObject:self afterDelay:0.1];
            [self.detailItem insertObjectInButtonsPressed:@2 AtLetterSpot:sender.titleLabel.text];
            
        } else {
            [self.detailItem insertObjectInButtonsPressed:@1 AtLetterSpot:sender.titleLabel.text];
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", 5 - [self.detailItem.qAttempts integerValue]];
        }
        
    } else { // It is a report question
        self.detailItem.questionFinished = YES; // This will turn off all the buttons when calling EnableButtonsAccordingToButtonsPressed
        [self sendAttemptsToParse]; // This will send the button selected to parse

        [self.detailItem insertObjectInButtonsPressed:@3 AtLetterSpot:sender.titleLabel.text];
        self.detailItem.reportButtonChoice = currentButton;
    }
    [self EnableButtonsAccordingToButtonsPressed]; // Both types of questions use EnableButtons and SetImages  Method
    [self SetImagesAccordingToButtonsPressed];
}

- (IBAction)reportButtonSelected:(UIButton *)sender {
   
    [self performSegueWithIdentifier: @"goToBigButton" sender: self];
    
}

// Next questions redirects to GoToNextQuestions because the swipeleft gesture also needs the same code
- (IBAction)nextQuestion:(id)sender {
    
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1){
        NSLog(@"The question number is %ld", (long)[self.detailItem.questionNumber integerValue]);
        [self goToNextQuestion];
    }


}

- (IBAction)swipedRight:(id)sender {
    
    // Make sure you cant swipe on the last question
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1){
        NSLog(@"The question number is %ld", (long)[self.detailItem.questionNumber integerValue]);
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

// Use this method to import all of the data from import view controller and then perform the same replace master segue to QuizTableController that import view controller used to do
// After you get that working, try to make "didSelectRowAtIndexPath" to do everything the replace segue did, and disable the replace segue

// called from unwind segue when the quiz identifier is recieved from past quiz view controller
- (void)sendQuizIDto:(QuizTableViewController *)qtvc withidentifier:(NSString *)identifier {
    qtvc.quizIdentifier = identifier;
    [qtvc loadQuizData];
}

// Unwinds from pastquiz view controller when the user taps a quiz
- (IBAction)unwindToQuestion:(UIStoryboardSegue *)segue {
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


- (IBAction)unwindFromBigButton:(UIStoryboardSegue *)segue {
    
    [self switchQuestion];
    
}
#pragma mark - alertivew stuff

- (IBAction)logOutButtonTapAction:(id)sender {
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil) message:NSLocalizedString(@"Logging out will finish your quiz", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"I'm Sure", nil) otherButtonTitles:NSLocalizedString(@"Go Back",nil), nil] show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [PFUser logOut];
        
        loggedIn = NO;
        quizImported = NO;
        firstQuestionDisplayed = NO;
        
        MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsLogInButton;
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        
        [self presentViewController:logInViewController animated:NO completion:NULL];
        
        //NSMutableArray *sneakyLogout = [[NSMutableArray alloc] initWithObjects:@[@0], nil];
        //NSLog(@"%@", sneakyLogout[2]);
    }
}




- (void)longTapButton{
    // Commented code is for a longtap button
    
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
    [self dismissViewControllerAnimated:NO completion:nil];
    
    
    
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

// Signup isnt needed, but keep if we ever want to implement it.

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
