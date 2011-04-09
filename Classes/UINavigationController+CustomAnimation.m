//
//  UINavigationController+CustomAnimation.m
//  lifelapse
//
//  Created by Brian King on 12/29/10.
//  Copyright 2010 King Software Design. All rights reserved.
//

#import "UINavigationController+CustomAnimation.h"
#import "UIView+Transition.h"

#import "NSObject+Proxy.h"
#include <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

// Dictionary Keys for Lazy Loading
static NSString* kClassNameKey = @"kClassNameKey";
static NSString* kNibNameKey = @"kNibNameKey";
static NSString* kBundleNameKey = @"kBundleNameKey";

static NSString *UINavigationControllerCustomAnimationKey = @"UINavigationControllerCustomAnimation_Key";
static NSString *UINavigationControllerCustomAnimationNewControllersKey = @"UINavigationControllerCustomAnimationNewControllers_Key";
static NSString *UINavigationControllerLazyLoadingControllers = @"UINavigationControllerLazyLoadingControllers_Key";
static NSString *UINavigationControllerLazyLoadingControllerMetaData = @"UINavigationControllerLazyLoadingControllerMetaData_Key";


// These are some new properties to hold some state while the animation is in transition
@interface UINavigationController(CustomAnimationPrivate)
@property (nonatomic, retain) UIViewController *newViewController;
@property (nonatomic, retain) NSArray *newViewControllers;

@end

@implementation UINavigationController(CustomAnimation)
- (void) setViewControllers:(NSArray *)viewControllers slide:(BKSlideDirection)direction {
    NSParameterAssert(viewControllers);

    UIViewController *viewController = [viewControllers lastObject];

    // Add the view controller to the superview of the topviewcontroller.
	[[self.topViewController.view superview] addSubview:viewController.view];

    BKSlideDirection otherDirection = BKSlideOtherDirection(direction);
    
    // Find the offscreen point in the other direction for the view controller to slide on.
    CGPoint offscreenPoint = BKSlideOffscreenCenterPoint([[UIScreen mainScreen] bounds], 
                                                         viewController.view.frame,
                                                         otherDirection);

    CGPoint topOffscreenPoint = BKSlideOffscreenCenterPoint([[UIScreen mainScreen] bounds], 
                                                         viewController.view.frame,
                                                            direction);

    // Move to the new place, off screen
	[viewController.view transitionMoveTo:offscreenPoint];
    
    
	[UIView transitionWithView:self.view duration:.4 options:0 animations:^(void) {
		self.toolbar.items = viewController.toolbarItems;
		[viewController.view removeTransition];
		[self.topViewController.view transitionMoveTo:topOffscreenPoint];
	} completion:^(BOOL completed) {
		UIViewController *old = self.topViewController;
        self.viewControllers = viewControllers;
		[old.view removeTransition];
	}];
}

- (void) pushViewController:(UIViewController *)viewController slide:(BKSlideDirection)direction {
    // This method is doubled up.   If you pass nil, it will pop.  A bit ugly, but hey.
	BOOL push = YES;
	if (viewController == nil) {
		push = NO;
		NSUInteger count = [self.viewControllers count];
		NSAssert(count > 1, @"Cannot pop top view controller");
		viewController = [self.viewControllers objectAtIndex:count - 2];
	}

	[[self.topViewController.view superview] addSubview:viewController.view];

    BKSlideDirection otherDirection = BKSlideOtherDirection(direction);
    
    // Find the offscreen point in the other direction for the view controller to slide on.
    CGPoint offscreenPoint = BKSlideOffscreenCenterPoint([[UIScreen mainScreen] bounds], 
                                                         viewController.view.frame,
                                                         otherDirection);
    
    CGPoint topOffscreenPoint = BKSlideOffscreenCenterPoint([[UIScreen mainScreen] bounds], 
                                                            viewController.view.frame,
                                                            direction);
    
    // Move to the new place, off screen
	[viewController.view transitionMoveTo:offscreenPoint];


	[UIView transitionWithView:self.view duration:.4 options:0 animations:^(void) {
		self.toolbar.items = viewController.toolbarItems;
		[viewController.view removeTransition];
		[self.topViewController.view transitionMoveTo:topOffscreenPoint];
	} completion:^(BOOL completed) {
		UIViewController *old = self.topViewController;
		if (push) {
			[self pushViewController:viewController animated:NO];
		} else {
			[self popViewControllerAnimated:NO];
		}
		[old.view removeTransition];
        [old.view removeFromSuperview];
	}];
}

- (void) popViewControllerSlide:(BKSlideDirection)direction {
	[self pushViewController:nil slide:direction];
}

- (void) pushViewController:(UIViewController *)viewController animation:(UIViewAnimationOptions)options {
    NSAssert(self.visibleViewController != viewController, @"Can not push the visible controller on");

	[UIView transitionWithView:self.view duration:.4
					   options:options 
					animations:^(void) {
						[self pushViewController:viewController animated:NO];
					} 
					completion:nil];
}

- (void) popViewControllerAnimation:(UIViewAnimationOptions)options {
	[UIView transitionWithView:self.view duration:.4
					   options:options 
					animations:^(void) {
						[self popViewControllerAnimated:NO];
					} 
					completion:nil];	
}

- (void) prepareView:(UIView*)newViewControllerView {
    // There's an odd low memory crash here if [newViewController.view superview] is nil, so add it.
    // This causes double viewDidAppear messages as the container-subview is a delegate that triggers these things
	[[self.view superview] addSubview:newViewControllerView];
    [[self.view superview] sendSubviewToBack:newViewControllerView];
}
- (void) popViewControllerCustomAnimation {
	NSParameterAssert([self.viewControllers count] > 1);
    self.newViewControllers = [self.viewControllers subarrayWithRange:NSMakeRange(0, [self.viewControllers count] - 1)];
	self.newViewController = [self.newViewControllers lastObject];
    
    [self prepareView:self.newViewController.view];

    // Animate the Exit To Transition
	UIViewController *currentController = self.topViewController;

	if ([currentController respondsToSelector:@selector(animateTransitionExitTo:)]) {
        [currentController performSelector:@selector(animateTransitionExitTo:) withObject:self.newViewController];
	} else {
		[self animationComplete];
	}
}

- (void) pushViewControllerCustomAnimation:(UIViewController*)newController {
	self.newViewController = newController;
    self.newViewControllers = [self.viewControllers arrayByAddingObject:self.newViewController];

    [self prepareView:self.newViewController.view];

    // Animate the Exit To Transition
    UIViewController *currentController = self.topViewController;
          
    if ([currentController respondsToSelector:@selector(animateTransitionExitTo:)]) {
        [[currentController nextRunloopProxy] performSelector:@selector(animateTransitionExitTo:) withObject:self.newViewController];
	} else {
		[self animationComplete];
	}
}

- (void) animationComplete {

	if (self.newViewControllers) {
        UIViewController *fromVC = [self.viewControllers lastObject];

        // Complete the exit stage and perform the enter stage
		self.viewControllers = self.newViewControllers;
        self.newViewController.view.hidden = NO;
        self.newViewControllers = nil;
        
        [self.view layoutIfNeeded];
        if ([self.newViewController respondsToSelector:@selector(animateTransitionEnterFrom:)]) {
            [self.newViewController performSelector:@selector(animateTransitionEnterFrom:) withObject:fromVC];
        } else {
            [self animationComplete];
        }
	} else {
        // We don't have to do anything when enterFrom is finished.
	}
}

- (void) setNewViewController:(UIViewController *)newController {
	objc_setAssociatedObject(self, UINavigationControllerCustomAnimationKey, newController, OBJC_ASSOCIATION_RETAIN);
}

- (UIViewController*) newViewController {
	UIViewController* newController = objc_getAssociatedObject(self, UINavigationControllerCustomAnimationKey);
	return newController;
}
- (void) setNewViewControllers:(NSArray *)newControllers {
	objc_setAssociatedObject(self, UINavigationControllerCustomAnimationNewControllersKey, newControllers, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray*) newViewControllers {
	NSArray *newControllers = objc_getAssociatedObject(self, UINavigationControllerCustomAnimationNewControllersKey);
	return newControllers;
}

@end

@interface UINavigationController(LazyLoadingPrivate)
@property (nonatomic, retain, readonly) NSMutableDictionary *controllers;
@property (nonatomic, retain, readonly) NSMutableDictionary *controllerMetaData;
@end
@implementation UINavigationController(LazyLoadingPrivate)

- (NSMutableDictionary*)controllers {
    NSMutableDictionary *controllers = objc_getAssociatedObject(self, UINavigationControllerLazyLoadingControllers);
    if (controllers == nil) {
        controllers = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, UINavigationControllerLazyLoadingControllers, controllers, OBJC_ASSOCIATION_RETAIN);
    }
    return controllers;
}
- (NSMutableDictionary*)controllerMetaData {
    NSMutableDictionary *controllerMetaData = objc_getAssociatedObject(self, UINavigationControllerLazyLoadingControllerMetaData);
    if (controllerMetaData == nil) {
        controllerMetaData = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, UINavigationControllerLazyLoadingControllerMetaData, controllerMetaData, OBJC_ASSOCIATION_RETAIN);
    }
    
    return controllerMetaData;
}

@end

@implementation UINavigationController(LazyLoading)
#pragma mark -
#pragma mark metaData

- (UIViewController*)controllerWithMetaData:(NSDictionary*)metaData{
	
	UIViewController* controller = nil;
	
	NSString* className = [metaData objectForKey:kClassNameKey];
	
	if(className == nil)
		return nil;
	
	Class vcClass = NSClassFromString(className);
	
	
	NSString* nib = [metaData objectForKey:kNibNameKey];
	NSBundle* bundle = [metaData objectForKey:kBundleNameKey];
	controller = [[vcClass alloc] initWithNibName:nib bundle:bundle];
    
	return [controller autorelease];
}


- (NSDictionary*)metaDataForClass:(Class)class nib:(NSString*)aNibName bundle:(NSString*)bundle{
	
	NSMutableDictionary* metaData = [NSMutableDictionary dictionaryWithCapacity:3];
	
	NSString *className = NSStringFromClass(class);	
	
	if(className == nil)
		return nil;
	
	[metaData setObject:(NSString*)className forKey:kClassNameKey];
	
	if(aNibName != nil)
		[metaData setObject:aNibName forKey:kNibNameKey];
	
	if(bundle != nil)
		[metaData setObject:bundle forKey:kBundleNameKey];
	
	return metaData;
	
} 


- (void)setViewControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key {
    [self.controllers removeObjectForKey:key];
	[self.controllerMetaData setObject:[self metaDataForClass:viewControllerClass nib:aNibName bundle:bundle] forKey:key];
}
- (void)setViewController:(UIViewController*)controller forKey:(NSString*)key {
    [self.controllers setObject:controller forKey:key];
	[self.controllerMetaData removeObjectForKey:key];
}
- (UIViewController*)viewControllerForKey:(NSString*)key {
    UIViewController *controller = [self.controllers objectForKey:key];
    if (controller == nil) {
        controller = [self controllerWithMetaData:[self.controllerMetaData objectForKey:key]];
        [self.controllers setObject:controller forKey:key];
    }
    return controller;
}

@end


#ifdef NAVIGATIONBAR_BACKGROUND
@implementation UINavigationBar(BKCustomDrawing)

#pragma mark Custom Drawing
- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if ([self isMemberOfClass:[UINavigationBar class]] == NO) {
        return;
    }
    UIImage *image = [UIImage imageNamed:NAVIGATIONBAR_BACKGROUND];
//    CGContextClip(context);
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), image.CGImage);
}



@end
#endif