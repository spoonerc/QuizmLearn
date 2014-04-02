//
//  squaresViewController.m
//  quizCard
//
//  Created by cisdev1 on 2013-08-24.
//  Copyright (c) 2013 cisdev1. All rights reserved.
//

#import "squaresViewController.h"
#import "questionViewController.h"
#import <Parse/Parse.h>

@implementation squaresViewController
{
    NSMutableArray *attemptsArray;
    NSArray *theList, *theOtherList;
    NSNumber *indexNum;             //forgot to set this guy
    NSUInteger questionsViewed;
    NSIndexPath *indexPath2;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //this specifies the border spacing to give 5 squares per row
    UICollectionViewFlowLayout *collectViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectViewLayout.sectionInset = (UIEdgeInsetsMake(90, 100, 0, 100));
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressedSubmit)];

    
    //initialize array that will track attempts used/question
    attemptsArray = [[NSMutableArray alloc]initWithObjects:@0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, nil];
    
    questionsViewed  = 0;

    //PFObject *testObject = [PFObject objectWithClassName:@"theList"];
    PFQuery *query = [PFQuery queryWithClassName:@"theList"];
    [query getObjectInBackgroundWithId:@"Dto3N6VkLf" block:^(PFObject *sol, NSError *error){
        //do stuff here
        theList = [sol objectForKey:@"sol"];
    }];
    
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;      //default is set/hard-coded to questions
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *squareImageView = (UIImageView *)[cell viewWithTag:100];
    UILabel *questionLabel = (UILabel *)[cell viewWithTag:10];
    
    indexNum = [attemptsArray objectAtIndex:indexPath.row];
    
    //show question number
    questionLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    
    //decide what * pic to show
    if ([indexNum isEqual:@0]) {
        squareImageView.image = [UIImage imageNamed:@"5.png"];
    }else{
        squareImageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", indexNum]];
    }

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //this function is used to pass data using the navigation segue
    if ([segue.identifier isEqual:@"goToQuestion"]) {
        
        questionsViewed++;  //add one to the number of questions viewed
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        questionViewController *destViewC = segue.destinationViewController;
        
        indexPath2 = [indexPaths objectAtIndex:0];
        
        //this is where the action happens; send info to the question view
        destViewC.attempts = [attemptsArray objectAtIndex:indexPath2.row];  //to decide if question should be available
        destViewC.correct = [theList objectAtIndex:indexPath2.row];         //to determine correct ans
        
       [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(questionViewed:) name:@"attempted" object:nil];
        NSLog(@"%@", [theList objectAtIndex:indexPath2.row]);
    }
}

-(void)questionViewed:(NSNotification *)notification
{
    [attemptsArray replaceObjectAtIndex:indexPath2.row withObject:[notification object]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

-(void)pressedSubmit
{
    PFObject *anObject;
    anObject = [PFObject objectWithClassName:@"submission"];
    [anObject setObject:attemptsArray forKey:@"attemptsUsed"];
    [anObject save];
}

@end
