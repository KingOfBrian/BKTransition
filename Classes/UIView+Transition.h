//
//  UIView+Home.h
//  lifelapse
//
//  Created by Brian King on 12/29/10.
//  Copyright 2010 King Software Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UISwipeGestureRecognizer.h>
#import "NSObject+Proxy.h"

#define BK_EXTERN extern __attribute__((visibility ("default")))

typedef enum {
    BKSlideDirectionRight = 1 << 0,
    BKSlideDirectionLeft  = 1 << 1,
    BKSlideDirectionUp    = 1 << 2,
    BKSlideDirectionDown  = 1 << 3,
    
    BKSlideDirectionVertical = BKSlideDirectionUp | BKSlideDirectionDown,
    BKSlideDirectionHorizontal = BKSlideDirectionLeft | BKSlideDirectionRight
} BKSlideDirection;

BK_EXTERN BKSlideDirection BKSlideOrientation(BKSlideDirection direction);
BK_EXTERN BKSlideDirection BKSlideOtherDirection(BKSlideDirection direction);
BK_EXTERN BOOL BKSlideIsDirection(BKSlideDirection check, BKSlideDirection direction);
BK_EXTERN CGPoint BKSlideOffscreenCenterPoint(CGRect enclosingFrame, CGRect frame, BKSlideDirection direction);
BK_EXTERN CGPoint CGPointCenterOfRect(CGRect frame);

@interface UIView(Transition)

- (void) transitionMoveDirection:(BKSlideDirection)direction by:(CGFloat)pixels;
- (void) transitionMoveOffscreenDirection:(BKSlideDirection)direction;
- (void) transitionMoveBy:(CGPoint)offset;
- (void) transitionMoveTo:(CGPoint)newPoint;
- (void) transitionSizeTo:(CGSize)size;
- (void) transitionSizeTo:(CGSize)toSize from:(CGSize)fromSize;
- (void) transitionTo:(CGRect)newLocation;
- (void) removeTransition;

@property (assign, nonatomic) CGAffineTransform transitionTransform;

@end

