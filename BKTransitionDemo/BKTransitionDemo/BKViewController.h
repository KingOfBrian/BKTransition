//
//  BKImagePassingViewController.h
//  BKTransitionDemo
//
//  Created by Brian King on 4/14/11.
//  Copyright 2011 King Software Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+CustomAnimation.h"


@interface BKViewController : UIViewController {
    
}
- (void) nextTransitionType;
- (void) pushController:(UIViewController*)controller;
- (void) popController;

// To be implemented by base classes
- (CGRect) locationForTransitionImageInView:(UIView*)inView;

@end
