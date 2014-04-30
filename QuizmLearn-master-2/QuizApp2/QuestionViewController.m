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
#import "AFKPageFlipper.h"
#import "AnimationDelegate.h"
#import "FlipView.h"
#import "AnimationFrame.h"
#import "GenericAnimationView.h"
#import "Reachability.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightGesture;
@property (weak, nonatomic) IBOutlet UITextView *qContentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *progressBarBorder;

@property (weak, nonatomic) IBOutlet UITextView *answerALabel;
@property (weak, nonatomic) IBOutlet UITextView *answerBLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerCLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerDLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerELabel;
@property (weak, nonatomic) IBOutlet UIView *viewInScrollView;

@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property BOOL *questionFinished;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray * questions;
@property (strong, nonatomic) NSMutableArray *attempts;
@property (strong, nonatomic) IBOutlet AFKPageFlipper *pageFlipper;


@property (weak, nonatomic) IBOutlet UIImageView *scrollIndicator;
@property (weak, nonatomic) IBOutlet UILabel *Ebackground;
@property (weak, nonatomic) IBOutlet UILabel *Dbackground;
@property (weak, nonatomic) IBOutlet UILabel *Cbackground;
@property (weak, nonatomic) IBOutlet UILabel *Abackground;
@property (weak, nonatomic) IBOutlet UILabel *bBackground;

@end

@implementation QuestionViewController
{
    Reachability *internetReachableFoo;
    UIAlertView *alert;
    CGPoint resultImageStartPoint;
    BOOL loggedIn;
    BOOL quizImported;
    BOOL logOutFlag;
    BOOL startedQuiz;
    BOOL firstQuestionDisplayed;
    BOOL alertVisible;
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
    NSArray *tapGestureArray;
    UITapGestureRecognizer *tapGestureRecognizerA;
    UITapGestureRecognizer *tapGestureRecognizerB;
    UITapGestureRecognizer *tapGestureRecognizerC;
    UITapGestureRecognizer *tapGestureRecognizerD;
    UITapGestureRecognizer *tapGestureRecognizerE;
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
@synthesize resultImage;

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
    [self testInternetConnection];
    
    nextButton.enabled = NO;
    [nextButton setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
    nextButton.titleLabel.tintColor = [UIColor whiteColor];
    [nextButton setAlpha:0.8];
    
    //self.answerALabel.backgroundColor = UIColorFromRGB(0xD1EEFC);
    //self.answerBLabel.backgroundColor = UIColorFromRGB(0xD1EEFC);
    //self.answerCLabel.backgroundColor = UIColorFromRGB(0xD1EEFC);
    //self.answerDLabel.backgroundColor = UIColorFromRGB(0xD1EEFC);
    //self.answerELabel.backgroundColor = UIColorFromRGB(0xD1EEFC);
    
    [self.scrollView setScrollEnabled:YES];
    //[self.scrollView setContentSize:CGSizeMake(704, 1400)];
    //self.scrollView.contentSize = CGSizeMake(768, 1024);
    
    //self.viewInScrollView.frame = CGRectMake(0, 0, 768, 900);
   self.navigationItem.title = ( [self.detailItem.qtype isEqualToString:@"0"] ? [NSString stringWithFormat:@"Question %d", self.detailItem.sortedQNumber] :[NSString stringWithFormat:@"Application %d", self.detailItem.sortedQNumber ]);
    
    

    
    tapGestureRecognizerA = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromA:)];
    tapGestureRecognizerB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromB:)];
    tapGestureRecognizerC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromC:)];
    tapGestureRecognizerD = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromD:)];
    tapGestureRecognizerE = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromE:)];
    
    [self.answerALabel addGestureRecognizer:tapGestureRecognizerA];
    [self.answerBLabel addGestureRecognizer:tapGestureRecognizerB];
    [self.answerCLabel addGestureRecognizer:tapGestureRecognizerC];
    [self.answerDLabel addGestureRecognizer:tapGestureRecognizerD];
    [self.answerELabel addGestureRecognizer:tapGestureRecognizerE];
    
    
//    [self.Abackground addGestureRecognizer:tapGestureRecognizerA];
//     [self.bBackground addGestureRecognizer:tapGestureRecognizerB];
//     [self.Cbackground addGestureRecognizer:tapGestureRecognizerC];
//     [self.Dbackground addGestureRecognizer:tapGestureRecognizerD];
//     [self.Ebackground addGestureRecognizer:tapGestureRecognizerE];
    
    
//    [self.aImage addGestureRecognizer:tapGestureRecognizerA];
//    [self.bImage addGestureRecognizer:tapGestureRecognizerB];
//    [self.cImage addGestureRecognizer:tapGestureRecognizerC];
//    [self.dImage addGestureRecognizer:tapGestureRecognizerD];
//    [self.eImage addGestureRecognizer:tapGestureRecognizerE];
    
    
    tapGestureArray = [[NSArray alloc]initWithObjects:tapGestureRecognizerA, tapGestureRecognizerB, tapGestureRecognizerC, tapGestureRecognizerD, tapGestureRecognizerE, nil];
    
    tapGestureRecognizerA.delegate = self;
    tapGestureRecognizerB.delegate = self;
    tapGestureRecognizerC.delegate = self;
    tapGestureRecognizerD.delegate = self;
    tapGestureRecognizerE.delegate = self;
    
    
    
//    [self.qContentLabel sizeToFit];
//    [self.answerALabel sizeToFit];
//    [self.answerBLabel sizeToFit];
//    [self.answerCLabel sizeToFit];
//    [self.answerDLabel sizeToFit];
    
    buttonArray = [[NSArray alloc] initWithObjects:buttonA, buttonB, buttonC, buttonD, buttonE, nil];
    
    for (UIButton* button in buttonArray) {
        [button setTitleColor:UIColorFromRGB(0x007AFF) forState:UIControlStateNormal];
        //[button setBackgroundImage:[UIImage imageNamed:@"0square.png"] forState:UIControlStateNormal];
        
    }
    

    
    imageArray = [[NSArray alloc] initWithObjects:_aImage,_bImage,_cImage,_dImage, _eImage, nil];
    
    //resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"0bar.png"]];
    resultImage.alpha = 0.6;
    resultImageStartPoint = resultImage.center;
    
    self.progressBarBorder.alpha = 0.6;
    
    // Also create an array of startpoints so the controller knows where the bar should be upon returning to a question
    // Make it an array of values corresponding to the CGPoints, and when you access it, get CGPoint value
    
    float movePercentage = 0.0;
    
    if (self.detailItem.numberOfAnswers == 2){
        movePercentage = 1;
    }else if (self.detailItem.numberOfAnswers == 3){
        movePercentage = 0.5;
    }else if (self.detailItem.numberOfAnswers == 4){
        movePercentage = 0.33;
    }else if (self.detailItem.numberOfAnswers == 5){
        movePercentage = 0.25;
    }
    
    NSLog(@"move percentage: %f", movePercentage);
    
    int pixelMove = resultImage.frame.size.width*movePercentage;
    
    NSLog(@"pixelMove: %i", pixelMove);
    
    
    startpointsArray = [[NSArray alloc] initWithObjects:[NSValue valueWithCGPoint:resultImageStartPoint], [NSValue valueWithCGPoint:CGPointMake(resultImageStartPoint.x - pixelMove*1, resultImageStartPoint.y)], [NSValue valueWithCGPoint:CGPointMake(resultImageStartPoint.x - pixelMove*2, resultImageStartPoint.y)], [NSValue valueWithCGPoint:CGPointMake(resultImageStartPoint.x - pixelMove*3, resultImageStartPoint.y)],[NSValue valueWithCGPoint:CGPointMake(resultImageStartPoint.x - pixelMove*4, resultImageStartPoint.y)] , nil] ;
    
    [self.qContentLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    
   // DISABLE LOGIN
   //loggedIn = YES;
}

- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (alertVisible){ // can probably just check the alert.visible property instead
                
                UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios7-checkmark"]];
            
            
                [alert dismissWithClickedButtonIndex:0 animated:NO];
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection found!", nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                
                
                [successAlert setValue:checkMark forKey:@"accessoryView"];
                [successAlert show];
                [self performSelector:@selector(hideAlert:) withObject:successAlert afterDelay:2.0];
            }
            
            
            
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
            [spinner startAnimating];
            
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Lost Internet!", nil) message:NSLocalizedString(@"Waiting for connection...", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil, nil];
            
            
            [alert setValue:spinner forKey:@"accessoryView"];
            [alert show];
            alertVisible = YES;
            
            
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [internetReachableFoo startNotifier];
}

- (void)hideAlert:(UIAlertView *)successAlert{
    [successAlert dismissWithClickedButtonIndex:0 animated:YES];
    
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
        
      
        
        [self performSelector:@selector(goToWelcomeMethod) withObject:nil afterDelay:0];

        quizImported = YES;
        
        // The third time the view loads, display the first question!
    } else if (!firstQuestionDisplayed){

        //resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"0bar.png"]];
        //resultImage.alpha = 0.5;
        //resultImageStartPoint = resultImage.center;
        
        
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
        [master.navigationItem.rightBarButtonItem setTintColor:UIColorFromRGB(0x007AFE)];
        
        master.listPastQuizzes = self.listPastQuizzes;
        [self assignQuizLengthFromMaster:master];
        
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
    
    if (self.detailItem.numberOfAnswers>3){
    
    
    if (self.detailItem.numberOfAnswers == 4){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerDLabel.frame),
                              self.answerDLabel.frame)){
            [self hideTheTabBarWithAnimation:YES];
           // NSLog(@"last answer is on screen, dismiss scroll indicator");
        }
    }else if (self.detailItem.numberOfAnswers == 5){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerELabel.frame),
                              self.answerELabel.frame)){
     [self hideTheTabBarWithAnimation:YES];
                 // NSLog(@"last answer is on screen, dismiss scroll indicator");
    }
    }else{
        [self unhideTheTabBarWithAnimation:YES];
    }
        
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
    
    if ([sender.titleLabel.text isEqualToString:@"Next Question"]){
        [sender setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
        sender.titleLabel.tintColor = [UIColor whiteColor];
        [sender setAlpha:0.8];
    }else if (![normalbuttonStrings containsObject:sender.titleLabel.text] ){
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

- (void) handleTapFromA: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonA];
    NSLog(@"label A tapped by %@", recognizer);
    
    recognizer.enabled = NO;
    //Code to handle the gesture
}

- (void) handleTapFromB: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonB];
    NSLog(@"label B tapped by %@", recognizer);
    
    recognizer.enabled = NO;
    //Code to handle the gesture
}

- (void) handleTapFromC: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonC];
    NSLog(@"label C tapped by %@", recognizer);
    
    recognizer.enabled = NO;
    //Code to handle the gesture
}

- (void) handleTapFromD: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonD];
    NSLog(@"label D tapped by %@", recognizer);
    
    recognizer.enabled = NO;
    //Code to handle the gesture
}

- (void) handleTapFromE: (UITapGestureRecognizer *)recognizer
{
    [self clicked:self.buttonE];
    NSLog(@"label E tapped by %@", recognizer);
    
    recognizer.enabled = NO;
    //Code to handle the gesture
}

// Called from the master when a new question is pushed, also called for nextbutton. It manages updating all the labels, and calls the neccesarry methods to update the images and buttons
- (void)switchQuestion{
    
//    if (!self.detailItem.questionFinished){
//        tapGestureRecognizerA.enabled = YES;
//         tapGestureRecognizerB.enabled = YES;
//         tapGestureRecognizerC.enabled = YES;
//         tapGestureRecognizerD.enabled = YES;
//         tapGestureRecognizerE.enabled = YES;
//    }
    
    NSLog(@"%@  %@", self.detailItem.questionNumber, self.detailItem.questionContent);
    
    NSLog(@"Position of the bar: x:%f y:%f", resultImage.center.x, resultImage.center.y);
    
    //[self.pageFlipper setCurrentPage:[self.detailItem.questionNumber integerValue] animated:YES];
    
//    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
//        resultImage.center = CGPointMake(384, 86);
//    }else{
//        resultImage.center = CGPointMake(384, 1002.5);
//    }
 
    if (self.detailItem.numberOfAnswers>3) {
        
        [self unhideTheTabBarWithAnimation:YES];
    }else{
        [self hideTheTabBarWithAnimation:YES];
    }
    
    [UIView transitionWithView:self.view duration:0.6 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        
        
        
//        AnimationDelegate *animationDelegate = [[AnimationDelegate alloc] initWithSequenceType:kSequenceTriggered  directionType:kDirectionForward];
//        
//        FlipView *flipView = [[FlipView alloc] initWithAnimationType:kAnimationFlipHorizontal frame:self.view.frame];
//        
//        animationDelegate.transformView = flipView;
//        
//        [animationDelegate startAnimation:kDirectionForward];
//        
        self.qContentLabel.text = [NSString stringWithFormat:@"%@. %@", self.detailItem.questionNumber, self.detailItem.questionContent];
        self.qContentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        
        
        [self.qContentLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
        self.qContentLabel.textAlignment = NSTextAlignmentCenter;
  
 




        
        self.answerALabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerA];
        self.answerALabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerALabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
               self.answerALabel.textAlignment = NSTextAlignmentCenter;
        
        if (self.detailItem.numberOfAnswers == 2) {
        
        self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
        self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
                    self.answerBLabel.textAlignment = NSTextAlignmentCenter;
            
            //NO C, D, E
            self.answerCLabel.hidden = YES;
            self.buttonC.alpha = 0;
            
            self.answerDLabel.hidden = YES;
            self.buttonD.alpha = 0;
            
            self.answerELabel.hidden = YES;
            self.buttonE.alpha = 0;
            
            self.Cbackground.backgroundColor = [UIColor clearColor];
            self.Dbackground.backgroundColor = [UIColor clearColor];
            self.Ebackground.backgroundColor = [UIColor clearColor];
            
        
        }
        
        
        
        if (self.detailItem.numberOfAnswers == 3){
            
            
            self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
            self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
               self.answerBLabel.textAlignment = NSTextAlignmentCenter;
            
            
            self.answerCLabel.hidden = NO;
            self.buttonC.alpha = 1;
        
        self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
        self.answerCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerCLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
                    self.answerCLabel.textAlignment = NSTextAlignmentCenter;
            
            
            self.Cbackground.backgroundColor = UIColorFromRGB(0x007AFF);
            self.Cbackground.alpha = 0.3;
            self.Dbackground.backgroundColor = [UIColor clearColor];
            self.Ebackground.backgroundColor = [UIColor clearColor];
            
            self.answerDLabel.hidden = YES;
            self.buttonD.alpha = 0;
            
            self.answerELabel.hidden = YES;
            self.buttonE.alpha = 0;
        
        }
        
        
        if (self.detailItem.numberOfAnswers == 4){
            
            self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
            self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
               self.answerBLabel.textAlignment = NSTextAlignmentCenter;
            
            self.answerCLabel.hidden = NO;
            self.buttonC.alpha = 1;
            
            self.answerDLabel.hidden = NO;
            self.buttonD.alpha = 1;
            
            self.answerELabel.hidden = YES;
            self.buttonE.alpha = 0;
            
            self.Cbackground.backgroundColor = UIColorFromRGB(0x007AFF);
            self.Cbackground.alpha = 0.3;
            self.Dbackground.backgroundColor = UIColorFromRGB(0x007AFF);
            self.Dbackground.alpha = 0.3;
            
              self.Ebackground.backgroundColor = [UIColor clearColor];
            
            self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
            self.answerCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerCLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
                self.answerCLabel.textAlignment = NSTextAlignmentCenter;
            
            self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerD];
            self.answerDLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerDLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
                self.answerDLabel.textAlignment = NSTextAlignmentCenter;
            
        }
        
        if (self.detailItem.numberOfAnswers == 5){
            
            self.answerBLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerB];
            self.answerBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerBLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
               self.answerBLabel.textAlignment = NSTextAlignmentCenter;
            
            self.answerCLabel.hidden = NO;
            self.buttonC.alpha = 1;
            
            self.answerDLabel.hidden = NO;
            self.buttonD.alpha = 1;
            
            self.answerELabel.hidden = NO;
            self.buttonE.alpha = 1;
            
            self.Cbackground.backgroundColor = UIColorFromRGB(0x007AFF);
            self.Cbackground.alpha = 0.3;
            self.Dbackground.backgroundColor = UIColorFromRGB(0x007AFF);
            self.Dbackground.alpha = 0.3;
            self.Ebackground.backgroundColor = UIColorFromRGB(0x007AFF);
            self.Ebackground.alpha = 0.3;
            
            self.answerCLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerC];
            self.answerCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerCLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
                self.answerCLabel.textAlignment = NSTextAlignmentCenter;
            
            self.answerDLabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerD];
            self.answerDLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            [self.answerDLabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
 self.answerDLabel.textAlignment = NSTextAlignmentCenter;
    
        self.answerELabel.text = [NSString stringWithFormat: @"%@", self.detailItem.answerE];
        self.answerELabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        [self.answerELabel addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
                 self.answerELabel.textAlignment = NSTextAlignmentCenter;
        }
     

    }completion:nil];
    
    if ([self qIsTypeNormal]){
        [QuestionViewController shouldDisableButton:reportButton should:YES];
        
        self.progressBarBorder.image = [UIImage imageNamed:@"4bar.png"];
        self.progressBarBorder.alpha = 0.6;
        resultImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"0bar.png"]];
        resultImage.alpha = 0.6;
        resultImageStartPoint = resultImage.center;
        if (!self.detailItem.qAttempts) { //If buttons pressed is still Null, create it.
            self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, @0, nil];
            
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %d", self.detailItem.numberOfAnswers];
        } else { //Question has been attempted
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %ld", self.detailItem.numberOfAnswers - [self.detailItem.qAttempts integerValue]];
        }
        nextButton.enabled = NO;
    } else { // else, it is a report question!
        
        resultImage.image = nil;
        self.progressBarBorder.image = nil;
        if (!self.detailItem.qAttempts) { //If buttons pressed is still Null
            self.detailItem.ButtonsPressed = [[NSMutableArray alloc] initWithObjects:@0,@0, @0, @0, @0, nil];
        }
        
        
        self.attemptsLabel.text = @"";
        
//        if (!self.questionFinished){
//        self.attemptsLabel.text = @"Application Question";
//        }else{
//            self.attemptsLabel.text = @"";
//        }
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
            UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
            tapGesture.enabled = NO;
            
        }
        
        // Prevents enabled next button on the last question
        if ([self.detailItem.questionNumber integerValue] != (int)quizLength-1 ){
            
            [QuestionViewController shouldDisableButton:nextButton should:NO];
            
            //nextButton.enabled = YES;
            
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
                UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
                tapGesture.enabled = YES;
            } else {
                [QuestionViewController shouldDisableButton:[buttonArray objectAtIndex:index] should:YES];
                UITapGestureRecognizer  *tapGesture = [tapGestureArray objectAtIndex:index];
                tapGesture.enabled = NO;
            }
        }
    }
}

// Handles all the logistics for setting the images (checkmarks and x's, progress bars, and background of button)
- (void)SetImagesAccordingToButtonsPressed{
    
    // This is needed to tell if a button has been pressed at all. If the table tries to update before a button is pressed, it will crash
    bool flag = false;
    
    if ([self qIsTypeNormal]){
        
//        [buttonA setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonB setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonC setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonD setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonE setBackgroundImage:nil forState:UIControlStateNormal];
        
        
        

        // Set the lower progress bar image for the first time
        if (!self.detailItem.qAttempts)
        {
            resultImage.center = CGPointMake(resultImageStartPoint.x, resultImage.center.y);
        }
        else if (self.detailItem.questionFinished) //question is finished, display qattempts-1 as progress bar
        {
           resultImage.center = CGPointMake([[startpointsArray objectAtIndex:[self.detailItem.qAttempts integerValue]-1] CGPointValue].x, resultImage.center.y);
        }
        else // question is not finished, move bar to the left 200 pixels
        {
            
            float movePercentage = 0.0;
            
            if (self.detailItem.numberOfAnswers == 2){
                movePercentage = 1;
            }else if (self.detailItem.numberOfAnswers == 3){
                movePercentage = 0.5;
            }else if (self.detailItem.numberOfAnswers == 4){
                movePercentage = 0.33;
            }else if (self.detailItem.numberOfAnswers == 5){
                movePercentage = 0.25;
            }
            
            NSLog(@"move percentage: %f", movePercentage);
            
            int pixelMove = resultImage.frame.size.width*movePercentage;
            
            NSLog(@"pixelMove: %i", pixelMove);
            
            
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{ resultImage.center = CGPointMake(resultImage.center.x-pixelMove, resultImage.center.y); } completion:^ (BOOL fin){ }];
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
            
            
            
            NSLog(@"set images, bar x: %f, bary: %f", resultImage.center.x, resultImage.center.y);
            
            
        }

    } else { // it's a report question, need to set the background image to show its been selected, and make sure all other images are nil
        
        
        
        _aImage.image = nil;
        _bImage.image = nil;
        _cImage.image = nil;
        _dImage.image = nil;
        _eImage.image = nil;
        
//        _aImage.alpha = 0;
//         _bImage.alpha = 0;
//         _cImage.alpha = 0;
//         _dImage.alpha = 0;
//         _eImage.alpha = 0;
//        [buttonA setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonB setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonC setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonD setBackgroundImage:nil forState:UIControlStateNormal];
//        [buttonE setBackgroundImage:nil forState:UIControlStateNormal];
        
        resultImage.center = resultImageStartPoint;
        
        // The @3 in the index of buttonspressed means it was chosen as a report question answer
        for(int index = 0; index < 5; index++)
        {
            if ([[self.detailItem.ButtonsPressed objectAtIndex:index] isEqualToValue:@3]){
                UIImageView *tempimage = [imageArray objectAtIndex:index];
                tempimage.image = [UIImage imageNamed:@"1-ext.png"];
            }
        }
    }
    
    // stuff below here applies to both types of questions
    if (( UIDeviceOrientationIsLandscape(self.interfaceOrientation) && flag ) || (( UIDeviceOrientationIsLandscape(self.interfaceOrientation)) &&![self qIsTypeNormal])){
        // Device is in landscape, so we need to update the table image as soon as the button is pressed. Only do this if a button has been pressed (flag will be yes)
        // If it is a report question, only update it the first time.
        id masternav = self.splitViewController.viewControllers[0];
        QuizTableViewController *master = (QuizTableViewController *)[masternav topViewController];
        
        
        NSArray *indexPaths;
        if ([self.detailItem.qtype isEqualToString:@"0"]){
        
        indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.detailItem.sortedQNumber-1 inSection:0], nil];
        }else if ([self.detailItem.qtype isEqualToString:@"1"]){
            indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.detailItem.sortedQNumber-1 inSection:1], nil];
        }

       [master.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
    NSLog(@"set images exiting method, bar x: %f, bary: %f", resultImage.center.x, resultImage.center.y);
}

// Called when a correct answer is pressed or anytime a report answer is chosen
- (void)sendAttemptsToParse{
    if (!self.attempts){  //if the attempts array hasnt been made
        
        id masternav = self.splitViewController.viewControllers[0];
        id master = [masternav topViewController];
        if ([master isKindOfClass:[QuizTableViewController class]]){
            [self assignQuizLengthFromMaster:master];
        }
        
        self.attempts = [[NSMutableArray alloc] init];
        for (int i = 0; i < (int)quizLength+1; i++ ){
            [self.attempts insertObject:@0 atIndex:i];
        }
        NSLog(@"The legth of attempts array: %lu\nThe number of questions: %d", (unsigned long)[self.attempts count], quizLength);
        
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
            self.attemptsLabel.text = [NSString stringWithFormat:@"Attempts Left: %ld", self.detailItem.numberOfAnswers - [self.detailItem.qAttempts integerValue]];
        }
        
    } else { // It is a report question
        self.detailItem.questionFinished = YES; // This will turn off all the buttons when calling EnableButtonsAccordingToButtonsPressed
        [self sendAttemptsToParse]; // This will send the button selected to parse

        [self.detailItem insertObjectInButtonsPressed:@3 AtLetterSpot:sender.titleLabel.text];
        self.detailItem.reportButtonChoice = currentButton;
        self.attemptsLabel.text = @"";
    }
    [self EnableButtonsAccordingToButtonsPressed]; // Both types of questions use EnableButtons and SetImages  Method
    
    NSLog(@"before set images, bar x: %f, bary: %f", resultImage.center.x, resultImage.center.y);
    
    [self SetImagesAccordingToButtonsPressed];
    
    NSLog(@"clicked: bar x: %f, bary: %f", resultImage.center.x, resultImage.center.y);
}

- (IBAction)reportButtonSelected:(UIButton *)sender {
   
    [self performSegueWithIdentifier: @"goToBigButton" sender: self];
    
}

// Next questions redirects to GoToNextQuestions because the swipeleft gesture also needs the same code
- (IBAction)nextQuestion:(id)sender {
    
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength){
        NSLog(@"The question number is %ld", (long)[self.detailItem.questionNumber integerValue]);
        [self goToNextQuestion];
    }


}

- (IBAction)swipedRight:(id)sender {
    
    // Make sure you cant swipe on the last question
    if ([self.detailItem.questionNumber integerValue] != (int)quizLength){
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
    self.attemptsLabel.text = @"";
    
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
        
        self.navigationItem.rightBarButtonItem.tintColor = UIColorFromRGB(0x007AFF);
      
        
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

#pragma mark - page flipper protocols

- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *) pageFlipper{
    
    return *quizLength;
    
}
- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper{
    UIView *view = [[UIView alloc] initWithFrame:pageFlipper.frame];
    
    return view;
    
}


#pragma mark - Scroll view delegates


-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.detailItem.numberOfAnswers>3){
    
    if (self.detailItem.numberOfAnswers == 4){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerDLabel.frame),
                              self.answerDLabel.frame)){
            [self hideTheTabBarWithAnimation:YES];
           // NSLog(@"last answer is on screen, dismiss scroll indicator");
        }else{
            [self unhideTheTabBarWithAnimation:YES];
        }
    }
    
    
    if (self.detailItem.numberOfAnswers == 5){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerELabel.frame),
                              self.answerELabel.frame)){
            [self hideTheTabBarWithAnimation:YES];
          //  NSLog(@"last answer is on screen, dismiss scroll indicator");
        }else{
            [self unhideTheTabBarWithAnimation:YES];
        }
    }
    }
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (self.detailItem.numberOfAnswers>3){
    
    if (self.detailItem.numberOfAnswers == 4){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerDLabel.frame),
                              self.answerDLabel.frame)){
            [self hideTheTabBarWithAnimation:YES];
           // NSLog(@"last answer is on screen, dismiss scroll indicator");
        }else{
            [self unhideTheTabBarWithAnimation:YES];
        }
    }else if (self.detailItem.numberOfAnswers == 5){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerELabel.frame),
                              self.answerELabel.frame)){
            [self hideTheTabBarWithAnimation:YES];
          //  NSLog(@"last answer is on screen, dismiss scroll indicator");
        }else{
            [self unhideTheTabBarWithAnimation:YES];
        }
    }
    
    }
}



-(void) scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    [self unhideTheTabBarWithAnimation:YES];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (self.detailItem.numberOfAnswers>3){
    
    if (self.detailItem.numberOfAnswers == 4){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerDLabel.frame),
                              self.answerDLabel.frame)){
            [self hideTheTabBarWithAnimation:YES];
           // NSLog(@"last answer is on screen, dismiss scroll indicator");
        }else{
            [self unhideTheTabBarWithAnimation:YES];
        }
    }else if (self.detailItem.numberOfAnswers == 5){
        if (CGRectEqualToRect(CGRectIntersection(self.scrollView.bounds, self.answerELabel.frame),
                              self.answerELabel.frame)){
            [self hideTheTabBarWithAnimation:YES];
          //  NSLog(@"last answer is on screen, dismiss scroll indicator");
        }else{
            [self unhideTheTabBarWithAnimation:YES];
        }
    }
        
    }
}




- (void) hideTheTabBarWithAnimation:(BOOL) withAnimation {
    if (NO == withAnimation) {
        self.scrollIndicator.image = nil;
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDuration:0.75];
        
        self.scrollIndicator.alpha = 0;
        
        [UIView commitAnimations];
    }
}


- (void) unhideTheTabBarWithAnimation:(BOOL) withAnimation {
    if (NO == withAnimation) {
        self.scrollIndicator.image = [UIImage imageNamed:@"downSimple.png"];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDuration:0.75];
        
        self.scrollIndicator.alpha = 1;
        
        [UIView commitAnimations];
    }
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

//#pragma mark - PFSignUpViewControllerDelegate
//
//// Signup isnt needed, but keep if we ever want to implement it.
//
//// Sent to the delegate to determine whether the sign up request should be submitted to the server.
//- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
//    BOOL informationComplete = YES;
//    
//    // loop through all of the submitted data
//    for (id key in info) {
//        NSString *field = [info objectForKey:key];
//        if (!field || !field.length) { // check completion
//            informationComplete = NO;
//            break;
//        }
//    }
//    
//    // Display an alert if a field wasn't completed
//    if (!informationComplete) {
//        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
//    }
//    
//    return informationComplete;
//}
//
//// Sent to the delegate when a PFUser is signed up.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}
//
//// Sent to the delegate when the sign up attempt fails.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
//    NSLog(@"Failed to sign up...");
//}
//
//// Sent to the delegate when the sign up screen is dismissed.
//- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
//    NSLog(@"User dismissed the signUpViewController");
//}
//
@end
