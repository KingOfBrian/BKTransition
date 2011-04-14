//
//  CartoonViewController.h
//  BKTransitionDemo
//
//  Created by Brian King on 4/14/11.
//  Copyright 2011 King Software Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKViewController.h"


@interface CartoonViewController : BKViewController {

    IBOutlet UIImageView *_imageView;
}
- (void) setCartoonImage:(UIImage*)image;

@end
