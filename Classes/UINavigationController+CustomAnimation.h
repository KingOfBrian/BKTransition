//
//  UINavigationController+CustomAnimation.h
//  lifelapse
//
//  Created by Brian King on 12/29/10.
//  Copyright 2010 King Software Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Transition.h"

// Informal protocol to define the signals used by custom transitions.
@protocol BKCustomAnimationUINavigationController 
@optional

- (void) animateTransitionEnterFrom:(UIViewController*)fromViewController;
- (void) animateTransitionExitTo:(UIViewController*)toViewController;

@end


@interface UINavigationController(CustomAnimation)

// Wrapper around UIView's custom animations.  UIViewAnimationTransitionCurl/Flip
- (void) pushViewController:(UIViewController *)viewController animation:(UIViewAnimationOptions)options;
- (void) popViewControllerAnimation:(UIViewAnimationOptions)options;

// Helpers for sliding left, right, up, and down.
- (void) pushViewController:(UIViewController *)viewController slide:(BKSlideDirection)direction;
- (void) popViewControllerSlide:(BKSlideDirection)direction;
- (void) setViewControllers:(NSArray *)viewControllers slide:(BKSlideDirection)direction;

// Custom Transitions
- (void) pushViewControllerCustomAnimation:(UIViewController *)viewController;
- (void) popViewControllerCustomAnimation;

// This function is called by the completion block in the custom transition animation 
- (void) animationComplete;

@end

// When playing with Animations, I found it very painful to move around where my UIViewControllers are
// Defined.  Define them by name and get them from anywhere.   The views will unload, but the controllers
// are never deallocated.  Thanks to FJSTransitionController for the basic code.

@interface UINavigationController(LazyLoading)

- (void)setViewControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key;
- (void)setViewController:(UIViewController*)controller forKey:(NSString*)key;
- (UIViewController*)viewControllerForKey:(NSString*)key;

@end
