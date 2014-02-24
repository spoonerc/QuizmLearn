//
//  RKiOS7Loading.h
//  QuizApp2-7
//
//  Created by cisdev2 on 2/24/2014.
//  Copyright (c) 2014 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
//#import "UIColor+iOS7.h"

@interface RKiOS7Loading : UIView

/**
 * The width of the line used to draw the indicator view.
 **/
@property (nonatomic, assign) CGFloat lineWidth;

/**
 * The color of the indicator view
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 * Make the background layer to spin around its center. This should be called in the main thread.
 */
- (void) startSpinProgressBackgroundLayer;

/**
 * Stop the spinning of the background layer. This should be called in the main thread.
 * WARN: This implementation remove all animations from background layer.
 **/
- (void) stopSpinProgressBackgroundLayer;

// To show the indicator in the View
+ (RKiOS7Loading *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated ;

// To Hide the indicator in the View

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated ;

@end
