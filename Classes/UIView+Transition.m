//
//  UIView+Home.m
//  lifelapse
//
//  Created by Brian King on 12/29/10.
//  Copyright 2010 King Software Design. All rights reserved.
//

#import "UIView+Transition.h"
#include <objc/runtime.h>

BK_EXTERN BOOL BKSlideIsDirection(BKSlideDirection check, BKSlideDirection direction) {
    BOOL value = (check | direction) == check;
    return value;
}

BK_EXTERN BKSlideDirection BKSlideOrientation(BKSlideDirection direction) {
    if ((direction | BKSlideDirectionHorizontal) == BKSlideDirectionHorizontal) {
        return BKSlideDirectionHorizontal;
    } else {
        return BKSlideDirectionVertical;
    }
}

BK_EXTERN BKSlideDirection BKSlideOtherDirection(BKSlideDirection direction) {
    BKSlideDirection orientation = BKSlideOrientation(direction);
    return (direction ^ orientation);
}

BK_EXTERN CGPoint CGPointCenterOfRect(CGRect frame) {
    return CGPointMake(frame.origin.x + (frame.size.width / 2), 
                       frame.origin.y + (frame.size.height / 2));
}

BK_EXTERN CGPoint BKSlideOffscreenCenterPoint(CGRect enclosingFrame, CGRect frame, BKSlideDirection direction) {

    // In theory this might handle diagonals too, but the mask would need to be altered.
    CGPoint offscreenCenter = CGPointCenterOfRect(frame);
    if (BKSlideIsDirection(BKSlideDirectionVertical, direction)) {
        CGFloat shift = frame.size.height / 2;
        
        if (BKSlideIsDirection(BKSlideDirectionUp, direction)) {
            offscreenCenter.y = enclosingFrame.origin.y - shift;
        } else if (BKSlideIsDirection(BKSlideDirectionDown, direction)) {
            offscreenCenter.y = enclosingFrame.size.height + shift;
        }
    }
    if (BKSlideIsDirection(BKSlideDirectionHorizontal, direction)) {
        CGFloat shift = frame.size.width / 2;
        
        if (BKSlideIsDirection(BKSlideDirectionRight, direction)) {
            offscreenCenter.x = enclosingFrame.size.width + shift;
        } else if (BKSlideIsDirection(BKSlideDirectionLeft, direction)) {
            offscreenCenter.x = enclosingFrame.origin.x - shift;
        }
    }
    return offscreenCenter;
}

static NSString *UIViewTransitionKey = @"UIView_Transition_Key";

@implementation UIView(Transition)

- (void) setTransitionTransform:(CGAffineTransform)tt {
   objc_setAssociatedObject(self, UIViewTransitionKey, [NSValue valueWithCGAffineTransform:tt], OBJC_ASSOCIATION_RETAIN);

}


- (CGAffineTransform) transitionTransform {
	NSValue *transformAsValue = objc_getAssociatedObject(self, UIViewTransitionKey);
	if (transformAsValue) {
		return [transformAsValue CGAffineTransformValue];
	}
	return CGAffineTransformIdentity;
}

- (void) transitionMoveDirection:(BKSlideDirection)direction by:(CGFloat)pixels {
	CGPoint move = CGPointMake(0, 0);
	if (direction == UISwipeGestureRecognizerDirectionRight) {
		move.x += pixels;
	} else if (direction == UISwipeGestureRecognizerDirectionLeft) {
		move.x -= pixels;
	} else if (direction == UISwipeGestureRecognizerDirectionUp) {
		move.y -= pixels;
	} else if (direction == UISwipeGestureRecognizerDirectionDown) {
		move.y += pixels;
	}
	[self transitionMoveBy:move];

}

- (void) transitionMoveOffscreenDirection:(BKSlideDirection)direction {
    CGPoint offscreenCenter = BKSlideOffscreenCenterPoint([UIScreen mainScreen].bounds, 
                                                          self.frame, 
                                                          direction);
	[self transitionMoveTo:offscreenCenter];
}
- (void) transitionMoveTo:(CGPoint)newCenter {
	CGPoint offset = CGPointMake(newCenter.x - self.center.x, 
								 newCenter.y - self.center.y);
    
	CGAffineTransform move = CGAffineTransformMakeTranslation(offset.x, offset.y);
	self.transitionTransform = CGAffineTransformConcat(self.transitionTransform, move);

	self.transform = CGAffineTransformConcat(self.transform, move);	
}

- (void) transitionMoveBy:(CGPoint)offset {
	// Create the move transform
	CGAffineTransform move = CGAffineTransformMakeTranslation(offset.x, offset.y);

	// Apply the move transform to the transitionTransform varible so it can be un-done
	self.transitionTransform = CGAffineTransformConcat(self.transitionTransform, move);

	// Apply the move transform to the transform variable so it occurs
	self.transform = CGAffineTransformConcat(self.transform, move);
}
- (void) transitionSizeTo:(CGSize)toSize {
	[self transitionSizeTo:toSize from:self.frame.size];
}

- (void) transitionSizeTo:(CGSize)toSize from:(CGSize)fromSize {
	CGFloat sx = fromSize.width  / toSize.width;
	CGFloat sy = fromSize.height / toSize.height;
	CGAffineTransform scale = CGAffineTransformMakeScale(1/sx, 1/sy);

	// Apply the move transform to the transitionTransform varible so it can be un-done
	self.transitionTransform = CGAffineTransformConcat(self.transitionTransform, scale);

	// Apply the move transform to the transform variable so it occurs
	self.transform = CGAffineTransformConcat(self.transform, scale);
}

- (void) transitionTo:(CGRect)newLocation {
	// Create the scale
	CGSize toSize = newLocation.size;
	CGSize fromSize = self.frame.size;
	CGFloat sx = toSize.width  / fromSize.width;
	CGFloat sy = toSize.height / fromSize.height;
	CGAffineTransform scale = CGAffineTransformMakeScale(sx, sy);
	// Create the move
	CGPoint newCenter = CGPointCenterOfRect(newLocation);

	CGPoint offset = CGPointMake(newCenter.x - self.center.x, 
								 newCenter.y - self.center.y);

	CGAffineTransform move = CGAffineTransformMakeTranslation(offset.x, offset.y);
	self.transitionTransform = CGAffineTransformConcat(self.transitionTransform, CGAffineTransformConcat(scale, move));
	self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformConcat(scale, move));	
}

- (void) removeTransition {
	if (!CGAffineTransformIsIdentity(self.transitionTransform)) {
		self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformInvert(self.transitionTransform));
		self.transitionTransform = CGAffineTransformIdentity;
	}
}
@end
