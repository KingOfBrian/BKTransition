//
//  BKImagePassingViewController.m
//  BKTransitionDemo
//
//  Created by Brian King on 4/14/11.
//  Copyright 2011 King Software Design. All rights reserved.
//

#import "BKViewController.h"
static NSUInteger mode = 0;

@implementation BKViewController
- (void) updateTitle {
    if (mode == 0) {
        self.title = @"Normal";
    } else if (mode == 1) {
        self.title = @"Vertical Slide";
    } else if (mode == 2) {
        self.title = @"Horizontal Slide";        
    } else if (mode == 3) {
        self.title = @"Curl Transition";        
    } else if (mode == 4) {
        self.title = @"Flip Transition";        
    } else if (mode == 5) {
        self.title = @"Custom Transition";        
    }
}
- (void) nextTransitionType {
    mode++;
    if (mode > 5) mode = 0;
    [self updateTitle];
}
- (void) pushController:(UIViewController*)controller {
    if (mode == 0) {
        [self.navigationController pushViewController:controller animated:YES];
    } else if (mode == 1) {
        [self.navigationController pushViewController:controller slide:BKSlideDirectionUp];
    } else if (mode == 2) {
        [self.navigationController pushViewController:controller slide:BKSlideDirectionLeft];
    } else if (mode == 3) {
        [self.navigationController pushViewController:controller animation:UIViewAnimationOptionTransitionCurlUp];
    } else if (mode == 4) {
        [self.navigationController pushViewController:controller animation:UIViewAnimationOptionTransitionFlipFromLeft];
    } else if (mode == 5) {
        [self.navigationController pushViewControllerCustomAnimation:controller];
    }
}
- (void) popController {
    if (mode == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (mode == 1) {
        [self.navigationController popViewControllerSlide:BKSlideDirectionDown];
    } else if (mode == 2) {
        [self.navigationController popViewControllerSlide:BKSlideDirectionRight];
    } else if (mode == 3) {
        [self.navigationController popViewControllerAnimation:UIViewAnimationOptionTransitionCurlDown];
    } else if (mode == 4) {
        [self.navigationController popViewControllerAnimation:UIViewAnimationOptionTransitionFlipFromRight];
    } else if (mode == 5) {
        [self.navigationController popViewControllerCustomAnimation];
    }
}

@end
