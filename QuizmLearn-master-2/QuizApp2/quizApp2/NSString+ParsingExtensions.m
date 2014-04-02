//
//  NSString+ParsingExtensions.m
//  QuizApp2
//
//  Created by Bruce Li on 1/27/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import "NSString+ParsingExtensions.h"

@implementation NSString (ParsingExtensions)

-(NSArray *)csvRows {
    NSMutableArray *rows = [NSMutableArray array];
    
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
    
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
            
            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""];
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {
                if ( insideQuotes ) {
                    [currentColumn appendString:@","];
                }
                else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
    
    return rows;
}

//- (NSArray *) parse: (NSString *) filePath {
//    
//    NSArray *pathFragments = [filePath componentsSeparatedByString:@"."];
//    NSString *path = pathFragments[0];
//    //NSString *type = pathFragments[1];
//    
//    NSArray *quizInfo = [path componentsSeparatedByString:@"_"];
//    
//    NSString *instructor = quizInfo[0];
//    NSString *quizName = quizInfo[1];
//    NSString *courseCode = quizInfo[2];
//    NSString *date = quizInfo[3];
//    NSLog(@"Instructor: %@, Quiz Name: %@, Course: %@, Date: %@", instructor, quizName, courseCode, date );
//    return quizInfo;
//}

@end

