//
//  RootViewController.m
//  BKTransitionDemo
//
//  Created by Brian King on 4/14/11.
//  Copyright 2011 King Software Design. All rights reserved.
//

#import "RootViewController.h"
#import "UINavigationController+CustomAnimation.h"

@implementation RootViewController

- (void) animateTransitionEnterFrom:(BKViewController*)fromViewController {
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
    
    // Create an ImageView in the navigation controller view
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    CGRect originalFrame = cell.imageView.frame;
    
    _transtitioningImage.image = cell.imageView.image;
    _transtitioningImage.frame = [self.navigationController.view convertRect:originalFrame 
                                                                    fromView:[cell.imageView superview]];
    
    
    [self.navigationController.view addSubview:_transtitioningImage];
    
    
    self.tableView.alpha = 0.0f;
    [UIView animateWithDuration:.5 animations:^(void) {

        self.tableView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        [_transtitioningImage removeFromSuperview];
        
        [self.navigationController  animationComplete];
    }];

}

- (void) animateTransitionExitTo:(BKViewController*)toViewController {
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
    
    // Create an ImageView in the navigation controller view
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    CGRect originalFrame = cell.imageView.frame;

    _transtitioningImage.image = cell.imageView.image;
    _transtitioningImage.frame = [self.navigationController.view convertRect:originalFrame 
                                                                    fromView:[cell.imageView superview]];


    [self.navigationController.view addSubview:_transtitioningImage];
    
    
    [UIView animateWithDuration:.5 animations:^(void) {
        self.tableView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        self.tableView.alpha = 1.0f;
        [_transtitioningImage removeFromSuperview];
        
        [self.navigationController  animationComplete];
    }];
}

- (CGRect) locationForTransitionImageInView:(UIView*)inView {
    return [inView convertRect:_transtitioningImage.frame 
                      fromView:[_transtitioningImage superview]];
}



- (UITableView*) tableView {
    return (UITableView*) self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 132;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                                           target:self
                                                                                            action:@selector(nextTransitionType)] autorelease];
    _transtitioningImage = [[UIImageView alloc] initWithImage:nil];

    self.title = @"Custom";
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Face%d", indexPath.row + 1]];
    cell.textLabel.text  = [NSString stringWithFormat:@"Cartoon %d", indexPath.row + 1];

    // Configure the cell.
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    _cartoonController.view;
    [_cartoonController setCartoonImage:[UIImage imageNamed:[NSString stringWithFormat:@"Face%d", indexPath.row + 1]]];

    [self pushController:_cartoonController];
}


- (void)viewDidUnload
{
    [_transtitioningImage release];
    _transtitioningImage = nil;
    [_cartoonController release];
    _cartoonController = nil;
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [_transtitioningImage release];
    [_cartoonController release];
    [super dealloc];
}

@end
