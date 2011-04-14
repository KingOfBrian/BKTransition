//
//  CartoonViewController.m
//  BKTransitionDemo
//
//  Created by Brian King on 4/14/11.
//  Copyright 2011 King Software Design. All rights reserved.
//

#import "CartoonViewController.h"


@implementation CartoonViewController

- (void) animateTransitionEnterFrom:(BKViewController*)fromViewController {
    CGRect originalPosition = _imageView.frame;
    _imageView.frame = [fromViewController locationForTransitionImageInView:self.view];
    [UIView animateWithDuration:.5 animations:^(void) {
        _imageView.frame = originalPosition;
    } completion:^(BOOL finished) {
        [self.navigationController  animationComplete];

    }];
}

- (void) animateTransitionExitTo:(BKViewController*)fromViewController {
    CGRect originalPosition = _imageView.frame;
    [UIView animateWithDuration:.5 animations:^(void) {
        _imageView.frame = [fromViewController locationForTransitionImageInView:self.view];
    } completion:^(BOOL finished) {
        _imageView.frame = originalPosition;
        [self.navigationController  animationComplete];
    }];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_imageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void) setCartoonImage:(UIImage*)image {
    _imageView.image = image;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = 
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                   target:self
                                                   action:@selector(popController)] autorelease];
}

- (void)viewDidUnload
{
    [_imageView release];
    _imageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
